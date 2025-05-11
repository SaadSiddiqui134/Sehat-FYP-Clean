from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import DiabetesPredictionLog, HypertensionPredictionLog
from django.contrib.auth.models import User
import json
import numpy as np
import pickle
import os
import pandas as pd
import base64
from PIL import Image
import io
import tensorflow as tf

# Load the ML models
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, 'mlmodel')

# Load scaler and PCA
try:
    with open(os.path.join(MODEL_DIR, 'DiabetesScaler_SMOTE.pkl'), 'rb') as f:
        scaler = pickle.load(f)
    
    with open(os.path.join(MODEL_DIR, 'DiabetesPca_SMOTE.pkl'), 'rb') as f:
        pca = pickle.load(f)
        
    # You should also load your prediction model (assuming there's a model file)
    # Replace 'DiabetesModel.pkl' with your actual model filename
    with open(os.path.join(MODEL_DIR, 'Diabetes_model_SMOTE.pkl'), 'rb') as f:
        model = pickle.load(f)
    
    MODELS_LOADED = True
except Exception as e:
    print(f"Error loading ML models: {e}")
    MODELS_LOADED = False

# Load food detection model
try:
    food_model = tf.keras.models.load_model(os.path.join(MODEL_DIR, 'FOOD101_FINAL_MODEL_MOBILENETV2.h5'))
    FOOD_MODEL_LOADED = True
except Exception as e:
    print(f"Error loading food detection model: {e}")
    FOOD_MODEL_LOADED = False

# Create your views here.
@csrf_exempt
def predict_diabetes(request):
    if request.method == 'POST':
        try:
            if not MODELS_LOADED:
                return JsonResponse({"error": "ML models failed to load"}, status=500)
                
            data = json.loads(request.body)

            # Map inputs to numbers
            gender_map = {'male': 1, 'female': 0}
            yes_no_map = {'yes': 1, 'no': 0, 'yes': 1, 'no': 0}
            smoking_map = {
                'no info': 0,
                'current': 1,
                'ever': 2,
                'former': 3,
                'never': 4,
                'not current': 5
            }

            # Process input data
            try:
                gender = gender_map.get(data.get('gender', '').lower(), 0)
                smoking = smoking_map.get(data.get('smoking_history', '').lower(), 0)
                hypertension = yes_no_map.get(data.get('hypertension', '').lower(), 0)
                heart_disease = yes_no_map.get(data.get('heart_disease', '').lower(), 0)
                
                # Validate numeric inputs
                age = float(data.get('age', 0))
                if not (0 <= age <= 120):
                    return JsonResponse({"error": "Age must be between 0 and 120"}, status=400)
                
                bmi = float(data.get('bmi', 0))
                if not (10 <= bmi <= 50):
                    return JsonResponse({"error": "BMI must be between 10 and 50"}, status=400)
                
                hba1c = float(data.get('HbA1c_level', 0))
                if not (3 <= hba1c <= 15):
                    return JsonResponse({"error": "HbA1c level must be between 3 and 15"}, status=400)
                
                glucose = float(data.get('blood_glucose_level', 0))
                if not (50 <= glucose <= 500):
                    return JsonResponse({"error": "Blood glucose level must be between 50 and 500"}, status=400)
                
                diabetes = yes_no_map.get(data.get('diabetes', '').lower(), 0)
            except ValueError as e:
                return JsonResponse({"error": f"Invalid numeric value: {str(e)}"}, status=400)

            # Create feature array
            features = np.array([[
                gender, age, hypertension, heart_disease, 
                smoking, bmi, hba1c, glucose
            ]])

            # Apply preprocessing and make prediction
            try:
                columns = ['gender', 'age', 'hypertension', 'heart_disease', 
                           'smoking_history', 'bmi', 'HbA1c_level', 'blood_glucose_level']
                features_df = pd.DataFrame(features, columns=columns)
                features_scaled = scaler.transform(features_df)
                features_pca = pca.transform(features_scaled)
                
                # Get prediction probabilities
                if hasattr(model, 'predict_proba'):
                    probabilities = model.predict_proba(features_pca)[0]
                    print("Prediction probabilities:", probabilities)
                
                prediction = int(model.predict(features_pca)[0])

                # Add debug logging
                print("Input features:", features.tolist())
                print("Scaled features:", features_scaled.tolist())
                print("PCA transformed features:", features_pca.tolist())
                print("Raw prediction:", model.predict(features_pca))
                print("Final prediction:", prediction)
            except Exception as e:
                import traceback
                print(f"Prediction error: {e}")
                print(traceback.format_exc())  # This prints the full stack trace
                return JsonResponse({"error": str(e)}, status=500)
            
            # Log prediction if user_id provided
            try:
                if 'user_id' in data and data['user_id'] and str(data['user_id']).strip():
                    user_id = data.get('user_id')
                    print(f"User ID from request: '{user_id}', type: {type(user_id)}")
                    
                    try:
                        user = User.objects.get(id=user_id)
                        print(f"Found user: {user.username}")
                        
                        # Create the log
                        log = DiabetesPredictionLog.objects.create(
                            user=user,
                            gender=data.get('gender', ''),
                            age=age,
                            hypertension=data.get('hypertension', ''),
                            heart_disease=data.get('heart_disease', ''),
                            smoking_history=data.get('smoking_history', ''),
                            bmi=bmi,
                            HbA1c_level=hba1c,
                            blood_glucose_level=glucose,
                            prediction=bool(prediction)
                        )
                        print(f"Successfully created log with ID: {log.id}")
                        
                    except User.DoesNotExist:
                        print(f"ERROR: User with ID {user_id} not found")
                    except Exception as create_error:
                        print(f"ERROR creating log: {create_error}")
                        import traceback
                        print(traceback.format_exc())
                else:
                    print(f"Invalid user_id in request. Full data: {data}")
                
            except Exception as log_error:
                print(f"ERROR in logging section: {log_error}")
                import traceback
                print(traceback.format_exc())

            # Return prediction result
            return JsonResponse({
                "prediction": prediction,
                "result": "Positive" if prediction == 1 else "Negative",
                "message": "Based on the provided information, you may have diabetes. Please consult with a healthcare professional for a proper diagnosis and treatment plan." 
                           if prediction == 1 else 
                           "Based on the provided information, you likely don't have diabetes. However, maintaining a healthy lifestyle is still important for prevention."
            })

        except Exception as e:
            return JsonResponse({"error": f"Prediction failed: {str(e)}"}, status=400)

    return JsonResponse({"message": "Only POST requests are accepted"}, status=405)



