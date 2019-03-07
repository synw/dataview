import 'package:err/err.dart';

ErrRouter log;

initLogger(ErrRouter errRouter) {
  log = errRouter ??
      ErrRouter(
          errorRoute: [ErrRoute.screen, ErrRoute.console],
          infoRoute: [ErrRoute.screen, ErrRoute.console],
          debugRoute: [ErrRoute.blackHole]);
}
