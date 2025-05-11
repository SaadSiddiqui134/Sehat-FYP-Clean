import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/tab_button.dart';
import 'package:fitness/view/home/blank_view.dart';
import 'package:fitness/view/main_tab/select_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../home/home_view.dart';
import '../photo_progress/photo_progress_view.dart';
import '../profile/profile_view.dart';
import '../workout_tracker/workout_tracker_view.dart';

class MainTabView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MainTabView({Key? key, required this.userData}) : super(key: key);

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket();
  late Widget currentTab;

  @override
  void initState() {
    super.initState();
    // Initialize `currentTab` with `HomeView` and pass `userData`
    currentTab = HomeView(
      userData: widget.userData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: SizedBox(
      //   width: 70,
      //   height: 70,
      //   child: InkWell(
      //     onTap: () {},
      //     child: Container(
      //       width: 65,
      //       height: 65,
      //       decoration: BoxDecoration(
      //         gradient: LinearGradient(
      //           colors: TColor.primaryG,
      //         ),
      //         borderRadius: BorderRadius.circular(35),
      //         boxShadow: const [
      //           BoxShadow(
      //             color: Colors.black12,
      //             blurRadius: 2,
      //           )
      //         ],
      //       ),
      //       child: Icon(
      //         Icons.search,
      //         color: TColor.white,
      //         size: 35,
      //       ),
      //     ),
      //   ),
      // ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: TColor.primaryColor2.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                icon: "assets/img/home_tab.png",
                selectIcon: "assets/img/icons8-home-48.png",
                isActive: selectTab == 0,
                onTap: () {
                  selectTab = 0;
                  currentTab = HomeView(
                    userData: widget.userData,
                  );
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              // TabButton(
              //   icon: "assets/img/activity_tab.png",
              //   selectIcon: "assets/img/activity_tab_select.png",
              //   isActive: selectTab == 1,
              //   onTap: () {
              //     selectTab = 1;
              //     currentTab = const SelectView();
              //     if (mounted) {
              //       setState(() {});
              //     }
              //   },
              // ),
              // const SizedBox(
              //   width: 40,
              // ),
              TabButton(
                icon: "assets/img/camera_tab.png",
                selectIcon: "assets/img/icons8-camera-64.png",
                isActive: selectTab == 2,
                onTap: () {
                  selectTab = 2;
                  // currentTab = const PhotoProgressView();
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              TabButton(
                icon: "assets/img/profile_tab.png",
                selectIcon: "assets/img/icons8-person-30.png",
                isActive: selectTab == 3,
                onTap: () {
                  selectTab = 3;
                  currentTab = ProfileView(userData: widget.userData);
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
