# Interesting keys

- `AsmString` - theoretically convertible to/from asm
- `Pattern` - seems to define approximate semantics?
- Inputs and outputs:
    - `InOperandList`/`OutOperandList` - explicit inputs and outputs (on LLVM level, not asm)
    - `Constraints` - defines constraints, e.g. two-operand add has `src1 = dst`
    - `Uses`/`Defs` - implicitly-accessed registers



# Fun examples

Original TriCore struggle:

```
./lllookup --arch TriCore --input addr --output data
```

How do I add to an address in TriCore?

```
./lllookup --arch TriCore --mnemonic add --input addr
```

Find x86 instructions to add immediate to memory:

```
./lllookup --arch X86 --mnemonic add --input mem --input imm --store
```

What are SH2's branch/call instructions called again...?

```
./lllookup --arch J2 --no-store --no-load --input mem
```

Find flag-pushing instructions:

```
./lllookup --arch X86 --nullary --store
```

# Addressing modes

TriCore uses addressing modes for its instructions so searching by just `data` or `imm` doesn't
bring anything up...

Maybe need to 'explode' those somehow
