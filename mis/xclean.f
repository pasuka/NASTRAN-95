      SUBROUTINE XCLEAN
C
      IMPLICIT INTEGER (A-Z)
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF
      DIMENSION       NCLEAN( 2),DDBN ( 1),DFNU ( 1),FCUM ( 1),
     2                FCUS  ( 1),FDBN ( 1),FEQU ( 1),FILE ( 1),
     2                FKND  ( 1),FMAT ( 1),FNTU ( 1),FPUN ( 1),
     3                FON   ( 1),FORD ( 1),MINP ( 1),MLSN ( 1),
     4                MOUT  ( 1),MSCR ( 1),SAL  ( 1),SDBN ( 1),
     5                SNTU  ( 1),SORD ( 1)
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25
      COMMON /XMSSG / UFM,UWM,UIM,SFM
      COMMON /SYSTEM/ IBUFSZ,OUTTAP
      COMMON /XFIAT / FIAT(7)
      COMMON /XFIST / FIST
      COMMON /XDPL  / DPD(6)
      COMMON /XSFA1 / MD(401),SOS(1501),COMM(20),XF1AT(5)
      EQUIVALENCE             (DPD  (1),DNAF    ),(DPD  (2),DMXLG   ),
     1    (DPD  (3),DCULG   ),(DPD  (4),DDBN (1)),(DPD  (6),DFNU(1) ),
     2    (FIAT (1),FUNLG   ),(FIAT (2),FMXLG   ),(FIAT (3),FCULG   ),
     3    (FIAT (4),FEQU (1)),(FIAT (4),FILE (1)),(FIAT (4),FORD (1)),
     4    (FIAT (5),FDBN (1)),(FIAT (7),FMAT (1)),(MD   (1),MLGN    ),
     5    (MD   (2),MLSN (1)),(MD   (3),MINP (1)),(MD   (4),MOUT (1)),
     6    (MD   (5),MSCR (1)),(SOS  (1),SLGN    ),(SOS  (2),SDBN (1)),
     7    (SOS  (4),SAL  (1)),(SOS  (4),SNTU (1)),(SOS  (4),SORD (1)),
     8    (XF1AT(1),FNTU (1)),(XF1AT(1),FON  (1)),(XF1AT(2),FPUN (1)),
     9    (XF1AT(3),FCUM (1)),(XF1AT(4),FCUS (1)),(XF1AT(5),FKND (1))
      EQUIVALENCE             (COMM (1),ALMSK   ),(COMM (2),APNDMK  ),
     1    (COMM (3),CURSNO  ),(COMM (4),ENTN1   ),(COMM (5),ENTN2   ),
     2    (COMM (6),ENTN3   ),(COMM (7),ENTN4   ),(COMM (8),FLAG    ),
     3    (COMM (9),FNX     ),(COMM(10),LMSK    ),(COMM(11),LXMSK   ),
     4    (COMM(12),MACSFT  ),(COMM(13),RMSK    ),(COMM(14),RXMSK   ),
     5    (COMM(15),S       ),(COMM(16),SCORNT  ),(COMM(17),TAPMSK  ),
     6    (COMM(18),THCRMK  ),(COMM(19),ZAP     )
      DATA  NCLEAN / 4HXCLE,4HAN  /
C
C     ENTRY SIZE NUMBERS,  1=FIAT, 2=SOS, 3=MD
C
      IFAIL  = 0
      ENTN1X = ENTN1 - 1
      ENTN1Y = ENTN1*2
      LMT1   = FUNLG*ENTN1
      LMT2   = LMT1 + 1
      LMT3   = FCULG*ENTN1
      FLAG   = 0
      ICURSN = LSHIFT(CURSNO,16)
C
C     MERGE FIAT BY REPLACING ANY UNIQUE FILES WITH MATCHED CURRENT
C     FILES ONLY CURRENT TAIL  AND  EXCEPT EQU FILES
C
      IF (FUNLG .EQ. FCULG) GO TO 170
      ASSIGN 170 TO ISW
  100 DO 160 I = LMT2,LMT3,ENTN1
      TRIAL = ANDF(RMSK,FILE(I))
      IF (TRIAL .EQ. ZAP) GO TO 160
