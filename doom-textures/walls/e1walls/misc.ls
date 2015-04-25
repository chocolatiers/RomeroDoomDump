$load t14.lbm
;T14.LS:  lights and silver stuff
;       t14_1           patch255        24  24  64  72
;       t14_2           patch255        96  24  64  72
;       t14_3           patch255        168 24  64  72
;       t14_4           patch255        120 104 32  72
t14_5           patch255        232 104 16  72
;       t14_6           patch255        288 104 16  72

$load t15.lbm
;T15.LS:  tall silver walls (128 tall, that is)
ag128_1         patch255        24  24  64  128
ag128_2         patch255        96  24  64  128
;       ag128_3         patch255        168 24  64  128
agb128_1        patch255        240 24  8   128
;       agb128_2        patch255        256 24  16  128
;       agb128_3        patch255        280 24  24  128

$load t16.lbm
wla128_1        PATCH255        24      24      64      128
;       wla128_2        PATCH255        96      24      64      128
;       wla128_3        PATCH255        168     24      64      128
;       wla128_4        PATCH255        240     24      8       128
;       wla128_5        PATCH255        256     24      16      128
;       wla128_6        PATCH255        280     24      24      128

;       $load t17.lbm
;       t17_1           PATCH255        24      24      16      128

$load tomw0.lbm
;       support1        PATCH255        16      16      24      72
support2        PATCH255        48      16      24      72
;       support3        PATCH255        80      16      24      72
;       support4        PATCH255        112     16      24      72
;       support5        PATCH255        144     16      24      72

$load tomw2.lbm
tomw2_1         PATCH255        16      16      128     72
tomw2_2         PATCH255        16      96      128     72

$load crates.lbm
;CRATES.LS:  Crates, steps, and such.
;       bcratel1        patch255        16  16  32  64 
;       bcratem1        patch255        240 16  8   64
;       bcrater1        patch255        48  16  32  64 
;       gcratel1        patch255        128 16  32  64
;       gcratem1        patch255        256 16  8   64
;       gcrater1        patch255        160 16  32  64
;       sbcrate1        patch255        88  16  32  64
;       sgcrate1        patch255        200 16  32  64
;       vbcrate1        patch255        272 40  16  16
;       vgcrate1        patch255        272 64  16  16
; STEPS
;       step01          patch255        16      96      32      8
;       step02          patch255        56      96      32      8
step03          patch255        96      96      32      8
step04          patch255        136     96      32      8
step05          patch255        176     96      32      8
step06          patch255        16      120     32      8
step07          patch255        56      120     32      8
step08          patch255        96      120     32      8
step09          patch255        136     120     32      8
step10          patch255        176     120     32      8
;       step11          patch255        16      144     32      8
;       step12          patch255        56      144     32      8
;       step13          patch255        96      144     32      8
;       step14          patch255        136     144     32      8
;       step15          patch255        176     144     40      8
;       step16          patch255        224     96      56      16
; EXIT SIGN
exit1           patch255        16      160     32      16
exit2           patch255        56      160     8       16
;       exit3           patch255        16      184     32      8
; LADDER TEXTURE
;       ladder32        patch255        72      160     64      32
;       ladder16        patch255        144     160     64      16

;       $load crates2.lbm
;CRATES2.LS:  Crates, steps, and such.
;       bcrate2         patch255        16  16  64  64 
;       gcrate2         patch255        128 16  64  64
;       sbcrate2        patch255        88  16  32  64
;       sgcrate2        patch255        200 16  32  64

;       $load plat1.lbm
;       plat1_1         PATCH255        16      16      192      136

$load plat2.lbm
plat2_1         PATCH255        16      16      128     128

$load ttall1.lbm
ttall1_2         PATCH255        120     0      8       128
;       ttall1_3         PATCH255        136     0      64      128

;       $load cyl1.lbm
;       cyl1_1          PATCH255        16      16      118     72
;       cyl1_2          PATCH255        144     16      68      72
;       cyl1_4          PATCH255        144     96      128     72
;       cyl1_3          PATCH255        16      96      118     72

;       $load talpipe1.lbm
;       pipe1           PATCH255        17      17      112 176
;       pipe2           PATCH255        136 16 112 176

$load talpipe2.lbm
tp2_1           PATCH255        16      16      128 128
tp2_2           PATCH255        152 16 128 128

;       $load talpipe3.lbm
;       tp3_1           PATCH255        16      16      128 128
;       tp3_2           PATCH255        152 16 128 128

;       $load talpipe4.lbm
;       tp4_1           PATCH255        16      16      128 128
;       tp4_2           PATCH255        152 16 128 128

;       $load talpipe5.lbm
;       tp5_1           PATCH255        16      16      32      128
;       tp5_2           PATCH255        56      16      32      128
;       tp5_3           PATCH255        96      16      32      128
;       tp5_4           PATCH255        136 16 32 128

;       $load talpipe6.lbm
;       tp6_1           PATCH255        16      16      128 128
;       tp6_2           PATCH255        152 16 128 128

;       $load talpipe7.lbm
;       tp7_1           PATCH255        16      16      128 128
;       tp7_2           PATCH255        152 16 128 128