try:
    with open(os.path.join(MODEL_DIR, 'HP_LGBM_SCALER.pkl'), 'rb') as f:
        hypertension_scaler = pickle.load(f)

    with open(os.path.join(MODEL_DIR, 'HP_LGBM_PCA.pkl'), 'rb') as f:
        hypertension_pca = pickle.load(f)

    with open(os.path.join(MODEL_DIR, 'HP_LGBM_MODEL.pkl'), 'rb') as f:
        hypertension_model = pickle.load(f)
    
    HYPERTENSION_MODELS_LOADED = True
except Exception as e:
    print(f"Error loading Hypertension models: {e}")
    HYPERTENSION_MODELS_LOADED = False


@csrf_exempt
def predict_hypertension(request):
    if request.method == 'POST':
        try:
            # Log the incoming request data
            print(f"Received hypertension prediction request: {request.body}")
            
            if not HYPERTENSION_MODELS_LOADED:
                return JsonResponse({"error": "Hypertension ML models failed to load"}, status=500)
                
            data = json.loads(request.body)

            # Process input fields
            try:
                gender = data.get('gender', '').lower()
                smoking_history = data.get('smoking_history', '').lower()
                heart_disease = 1 if data.get('heart_disease', '').lower() in ['yes', 'true'] else 0
                diabetes = 1 if data.get('diabetes', '').lower() in ['yes', 'true'] else 0
                age = float(data.get('age', 0))
                bmi = float(data.get('bmi', 0))
                hba1c = float(data.get('HbA1c_level', 0))
                glucose = float(data.get('blood_glucose_level', 0))
            except ValueError as e:
                return JsonResponse({"error": f"Invalid numeric value: {str(e)}"}, status=400)

            # Create a DataFrame with the input values (similar to how the model was trained)
            input_data = {
                'gender': [gender],
                'age': [age],
                'heart_disease': [heart_disease],
                'smoking_history': [smoking_history],
                'bmi': [bmi],
                'HbA1c_level': [hba1c],
                'blood_glucose_level': [glucose],
                'diabetes': [diabetes]
            }
            
            # Create DataFrame and one-hot encode categorical columns just like in training
            features_df = pd.DataFrame(input_data)
            features_df = pd.get_dummies(features_df, columns=['gender', 'smoking_history'], drop_first=True)
            
            # Debug: Print current columns
            print("Features after encoding:", features_df.columns.tolist())
            print("Scaler expects:", hypertension_scaler.feature_names_in_.tolist())
            
            # Ensure all columns used during training are present
            missing_cols = set(hypertension_scaler.feature_names_in_) - set(features_df.columns)
            for col in missing_cols:
                features_df[col] = 0
                
            # Remove any extra columns not used in training
            extra_cols = set(features_df.columns) - set(hypertension_scaler.feature_names_in_)
            if extra_cols:
                features_df = features_df.drop(columns=extra_cols)
            
            # Ensure columns are in the same order as during training
            features_df = features_df[hypertension_scaler.feature_names_in_]
            
            # Apply preprocessing and make prediction
            try:
                features_scaled = hypertension_scaler.transform(features_df)
                features_pca = hypertension_pca.transform(features_scaled)
                prediction = int(hypertension_model.predict(features_pca)[0])
                print("Input features:", features_df)
                if hasattr(hypertension_model, 'predict_proba'):
                    print("Prediction probabilities:", hypertension_model.predict_proba(features_pca)[0])
                print("Raw prediction:", hypertension_model.predict(features_pca))
            except Exception as e:
                import traceback
                print(f"Prediction error: {e}")
                print(traceback.format_exc())
                return JsonResponse({"error": str(e)}, status=500)

            # Log prediction if user_id provided
            try:
                if 'user_id' in data and data['user_id'] and str(data['user_id']).strip():
                    user_id = data.get('user_id')
                    print(f"User ID from request: '{user_id}', type: {type(user_id)}")
                    
                    try:
                        user = User.objects.get(id=user_id)
                        print(f"Found user: {user.username}")
                        
                        # Create the log
                        log = HypertensionPredictionLog.objects.create(
                            user=user,
                            gender=gender,
                            age=age,
                            heart_disease=data.get('heart_disease', '').lower(),
                            smoking_history=smoking_history,
                            bmi=bmi,
                            HbA1c_level=hba1c,
                            blood_glucose_level=glucose,
                            diabetes=data.get('diabetes', '').lower(),
                            prediction=bool(prediction)
                        )
                        print(f"Successfully created hypertension log with ID: {log.id}")
                        
                    except User.DoesNotExist:
                        print(f"ERROR: User with ID {user_id} not found")
                    except Exception as create_error:
                        print(f"ERROR creating log: {create_error}")
                        import traceback
                        print(traceback.format_exc())
                else:
                    print(f"Invalid user_id in request. Full data: {data}")
                
            except Exception as log_error:
                print(f"ERROR in logging section: {log_error}")
                import traceback
                print(traceback.format_exc())

            # Return prediction result
            return JsonResponse({
                "prediction": prediction,
                "result": "Positive" if prediction == 1 else "Negative",
                "message": "You may have hypertension. Please consult a healthcare provider."
                           if prediction == 1 else
                           "You likely do not have hypertension. Continue regular health monitoring."
            })

        except Exception as e:
            import traceback
            print(f"Hypertension prediction error: {e}")
            print(traceback.format_exc())
            return JsonResponse({"error": str(e)}, status=500)

    return JsonResponse({"message": "Only POST requests are accepted"}, status=405)