C
C     ERASE SCRATCH AND LTU EXPIRED FILES FROM CURRENT TAIL
C
      K = ANDF(LMSK,FORD(I))
      IF (K.EQ.LMSK .OR. (ICURSN.GT.K .AND. K.NE.0 .AND. FEQU(I).GT.0))
     1    GO TO 152
      DO 130 J = 1,LMT1,ENTN1
      IF (TRIAL .NE. ANDF(RMSK,FILE(J))) GO TO 130
      IF (FEQU(J)) 160,140,140
  130 CONTINUE
      GO TO 160
  140 K = ANDF(LMSK,FORD(J))
      IF (K.NE.LMSK .AND. ICURSN.LE.K) GO TO 160
      LMT4 = I + ENTN1X
      DO 150 K = I,LMT4
      FILE(J) = FILE(K)
      FILE(K) = 0
      FNTU(J) = FNTU(K)
  150 J = J + 1
      J = J - ENTN1
      GO TO 156
  152 LMT4 = I + ENTN1X
      DO 154 K = I,LMT4
  154 FILE(K) = 0
      J = I
  156 CALL XPOLCK (FDBN(J),FDBN(J+1),IK,L)
      IF (FEQU(J) .LT. 0) FLAG = -1
      IF (IK .EQ. 0) GO TO 160
      DDBN(L  ) = 0
      DDBN(L+1) = 0
  160 CONTINUE
      GO TO ISW, (170,310)
C
C     REGENERATE ALL NTU VALUES (AND LTU IF EMPTY) IN FIAT BY SCANNING
C     SOS DELETE FIAT ENTRY IF NOT FOUND, OR A SCRATCH
C
  170 LMT4 = MLGN*ENTN3
      LMT2 = LMT1 + 1
C
C     FIAT LOOP
C
      DO 250 I = 1,LMT3,ENTN1
      IF (ANDF(LMSK,FORD(I)) .EQ. LMSK) GO TO 220
      TRIAL = FDBN(I)
      IF (TRIAL .EQ. 0) GO TO 250
C
C     SOS LOOP - BY MODULE
C
      LMT6 = 0
      DO 200 J = 1,LMT4,ENTN3
      LMT5 = LMT6 + 1
      LMTI = LMT6 + MINP(J)*ENTN2
      LMT6 = LMT6 +(MINP(J) + MOUT(J) + MSCR(J))*ENTN2
C
C     SOS LOOP - BY FILE WITHIN MODULE
C
      DO 200 K = LMT5,LMT6,ENTN2
      IF (TRIAL.NE.SDBN(K) .OR. FDBN(I+1).NE.SDBN(K+1)) GO TO 200
      IF (ANDF(RMSK,FILE(I)) .EQ. ZAP) GO TO 190
      IF (K.GT.LMTI .OR. FMAT(I).NE.0 .OR. FMAT(I+1).NE.0 .OR.
     1    FMAT(I+2).NE.0) GO TO 190
      IF (ENTN1.EQ.11 .AND. (FMAT(I+5).NE.0 .OR. FMAT(I+6).NE.0 .OR.
     1    FMAT(I+7).NE.0)) GO TO 190
C
C     IF FIAT ENTRY IS INPUT WITH ZERO TRAILERS - PURGE IT
C
      IF (I .LE. LMT1) GO TO 185
      LMTI = 0
      FILE(I) = ORF(FILE(I),ZAP)
      GO TO 210
C
C     PURGE FILE --PUT ENTRY AT END OF FIAT
C
  185 IF (FCULG .EQ. FMXLG) GO TO 186
      NFCULG = FCULG*ENTN1 + 1
      IFAIL  = 0
      FCULG  = FCULG + 1
      FILE(NFCULG  ) = ORF(FILE(I),ZAP)
      FDBN(NFCULG  ) = FDBN(I  )
      FDBN(NFCULG+1) = FDBN(I+1)
      GO TO 210
C
C     TRY TO PACK FIAT FOR MORE SPACE
C
  186 IF (IFAIL .EQ. 1) GO TO 900
      IFAIL = 1
      ASSIGN 170 TO IHOP
      GO TO 310
  190 FNTU(I) = ANDF(RMSK,MLSN(J))
      IF (ANDF(LMSK,FORD(I)) .EQ. 0)
     1    FORD(I) = ORF(FORD(I),ANDF(LMSK,SORD(K)))
      GO TO 250
  200 CONTINUE
