# CI/CD Notes

## Fastlane

Fastlane is an automation tool for iOS and Android build and deployment. See usage instructions in /android/fastlane/README.md.

### Install and configure

Following [the fastlane docs](https://docs.fastlane.tools/getting-started/android/setup/) and [the flutter docs](https://flutter.dev/docs/deployment/cd).

First create project_root/Gemfile then run:

```sh
bundle update
cd android
bundle exec fastlane init
```

This will prompt you to create a **developer console service account** for Supply (upload_to_play_store action). Following [these instructions](https://docs.fastlane.tools/actions/supply/) I did the following:

1. I went to Google Play Console / Settings / API Access and clicked the button to enable.
1. This took me through to Google Cloud Console / IAM & Admin / Service Accounts. 
1. I created a new service account and downloaded the key in JSON format.

### Test installation

Now I tested Fastlane using `bundle exec fastlane test`. 

* I hit an error: `Exit status of command '/Users/david/dev/sermon_publisher_app/android/gradlew test -p .' was 1 instead of 0.`
* This was because of my Java version. It did not like OpenJDK 14. I downgraded to OpenJDK 11 and it worked.
* Next I hit a snag because my package name was not set correctly in the AndroidManifest.xml. Note, there are three manifest files to update.

I tested Supply using `fastlane supply init`.

* I hit this error: `[!] Google Api Error: notFound: Package not found: xyz.davidmaccallum.sermon_publish. - Package not found: xyz.davidmaccallum.sermon_publish.`
* Then I manually created a release using the Play Console.
* Then I hit this error: `[!] No authentication parameters were specified. These must be provided in order to authenticate with Google`
* I was running `fastlane supply init` in project root. Must run it in android dir.