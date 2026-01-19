class BuildConfig {
  static const int versionCode = int.fromEnvironment(
    "im_test.versionCode",
    defaultValue: 1,
  );

  static const String versionName = String.fromEnvironment(
    'im_test.versionName',
    defaultValue: 'SNAPSHOT',
  );

  static const int buildTime = int.fromEnvironment('im.buildTime');

  static const String commitHash = String.fromEnvironment(
    'im_test.commitHash',
    defaultValue: 'N/A',
  );
}
