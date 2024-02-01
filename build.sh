#!/bin/bash

# Copyright (C) 2023 psionicprjkt

function psionic_compile()
{
    # cleanup_directories
    rm -rf out AnyKernel AK3-* clang arm64 arm32 && mkdir -p out

    # download_resources
    wget --quiet https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-12.0.0_r12/clang-r416183b1.tar.gz -O "aosp-clang.tar.gz"
    mkdir clang && tar -xf aosp-clang.tar.gz -C clang && rm -rf aosp-clang.tar.gz
    git clone --depth=1 https://github.com/psionicprjkt/aarch64-linux-android-4.9 arm64
    git clone --depth=1 https://github.com/psionicprjkt/arm-linux-androideabi-4.9 arm32


  
    # compile_kernel
    export ARCH=arm64
    make O=out ARCH=arm64 surya_defconfig
    PATH="${PWD}/clang/bin:${PWD}/arm64:${PWD}/arm32:${PATH}" \
        make -j$(nproc --all) O=out \
        LLVM=1 \
        LLVM_IAS=1 \
        ARCH=arm64 \
        CC="clang" \
        LD=ld.lld \
        STRIP=llvm-strip \
        AS=llvm-as \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE="${PWD}/arm64/aarch64-linux-android-" \
        CROSS_COMPILE_COMPAT="${PWD}/arm32/arm-linux-androideabi-" \
        CONFIG_NO_ERROR_ON_MISMATCH=y \
        CFLAGS="-Wno-pragma-messages" 2>&1 | tee error.log
}

function psionic_upload()
{
    # setup_kernel_release
    git clone --depth=1 https://github.com/Konjikin/AnyKernel3  AnyKernel
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
    cp out/arch/arm64/boot/dtbo.img AnyKernel
    cd AnyKernel
    zip -r9 "surya-$(date "+%d%m%Y")-release.zip" *

    # upload_kernel_release
    curl -s bashupload.com -T surya*
}

psionic_compile
psionic_upload
