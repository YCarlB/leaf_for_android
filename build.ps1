########
# Tested under PowerShell 7.1.2 on Windows x64.
# Set the following env. var. before launching this script.
# NDK_HOME: The destination of the Android NDK installatin.
# LLVM_WIN64_HOME: The destination of the LLVM installation, for your Windows host machine.

Set-Location $PSScriptRoot

$Env:LLVM_WIN64_HOME = 'F:\LLVM'
$Env:ANDROID_HOME = 'C:\Users\yangi\AppData\Local\Android\Sdk'
$Env:NDK_HOME = 'C:\Users\yangi\AppData\Local\Android\Sdk\ndk\21.3.6528147'

# This script is for Windows only, so we hardcode the root path
$ndkLlvmRoot = "$Env:NDK_HOME\toolchains\llvm\prebuilt\windows-x86_64"

# Build mode
if ($args[0] -eq "release") {
    $mode = "release"
} else {
    $mode = "debug"
}

# Android API level
$api = "30"

# Now build
foreach ($target in "aarch64-linux-android", "x86_64-linux-android") {
    # Select proper linker and ar executables
    $linker = "$ndkLlvmRoot\bin\$target$api-clang.cmd"
    $ar = "$ndkLlvmRoot\bin\$target-ar.exe"
    switch ($target) {
        "aarch64-linux-android" {
            $jniDir = "arm64-v8a"
            $Env:CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER = $linker
            $Env:CARGO_TARGET_AARCH64_LINUX_ANDROID_AR = $ar
            break
        }
        "x86_64-linux-android" {
            $jniDir = "x86_64"
            $Env:CARGO_TARGET_X86_64_LINUX_ANDROID_LINKER = $linker
            $Env:CARGO_TARGET_X86_64_LINUX_ANDROID_AR = $ar
            break
        }
    }
    # For ring
    $Env:TARGET_CC = $linker
    $Env:TARGET_AR = $ar
    # For bindgen
    $Env:LIBCLANG_PATH = "$Env:LLVM_WIN64_HOME\lib"
    $Env:BINDGEN_EXTRA_CLANG_ARGS = "--target=$target$api -isystem '$ndkLlvmRoot\sysroot\usr\include' -isystem '$ndkLlvmRoot\lib64\clang\9.0.8\include'"

    # Now build
    switch ($mode) {
        "release" { 
            cargo build --target $target --no-default-features --features "leaf/default-ring" --release -p leaf-android
            break
         }
        "debug" {
            cargo build --target $target --no-default-features --features "leaf/default-ring" -p leaf-android
            break
        }
    }

    # Copy built .so files
    # New-Item "$PSScriptRoot\..\..\jniLibs\$jniDir" -ItemType Directory -ErrorAction SilentlyContinue
    # Copy-Item -Force "$PSScriptRoot\target\$target\$mode\libleafandroid.so" "$PSScriptRoot\..\..\jniLibs\$jniDir"
}