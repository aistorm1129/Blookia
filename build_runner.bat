@echo off
echo Generating Hive adapters...
dart run build_runner build
echo Build complete!
pause