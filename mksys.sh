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
mkfs.fat -F 12 -n SYS12 "$IMG"

echo "[3] install Syslinux..."
syslinux -i "$IMG"

echo "[4] create syslinux.cfg..."
cat << EOF > syslinux.cfg
DEFAULT kernel
LABEL kernel
    KERNEL kernel.bin
EOF

echo "[5] create kernel..."
cat << EOF > kernel.asm
BITS 16
ORG 0x1000

start:
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ax, 0x0741
.fill:
    stosw
    loop .fill
.hang:
    jmp .hang
EOF

echo "[6] compile kernel..."
nasm -f bin kernel.asm -o kernel.bin

echo "[7] copy files..."
mcopy -i "$IMG" syslinux.cfg ::/syslinux.cfg
mcopy -i "$IMG" kernel.bin ::/kernel.bin

rm -f kernel.asm syslinux.cfg

echo "[OK] image created: $IMG"
