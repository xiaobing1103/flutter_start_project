buildscript {
    repositories {
        google()
        mavenCentral() // 使用 Maven Central 仓库
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0") // 使用双引号和括号
    }
}

allprojects {
    repositories {
        google() // 使用 Google 的 Maven 仓库
        mavenCentral() // 使用 Maven Central 仓库
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