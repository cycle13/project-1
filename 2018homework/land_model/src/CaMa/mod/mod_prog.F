MODULE MOD_PROG
USE PARKIND1 ,ONLY: JPIM, JPRB, JPRM
IMPLICIT NONE

SAVE
!! prognostics / state variables initial conditions

                                                       !! for use in ECMWF
REAL(KIND=JPRB),ALLOCATABLE   ::  D2RIVSTO_IN(:,:)     !! river      storage [m3]
REAL(KIND=JPRB),ALLOCATABLE   ::  D2FLDSTO_IN(:,:)     !! floodplain storage [m3]

REAL(KIND=JPRB),ALLOCATABLE   ::  D2RIVOUT_IN(:,:)     !! river      outflow [m3/s]
REAL(KIND=JPRB),ALLOCATABLE   ::  D2FLDOUT_IN(:,:)     !! floodplain outflow [m3/s]


REAL(KIND=JPRB),ALLOCATABLE   ::  D2RUNOFF(:,:)        !! input runoff       [m3/s]

REAL(KIND=JPRB),ALLOCATABLE   ::  D2RIVSTO_OUT(:,:)    !! river      storage [m3]
REAL(KIND=JPRB),ALLOCATABLE   ::  D2FLDSTO_OUT(:,:)    !! floodplain storage [m3]

REAL(KIND=JPRB),ALLOCATABLE   ::  D2RIVOUT_OUT(:,:)    !! river      outflow [m3/s]
REAL(KIND=JPRB),ALLOCATABLE   ::  D2FLDOUT_OUT(:,:)    !! floodplain outflow [m3/s]

                                                       !! for implicit schemes of the local inertial equation
REAL(KIND=JPRB),ALLOCATABLE   ::  D2RIVOUT_PRE(:,:)    !! river      outflow [m3/s] (at a previous time step of flow computation)
REAL(KIND=JPRB),ALLOCATABLE   ::  D2FLDOUT_PRE(:,:)    !! floodplain outflow [m3/s]
REAL(KIND=JPRB),ALLOCATABLE   ::  D2RIVDPH_PRE(:,:)    !! river      depth   [m]
REAL(KIND=JPRB),ALLOCATABLE   ::  D2FLDSTO_PRE(:,:)    !! floodplain storage [m3]

REAL(KIND=JPRB),ALLOCATABLE   ::  D1PTHFLW_IN(:,:)     !! flood path outflow [m3/s]
REAL(KIND=JPRB),ALLOCATABLE   ::  D1PTHFLW_OUT(:,:)    !! flood path outflow [m3/s]
REAL(KIND=JPRB),ALLOCATABLE   ::  D1PTHFLW_PRE(:,:)    !! flood path outflow [m3/s]


END MODULE MOD_PROG