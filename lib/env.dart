import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'FIRE_API', obfuscate: true)
  static final fireApiKey = _Env.fireApiKey;
}
