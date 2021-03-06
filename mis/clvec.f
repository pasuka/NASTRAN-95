      SUBROUTINE CLVEC (LAMD,NVECT,PHIDL,IH,IBUF,IBUF1)
C*****
C     CLVEC CACLULATES THE LEFT EIGENVECTORS FOR THE DETERMINANT AND
C     UPPER HESSENBERG APPROACHES TO THE COMPLEX EIGENVALUE PROBLEM
C*****
      DOUBLE PRECISION DI1,DNROW,DZ(1),LAMBDA,MINDIA
      INTEGER CLSREW,FLAG,PHIDL,RDREW,SWITCH,SYSBUF
      INTEGER FILEK,FILEM,FILEB,SCR
      DIMENSION NAME(2),BUF(6),IH(7)
      COMMON / CDCMPX / DUMDCP(30),MINDIA
      COMMON / ZZZZZZ / Z(1)
      COMMON / CINVPX / FILEK(7),FILEM(7),FILEB(7),DUM(15),SCR(11)
      COMMON / CINVXX / LAMBDA(2),SWITCH
      COMMON / NAMES  / RD,RDREW,WRT,WRTREW,CLSREW,NOREW
      COMMON / PACKX  / IT1,IT2,II,JJ,INC
      COMMON / SYSTEM / SYSBUF
      EQUIVALENCE (NROW,FILEK(3))
      EQUIVALENCE (DZ(1),Z(1))
      DATA NAME   / 4HCLVE,4HC    /
C*****
C     INITIALIZATION
C*****
      IBUF2 = IBUF1 - SYSBUF
      IF (FILEB(1) .LT. 0) FILEB(1) = 0
      IF (FILEB(6) .EQ. 0) FILEB(1) = 0
      DO 50 I=1,11
      SCR(I) = 300 + I
   50 CONTINUE
      SWITCH = -204
      FNROW = FLOAT(NROW)
      DNROW = FNROW
C*****
C     OPEN SORTED EIGENVALUE FILE
C*****
      CALL GOPEN (LAMD,Z(IBUF),RDREW)
      CALL SKPREC (LAMD,1)
C*****
C     LOOP TO CALCULATE LEFT EIGENVECTORS
C*****
      DO 1000 I=1,NVECT
C READ EIGENVALUE
      CALL READ(*9002,*9003,LAMD,BUF,6,0,FLAG)
      LAMBDA(1) = BUF(3)
      LAMBDA(2) = BUF(4)
C CREATE DYNAMIC MATRIX
  100 CALL CINVP1
C DECOMPOSE DYNAMIC MATRIX
      CALL CINVP2(*900)
C BUILD LOAD FOR FBS
      FI1 = FLOAT(I-1)
      DI1 = FI1
      J2 = 2*NROW
      DO 200 J=1,J2,2
      F = FLOAT((J+1)/2)
      DZ(J) = MINDIA/(1.0D0 + (1.0D0 - F/DNROW)*DI1)
      DZ(J+1) = 0.0D0
  200 CONTINUE
C PERFORM FORWARD-BACKWARD SUBSTITUTION - U(T)*L(T)*PHI
      CALL CDIFBS (DZ(1),Z(IBUF2))
C NORMALIZE LEFT EIGENVECTOR
      CALL CNORM1 (DZ(1),NROW)
C PACK LEFT EIGENVECTOR ONTO PHIDL
      IT1 = 4
      IT2 = 3
      II = 1
      JJ = NROW
      INC = 1
      CALL PACK (DZ(1),PHIDL,IH)
      GO TO 1000
C ADJUST CURRENT EIGENVALUE
  900 LAMBDA(1) = 1.01D0*LAMBDA(1)
      LAMBDA(2) = 1.01D0*LAMBDA(2)
      GO TO 100
C END OF LOOP
 1000 CONTINUE
      CALL CLOSE (LAMD,CLSREW)
      RETURN
C*****
C     ERRORS
C*****
 9002 N = -2
      GO TO 9999
 9003 N = -3
 9999 CALL MESAGE (N,LAMD,NAME)
      RETURN
      END
