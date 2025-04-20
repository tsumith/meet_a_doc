import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

Future<Uri> generateDynamicLink(String doctorCode) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://meetadoct.page.link', // Your Firebase domain
    link: Uri.parse(
        'https://meetadoc.com/welcome?ref=DR${doctorCode}'), // Deep link with referral
    androidParameters: AndroidParameters(
      packageName: 'com.example.meet_a_doc',
      minimumVersion: 0,
    ),
    iosParameters: IOSParameters(
      bundleId: 'com.example.meet_a_doc',
      minimumVersion: '0',
    ),
  );

  final ShortDynamicLink shortLink =
      await FirebaseDynamicLinks.instance.buildShortLink(parameters);

  return shortLink.shortUrl;
}
