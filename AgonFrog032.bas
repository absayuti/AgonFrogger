   10 REM Frogger for AGON Light 2
   20 REM Written for AgonBASIC but tried to be BBCSDL compatible
   30 REM
   40 REM Using MODE 2 (40x25) in AGON Light
   50 REM       MODE 1 (40x32) in BBSDL (Windows/Mac)
   60 REM
   70 REM To run on AGON LIGHT:
   80 REM   o Save this file as AFROG.BAS in the AGON's SDCARD,
   90 REM     preferably in its BAS folder.
  100 REM   o On AGON, enter:
  110 REM        *CD BAS
  120 REM        LOAD "AFROG.BAS"
  130 REM        RUN
  140 REM
  150 REM To run in FAB-agon-emulator:
  160 REM   o Copy this file as AFROG.BAS in the sdcard\BAS subfolder
  170 REM     inside the Fab-agon-emulator-v0.9.77 folder.
  180 REM   o Enter the same commands as above.
  190 REM
  200 REM
  210 REM ---------------------------------------------------------------------
  220 REM V 0.32 - Check for full nest --> game win/over
  230 REM          Game over + play again routines
  240 REM V 0.31 - Trying diffrent looping technique for traffic vs frog
  250 REM V 0.30 - Change the mapping of the obstacles as strings (arrays?).
  260 REM          Collision detection to be done on the strings rather than
  270 REM          locations on screen (GET() function gives strange results).
  280 REM          Added advantage: objects can have different colours??
  290
  300 REM V 0.23 - Debugging for Agon HW (GET() gets -1???)
  310 REM V 0.22 - Optimize for AGON HW/emu.
  320 REM        - Check for full nest
  330 REM V 0.21 - Add timer. Animate frog jumping.
  340 REM V 0.20 - Overall game play
  350
  360 REM V 0.15 - Frog reaches nests or die
  370 REM V 0.13 - Optimize frog movement vs traffic
  380 REM V 0.12 - Changed UDC to 2x2
  390 REM        - Frog movement
  400 REM V 0.11 - Format of traffic as strings
  410 REM V 0.10 - Basic structure
  420 REM ---------------------------------------------------------------------
  430 REM
  440 PROC_initialise
  450 PROC_intro
  460 PROC_setup
  470 REM PROC_intro
  480 REPEAT
  490   PROC_initGame
  500   tstart% = TIME
  510   REPEAT
  520     tleft% = 200 - (TIME-tstart%)/100
  530     IF tleft%<1 THEN gameover% = TRUE
  540     COLOUR Black%: COLOUR 128+Green%
  550     PRINT TAB(28,0);tleft%
  560     PROC_getInput
  570     REM Counters for the traffic
  580     REM cloop% = cloop%+1: IF cloop%>5 THEN cloop% = 0
  590     PROC_traffic
  600     PROC_moveFrog
  610     IF collided% THEN PROC_collided
  620     IF row%=0 THEN PROC_checkNested
  630     IF machine$="SDL" THEN PROC_wait(1)
  640   UNTIL gameover%
  650   play% = FN_playAgain
  660 UNTIL play%=FALSE
  670 END
  680
  690 REM ---------------------------------------------------------------------
  700 DEF PROC_getInput
  710 r% = 0: c% = 0
  720 k% = INKEY(1)
  730 IF k%=8 OR k%=136 OR k%=74 THEN c% =-1
  740 IF k%=21 OR k%=137 OR k%=76 THEN c% = 1
  750 IF k%=11 OR k%=139 OR k%=73 THEN r% =-1
  760 IF k%=10 OR k%=138 OR k%=75 THEN r% = 1
  770 ENDPROC
  780
  790 REM ---------------------------------------------------------------------
  800 DEF PROC_traffic
  810 cloop% = cloop%+1
  820 IF cloop%<8 THEN 1080
  830 cloop% = 0
  840 REM Shift objects in traffic strings
  850 REM River
  860 obs$(0,0) = FN_shiftLeft(obs$(0,0))
  870 obs$(0,1) = FN_shiftLeft(obs$(0,1))
  880 obs$(1,0) = FN_shiftRight(obs$(1,0))
  890 obs$(1,1) = FN_shiftRight(obs$(1,1))
  900 obs$(2,0) = FN_shiftLeft(obs$(2,0))
  910 obs$(2,1) = FN_shiftLeft(obs$(2,1))
  920 obs$(3,0) = FN_shiftRight(obs$(3,0))
  930 obs$(3,1) = FN_shiftRight(obs$(3,1))
  940 PROC_shiftFrogToo
  950 REM Vehicles
  960 obs$(5,0) = FN_shiftRight(obs$(5,0))
  970 obs$(5,1) = FN_shiftRight(obs$(5,1))
  980 obs$(6,0) = FN_shiftLeft(obs$(6,0))
  990 obs$(6,1) = FN_shiftLeft(obs$(6,1))
 1000 IF movelorry%=0 THEN movelorry%=1: GOTO 1080
 1010 obs$(4,0) = FN_shiftRight(obs$(4,0))
 1020 obs$(4,1) = FN_shiftRight(obs$(4,1))
 1030 obs$(7,0) = FN_shiftLeft(obs$(7,0))
 1040 obs$(7,1) = FN_shiftLeft(obs$(7,1))
 1050 movelorry% = 0
 1060 REM Print traffic objects
 1070 REM river
 1080 COLOUR Red%: COLOUR Blue%+128
 1090 PRINT TAB(0,2);obs$(0,0);
 1100 PRINT TAB(0,3);obs$(0,1);
 1110 COLOUR Green2%
 1120 PRINT TAB(0,4);obs$(1,0);
 1130 PRINT TAB(0,5);obs$(1,1);
 1140 COLOUR Red2%
 1150 PRINT TAB(0,6);obs$(2,0);
 1160 PRINT TAB(0,7);obs$(2,1);
 1170 COLOUR Cyan2%
 1180 PRINT TAB(0,8);obs$(3,0);
 1190 PRINT TAB(0,9);obs$(3,1);
 1200 REM vehicles
 1210 COLOUR Grey%: COLOUR 128
 1220 PRINT TAB(0,12);obs$(4,0);
 1230 PRINT TAB(0,13);obs$(4,1);
 1240 COLOUR Cyan%
 1250 PRINT TAB(0,15);obs$(5,0);
 1260 PRINT TAB(0,16);obs$(5,1);
 1270 COLOUR Yellow%
 1280 PRINT TAB(0,18);obs$(6,0);
 1290 PRINT TAB(0,19);obs$(6,1);
 1300 COLOUR Grey%
 1310 PRINT TAB(0,21);obs$(7,0);
 1320 PRINT TAB(0,22);obs$(7,1);
 1330 ENDPROC
 1340
 1350 REM ---------------------------------------------------------------------
 1360 DEF FN_shiftLeft(x$)
 1370 = RIGHT$(x$,39)+LEFT$(x$,1)
 1380
 1390 REM ---------------------------------------------------------------------
 1400 DEF FN_shiftRight(x$)
 1410 = RIGHT$(x$,1)+LEFT$(x$,39)
 1420
 1430 REM ---------------------------------------------------------------------
 1440 DEF PROC_shiftFrogToo
 1450 IF row%=1 OR row%=3 THEN c% = -1
 1460 IF row%=2 OR row%=4 THEN c% = 1
 1470 ENDPROC
 1480
 1490 REM ---------------------------------------------------------------------
 1500 DEF PROC_moveFrog
 1510 COLOUR Black%: COLOUR 128+Green%
 1520 IF row%=5 OR row%=10 THEN PRINT TAB(col%,ypos%(row%));"  ";: PRINT TAB(col%,ypos%(row%)+1);"  ";
 1530 row% = row%+r%: score% = score%-10*r%: PRINT TAB(17,0);score%
 1540 IF row%<0 THEN row% = 0
 1550 IF row%>10 THEN row% = 10
 1560 col% = col%+c%
 1570 IF col%<0 THEN col%=0
 1580 IF col%>37 THEN col%=38
 1590 collided% = FN_checkCollision
 1600 IF r% THEN SOUND 1,-8,100,2
 1610 PROC_printFrog
 1620 IF r% THEN SOUND 1,-8,50,1
 1630 COLOUR 128
 1640 ENDPROC
 1650
 1660 REM ---------------------------------------------------------------------
 1670 DEF PROC_printFrog
 1680 COLOUR Magenta2%: COLOUR 128
 1690 IF row%<5 THEN COLOUR 128+Blue%
 1700 IF row%=5 OR row%=10 THEN COLOUR 128+Green%
 1710 IF r%<0 THEN PROC_printFrog2
 1720 PRINT TAB(col%,ypos%(row%));CHR$(frog%)+CHR$(frog%+1);
 1730 PRINT TAB(col%,ypos%(row%)+1);CHR$(frog%+2)+CHR$(frog%+3);
 1740 ENDPROC
 1750
 1760 REM ---------------------------------------------------------------------
 1770 DEF PROC_printFrog2
 1780 PRINT TAB(col%,ypos%(row%));CHR$(frog%+4)+CHR$(frog%+5);
 1790 PRINT TAB(col%,ypos%(row%)+1);CHR$(frog%+6)+CHR$(frog%+7);
 1800 PROC_wait(5)
 1810 ENDPROC
 1820
 1830 REM ---------------------------------------------------------------------
 1840 DEF FN_checkCollision
 1850 IF row%=0 OR row%=5 OR row%=10 THEN = 0
 1860 IF row%<5 THEN y% = row%-1
 1870 IF row%>5 THEN y% = row%-2
 1880 x$ = obs$(y%,0)
 1890 cc% = ASC(MID$(x$,col%+1,1))
 1900 IF cc%<>32 AND row%<5 THEN = 0
 1910 IF cc%=32 AND row%>5 THEN = 0
 1920 SOUND 0,-8,1,1
 1930 = 1
 1940 ENDPROC
 1950
 1960 REM ---------------------------------------------------------------------
 1970 DEF PROC_collided
 1980 PROC_printDead
 1990 lives% = lives%-1
 2000 IF lives%=0 THEN gameover% = TRUE
 2010 PROC_printHeader
 2020 PROC_resetFrog
 2030 ENDPROC
 2040
 2050 REM ---------------------------------------------------------------------
 2060 DEF PROC_printDead
 2070 COLOUR Red%: COLOUR 128
 2080 IF row%<5 THEN COLOUR 128+Blue%
 2090 IF row%=0 THEN COLOUR 128+Green%
 2100 PRINT TAB(col%,ypos%(row%));CHR$(dead%)+CHR$(dead%+1);
 2110 PRINT TAB(col%,ypos%(row%)+1);CHR$(dead%+2)+CHR$(dead%+3);
 2120 PROC_soundDead
 2130 ENDPROC
 2140
 2150 REM ---------------------------------------------------------------------
 2160 DEF PROC_resetFrog
 2170 row% = 23: col% = 19
 2180 REPEAT UNTIL INKEY(0)=-1
 2190 PROC_wait(50)
 2200 REM tstart% = TIME
 2210 ENDPROC
 2220
 2230 REM ---------------------------------------------------------------------
 2240 DEF PROC_checkNested
 2250 LOCAL nested%
 2260 nested% = FN_isNested
 2270 IF nested%<>-1 THEN PROC_nestReached: ENDPROC
 2280 REM Else...
 2290 PROC_printDead
 2300 lives% = lives%-1
 2310 IF lives%=0 THEN gameover% = TRUE
 2320 PROC_printHeader
 2330 PROC_resetFrog
 2340 ENDPROC
 2350
 2360 REM ---------------------------------------------------------------------
 2370 DEF FN_isNested
 2380 LOCAL i%, pos%
 2390 IF row%<>0 THEN = 0
 2400 pos% = -1
 2410 FOR i%=0 TO 4
 2420   IF nest%(i%)=0 AND ncol%(i%)=col% THEN nest%(i%) = 1: pos% = i%
 2430 NEXT
 2440 = pos%
 2450 ENDPROC
 2460
 2470 REM ---------------------------------------------------------------------
 2480 DEF PROC_nestReached
 2490 PROC_printHeader
 2500 COLOUR Magenta%: COLOUR 128+Blue%
 2510 PRINT TAB(col%,row%+1);CHR$(frog%+10)+CHR$(frog%+11);
 2520 row% = 23: col% = 19
 2530 nested% = 0
 2540 score% = score%+200
 2550 PROC_soundScore
 2560 IF nest%(0)+nest%(1)+nest%(2)+nest%(3)+nest%(4)=5 THEN gameover% = 1
 2570 IF gameover%=1 THEN score% = score% + 50*lives% + 10*tleft%
 2580 PROC_wait(50)
 2590 ENDPROC
 2600
 2610 REM ---------------------------------------------------------------------
 2620 DEF PROC_setup
 2630 DIM nest%(4), ncol%(4)
 2640 ncol%(0) = 5: ncol%(1) = 12: ncol%(2) = 19
 2650 ncol%(3) = 26:  ncol%(4) = 33
 2660 DIM ypos%(10) :REM Actual Y (row) position of the frog
 2670 ypos%(0) = 0: ypos%(1) = 2: ypos%(2) = 4: ypos%(3) = 6: ypos%(4) = 8: ypos%(5) = 10
 2680 ypos%(6) = 12: ypos%(7) = 15: ypos%(8) = 18: ypos%(9) = 21: ypos%(10) = 23
 2690 hiscore% = 199
 2700 REM Notes for happy tune
 2710 DIM happy%(9)
 2720 FOR i=0 TO 8
 2730   READ happy%(i)
 2740 NEXT
 2750 DATA 164,164,164,0,148,164,176,0,128
 2760 REM User defined characters and data strings for traffics
 2770 PROC_customChar
 2780 REM The obstacle/traffic
 2790 DIM obs$(7,1)
 2800 REM   1........01........01........01........0
 2810 t$ = "1112   1112    112   1112   1112   112  "
 2820 obs$(0,0) = FN_convert(t$,log%)
 2830 obs$(0,1) = FN_convert(t$,log%+2)
 2840 t$ = "121212    1212    121212    12    1212  "
 2850 obs$(1,0) = FN_convert(t$,turtle%)
 2860 obs$(1,1) = FN_convert(t$,turtle%+2)
 2870 t$ = "1112   1112    112   1112   1112   112  "
 2880 obs$(2,0) = FN_convert(t$,log%)
 2890 obs$(2,1) = FN_convert(t$,log%+2)
 2900 t$ = "121212    1212    121212    12    1212  "
 2910 obs$(3,0) = FN_convert(t$,turtle%)
 2920 obs$(3,1) = FN_convert(t$,turtle%+2)
 2930 t$ = "1112         1112        1112      1112 "
 2940 obs$(4,0) = FN_convert(t$,lorry%+4)
 2950 obs$(4,1) = FN_convert(t$,lorry%+6)
 2960 t$ = " 12 12       12          12 12 12       "
 2970 obs$(5,0) = FN_convert(t$,car%+4)
 2980 obs$(5,1) = FN_convert(t$,car%+6)
 2990 t$ = "    12 12 12        12 12          12   "
 3000 obs$(6,0) = FN_convert(t$,car%)
 3010 obs$(6,1) = FN_convert(t$,car%+2)
 3020 t$ = "122        1222         1222            "
 3030 obs$(7,0) = FN_convert(t$,lorry%)
 3040 obs$(7,1) = FN_convert(t$,lorry%+2)
 3050 ENDPROC
 3060
 3070 REM ---------------------------------------------------------------------
 3080 DEF FN_convert(x$,n%)
 3090 result$ = ""
 3100 FOR i%=1 TO LEN(x$)
 3110   a% = VAL(MID$(x$,i%,1))
 3120   IF a%=0 THEN result$ = result$ + CHR$(32)
 3130   IF a%<>0 result$ = result$ +CHR$(a%+n%-1)
 3140 NEXT
 3150 = result$
 3160
 3170 REM ---------------------------------------------------------------------
 3180 DEF PROC_customChar
 3190 frog% = 210
 3200 VDU 23,frog%,   0,0,0,0,0,0,0,0
 3210 VDU 23,frog%,   0,7,13,15,15,119,127,63
 3220 VDU 23,frog%+1, 0,224,176,240,240,238,254,252
 3230 VDU 23,frog%+2, 111,255,255,255,127,61,254,0
 3240 VDU 23,frog%+3, 246,255,255,255,254,188,127,0
 3250 REM Jumping frog
 3260 VDU 23,frog%+4, 168,112,96,70,75,79,111,103
 3270 VDU 23,frog%+5, 21,14,6,98,210,242,246,230
 3280 VDU 23,frog%+6, 119,63,63,31,15,15,31,31
 3290 VDU 23,frog%+7, 238,254,252,248,240,240,248,248
 3300 VDU 23,frog%+8, 198,60,62,127,127,62,60,198
 3310 VDU 23,frog%+9, 99,60,124,254,254,124,60,99
 3320 REM Nested frog
 3330 VDU 23,frog%+10, 7,13,7,15,63,127,63,123
 3340 VDU 23,frog%+11, 224,176,224,240,252,254,252,222
 3350 REM Dead
 3360 dead% = frog%+12: REM 222
 3370 VDU 23,dead%,   3,12,16,32,72,68,130,129
 3380 VDU 23,dead%+1, 192,48,8,4,18,34,65,129
 3390 VDU 23,dead%+2, 129,130,68,72,32,16,12,3
 3400 VDU 23,dead%+3, 129,65,34,18,4,8,48,192
 3410 turtle% = dead%+4: REM 226
 3420 VDU 23,turtle%,   0,0,192,120,23,63,127,127
 3430 VDU 23,turtle%+1, 0,0,14,60,208,224,248,246
 3440 VDU 23,turtle%+2, 127,127,127,127,63,23,120,192
 3450 VDU 23,turtle%+3, 255,255,246,248,224,208,60,14
 3460 log% = turtle%+4  :REM 232
 3470 VDU 23,log%,   0,127,127,255,255,255,255,255
 3480 VDU 23,log%+1, 0,188,250,250,251,241,241,241
 3490 VDU 23,log%+2, 255,255,255,255,255,255,127,119
 3500 VDU 23,log%+3, 241,241,241,241,251,250,250,252
 3510 car% = log%+4  : REM 236
 3520 VDU 23,car%,   0,0,0,127,185,247,247,247
 3530 VDU 23,car%+1, 0,0,0,254,199,255,253,253
 3540 VDU 23,car%+2, 247,247,247,247,247,185,127,0
 3550 VDU 23,car%+3, 253,253,253,253,255,199,254,0
 3560 VDU 23,car%+4, 0,0,0,127,227,255,191,191
 3570 VDU 23,car%+5, 0,0,0,254,157,239,239,239
 3580 VDU 23,car%+6, 191,191,191,191,255,227,127,0
 3590 VDU 23,car%+7, 239,239,239,239,239,157,254,0
 3600 lorry% = car%+8 :REM 244
 3610 VDU 23,lorry%,   0,127,167,175,239,239,239,255
 3620 VDU 23,lorry%+1, 0,127,255,255,255,255,255,255
 3630 VDU 23,lorry%+2, 239,239,239,239,175,167,127,0
 3640 VDU 23,lorry%+3, 255,255,255,255,255,255,127,0
 3650 VDU 23,lorry%+4, 0,254,255,255,255,255,255,255
 3660 VDU 23,lorry%+5, 0,254,229,245,247,247,247,255
 3670 VDU 23,lorry%+6, 255,255,255,255,255,255,254,0
 3680 VDU 23,lorry%+7, 247,247,247,247,245,229,254,0
 3690 block% = lorry%+8  :REM 252
 3700 VDU 23,block%, 85,170,85,170,85,170,85,170
 3710 line% = block%+1   :REM 253
 3720 VDU 23,line%,  0,0,0,0,255,0,0,0
 3730 ENDPROC
 3740
 3750 REM ---------------------------------------------------------------------
 3760 DEF PROC_intro
 3770 LOCAL b$,i,n
 3780 DIM a$(11)
 3790 a$(0) = "                     @@@@@"
 3800 a$(1) = "##### ####   ###   #@@##   ##### ####"
 3810 a$(2) = "##    ##  # ##  # ##@@ @@@ ##    ##  #"
 3820 a$(3) = "####  ##### ##  # ##@@##@@ ####  #####"
 3830 a$(4) = "##    ## #  ##  # ## @@@@@ ##    ## #"
 3840 a$(5) = "##    ##  #  ###   #####   ##### ##  #"
 3850 a$(6) = " "
 3860 a$(7)  = "     ####    @@@@@   ####   ##  ##"
 3870 a$(8)  = "    ##  ##  @@      ##  ##  ### ##"
 3880 a$(9)  = "    ######  @@ @@@  ##  ##  ## ###"
 3890 a$(10) = "    ##  ##  @@  @@  ##  ##  ##  ##"
 3900 a$(11) = "    ##  ##   @@@@@   ####   ##   #"
 3910 CLS
 3920 PRINT: PRINT: PRINT: PRINT
 3930 FOR n=0 TO 11
 3940   COLOUR 128: PRINT " ";
 3950   FOR i=1 TO LEN(a$(n))
 3960     IF MID$(a$(n),i,1)="#" THEN COLOUR 128+Green2%: PRINT " ";
 3970     IF MID$(a$(n),i,1)="@" THEN COLOUR 128+Red2%: PRINT " ";
 3980     IF MID$(a$(n),i,1)=" " THEN COLOUR 128: PRINT " ";
 3990   NEXT
 4000   PRINT
 4010 NEXT
 4020 COLOUR Blue2%: COLOUR 128: PRINT TAB(36);machine$;
 4030 PRINT: PRINT
 4040 COLOUR White%
 4050 PRINT TAB(8);"USE CURSOR KEYS TO MOVE"
 4060 PRINT TAB(8);"  UP/DOWN/LEFT/RIGHT"
 4070 COLOUR Grey%
 4080 k = INKEY(1000)
 4090 ENDPROC
 4100 REM
 4110 REM ---------------------------------------------------------------------
 4120 DEF PROC_initGame
 4130 LOCAL i%
 4140 REM Reset game variables
 4150 row% = 10: col% = 18: r% = 0: c% = 0
 4160 movelorry% = 1
 4170 play% = TRUE: gameover% = FALSE: cloop% = 0
 4180 lives% = 5: nested% = 0: collided%= 0
 4190 FOR i%=0 TO 4: nest%(i%) = 0: NEXT
 4200 score% = 0: tleft%= 200
 4210 REM Main screen
 4220 COLOUR 128: CLS
 4230 PROC_printHeader
 4240 REM Middle and bottom green strips
 4250 COLOUR Green%+128
 4260 PRINT TAB(0,10);
 4270 FOR i%=1 TO 80: PRINT " "; :NEXT
 4280 PRINT TAB(0,23);
 4290 FOR i%=1 TO 80: PRINT " "; :NEXT
 4300 PRINT TAB(0,0);
 4310 REM Road + markings
 4320 COLOUR White%: COLOUR 128
 4330 PRINT TAB(0,17);
 4340 FOR i%=1 TO 40
 4350   PRINT CHR$(line%);
 4360 NEXT
 4370 FOR i%=1 TO 5
 4380   PRINT TAB(i%*7-2,14);CHR$(line%)
 4390   PRINT TAB(i%*7-2,20);CHR$(line%)
 4400 NEXT
 4410 ENDPROC
 4420
 4430 REM ---------------------------------------------------------------------
 4440 DEF PROC_printHeader
 4450 LOCAL i%
 4460 COLOUR Green%+128
 4470 PRINT TAB(0,0);
 4480 FOR i%=1 TO 80: PRINT " "; :NEXT
 4490 COLOUR Blue%+128
 4500 FOR i%=0 TO 4
 4510   IF nest%(i%) THEN PRINT TAB(ncol%(i%),1);CHR$(frog%+10)+CHR$(frog%+11)
 4520   IF nest%(i%)=0 PRINT TAB(ncol%(i%),1);"  "
 4530 NEXT
 4540 COLOUR Black%: COLOUR Green%+128
 4550 PRINT TAB(0,0);"HIGH ";hiscore%;
 4560 PRINT TAB(11,0);"SCORE ";score%;
 4570 PRINT TAB(23,0);"TIME ";tleft%;
 4580 PRINT TAB(33,0);"LIVES ";lives%;
 4590 ENDPROC
 4600
 4610 REM ---------------------------------------------------------------------
 4620 DEF PROC_initialise
 4630 machine$ = FN_whichMachine
 4640 IF machine$="SDL" THEN MODE 17
 4650 IF machine$="BBC32" THEN MODE 4
 4660 IF machine$="Agon" THEN MODE 2
 4670 IF machine$="emu" THEN MODE 8
 4680 VDU 23, 0, 10, 32 : REM Switch OFF the cursor
 4690 REM Colours
 4700 Black%=0: Red%=1: Green%=2: Yellow%=3: Blue%=4: Magenta%=5: Cyan%=6 :Grey%=7
 4710 Black2%=8: Red2%=9: Green2%=10: Yellow2%=11: Blue2%=12: Magenta2%=13: Cyan2%=14: White%=15
 4720 REM A few more (out of 64) colours on AGON light
 4730 DarkGreen%=17: Purple%=27: Brown%=42: Orange%=54
 4740 IF machine$="Agon" OR machine$="emu" THEN Green% = 32
 4750 ENDPROC
 4760 REM
 4770 REM ---------------------------------------------------------------------
 4780 DEF FN_whichMachine
 4790 LOCAL mach$
 4800 IF HIMEM<=31744 THEN mach$ = "BBC32": = mach$
 4810 IF HIMEM<>65280 THEN mach$ = "SDL": = mach$
 4820 IF GET(128)=12 THEN mach$="Agon" ELSE mach$="emu"
 4830 = mach$
 4840 REM
 4850 REM ---------------------------------------------------------------------
 4860 DEF FN_playAgain
 4870 LOCAL i
 4880 a$ = ""
 4890 FOR i=1 TO 21: a$ = a$+CHR$(block%): NEXT
 4900 COLOUR Red%
 4910 FOR i=7 TO 19: PRINT TAB(9,i);a$: NEXT
 4920 FOR i=8 TO 18: PRINT TAB(10,i);"                   ": NEXT
 4930 PRINT TAB(10,9);" G A M E   O V E R "
 4940 IF gameover%=-1 THEN PROC_tuneGameOver
 4950 IF gameover%=1 THEN PROC_happyTune
 4960 COLOUR White%
 4970 IF score%>hiscore% THEN hiscore% = score%
 4980 PRINT TAB(10,12);" SCORE:     ";score%
 4990 PRINT TAB(10,14);" HIGH SCORE:";hiscore%
 5000 PRINT TAB(10,17);" Play again? [Y/N] "
 5010 answer = FALSE
 5020 REPEAT
 5030   a$ = INKEY$(0)
 5040 UNTIL a$="Y" OR a$="y" OR a$="N" OR a$="n"
 5050 IF a$="Y" OR a$="y" THEN answer = TRUE
 5060 = answer
 5070 REM
 5080 REM ---------------------------------------------------------------------
 5090 REM PLAY GAME OVER TUNE
 5100 DEF PROC_tuneGameOver
 5110 PROC_playSound(52,1)
 5120 PROC_playSound(48,1)
 5130 PROC_playSound(44,1)
 5140 PROC_playSound(36,3)
 5150 PROC_wait(200)
 5160 ENDPROC
 5170 REM
 5180 REM ---------------------------------------------------------------------
 5190 DEF PROC_playSound(f%,d%)
 5200 LOCAL i%
 5210 FOR i%=0 TO 7
 5220   SOUND 1, -8+i%, f%, d%
 5230   SOUND 2, -8+i%, f%+4, d%
 5240 NEXT
 5250 ENDPROC
 5260 REM
 5270 REM ---------------------------------------------------------------------
 5280 DEF PROC_soundDead
 5290 LOCAL v%
 5300 FOR v%=8 TO 0 STEP -1
 5310   SOUND 2,-v%,20+v%*10,2
 5320 NEXT
 5330 ENDPROC
 5340
 5350 REM ---------------------------------------------------------------------
 5360 DEF PROC_soundBeast
 5370 LOCAL f
 5380 FOR f=1 TO 14 STEP 2
 5390   SOUND 1,-f,5+f,1
 5400 NEXT
 5410 FOR f=15 TO 1 STEP -1
 5420   SOUND 1,-f,5+f,1
 5430 NEXT
 5440 ENDPROC
 5450
 5460 REM ---------------------------------------------------------------------
 5470 DEF PROC_soundLevitate
 5480 LOCAL f%
 5490 FOR f%=5 TO 14
 5500   SOUND 1,-15+f%,50+f%,1
 5510 NEXT
 5520 FOR f%=1 TO 15
 5530   SOUND 1,-15+f%,40+f%,1
 5540 NEXT
 5550 ENDPROC
 5560
 5570 REM ---------------------------------------------------------------------
 5580 DEF PROC_soundScore
 5590 SOUND 1,-10,100,2
 5600 SOUND 1,-7,150,2
 5610 SOUND 1,-5,120,1
 5620 ENDPROC
 5630
 5640 REM ---------------------------------------------------------------------
 5650 DEF PROC_happyTune
 5660 LOCAL i%, j%, k%
 5670 FOR j%=1 TO 2
 5680   FOR i%=0 TO 8
 5690     SOUND 1,-10,happy%(i%), 3
 5700   NEXT
 5710   k% = INKEY(170)
 5720 NEXT
 5730 ENDPROC
 5740
 5750 REM ---------------------------------------------------------------------
 5760 DEF PROC_wait(cs%)
 5770 t% = TIME+cs%
 5780 REPEAT UNTIL TIME > t%
 5790 ENDPROC
 5800 REM
 5810
