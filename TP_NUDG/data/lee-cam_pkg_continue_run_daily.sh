#!/bin/sh
#-----------------------------------------------
#   This is a shell script for configuring the basic post processing tool of CAM model, You 
# should set the basic parameters as below. Good Luck!
#               Last Modified on  2016-04-02
#               A L_Zealot Product
#Modified by Ql_Ren 2017/12/26 for TP-NUDG
#-----------------------------------------------

# Path of the original data
# Caution: DO NOT DELETE \" IN STRING!
PRE_DIR=\"/users/yangsong3/L_Zealot/F/AMIP_C5PM_TP_NUDG/exe/\"
#PRE_DIR=\"/users/yangsong3/L_Zealot/F/AMIP_C5PM_TP_NUDG/pre_data_24h/\"
#PRE_DIR=\"/users/yangsong3/L_Zealot/F/AMIP_C5PM/exe/\"

# Path of the post processed data
PRO_DIR=\"/users/yangsong3/L_Zealot/F/AMIP_C5PM_TP_NUDG/post_data_6h/\"
#PRO_DIR=\"/users/yangsong3/L_Zealot/F/AMIP_C5PM_TP_NUDG/post_data_24h/\"
#PRO_DIR=\"/users/yangsong3/L_Zealot/F/AMIP_C5PM/post_data/\"

# Case name
CASENAME=\"AMIP_C5PM_TP_NUDG\"
#CASENAME=\"AMIP_C5PM\"


# Names of 2D fields
#FDNAME2D="(/\"PRECL\",\"PRECC\",\"LHFLX\",\"PS\",\"PSL\",\"QFLX\",\"TS\",\"TMQ\"/)" #often use
FDNAME2D="(/\"TS\"/)" #often use
#FDNAME2D="(/\"PRECT\",\"U850\",\"V850\"/)" #often use
#FDNAME2D="(/\"PRECC\",\"PRECL\"/)" #often use
#FDNAME2D="(/\"LHFLX\",\"SHFLX\"/)" #often use

# Names of 3D fields
#FDNAME3D="(/\"U\",\"V\",\"Q\"/)" # hybrid coordinate
#FDNAME3D="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"Z3\"/)" #often use
FDNAME3D="(/\"RELHUM\"/)" #often use
#FDNAME3D_HY="(/\"RELHUM\"/)" #often use
#FDNAME3D_HY="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\",\"DTCOND\"/)" # hybrid coordinate
#FDNAME3D_HY="(/\"U\",\"V\",\"T\"/)" # hybrid coordinate

# First year of the subset
FRSTYEAR=1979

# Last year of the subset
LSTYEAR=2005

# Layers of 3D fields
# CAM4 = 26; CAM5 = 30
LAYERS=30

# Output specific pressure layers
# CAUTION: Do not leave species between element!
#PLEV="(/925,850,700,600,500,400,300,200,100,50/)"
#PLEV="(/1000,925,850,700,500,200/)"
PLEV="(/1000,925,850,700,600,500,400,300,200/)"


# Process flag
FLAG_2D=0
FLAG_3D=1
FLAG_3D_HY=0

#-----------------------------------------------------------

#Output post processed 2D fields
if [ $FLAG_2D == 1 ] ; then
    echo "-----package 2D field    (1)-----"
    ncl -nQ \
        pre_dir=$PRE_DIR            \
        pro_dir=$PRO_DIR            \
        fdname2d=$FDNAME2D          \
        frstyear=$FRSTYEAR          \
        lstyear=$LSTYEAR           \
        case_name=$CASENAME         \
        ./package_2D_from_raw_data_daily-160402.ncl
fi


#Output post processed 3D fields
if [ $FLAG_3D == 1 ] ; then
    echo "-----package 3D field    (1)-----"
    ncl -nQ \
       pre_dir=$PRE_DIR            \
       pro_dir=$PRO_DIR            \
       fdname3d=$FDNAME3D          \
       layers=$LAYERS              \
       plev=$PLEV                  \
       frstyear=$FRSTYEAR          \
       lstyear=$LSTYEAR           \
       case_name=$CASENAME         \
       ./package_3D_from_raw_data_daily-160808.ncl
fi

#Output post processed 3D Hybrid fields
if [ $FLAG_3D_HY == 1 ] ; then
    echo "-----package 3D field    (1)-----"
    ncl -nQ \
       pre_dir=$PRE_DIR            \
       pro_dir=$PRO_DIR            \
       fdname3d=$FDNAME3D_HY          \
       frstyear=$FRSTYEAR          \
       lstyear=$LSTYEAR           \
       layers=$LAYERS              \
       case_name=$CASENAME         \
       ./package_3DHY_from_raw_data_daily-171019.ncl
fi
