require_relative 'ghidra_index_provider'

module Documentation
  # A documentation provider for TriCore which uses the Ghidra manual index.
  class TriCoreGhidraIndexProvider < GhidraIndexProvider
    def initialize
      super(
        "TriCore V1.3 Instruction Set - PDF",
        "https://www.infineon.com/dgdl/tc_v131_instructionset_v138.pdf?fileId=db3a304412b407950112b409b6dd0352",
        INDEX_TEXT,
      )
    end

    INDEX_TEXT = <<END
# Ghidra/Processors/tricore/data/manuals/tricore.idx
# at 7fc76dbca41419929d59267bcb263637ccc97e52
__END__
@tc_v131_instructionset_v138.pdf[TriCore Architecture Volume 2: Instruction Set, V1.3 & V1.3.1]
ABS, 66
ABS.B, 67
ABSDIF, 69
ABSDIF.B, 71
ABSDIF.H, 71
ABSDIFS, 73
ABSDIFS.H, 75
ABS.H, 67
ABSS, 76
ABSS.H, 77
ADD, 78
ADD.A, 81
ADD.B, 83
ADDC, 85
ADD.F, 511
ADD.H, 83
ADDI, 87
ADDIH, 88
ADDIH.A, 89
ADDS, 90
ADDSC.A, 96
ADDSC.AT, 96
ADDS.H, 92
ADDS.HU, 92
ADDS.U, 94
ADDX, 98
AND, 100
AND.ANDN.T, 102
AND.AND.T, 102
AND.EQ, 104
AND.GE, 105
AND.GE.U, 105
AND.LT, 107
AND.LT.U, 107
ANDN, 111
AND.NE, 109
AND.NOR.T, 102
ANDN.T, 112
AND.OR.T, 102
AND.T, 110
BISR, 113
BMERGE, 115
BSPLIT, 116
CACHEA.I, 117
CACHEA.W, 120
CACHEA.WI, 123
CACHEI.W, 126
CACHEI.WI, 128
CADD, 130
CADDN, 132
CALL, 134
CALLA, 137
CALLI, 139
CLO, 141
CLO.H, 142
CLS, 143
CLS.H, 144
CLZ, 145
CLZ.H, 146
CMOV, 147
CMOVN, 148
CMP.F, 513
CSUB, 149
CSUBN, 150
DEBUG, 151
DEXTR, 152
DISABLE, 153
DIV.F, 515
DSYNC, 154
DVADJ, 155
DVINIT, 157
DVINIT.B, 157
DVINIT.BU, 157
DVINIT.H, 157
DVINIT.HU, 157
DVINIT.U, 157
DVSTEP, 162
DVSTEP.U, 162
ENABLE, 165
EQ, 166
EQ.A, 168
EQANY.B, 171
EQANY.H, 171
EQ.B, 169
EQ.H, 169
EQ.W, 169
EQZ.A, 173
EXTR, 174
EXTR.U, 174
FTOI, 517
FTOIZ, 518
FTOQ31, 519
FTOQ31Z, 521
FTOU, 523
FTOUZ, 524
GE, 176
GE.A, 178
GE.U, 176
IMASK, 179
INSERT, 182
INSN.T, 181
INS.T, 181
ISYNC, 185
ITOF, 525
IXMAX, 186
IXMAX.U, 186
IXMIN, 188
IXMIN.U, 188
J, 190
JA, 191
JEQ, 192
JEQ.A, 194
JGE, 195
JGE.U, 195
JGEZ, 197
JGTZ, 198
JI, 199
JL, 200
JLA, 201
JLEZ, 202
JLI, 203
JLT, 204
JLT.U, 204
JLTZ, 206
JNE, 207
JNE.A, 209
JNED, 210
JNEI, 212
JNZ, 214
JNZ.A, 215
JNZ.T, 216
JZ, 217
JZ.A, 218
JZ.T, 219
LD.A, 220
LD.B, 224
LD.BU, 224
LD.D, 229
LD.DA, 232
LD.H, 235
LD.HU, 238
LDLCX, 246
LDMST, 247
LD.Q, 240
LDUCX, 250
LD.W, 242
LEA, 251
LOOP, 253
LOOPU, 255
LT, 256
LT.A, 259
LT.B, 260
LT.BU, 260
LT.H, 262
LT.HU, 262
LT.U, 256
LT.W, 264
LT.WU, 264
MADD, 265
MADD.F, 526
MADD.H, 268
MADDM.H, 282
MADDMS.H, 282
MADD.Q, 272
MADDR.H, 286
MADDR.Q, 291
MADDRS.H, 286
MADDRS.Q, 291
MADDS, 265
MADDS.H, 268
MADDS.Q, 272
MADDS.U, 279
MADDSU.H, 293
MADDSUM.H, 297
MADDSUMS.H, 297
MADDSUR.H, 301
MADDSURS.H, 301
MADDSUS.H, 293
MADD.U, 279
MAX, 306
MAX.B, 308
MAX.BU, 308
MAX.H, 310
MAX.HU, 310
MAX.U, 306
MFCR, 311
MIN, 312
MIN.B, 314
MIN.BU, 314
MIN.H, 316
MIN.HU, 316
MIN.U, 312
MOV, 317
MOV.A, 319
MOV.AA, 321
MOV.D, 322
MOVH, 324
MOVH.A, 325
MOV.U, 323
MSUB, 326
MSUBAD.H, 343
MSUBADM.H, 347
MSUBADMS.H, 347
MSUBADR.H, 351
MSUBADRS.H, 351
MSUBADS.H, 343
MSUB.F, 528
MSUB.H, 329
MSUBM.H, 356
MSUBMS.H, 356
MSUB.Q, 333
MSUBR.H, 360
MSUBR.Q, 365
MSUBRS.H, 360
MSUBRS.Q, 365
MSUBS, 326
MSUBS.H, 329
MSUBS.Q, 333
MSUBS.U, 340
MSUB.U, 340
MTCR, 367
MUL, 368
MUL.F, 530
MUL.H, 371
MULM.H, 379
MUL.Q, 374
MULR.H, 382
MULR.Q, 385
MULS, 368
MULS.U, 377
MUL.U, 377
NAND, 387
NAND.T, 388
NE, 389
NE.A, 390
NEZ.A, 391
NOP, 392
NOR, 393
NOR.T, 394
NOT, 395
OR, 396
OR.ANDN.T, 398
OR.AND.T, 398
OR.EQ, 400
OR.GE, 401
OR.GE.U, 401
OR.LT, 403
OR.LT.U, 403
ORN, 407
OR.NE, 405
OR.NOR.T, 398
ORN.T, 408
OR.OR.T, 398
OR.T, 406
PACK, 409
PARITY, 412
Q31TOF, 532
QSEED.F, 533
RET, 413
RFE, 415
RFM, 417
RSLCX, 419
RSTV, 420
RSUB, 421
RSUBS, 423
RSUBS.U, 423
SAT.B, 425
SAT.BU, 427
SAT.H, 428
SAT.HU, 430
SEL, 431
SELN, 432
SH, 433
SHA, 446
SHA.H, 449
SH.ANDN.T, 443
SH.AND.T, 443
SHAS, 451
SH.EQ, 435
SH.GE, 436
SH.GE.U, 436
SH.H, 438
SH.LT, 440
SH.LT.U, 440
SH.NAND.T, 443
SH.NE, 442
SH.NOR.T, 443
SH.ORN.T, 443
SH.OR.T, 443
SH.XNOR.T, 443
SH.XOR.T, 443
ST.A, 453
ST.B, 457
ST.D, 460
ST.DA, 463
ST.H, 466
STLCX, 476
ST.Q, 469
ST.T, 471
STUCX, 477
ST.W, 472
SUB, 478
SUB.A, 480
SUB.B, 481
SUBC, 483
SUB.F, 535
SUB.H, 481
SUBS, 484
SUBS.H, 486
SUBS.HU, 486
SUBS.U, 484
SUBX, 488
SVLCX, 489
SWAP.W, 491
SYSCALL, 494
TLBDEMAP, 541
TLBFLUSH.A, 542
TLBFLUSH.B, 542
TLBMAP, 544
TLBPROBE.A, 546
TLBPROBE.I, 548
TRAPSV, 495
TRAPV, 496
UNPACK, 497
UPDFL, 537
UTOF, 539
XNOR, 499
XNOR.T, 500
XOR, 501
XOR.EQ, 503
XOR.GE, 504
XOR.GE.U, 504
XOR.LT, 506
XOR.LT.U, 506
XOR.NE, 508
XOR.T, 509
END
  end
end
