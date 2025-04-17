plugins {
    id("com.android.application") version "8.2.1" apply false
   // id("com.android.library") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "2.1.10" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

buildscript{
//    ext.kotlin_version = "1.8.22"
    dependencies {
        classpath ("com.android.tools.build:gradle:8.1.2")  // Use the latest version
        classpath ("com.google.gms:google-services:4.4.2") // Ensure latest Firebase version
    }

    repositories{
        google()

    }

//  dependencies{
//      classpath ("com.google.gms.google-services") version "4.4.2" apply false
//  }
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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


subprojects.forEach { project ->
    logger.quiet("Updating settings for project foodontheway")
    project.tasks.withType<JavaCompile> {
        options.compilerArgs.addAll(listOf("-Xlint:deprecation"))
    }
}
//buildscript {
//    ext.kotlin_version = "1.5.31" //use late
//}
//

