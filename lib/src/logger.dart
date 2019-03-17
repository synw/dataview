import 'package:err/err.dart';

ErrRouter log;

void initLogger(ErrRouter errRouter) {
  if (errRouter == null) {
    log = ErrRouter(
        errorRoute: [ErrRoute.screen, ErrRoute.console],
        infoRoute: [ErrRoute.screen, ErrRoute.console],
        debugRoute: [ErrRoute.blackHole]);
  } else {
    log = errRouter;
  }
}
