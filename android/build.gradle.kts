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
    val configureAndroid = { p: Project ->
        val android = p.extensions.findByName("android")
        if (android != null) {
            try {
                android.javaClass.getMethod("setCompileSdk", Int::class.java).invoke(android, 37)
            } catch (_: Exception) {
                try {
                    android.javaClass.getMethod("setCompileSdkVersion", Int::class.java).invoke(android, 37)
                } catch (_: Exception) {
                    try {
                        android.javaClass.getMethod("setCompileSdkVersion", String::class.java).invoke(android, "android-37")
                    } catch (_: Exception) {}
                }
            }
        }
    }
    if (state.executed) {
        configureAndroid(this)
    } else {
        afterEvaluate {
            configureAndroid(this)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
