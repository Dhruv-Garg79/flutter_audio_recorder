// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import '../screens/recorder/recorder_view.dart';
import '../screens/splash/splash_view.dart';

class Routes {
  static const String recorderView = '/recorder-view';
  static const String splashView = '/';
  static const all = <String>{
    recorderView,
    splashView,
  };
}

class StackedRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.recorderView, page: RecorderView),
    RouteDef(Routes.splashView, page: SplashView),
  ];
  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, StackedRouteFactory>{
    RecorderView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const RecorderView(),
        settings: data,
      );
    },
    SplashView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const SplashView(),
        settings: data,
      );
    },
  };
}
