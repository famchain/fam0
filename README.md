# fam0

fam0 is an extremely small **self-hosting hex-to-binary converter** written as hand-crafted x86-64 machine code.

The seed binary (`fam0.seed`, **362 bytes**) reads a text file containing uppercase hex digits (with newlines and `#`-style comments allowed), packs them into binary bytes, and writes the result to an output file.

You can use the seed to "recompile" its own source code (`fam0.fam0`) and verify that the produced binary is bit-for-bit identical to the seed — proving a clean self-hosting round-trip.

### Quick validation

```
# Run the seed on its own hex source
./fam0.seed fam0.fam0 fam0.cmp

# Compare — should produce no output (identical files)
cmp fam0.seed fam0.cmp

# Show sizes — both should be 362 bytes
ls -l fam0.seed fam0.cmp
```

Expected output looks roughly like:

```
-rwxr-xr-x 1 user user 362 Mar  7 14:32 fam0.seed
-rwxr-xr-x 1 user user 362 Mar  7 14:33 fam0.cmp
```


