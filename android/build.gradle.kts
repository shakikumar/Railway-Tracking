allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    project.plugins.withId("com.android.library") {
        val androidExt = project.extensions.findByName("android")
        if (androidExt is org.gradle.api.plugins.ExtensionAware) {
            androidExt.extensions.add(
                "flutter",
                mapOf(
                    "compileSdkVersion" to 36,
                    "minSdkVersion" to 23,
                    "targetSdkVersion" to 36,
                    "ndkVersion" to "27.0.12077973"
                )
            )
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
