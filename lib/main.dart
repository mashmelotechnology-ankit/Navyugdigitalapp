import 'package:academy_lms_app/constants.dart';
import 'package:academy_lms_app/screens/course_details.dart';
import 'package:academy_lms_app/screens/login.dart';
import 'package:academy_lms_app/screens/splash.dart';
import 'package:academy_lms_app/screens/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';
import 'providers/categories.dart';
import 'providers/certificate_provider.dart';
import 'providers/courses.dart';
import 'providers/live_classes_provider.dart';
import 'providers/misc_provider.dart';
import 'providers/my_courses.dart';
import 'providers/poster_templates_provider.dart';
import 'providers/saved_posters_provider.dart';
import 'providers/slider_provider.dart';
import 'providers/subscription_plans.dart';
import 'providers/subscription_provider.dart';
import 'providers/template_editor_provider.dart';
import 'providers/topics_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/webinars_provider.dart';
import 'screens/account_remove_screen.dart';
import 'screens/category_details.dart';
import 'screens/certificate_screen.dart';
import 'screens/course_detail.dart';
import 'screens/courses_screen.dart';
import 'screens/refer_and_earn.dart';
import 'screens/sub_category.dart';
import 'screens/subscription_plans.dart';
import 'screens/subscription_history.dart';
import 'screens/wallet_screen.dart';
import 'screens/wallet_withdrawal_screen.dart';
import 'screens/wallet_withdrawal_history_screen.dart';

void main() {
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint(
        '${rec.loggerName}>${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Categories(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Languages(),
        ),
        ChangeNotifierProxyProvider<Auth, Courses>(
          create: (ctx) => Courses(
            [],
            [],
          ),
          update: (ctx, auth, prevoiusCourses) => Courses(
            prevoiusCourses == null ? [] : prevoiusCourses.items,
            prevoiusCourses == null ? [] : prevoiusCourses.topItems,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, MyCourses>(
          create: (ctx) => MyCourses([], []),
          update: (ctx, auth, previousMyCourses) => MyCourses(
            previousMyCourses == null ? [] : previousMyCourses.items,
            previousMyCourses == null ? [] : previousMyCourses.sectionItems,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SubscriptionPlans(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => WalletProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SliderProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TopicsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => WebinarsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LiveClassesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CertificateProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SubscriptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PosterTemplatesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TemplateEditorProvider(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Navyug Digital',
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: const ColorScheme.light(primary: kWhiteColor),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          routes: {
            '/home': (ctx) => const TabsScreen(
                  pageIndex: 0,
                ),
            '/login': (ctx) => const LoginScreen(),
            CoursesScreen.routeName: (ctx) => const CoursesScreen(),
            CategoryDetailsScreen.routeName: (ctx) =>
                const CategoryDetailsScreen(),
            CourseDetailScreen.routeName: (ctx) => const CourseDetailScreen(),
            CourseDetailScreen1.routeName: (ctx) => const CourseDetailScreen1(),
            SubCategoryScreen.routeName: (ctx) => const SubCategoryScreen(),
            AccountRemoveScreen.routeName: (ctx) => const AccountRemoveScreen(),
            CertificateScreen.routeName: (ctx) => const CertificateScreen(),
            SubscriptionPlansScreen.routeName: (ctx) =>
                const SubscriptionPlansScreen(),
            SubscriptionHistoryScreen.routeName: (ctx) =>
                const SubscriptionHistoryScreen(),
            ReferAndEarnScreen.routeName: (ctx) => const ReferAndEarnScreen(),
            WalletScreen.routeName: (ctx) => const WalletScreen(),
            WalletWithdrawalScreen.routeName: (ctx) =>
                const WalletWithdrawalScreen(),
            WalletWithdrawalHistoryScreen.routeName: (ctx) =>
                const WalletWithdrawalHistoryScreen(),
          },
        ),
      ),
    );
  }
}
