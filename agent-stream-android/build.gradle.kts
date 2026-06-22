import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("maven-publish")
}

val publishedVersion = providers.gradleProperty("versionName")
    .orElse(providers.environmentVariable("VERSION_NAME"))
    .orElse("0.1.0-SNAPSHOT")

val sourceSdkRef = providers.gradleProperty("agentStreamSdkRef")
    .orElse(providers.environmentVariable("AGENT_STREAM_SDK_REF"))
    .orElse("main")

group = "network.unseal"
version = publishedVersion.get()

android {
    namespace = "io.element.android.libraries.agentstream"
    compileSdk = 36

    defaultConfig {
        minSdk = 26
        consumerProguardFiles("consumer-rules.pro")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = false
    }

    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")
}

publishing {
    publications {
        register<MavenPublication>("agentStreamAndroid") {
            groupId = "network.unseal"
            artifactId = "agent-stream-android"
            version = publishedVersion.get()

            afterEvaluate {
                from(components["release"])
            }

            pom {
                name.set("agent-stream-android")
                description.set("Android AAR distribution for the Unseal Agent Stream SDK. Built from agent-stream-sdk ref ${sourceSdkRef.get()}.")
                url.set("https://github.com/unseal-network/agent-stream-components-kotlin")
                licenses {
                    license {
                        name.set("LicenseRef-Element-Commercial")
                        url.set("https://github.com/unseal-network/agent-stream-components-kotlin")
                    }
                }
                scm {
                    connection.set("scm:git:https://github.com/unseal-network/agent-stream-components-kotlin.git")
                    developerConnection.set("scm:git:ssh://git@github.com/unseal-network/agent-stream-components-kotlin.git")
                    url.set("https://github.com/unseal-network/agent-stream-components-kotlin")
                }
                developers {
                    developer {
                        id.set("unseal-network")
                        name.set("Unseal Network")
                    }
                }
            }
        }
    }

    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/unseal-network/agent-stream-components-kotlin")
            credentials {
                username = providers.environmentVariable("GITHUB_ACTOR").orElse("jelf-work").get()
                password = providers.environmentVariable("GITHUB_TOKEN")
                    .orElse(providers.environmentVariable("GH_TOKEN"))
                    .orElse(providers.environmentVariable("PACKAGES_TOKEN"))
                    .orElse(providers.environmentVariable("PRIVATE_REGISTRY_TOKEN"))
                    .getOrElse("")
            }
        }
    }
}
