// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()          // ✅ Required for Firebase
        mavenCentral()
    }
    dependencies {
        // ✅ Add the Google Services plugin for Firebase
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // ✅ Ensure all subprojects apply app evaluation
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
