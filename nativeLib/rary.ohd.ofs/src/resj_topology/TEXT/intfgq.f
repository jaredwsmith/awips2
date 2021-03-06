C     MODULE INTFGQ
C     -----------------------------------------------------------------
      SUBROUTINE INTFGQ(RC_ID,TSTEP,STAGE,FLOW,JDAY,HOUR,HISTG)
C
C     ORIGINALLY CREATED AUG 2007
C        DARRIN SHARP, RIVERSIDE TECHNOLOGY
C
C     THIS SUBROUTINE IS A WRAPPER BETWEEN RES-J C++ CODE AND NWSRFS
C     FORTRAN.
C
      CHARACTER*8 RC_ID
      INTEGER TSTEP,JDAY,HOUR,ERR_FLAG,WARN_FLG,RCHNG
      REAL STAGE,FLOW,HISTG,CURVHI,CURVLO
      REAL HDATA(1),QDATA(1)
      REAL CARRYO(4)
      REAL RCID(2)

      INCLUDE 'common/frcfil'
      INCLUDE 'common/fratng'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source$
     . $',                                                             '
     .$Id$
     . $' /
C    ===================================================================
C

C     EFFECTIVELY CAST THE RC ID TO SOMETHING FSTGQ CAN USE
      READ (RC_ID,'(2A4)') RCID
C     FSTGQ EXPECTS ARRAY INPUT
      HDATA(1) = STAGE
C     INIT QDATA(1) TO 0 IN CASE EXECUTION DOES NOT MAKE IT THROUGH 
C     FSTGQ - FOR EXAMPLE, IN THE CASE WHERE THIS ROUTINE WAS
C     ENTERED THROUGH MCP
      QDATA(1) = 0
C
C     ERRORS AND WARNINGS ARE FLAGGED AND HANDLED IN FSTGQ       
C        
C     ARGUMENT LIST:
C     RCID - 8-CHAR RATING CURVE IDENTIFIER
C     ICONV - CONVERSION INDICATOR
C          =0, NO CONVERSION--RETURN INFO ABOUT RATING CURVE AND X-SECT
C          =1, CONVERT STAGE TO DISCHARGE
C          =2, CONVERT DISCHARGE TO STAGE
C     ITSPOS - LOCATION OF FIRST VALUE IN INPUT ARRAY TO BE CONVERTED
C     NVALS  - NUMBER OF VALUES TO BE CONVERTED
C     TSTEP  - TIME INTERVAL BETWEEN INPUT DATA VALUES
C     QDATA  - DISCHARGE ARRAY
C     HDATA  - STAGE ARRAY
C     LOCPTR - POINTER ARRAY FOR LOOP RATING CURVE PROGRAM
C     T1     - TIMING ARRAY FOR LOOP RATING CURVE PGM
C     CURVLO - LOWEST RATING CURVE STAGE
C     CURVHI - HIGHEST RATING CURVE STAGE
C     XSECLO - BOTTOM-MOST GIVEN X-SECTION ELEVATION
C     XSECUP - UPPER-MOST GIVEN X-SECTION ELEVATION
C     METHOD - METHOD OF CONVERSION
C           =0, SIMPL INTERPOLATION /EXTRAPOLATION OF RATING CURVE
C           =1, DYNAMIC LOOP
C     FLSTAG - FLOOD STAGE (M) WRT GAGE ZERO
C     NEEDEX - EXTENSION INDICATOR
C           =0, NO EXTENSION NECESSARY
C           =1, LOG-LOG EXTENSION USED
C           =2, HYDRAULIC EXT. AT UPPER END
C           =3, LOG-LOG LOWER END, HYDRAULIC UPPER END
C           =4, LINEAR EXTENSION USED
C           =5, LINEAR LOWER END, HYDRAULIC UPPER END
C           =6, LOOP RATING AT UPPER END
C           =7, LOG-LOG LOWER END, LOOP RATING UPPER END
C           =8, LINEAR LOWER END, LOOP RATING UPPER END
C     CARRYO - CARRYOVER ARRAY
C           1ST ELEMENT = PREVIOUS STAGE
C           2ND ELEMENT = PREVIOUS DISCHARGE
C           3RD ELEMENT = DQ (ICONV=1);  DH (ICONV=2)
C           4TH ELEMENT = NUMBER OF MISSING VALUES BETW PREV AND ITSPOS
C     JULDAY - JULIAN DAY(INTERNAL CLOCK) OF INITIAL VALUE TO BE CONVERTED
C     INITHR - HOUR OF INITIAL VALUE TO BE CONVERTED
C     IRCHNG - COMMON BLOCK /FRATNG/ TRANSFER INDICATOR
C           =0, NO CHANGE
C           =1, CALIB. RUN EXCEEDED LAST APPLICABLE DAY OF R.C. IN
C               /FRATNG/ AND TRANSFER FROM SCRATCH FILE WAS MADE
C     IERROR - ERROR FLAG
C           =0, NORMAL RETURN, NO ERRORS
C           =1, ERROR OCCURRED -- OUTPUT TIME SERIES COULD NOT BE FILLED
C     IPRWRN - WARNING MESSAGE FLAG
C           =0, NO MESSAGE PRINTED
C           =1, MESSAGE PRINTED IF Q TO STAGE CONVRSION PRODUCED A STAGE
C               BELOW MIN ALLOWABLE AND STAGE WAS RESET TO MIN ALLOWED.C
C
C     SETUP THE PARAMS
C
      CARRYO(1)=0
      CARRYO(2)=0
      CARRYO(3)=0
      CARRYO(4)=0
      ICONV=1
      ITSPOS=1
      NVALS=1
      LOCPTR=NULL
      T1=NULL
C     CURVLO/HI INTENTIONALY UNINITIALIZED - RETURN PARAMS
      XSECLO=-999
      XSECUP=-999
      METHOD=0
      FLSTAG=-999
C     RETURN PARAM
      NEEDEX=0

      CALL FSTGQ(RCID, ICONV, ITSPOS, NVALS, TSTEP, QDATA, HDATA, LOCPTR, T1,        
     +   CURVLO, CURVHI, XSECLO, XSECUP, METHOD, FLSTAG, NEEDEX, CARRYO,          
     +   JDAY, HOUR, IRCHNG, ERR_FLAG, WARN_FLG)

C     PULL THE FLOW DATA OUT OF THE ARRAY TO PASS BACK TO C++
      FLOW=QDATA(1)
C     DETERMINE THE HIGHEST STAGE IN THE CURVE
      CURVHI=XRC(LOCH-1+NRCPTS)
      HISTG=CURVHI
      RETURN
      END
