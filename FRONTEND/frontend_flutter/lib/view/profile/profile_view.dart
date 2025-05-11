import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/setting_row.dart';
import '../../common_widget/title_subtitle_cell.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import '../login/login_view.dart';
import '../profile/contact_us.dart';
import '../profile/privacy_policy.dart';
import 'user_details_view.dart';

class ProfileView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfileView({Key? key, this.userData}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool positive = false;

  List accountArr = [
    {"image": "assets/img/p_personal.png", "name": "Personal Data", "tag": "1"},
    {"image": "assets/img/p_achi.png", "name": "Achievement", "tag": "2"},
    {
      "image": "assets/img/p_activity.png",
      "name": "Activity History",
      "tag": "3"
    }
  ];

  List otherArr = [
    {"image": "assets/img/p_contact.png", "name": "About Us", "tag": "5"},
    {"image": "assets/img/p_privacy.png", "name": "Privacy Policy", "tag": "6"},
  ];

  @override
  Widget build(BuildContext context) {
    final firstName = widget.userData?['UserFirstName'] ?? 'Guest';
    final lastname = widget.userData?['UserLastName'] ?? ' ';
    final email = widget.userData?['UserEmail'] ?? ' email@gmail.com';
    final gender = widget.userData?['UserGender'] ?? 'Male';
    final weight = widget.userData?['UserWeight'] ?? '80';
    final heightInCm = widget.userData?['UserHeight'] ?? '170';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
              color: TColor.primaryColor1,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginView()),
              );
            },
          ),
        ],
      ),
      backgroundColor: TColor.lightGray,
      body: Container(
        decoration: BoxDecoration(
          color: TColor.lightGray,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: TColor.primaryColor2.withOpacity(0.15),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: gender == "female"
                            ? Image.asset(
                                "assets/img/u2.png",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/img/u1.png",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$firstName $lastname",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              email,
                              style: TextStyle(
                                color: TColor.secondaryColor1,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        height: 32,
                        child: RoundButton(
                          title: "Edit",
                          type: RoundButtonType.bgGradient,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Quick Info Row
                Row(
                  children: [
                    Expanded(
                      child: TitleSubtitleCell(
                        title: "$heightInCm cm",
                        subtitle: "Height",
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TitleSubtitleCell(
                        title: "$weight kg",
                        subtitle: "Weight",
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TitleSubtitleCell(
                        title: "$gender",
                        subtitle: "Gender",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Account Section
                _buildSectionCard(
                  title: "Account",
                  children: List.generate(accountArr.length, (index) {
                    var iObj = accountArr[index] as Map? ?? {};
                    return SettingRow(
                      icon: iObj["image"].toString(),
                      title: iObj["name"].toString(),
                      onPressed: () {
                        if (iObj["name"] == "Personal Data") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailsView(
                                  userData: widget.userData ?? {}),
                            ),
                          );
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(height: 18),
                // Notification Section
                _buildSectionCard(
                  title: "Notification",
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/img/p_notification.png",
                            height: 18, width: 18, fit: BoxFit.contain),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            "Pop-up Notification",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        CustomAnimatedToggleSwitch<bool>(
                          current: positive,
                          values: [false, true],
                          dif: 0.0,
                          indicatorSize: Size.square(30.0),
                          animationDuration: const Duration(milliseconds: 200),
                          animationCurve: Curves.linear,
                          onChanged: (b) => setState(() => positive = b),
                          iconBuilder: (context, local, global) {
                            return const SizedBox();
                          },
                          defaultCursor: SystemMouseCursors.click,
                          onTap: () => setState(() => positive = !positive),
                          iconsTappable: false,
                          wrapperBuilder: (context, global, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                    left: 10.0,
                                    right: 10.0,
                                    height: 30.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: TColor.secondaryColor1,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50.0)),
                                      ),
                                    )),
                                child,
                              ],
                            );
                          },
                          foregroundIndicatorBuilder: (context, global) {
                            return SizedBox.fromSize(
                              size: const Size(10, 10),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: TColor.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0)),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black38,
                                        spreadRadius: 0.05,
                                        blurRadius: 1.1,
                                        offset: Offset(0.0, 0.8))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Other Section
                _buildSectionCard(
                  title: "Other",
                  children: List.generate(otherArr.length, (index) {
                    var iObj = otherArr[index] as Map? ?? {};
                    return SettingRow(
                      icon: iObj["image"].toString(),
                      title: iObj["name"].toString(),
                      onPressed: () {
                        if (iObj["name"] == "About Us") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactUs()),
                          );
                        } else if (iObj["name"] == "Privacy Policy") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicy()),
                          );
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryColor2.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColor.primaryColor1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
