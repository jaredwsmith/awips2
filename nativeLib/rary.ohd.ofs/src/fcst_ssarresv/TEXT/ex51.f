C MEMBER EX51
C-----------------------------------------------------------------------
C
C@PROCESS LVL(77)
C
      SUBROUTINE EX51(PO,CO,D,IDPT,WK)
C
C  DESC EXECUTION ROUTINE FOR 'SSARRESV' -
C  STREAMFLOW SYNTHESIS AND RESERVOIR REGULATION MODEL
C
C  ROUTINE FOR EXECUTING THE 'SSARRESV' OPERATION - #51 - THE SSARR
C  RESERVOIR OPERATION.
C
C      PO   - ARRAY HOLDING PARAMETERS FOR THIS OPERATION AS DEFINED IN
C             PIN51 ROUTINE.
C      CO   - CARRYOVER FOR THE VARIOUS SCHEMES AND UTILITIES DEFINED
C             IN THIS OPERATION DEFINITION.
C      D    - ARRAY HOLDING TIME-SERIES DATA FOR THE OPERATION.
C      IDPT - ARRAY HOLDING STARTING LOCATIONS OF ALL TIME-SERIES USED
C             IN THIS OPERATION.
C      WK   - WORK ARRAY FOR VARIOUS TASKS IN THE OPERATION. THE AMOUNT
C             OF SPACE NEEDED IS DETERMINED AT PIN TIME. ONE OF THE
C             ROUTINES IN THE EXECUTION PHASE WILL GIVE OUT THE WORK
C             SPACE AND NOTE THE LOCATION FOR PROGRAM USE.
C-----------------------------------------------------------------------
C  WRITTEN BY - KUANG HSU - HRL - OCTOBER 1994
C-----------------------------------------------------------------------
C
      INCLUDE 'common/fdbug'
      INCLUDE 'common/ionum'
      INCLUDE 'common/sarr51'
      INCLUDE 'common/fengmt'
      INCLUDE 'common/lts51'
      INCLUDE 'common/unit51'
      INCLUDE 'common/xco51'
C
      REAL*8 SNAME
      DIMENSION PO(*),CO(*),D(*),IDPT(*),WK(*),LOCWS(5)
      DIMENSION ERRD(750),LOCERR(750)
      DIMENSION AUNIT(2),SUNUM(2)
      REAL*8 RESTYP(4)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_ssarresv/RCS/ex51.f,v $
     . $',                                                             '
     .$Id: ex51.f,v 1.4 2000/07/28 12:49:22 page Exp $
     . $' /
C    ===================================================================
C
C
      DATA RESTYP/8H'NOT A' ,8H'UPPER' ,8H'LOWER' ,8H'3-VAR' /
      DATA SUNUM/1541.01,1511.01/
      DATA BLANK/4H    /
      DATA AUNIT/4H FT.,4H  M./
C
      DATA SNAME/8HSSARRESV/,NUMOP/51/
C
C-------------------------------------------
C  FIRST SET DEBUG LEVEL
C
      IBUG = 0
      CALL FPRBUG(SNAME,1,NUMOP,IPBUG)
      IF (ITRACE .GT. 0) IBUG = 1
      IF (IPBUG  .GT. 0) IBUG = 2
C
C  INITIALIZE VARIOUS VARIABLES FOR LATER USE IN ALL SUBSEQUENT ROUTINES
C
C        COMPUTE FLOW-TO-STORAGE CONVERSION FACTOR.
C        ENGLISH UNITS
C        ONE DAY-CFS IS 86400./43560. ACREFEET
      DCF = 86400./43560.
C
C        METRIC SYSTEM
C        ONE DAY-CUMEC IS 86.4 THOUSAND-CUBIC-METERS
      IF(METSAR.EQ.1) DCF = 86.4
C
      CALL XETM51(PO)
C
      CALL XNIT51(PO)
C
C  SET UP LOCATIONS FOR ALL THE NEEDED WORK SPACE
C  LOCWS IS ARRAY HOLDING POINTERS FOR REQUIRED WORK SPACE
C
      CALL XWKS51(PO,CO,D,WK,WK,IDPT,LOCWS)
C
C-----------------------------------------------------------------
C
C TO CHANGE ANY OBSEVED ELEVATIONS TO MISSING IF BELOW LOWEST
C   ELEVEATION DEFINED.  ONLY CHANGED TEMPORARILY, IE., SET
C   TO MISSING FOR THIS OPERATION BUT SET BACK TO ORIGINAL
C   OBS BEFORE EXITING.
C
C VARIABLES USED
C ELVMIN - LOWEST ELEV DEFINED
C LIOEL - POINTER TO IDPTR ARRAY FOR POOL ELEV TIME SERIES
C LDOEL - POINTER TO D ARRAY FOR POOL ELEV TS
C NERRD  - NUMBER OF ERRONOUS POOL OBS THAT WERE CHANGED
C ERRD   - ARRAY CONTAINING ORIGINAL ERRONUS POOL OBS
C LOCERR - ARRAY OF POINTERS TO LOCATION IN D ARRAY FOR EACH ERRD
C
C GO THRU TIME SERIES IN PO ARRAY TO SEE IF PELV DEFINED
C   IF NOT SKIP OUT OF THIS LOGIC
C   IF SO, THEN THE SEQUENCE NUMBER OF THIS TIME SERIES
C   IS THE POINTER NUMBER FOR IDPT ARRAY
C
      NERRD=0
