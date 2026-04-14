@ECHO OFF
SET DIR=%~dp0
IF NOT EXIST "%DIR%gradle\wrapper\gradle-wrapper.jar" (
  ECHO gradle-wrapper.jar missing. Run: gradle wrapper --gradle-version 8.10.2
  EXIT /B 1
)
java -classpath "%DIR%gradle\wrapper\gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain %*
