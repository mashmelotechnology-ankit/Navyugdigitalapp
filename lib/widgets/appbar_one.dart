import 'package:academy_lms_app/screens/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class AppBarOne extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final dynamic title;
  final dynamic logo;

  const AppBarOne({super.key, this.title, this.logo})
      : preferredSize = const Size.fromHeight(70.0);

  @override
  State<AppBarOne> createState() => _AppBarOneState();
}

class _AppBarOneState extends State<AppBarOne> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kBackGroundColor,
      toolbarHeight: 70,
      leadingWidth: 80,
      centerTitle: true,
      title: widget.title != null
          ? Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            )
          : (widget.logo != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 32,
                      width: 32,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Navyug ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(
                            text: 'Beauty Studio',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: kDefaultColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Text('')),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabsScreen(
                    pageIndex: 2,
                  ),
                ));
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 18, bottom: 18),
            child: Stack(
              fit: StackFit.loose,
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  'assets/icons/shopping-cart 1.svg',
                ),
                // const Center(
                //   child: Padding(
                //     padding: EdgeInsets.only(left: 14.0, bottom: 12),
                //     child: Text(
                //       '0',
                //       style: TextStyle(
                //         color: kWhiteColor,
                //         fontSize: 12,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
