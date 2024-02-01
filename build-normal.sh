#!/bin/bash

# Copyright (C) 2023 psionicprjkt

compile_kernel() {
    # compile_kernel
    export ARCH=arm64
    make O=out ARCH=arm64 surya_defconfig
    PATH="${PWD}/clang/bin:${PWD}/arm64:${PWD}/arm32:${PATH}" \
    make -j"$(nproc --all)" O=out \
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

setup_kernel_release() {
    # setup_kernel_release
    git clone --depth=1 https://github.com/Konjikin/AnyKernel3  AnyKernel
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
    cp out/arch/arm64/boot/dtbo.img AnyKernel
    cd AnyKernel
    zip -r9 "surya-$(date "+%d%m%Y")-release.zip" *
}

compile_kernel
setup_kernel_release

