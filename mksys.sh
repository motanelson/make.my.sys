#!/bin/bash

#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 imagem.img"
    exit 1
fi

IMG="$1"
SIZE_MB=12

echo "[1] create image ${SIZE_MB}MB..."
dd if=/dev/zero of="$IMG" bs=1M count=$SIZE_MB status=progress

echo "[2] format FAT12..."
mkfs.fat -F 12 "$IMG"

echo "[3] install Syslinux..."
syslinux "$IMG"

echo "[4] create syslinux.cfg..."
cat << EOF > syslinux.cfg
DEFAULT kernel
LABEL kernel
    KERNEL kernel.c32
EOF

echo "[5] create fake kernel..."
cat << EOF > kernel.asm
bits 16
org 0x100
mov eax,0x21cd4cff
loop0:
    jmp loop0
EOF

echo "[6] compile kernel..."
nasm -f bin kernel.asm -o kernel.com

echo "[7] copy syslinux.cfg..."
mcopy -i "$IMG" syslinux.cfg ::/syslinux.cfg

echo "[8] copy kernel.com..."
mcopy -i "$IMG" kernel.com ::/kernel.com

#rm -f syslinux.cfg kernel.asm kernel.com

echo "[OK] image created: $IMG"