C
C     DELETE FIAT ENTRY (UNLESS LTU YET TO COME)
C
C     HOLD FILES UNTIL LARGEST LTU OF EQUIVALENCED GROUP EXPIRES
C
      IF (FEQU(I).GE.0 .AND. ICURSN.GT.ANDF(LMSK,FORD(I))) GO TO 210
      FNTU(I) = RSHIFT(ANDF(LMSK,FORD(I)),16)
      GO TO 250
  210 CALL XPOLCK (FDBN(I),FDBN(I+1),IK,L)
      IF (IK .EQ. 0) GO TO 215
      DDBN(L  ) = 0
      DDBN(L+1) = 0
  215 IF (LMTI .EQ. 0) GO TO 250
  220 HOLD = ANDF(RXMSK,FILE(I))
      IF (FEQU(I) .LT. 0) FLAG = -1
      LMT6 = I + ENTN1X
      DO 230 K = I,LMT6
  230 FILE(K) = 0
      IF (I .GT. LMT1) GO TO 250
      FILE(I) = HOLD
      FLAG = -1
  250 CONTINUE
      LMT3 = FCULG*ENTN1
C
C     CHECK EQU FILES FOR BREAKING OF EQU
C
      IF (FUNLG .EQ. FCULG) RETURN
      DO 300 I = 1,LMT3,ENTN1
      IF (FEQU(I).GE.0 .OR. ANDF(LMSK,FORD(I)).GE.ICURSN) GO TO 300
      DO 290 J = 1,LMT3,ENTN1
      IF (FEQU(J) .GE. 0) GO TO 290
      IF (I .EQ. J) GO TO 290
      IF (ANDF(RMSK,FILE(I)) .EQ. ANDF(RMSK,FILE(J)) .AND.
     1    ICURSN.LE.ANDF(LMSK,FORD(J))) GO TO 300
C
  290 CONTINUE
      FEQU(I) = ANDF(ALMSK,FEQU(I))
      FLAG = -1
  300 CONTINUE
C
C     IF BREAK HAS OCCURED, REPEAT FIAT MERGE
C
      ASSIGN 451 TO IHOP
      IF (FLAG .NE. -1) GO TO 310
      ASSIGN 310 TO ISW
      GO TO 100
C
C     CLOSE UP FILES(IF ANY) BELOW UNIQUE LENGTH - RESET FCULG
C
  310 LMT7 = LMT3 - ENTN1X
      LMT3 = LMT7 - 1
  330 IF (LMT7 .LT. LMT2) GO TO 450
      IF (FDBN(LMT7) .NE. 0) GO TO 350
      LMT7 = LMT7 - ENTN1
      GO TO 420
  350 DO 390 I = LMT2,LMT3,ENTN1
      IF (FDBN(I) .NE. 0) GO TO 390
      LMT4 = I + ENTN1X
      DO 380 K = I,LMT4
      FILE(K) = FILE(LMT7)
      FILE(LMT7) = 0
      FNTU(K) = FNTU(LMT7)
  380 LMT7 = LMT7 + 1
      GO TO 410
  390 CONTINUE
      GO TO 450
  410 LMT7 = LMT7  - ENTN1Y
      LMT2 = I + ENTN1
  420 LMT3 = LMT3  - ENTN1
      FCULG= FCULG - 1
      GO TO 330
C
C     RESET ANY NECESSARY OFF SWITCHES
C
  450 GO TO IHOP, (451,170)
  451 IF (FUNLG .EQ. FCULG) RETURN
      LMT2 = LMT1 + 1
      LMT3 = FCULG*ENTN1
      DO 480 I = LMT2,LMT3,ENTN1
      IF (FEQU(I) .LT. 0) GO TO 480
      TRIAL = ANDF(RMSK,FILE(I))
      IF (TRIAL .EQ. RMSK) GO TO 480
      IFORDI = ANDF(LMSK,FORD(I))
      DO 460 J = 1,LMT3,ENTN1
      IF (TRIAL .NE. ANDF(RMSK,FILE(J))) GO TO 460
      IF (I .EQ. J) GO TO 460
      IF (ANDF(LMSK,FORD(J))-IFORDI) 452,460,454
  452 FON(J) = ORF(S,FON(J))
      GO TO 460
  454 FON(I) = ORF(S,FON(I))
  460 CONTINUE
  480 CONTINUE
      RETURN
C
  900 WRITE  (OUTTAP,901) SFM
  901 FORMAT (A25,' 1021, FIAT OVERFLOW.')
      CALL MESAGE (-37,0,NCLEAN)
      RETURN
      END