$load comput.lbm
comp01_1     PATCH255        24      16      56      56
;       comp01_2     PATCH255        88      16      56      56
;       comp01_3     PATCH255        152     16      56      56
;       comp01_4     PATCH255        216     16      56      56
comp01_5     PATCH255        24      80      56      56
comp01_6     PATCH255        88      80      56      56
;       comp01_7     PATCH255        152     80      56      56
;       comp01_8     PATCH255        216     80      56      56

$load compu1b.lbm
;       comb1b_1                PATCH255        24      16      56      56      0       0
;       comp1b_2                PATCH255        88      16      56      56      0       0
;       comp1b_3                PATCH255        152     16      56      56      0       0
comp1b_4                PATCH255        216     16      56      56      0       0
;       comp1b_5                PATCH255        88      80      56      56      0       0
;       comp1b_6                PATCH255        152     80      56      56      0       0

$load compu1c.lbm
;       comp1c_1                PATCH255        24      16      56      56      0       0
;       comp1c_2                PATCH255        88      16      56      56      0       0
;       comp1c_3                PATCH255        152     16      56      56      0       0
;       comp1c_4                PATCH255        216     16      56      56      0       0
;       comp1c_5                PATCH255        88      80      56      56      0       0
comp1c_6                PATCH255        152     80      56      56      0       0

$load comput2.lbm
comp02_1     PATCH255        32      24      64      56
comp02_2     PATCH255        104     24      64      56
comp02_3     PATCH255        176     24      64      56
comp02_4     PATCH255        248     24      64      56
comp02_5     PATCH255        32      88      64      56
comp02_6     PATCH255        104     88      64      56
comp02_7     PATCH255        176     88      64      56
comp02_8     PATCH255        248     88      64      56

;       $load compu2b.lbm
;       comp2b_1                PATCH255        32      24      64      56      0       0
;       comp2b_2                PATCH255        104     24      64      56      0       0
;       comp2b_3                PATCH255        176     24      64      56      0       0
;       comp2b_4                PATCH255        248     24      64      56      0       0
;       comp2b_5                PATCH255        32      88      64      56      0       0
;       comp2b_6                PATCH255        104     88      64      56      0       0
;       comp2b_7                PATCH255        176     88      64      56      0       0
;       comp2b_8                PATCH255        248     88      64      56      0       0

;       $load compu2c.lbm
;       comp2c_1                PATCH255        32      24      64      56      0       0
;       comp2c_2                PATCH255        104     24      64      56      0       0
;       comp2c_3                PATCH255        176     24      64      56      0       0
;       comp2c_4                PATCH255        248     24      64      56      0       0
;       comp2c_5                PATCH255        32      88      64      56      0       0
;       comp2c_6                PATCH255        104     88      64      56      0       0
;       comp2c_7                PATCH255        176     88      64      56      0       0
;       comp2c_8                PATCH255        248     88      64      56      0       0

$load comput3.lbm
comp03_1     PATCH255        32      24      64      64
;       comp03_2     PATCH255        104     24      64      64
;       comp03_3     PATCH255        176     24      64      64
comp03_4     PATCH255        248     24      32      64
comp03_5     PATCH255        32      96      64      64
comp03_6     PATCH255        104     96      32      64
comp03_7     PATCH255        144     96      32      64
comp03_8     PATCH255        184     96      32      64
comp03_9     PATCH255        224     96      64      64

;       $load compu3b.lbm
;       comp3b_1                PATCH255        32      24      64      64      0       0
;       comp3b_2                PATCH255        104     24      64      64      0       0
;       comp3b_3                PATCH255        176     24      64      64      0       0
;       comp3b_4                PATCH255        248     24      32      64      0       0
;       comp3b_5                PATCH255        32      96      64      64      0       0
;       comp3b_6                PATCH255        104     96      32      64      0       0
;       comp3b_7                PATCH255        144     96      32      64      0       0
;       comp3b_8                PATCH255        184     96      32      64      0       0
;       comp3b_9                PATCH255        224     96      64      64      0       0

;       $load compu3c.lbm
;       comp3c_1                PATCH255        32      24      64      64      0       0
;       comp3c_2                PATCH255        104     24      64      64      0       0
;       comp3c_3                PATCH255        176     24      64      64      0       0
;       comp3c_4                PATCH255        32      96      64      64      0       0
;       comp3c_5                PATCH255        104     96      32      64      0       0
;       comp3c_6                PATCH255        144     96      32      64      0       0
;       comp3c_7                PATCH255        224     96      64      64      0       0

$load comput4.lbm
comp04_1     PATCH255        32      24      64      64
comp04_2     PATCH255        104     24      64      64
;       comp04_3     PATCH255        176     24      64      64
;       comp04_4     PATCH255        248     24      64      64
comp04_5     PATCH255        32      104     64      64
comp04_6     PATCH255        104     104     64      64
comp04_7     PATCH255        176     104     64      64
comp04_8     PATCH255        248     104     64      64

;       $load compu4b.lbm
;       comp4b_1                PATCH255        32      24      64      64      0       0
;       comp4b_2                PATCH255        104     24      64      64      0       0
;       comp4b_3                PATCH255        176     24      64      64      0       0
;       comp4b_4                PATCH255        248     24      64      64      0       0

;       $load compu4c.lbm
;       comp4c_1                PATCH255        32      24      64      64      0       0
;       comp4c_2                PATCH255        104     24      64      64      0       0
;       comp4c_3                PATCH255        176     24      64      64      0       0
;       comp4c_4                PATCH255        248     24      64      64      0       0

