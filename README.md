# leaf_for_android

# leaf项目的安卓编译脚本（windows）

## 安装 [rust](https://www.rust-lang.org/zh-CN/tools/install)

## 安装 rust for android 编译工具
```
rustup target add x86_64-linux-android aarch64-linux-android
```

## 将 [build.ps1](build.ps1)、[leaf-android](leaf-android) 放到 [leaf]() 的根目录下
```
# 修改leaf/Cago.toml中
members = [
    "leaf",
    "leaf-bin",
    "leaf-ffi",
    "leaf-android", # 添加此项
    "leaf-plugins/shadowsocks",
]

```

## 下载 [llvm-win64](https://llvm.org/) 安装到计算机
## 修改build.ps1 中
```

$Env:LLVM_WIN64_HOME = 'path\to\LLVM'
$Env:ANDROID_HOME = 'path\to\Android\Sdk'
$Env:NDK_HOME = 'path\to\ndk\21.3.6528147'
```
## 修改['$ndkLlvmRoot\lib64\clang\9.0.8\include'](build.ps1#L50) 中的版本号

```
cd leaf
.\build.ps1 debug
# or
.\build.ps1 release
```