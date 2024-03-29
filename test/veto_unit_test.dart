import 'package:gherkin_unit_test/unit_test.dart';

import 'unit_features/has_error_feature.dart';
import 'unit_features/is_busy_feature.dart';
import 'unit_features/is_initialised_feature.dart';

void main() {
  VetoUnitTest().test();
}

class VetoUnitTest extends UnitTest {
  VetoUnitTest()
      : super(
          description: 'Tests all features of the veto package',
          features: [
            HasErrorFeature(),
            IsBusyFeature(),
            IsInitialisedFeature(),
          ],
        );
}
