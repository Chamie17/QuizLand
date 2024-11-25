import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizland_app/screens/login_screen.dart';
import 'package:quizland_app/screens/register_screen.dart';
import 'package:quizland_app/screens/welcome_screen.dart';

import '../screens/home_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'welcome',
      builder: (BuildContext context, GoRouterState state) {
        Future.delayed(const Duration(seconds: 2));
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomeScreen();
            } else {
              return const WelcomeScreen();
            }
          },
        );
      },
      routes: [
        GoRoute(
            path: '/login',
          name:'login',
          builder: (context, state) {
            Future.delayed(const Duration(seconds: 2));
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const HomeScreen();
                } else {
                  return const LoginScreen();
                }
              },
            );
          },


        ),
        GoRoute(
          path: '/register',
          name:'register',
          builder: (context, state) {
            Future.delayed(const Duration(seconds: 2));
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const HomeScreen();
                } else {
                  return const RegisterScreen();
                }
              },
            );
          },


        )
      ]
    ),


  ],
);