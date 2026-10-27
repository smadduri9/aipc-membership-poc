import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/utils/aadhaar.dart';
import 'package:aipc_poc/utils/social_link.dart';

void main() {
  group('Aadhaar', () {
    test('accepts a number with a valid Verhoeff checksum', () {
      expect(isValidAadhaar('2345 6789 0124'), isTrue);
    });

    test('rejects a wrong checksum, wrong length and a leading 0 or 1', () {
      expect(isValidAadhaar('2345 6789 0125'), isFalse);
      expect(isValidAadhaar('2345 6789 012'), isFalse);
      expect(isValidAadhaar('0345 6789 0124'), isFalse);
    });

    test('masks everything except the last four digits', () {
      expect(maskAadhaar('2345 6789 0124'), 'XXXX XXXX 0124');
    });
  });

  group('social links', () {
    test('accepts full profile links', () {
      expect(
        validateSocialLink(
          SocialPlatform.instagram,
          'https://www.instagram.com/yourname',
        ),
        isNull,
      );
      expect(
        validateSocialLink(
          SocialPlatform.linkedin,
          'https://www.linkedin.com/in/yourname',
        ),
        isNull,
      );
      expect(
        validateSocialLink(SocialPlatform.facebook, 'facebook.com/yourname'),
        isNull,
      );
    });

    test('rejects handles and empty paths', () {
      expect(
        validateSocialLink(SocialPlatform.instagram, '@yourname'),
        isNotNull,
      );
      expect(
        validateSocialLink(SocialPlatform.instagram, 'yourname'),
        isNotNull,
      );
      expect(
        validateSocialLink(
          SocialPlatform.instagram,
          'https://www.instagram.com/',
        ),
        isNotNull,
      );
    });

    test('rejects a link to the wrong site', () {
      expect(
        validateSocialLink(
          SocialPlatform.linkedin,
          'https://www.instagram.com/yourname',
        ),
        isNotNull,
      );
      expect(
        validateSocialLink(
          SocialPlatform.linkedin,
          'https://www.linkedin.com/yourname',
        ),
        isNotNull,
      );
    });
  });
}