@csrf_exempt
def detect_food(request):
    if request.method == 'POST':
        try:
            if not FOOD_MODEL_LOADED:
                return JsonResponse({"error": "Food detection model failed to load"}, status=500)

            # Get the image data from the request
            data = json.loads(request.body)
            image_data = data.get('image')
            
            if not image_data:
                return JsonResponse({"error": "No image data provided"}, status=400)

            # Decode base64 image
            try:
                # Remove the data URL prefix if present
                if ',' in image_data:
                    image_data = image_data.split(',')[1]
                
                image_bytes = base64.b64decode(image_data)
                image = Image.open(io.BytesIO(image_bytes))
                
                # Resize image to match model input size (adjust size as needed)
                image = image.resize((224, 224))
                
                # Convert to numpy array and preprocess
                img_array = np.array(image)
                img_array = img_array / 255.0  # Normalize
                img_array = np.expand_dims(img_array, axis=0)
                
                # Make prediction
                predictions = food_model.predict(img_array)
                
                # Get the top prediction
                predicted_class = np.argmax(predictions[0])
                confidence = float(predictions[0][predicted_class])
                
                # Map class index to food name (adjust according to your model's classes)
                food_classes = [
                    'apple pie', 'baby back ribs', 'baklava', 'beef carpaccio', 'beef tartare',
                    'beet salad', 'beignets', 'bibimbap', 'bread_pudding', 'breakfast_burrito',
                    'bruschetta', 'caesar salad', 'cannoli', 'caprese salad', 'carrot cake',
                    'ceviche', 'cheesecake', 'cheese plate', 'chicken curry', 'chicken quesadilla',
                    'chicken wings', 'chocolate cake', 'chocolate mousse', 'churros', 'clam chowder',
                    'club sandwich', 'crab cakes', 'creme brulee', 'croque madame', 'cup cakes',
                    'deviled eggs', 'donuts', 'dumplings', 'edamame', 'eggs benedict',
                    'escargots', 'falafel', 'filet mignon', 'fish and chips', 'foie gras',
                    'french fries', 'french onion soup', 'french toast', 'fried calamari', 'fried rice',
                    'frozen yogurt', 'garlic bread', 'gnocchi', 'greek salad', 'grilled cheese sandwich',
                    'grilled salmon', 'guacamole', 'gyoza', 'hamburger', 'hot and sour soup',
                    'hot dog', 'huevos rancheros', 'hummus', 'ice cream', 'lasagna',
                    'lobster bisque', 'lobster roll sandwich', 'macaroni and cheese', 'macarons', 'miso soup',
                    'mussels', 'nachos', 'omelette', 'onion rings', 'oysters',
                    'pad thai', 'paella', 'pancakes', 'panna cotta', 'peking duck',
                    'pho', 'pizza', 'pork chop', 'poutine', 'prime rib',
                    'pulled pork sandwich', 'ramen', 'ravioli', 'red velvet cake', 'risotto',
                    'samosa', 'sashimi', 'scallops', 'seaweed salad', 'shrimp and grits',
                    'spaghetti bolognese', 'spaghetti carbonara', 'spring rolls', 'steak', 'strawberry shortcake',
                    'sushi', 'tacos', 'takoyaki', 'tiramisu', 'tuna tartare',
                    'waffles'
                ]
                predicted_food = food_classes[predicted_class]
                
                return JsonResponse({
                    "food": predicted_food,
                    "confidence": confidence,
                    "message": f"Detected {predicted_food} with {confidence:.2%} confidence"
                })
                
            except Exception as e:
                return JsonResponse({"error": f"Error processing image: {str(e)}"}, status=400)
                
        except Exception as e:
            return JsonResponse({"error": f"Request processing failed: {str(e)}"}, status=400)
            
    return JsonResponse({"message": "Only POST requests are accepted"}, status=405)

