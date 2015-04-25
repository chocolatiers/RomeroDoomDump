$load switch2.lbm
sw2_1		PATCH255	24	24	24	32
sw2_2		PATCH255	56	24	24	32
;sw2_3		PATCH255	88	24	56	48
sw2_4		PATCH255	152 24 56 48
sw2_5		PATCH255	16	128 64 56
sw2_6		PATCH255	16	64	64	56
sw2_7		PATCH255	88	80	40	40
sw2_8		PATCH255	136 80 40 40

; MOVED FROM E1
$load ../e1patch/patch0.lbm
duct1                 PATCH255        56      96      24      32      0       0

$load ../e1patch/pict1.lbm
;ps15A0               PATCH255        144     96      40      40      0       0
ps18A0               PATCH255        224     64      64      40      0       0
