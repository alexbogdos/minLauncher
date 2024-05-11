
import 'package:flutter_test/flutter_test.dart';
import 'package:min_launcher/src/search/package_search_service.dart';


void main() {
  group('Package Loading', () {
    test('Should load device apps and create an empty database', () async {
      // Create PackageSearchService and initialize it
      PackageSearchService service = PackageSearchService();
      await service.initService();

    });
  });
}
