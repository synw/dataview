import 'package:err/err.dart';

var logger = ErrRouter(
    errorRoute: [ErrRoute.screen, ErrRoute.console],
    infoRoute: [ErrRoute.screen, ErrRoute.console]);
