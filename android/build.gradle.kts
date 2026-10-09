allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Single source of truth for Android API levels and NDK. Applied to :app
// (via rootProject.extra) and forced onto every Flutter plugin module below,
// so the whole build uses one compileSdk, one minSdk and one NDK.
val stampitCompileSdk by extra(36)
val stampitMinSdk by extra(24)
val stampitNdkVersion by extra("27.0.12077973")

// Must be registered before evaluationDependsOn(":app") below, so each
// plugin's afterEvaluate runs ahead of AGP finalizing its DSL.
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
            compileSdk = stampitCompileSdk
            ndkVersion = stampitNdkVersion
            defaultConfig.minSdk = stampitMinSdk
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
