# Archer

> **Hosted at [archer.computer](https://archer.computer)**

## What is this?

Archer is a web app which provides a searchable, filterable directory of machine instructions for a
variety of computer architectures.

I grew frustrated at a lack of standardised, consistent documentation for people writing Assembly.
You're largely stuck with clunky vendor websites or ancient PDFs.

Archer lets you answer questions like...

- Which instructions can I use to write x87 floating point data to memory?
    - Select only "x87 FPU" capability, filter to "Memory: Store"
- What flag-pushing instructions does x86 have?
    - Filter to "Operands: None" for input and output, and "Memory: Store"
- How do I transfer a value from an Address Register to a Data Register on TriCore?
    - Filter to "Operands: Input: Address register" and "Operands: Output: Data register"

## Data sources

Archer's data is a combination of:

* Machine information dumped from **LLVM and some forks of it**
    * Latest copy saved in `llvm/dump`
* Hand-written YAML "supplementary" files, to imbue more human-friendly meaning to the LLVM info
    * In `supp`

The latest list of forks used can always be found on the homepage of
[archer.computer](https://archer.computer).

## Building

Archer is a static site once built, and can be used offline if you like.

You will need a reasonably up-to-date Ruby to build the site (tested on 3.2).

```
bundle install
bundle exec build_site.rb
```

## Refreshing LLVM data

To fetch or refetch the LLVM data dumps, install Docker then run:

```
cd llvm
./generate_tablegen_dumps.sh
```

This will take a fair bit of time, disk space, and RAM, as it creates multiple checkouts of LLVM and
partially builds one of them.

## Things to do

- **Ideas**
    - [ ] _(Easy)_ "Clear filters" button
    - [ ] _(Medium)_ Copy link to specific instructions
    - [ ] _(Medium)_ Dark mode
    - [ ] _(Hard)_ Group instructions with the same mnemonic, rather than displaying separately
    - [ ] _(Hard)_ Properly collect and show register class members
- **Issues**
    - [ ] Mnemonic search includes entire text, not just the mnemonic
    - [ ] Instruction parsing seems broken - lots of errors for x86
- **Architecture Support**
    - [ ] ARM
    - [ ] Rest of the x86 capabilities
    - [ ] Rest of the RISC-V capabilities
    - [ ] More PowerPC

## License

All Archer source code and supplementary data is licensed under the [MIT License](./LICENSE).

LLVM dumped data in `llvm/dump` originates from the LLVM project and forks of it, therefore being
licensed under the [Apache License v2.0 with LLVM Exceptions](https://github.com/llvm/llvm-project/blob/main/LICENSE.TXT)
or the [University of Illinois/NCSA Open Source License](https://github.com/TriDis/llvm-tricore/blob/tricore/LICENSE.TXT)
depending on the age of the fork. I believe both of these licenses are compatible with MIT.