C  CONVERT MEAN FLOW FROM CFSD TO CFST OR VICE VERSA
C  CONVERT MEAN FLOW FROM CMSD TO CMST OR VICE VERSA
C
      CONVQM=CONVQ*NTIM24
C
      DO 1400 II=1,NRES
      IRES=II
C
      CALL TSPT51(PO,CO,D,LOCWS,IDPT)
C
C  SET DATA IN ALL TIME SERIES TO INPUT TEMPORARILY
      IF(LDOQM.GT.0) CALL DMTE51(D,LDOQM,NUM,CONVQM)
      IF(METSAR.EQ.1) GO TO 1410
      IF(IRES.GT.1) GO TO 1405
      IF(LDQI1.GT.0) CALL DMTE51(D,LDQI1,NUM,CONVQ)
      IF(LDQI2.GT.0) CALL DMTE51(D,LDQI2,NUM,CONVQ)
 1405 CONTINUE
      IF(LDOQO.GT.0) CALL DMTE51(D,LDOQO,NUM,CONVQ)
      IF(LDOEL.GT.0) CALL DMTE51(D,LDOEL,NUM,CONVL)
      IF(LDQL1.GT.0) CALL DMTE51(D,LDQL1,NUM,CONVQ)
      IF(LDQL2.GT.0) CALL DMTE51(D,LDQL2,NUM,CONVQ)
 1410 CONTINUE
C
C  DEBUG OUTPUT OF INFLOW TIME-SERIES (AT PERIOD START AND END)
C
      IF (IRES.GE.2) GO TO 1450
C
C  THE INSTANTANEOUS INFLOW TIME SERIES IS USED,
C  USE THE FIRST VALUE AS CARRYOVER
C
      IF(LDQI1.GT.0) THEN
        CO(1) = D(LDQI1)
      ENDIF
