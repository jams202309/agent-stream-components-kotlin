# Agent Stream Components Kotlin

This repository publishes the Android dependency for the shared Unseal Agent Stream SDK.

It exists so Android clients can install the stream SDK through Gradle instead of manually compiling Rust and copying `.so` files into an app repository.

## Published Artifact

Gradle coordinate:

```kotlin
implementation("network.unseal:agent-stream-android:<version>")
```

Published to GitHub Packages:

```text
https://maven.pkg.github.com/unseal-network/agent-stream-components-kotlin
```

The AAR contains:

- Kotlin wrapper/API code under `io.element.android.libraries.agentstream`
- `libunseal_agent_stream.so` for:
  - `arm64-v8a`
  - `armeabi-v7a`
  - `x86`
  - `x86_64`

## Consuming From Android

Add the repository:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven {
            name = "UnsealAgentStream"
            url = uri("https://maven.pkg.github.com/unseal-network/agent-stream-components-kotlin")
            credentials {
                username = providers.environmentVariable("GITHUB_ACTOR").orElse("<github-user>").get()
                password = providers.environmentVariable("GITHUB_TOKEN")
                    .orElse(providers.environmentVariable("GH_TOKEN"))
                    .orElse(providers.environmentVariable("PRIVATE_REGISTRY_TOKEN"))
                    .get()
            }
            content {
                includeGroup("network.unseal")
            }
        }
    }
}
```

Then depend on the version you released:

```kotlin
implementation("network.unseal:agent-stream-android:0.1.0-rc.3")
```

## Build Locally

Prerequisites:

- JDK 17+
- Android SDK and NDK
- Rust toolchain
- Android Rust targets
- `cargo-ndk`

Install Rust tooling:

```bash
cargo install cargo-ndk
```

Build from the default SDK repo and `main`:

```bash
./scripts/build-android-aar.sh
```

Build from a specific SDK ref:

```bash
AGENT_STREAM_SDK_REF=v0.1.0-rc.2 ./scripts/build-android-aar.sh
```

Build from a local SDK checkout:

```bash
AGENT_STREAM_SDK_DIR=/path/to/agent-stream-sdk ./scripts/build-android-aar.sh
```

The generated AAR is:

```text
agent-stream-android/build/outputs/aar/agent-stream-android-release.aar
```

## Publish Manually

The publish script builds native libraries first, then publishes the AAR to GitHub Packages.

Required environment:

- `GITHUB_ACTOR`
- one of `GITHUB_TOKEN`, `GH_TOKEN`, `PACKAGES_TOKEN`, or `PRIVATE_REGISTRY_TOKEN`

Command:

```bash
VERSION_NAME=0.1.0-rc.3 \
AGENT_STREAM_SDK_REF=<agent-stream-sdk-commit-or-tag> \
./scripts/publish-release.sh
```

Equivalent direct Gradle task after native libs are generated:

```bash
./gradlew :agent-stream-android:publishAgentStreamAndroidPublicationToGitHubPackagesRepository \
  -PversionName=0.1.0-rc.3 \
  -PagentStreamSdkRef=<agent-stream-sdk-commit-or-tag>
```

## Release With GitHub Actions

Use the `Release Android AAR` workflow.

Inputs:

- `version`: Maven version to publish, for example `0.1.0-rc.3`
- `sdk_ref`: commit SHA, branch, or tag in `unseal-network/agent-stream-sdk`

Required repository secrets:

- `AGENT_STREAM_SDK_TOKEN`: only needed if the workflow token cannot read `agent-stream-sdk`

The built-in `GITHUB_TOKEN` is used to publish the AAR to this repository's GitHub Packages.
