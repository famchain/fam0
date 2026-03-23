# fam0

fam0 is an extremely small self-hosting hex-to-binary converter written as hand-crafted riscv64 machine code.

The seed binary (fam0.seed, 188 bytes) reads a text file containing uppercase hex digits (with newlines and #-style comments allowed), packs them into binary bytes, and writes the result to an output file.

You can use the seed to "recompile" its own source code (fam0.fam0) and verify that the produced binary is bit-for-bit identical to the seed — proving a clean self-hosting round-trip.

### Quick validation

You will need to ensure the qemu-system-riscv64 is present on your system.

```
# Review fam0.fam0 source file
cat ./fam0.fam0
# Review bootstrap.sh
cat ./bootstrap.sh
# Run ./bootstrap.sh
./bootstrap.sh
```

Expected output looks roughly like:

```
$ cat bootstrap.sh 
#!/bin/sh

# Build fam0 from seed binary
(cat fam0.fam0; printf '\004') | qemu-system-riscv64 \
	-machine virt \
	-nographic \
	-bios none \
	-device loader,file=./fam0.seed,addr=0x80000000 \
	| tee ./fam0.bin > /dev/null

cmp ./fam0.bin ./fam0.seed || { echo "binaries don't match!"; exit 1; }

echo "Bootstrap successful!";
$ ./bootstrap.sh 
Bootstrap successful!
$
```

This confirms that the output is bit-for-bit identical.