C
      IF (IBUG.LT.2) GO TO 1450
      IF(LDQI1.LE.0) GO TO 1440
      WRITE(IODBUG,1610) (D(LDQI1+I-1),I=1,NUM)
 1610 FORMAT(/'   ** INST. INFLOW TIME-SERIES AT PERIOD START:',
     & //,(8F10.1))
 1440 WRITE(IODBUG,1620) (D(LDQI2+I-1),I=1,NUM)
 1620 FORMAT(/'   ** INST. INFLOW TIME-SERIES AT PERIOD END:',
     & //,(8f10.1))
 1450 CONTINUE
C
C      IF(LDOEL.LE.0 .OR. NRUN.LE.0) GO TO 1400
      IF(LDOEL.LE.0) GO TO 1400
C  SET UP POINTER FOR PO ARRAY
C  FIRST DETERMINE LOWSEST ELEV
C  BACKWATER RESERVOIR START AT POSITION 10 IN PO ARRAY
C  NON-BACKWATER RESERVOIR START AT POSITION 11 IN PO ARRAY
C
      IPTX = NRES-IRES+10
      LPP = PO(IPTX)
      ISTYP = PO(LPP)
      IRTYP = ISTYP+1
      LPELST =  LPP+2
      ELVMIN = PO(LPELST)
C
      IDT = PO(LPOEL+3)
C      NPEL = NRUN*MINODT/IDT
      NPELX = NUM*MINODT/IDT
      LOCDEL=LDOEL+NPELX-1
      IF (IFMSNG(D(LOCDEL)).EQ.0) THEN
        NPEL = NPELX
        GO TO 1260
      ENDIF 
C
C  LOOP THRU THIS TIME SERIES AND CHECK IF ANY BELOW ELVMIN
C IF SO THEN
C 1. INCREMENT NERRD
C 2. STORE OBS IN ERRD
C 3. STORE D LOCATION IN LOCERR
C 4. SET OBS TO MSNG IN D ARRAY
C
      NPEL=0
      DO 1250 I=NPELX,1,-1
      LOCDEL=LOCDEL-1
      IF (IFMSNG(D(LOCDEL)).EQ.1) GO TO 1250
      NPEL=I-1
      GO TO 1260
1250  CONTINUE
      NPEL=NPELX
C
 1260 IF(NPEL.LE.0) GO TO 1400
      LOCDEL=LDOEL-1
      DO 1300 I=1,NPEL
      LOCDEL=LOCDEL+1
      IF (IFMSNG(D(LOCDEL)).EQ.1) GO TO 1300
      IF (D(LOCDEL).GE.ELVMIN) GO TO 1300
C OBS IS BELOW
      NERRD=NERRD+1
      ERRD(NERRD)=D(LOCDEL)
      LOCERR(NERRD)=LOCDEL
      D(LOCDEL)=-999.0
1300  CONTINUE
      IF (NERRD.LE.0) GO TO 1400
      WRITE(IODBUG,1630) RESTYP(IRTYP),
     1 (D(LDOEL+I-1),I=1,NPEL)
 1630 FORMAT(/'   ** OBSERVED POOL ELEVATION TIME-SERIES FOR ',A8,
     & 'BACKWATER RESERVOIR :'//,(8F10.2))
      WRITE(IPR,810) NERRD,ELVMIN,AUNIT(METRIC+1),(ERRD(I),I=1,NERRD)
      CALL WARN
 810  FORMAT(/10X,'**WARNING **',I3,' OBSERVED POOL ELEVATIONS WERE',
     1 ' BELOW MINIMUM ELEVATION OF',F7.1,A4
     2 /10X,'THESE OBSERVATIONS WILL BE IGNORED:'/(8F10.2))
1400  CONTINUE
C
      IF (IBUG.GE.2) WRITE(IODBUG,1650) (CO(I),I=1,NUMCOV)
 1650 FORMAT(/'   ** CARRYOVER VALUES AT START OF RUN :',
     & /1X,F10.1,2(F10.1,F10.2,F10.0,F12.2))
C
C  CALL COMPUTATIONAL LOOP SUPERVISOR (ACTUAL SIMULATION OCCURS WITHIN
C  CONTROL OF THAT ROUTINE.)
C
      CALL XQT51(PO,CO,D,WK,WK,IDPT,LOCWS)
C
C----------------------------------------------------------------
C SEE IF ANY POOL OBS WERE CHANGED
C IF SO RESTORE THEM TO BE ORIGINAL VALUES
C
      IF (NERRD.EQ.0) GO TO 2000
      DO 1900 I=1,NERRD
      D(LOCERR(I))=ERRD(I)
1900  CONTINUE
      IF (IBUG.LT.2 .OR. LDOEL.LE.0) GO TO 2000
      WRITE(IODBUG,1640) (D(LDOEL+I-1),I=1,NPEL)
1640  FORMAT(/'   ** POOL ELEVATION TIME SERIES RESTORED :'//,(8F10.2))
2000  CONTINUE
C
C-------------------------------------------------------------------
C  THAT'S IT. SIMPLE,HUH?
C
C
C  SET DATA IN ALL TIME SERIES TO METRIC UNITS
      DO 2400 II=1,NRES
      IRES=II
      CALL TSPT51(PO,CO,D,LOCWS,IDPT)
C  CONVERT STORAGE FROM ACRE-FEET OR THOUSAND-CUBIC-METERS TO CMSD
      IF(LDQM.GT.0) CALL DETM51(D,LDQM,NUM,CONVQM)
      IF(LDOQM.GT.0) CALL DETM51(D,LDOQM,NUM,CONVQM)
      IF(LDST.GT.0) CALL DETM51(D,LDST,NUM,CONVST)
      IF(LDBQIM.GT.0) CALL DETM51(D,LDBQIM,NUM,CONVQM)
      IF(METSAR.EQ.1) GO TO 2400
      IF(IRES.GT.1) GO TO 2405
      IF(LDQI1.GT.0) CALL DETM51(D,LDQI1,NUM,CONVQ)
      IF(LDQI2.GT.0) CALL DETM51(D,LDQI2,NUM,CONVQ)
 2405 CONTINUE
      IF(LDQO1.GT.0) CALL DETM51(D,LDQO1,NUM,CONVQ)
      IF(LDQO2.GT.0) CALL DETM51(D,LDQO2,NUM,CONVQ)
      IF(LDEL.GT.0) CALL DETM51(D,LDEL,NUM,CONVL)
      IF(LDOQO.GT.0) CALL DETM51(D,LDOQO,NUM,CONVQ)
      IF(LDOEL.GT.0) CALL DETM51(D,LDOEL,NUM,CONVL)
      IF(LDQL1.GT.0) CALL DETM51(D,LDQL1,NUM,CONVQ)
      IF(LDQL2.GT.0) CALL DETM51(D,LDQL2,NUM,CONVQ)
      IF(LDBQI1.GT.0) CALL DETM51(D,LDBQI1,NUM,CONVQ)
      IF(LDBQI2.GT.0) CALL DETM51(D,LDBQI2,NUM,CONVQ)
 2400 CONTINUE
 9000 IF (IBUG.GE.1) WRITE(IODBUG,1699)
 1699 FORMAT('    *** EXIT EX51 ***')
      RETURN
      END
