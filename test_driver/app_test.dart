import 'package:flutter_driver/flutter_driver.dart';
import 'package:sermon_publish/const.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Counter App',
    () {
      final signInButton = find.byValueKey(WelcomeScreenKeys.signInButton);
      final titleText = find.byValueKey(SermonListScreenKeys.titleText);

      FlutterDriver driver;

      setUpAll(() async {
        driver = await FlutterDriver.connect();
      });

      tearDownAll(() async {
        if (driver != null) {
          driver.close();
        }
      });

      test('sign in', () async {
        await driver.tap(signInButton);
        expect(await driver.getText(titleText), "My Sermons");
      });
    },
    timeout: Timeout.none,
  );
}