DR_MODEL_PATH = os.path.join(BASE_DIR, 'mlmodel', 'dr_model_final_DR.keras')
try:
    dr_model = tf.keras.models.load_model(DR_MODEL_PATH)
    DR_MODEL_LOADED = True
except Exception as e:
    print("❌ Failed to load diabetic retinopathy model:", e)
    DR_MODEL_LOADED = False

# Class labels (index to severity mapping)
SEVERITY_CLASSES = ['No DR', 'Mild', 'Moderate', 'Severe', 'Proliferative DR']

@csrf_exempt
def predict_retinopathy_severity(request):
    if request.method == 'POST':
        if not DR_MODEL_LOADED:
            return JsonResponse({"error": "Model failed to load"}, status=500)

        try:
            data = json.loads(request.body)
            image_data = data.get('image')

            if not image_data:
                return JsonResponse({"error": "No image data provided"}, status=400)

            # Strip base64 prefix if present
            if ',' in image_data:
                image_data = image_data.split(',')[1]

            # Decode and load image
            image_bytes = base64.b64decode(image_data)
            image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
            image = image.resize((224, 224))

            # Convert to numpy array
            img_array = np.array(image) / 255.0  # Normalize
            img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension

            # Predict
            predictions = dr_model.predict(img_array)
            predicted_class_index = int(np.argmax(predictions[0]))
            confidence_score = float(predictions[0][predicted_class_index])
            severity = SEVERITY_CLASSES[predicted_class_index]

            return JsonResponse({
                "severity": severity,
                "confidence": confidence_score,
                "message": f"Predicted severity: {severity} ({confidence_score:.2%})"
            })

        except Exception as e:
            return JsonResponse({"error": f"Prediction error: {str(e)}"}, status=400)

    return JsonResponse({"message": "Only POST requests are accepted"}, status=405)
