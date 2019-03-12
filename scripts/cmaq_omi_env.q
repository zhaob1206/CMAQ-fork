#! /bin/csh -f
set echo


#define paths
 set BASE      = /home/hwo/tools/create_CMAQ_OMI_file
 set YEAR      = "2018"
 set input_dir = ${BASE}
 set DATA_DIR  = ${BASE}/TOMS_OMI_O3_column/${YEAR}
 
#set compiler for path to executable
#setenv COMPILER  intel
 setenv COMPILER gcc
#setenv COMPILER pgi

 set XBASE = ${BASE}/BLD_create_CMAQ_OMI_file_v00_${COMPILER}
 set EXEC  = ro3_mod_env
 if( ! ( -e  ${XBASE}/${EXEC} ) )then
     \ls ${XBASE}/${EXEC}
     exit()
 endif

#root directory for output files; final output directory set latter.
 set OUT_ROOT = ${BASE}"/output"
 
#create OMI data file list
#optimal results with data for entire length of needed year, plus December of previous year and
# at least January 1st of next year
set infile = toms_list.dat
\ls -1 $DATA_DIR/*.txt  >&! ${input_dir}/${infile}
cat ${input_dir}/${infile}

set numb_files = ` cat ${input_dir}/${infile} | wc -l `
if( $numb_files < 2 )then
  echo "Too few files to process"
  exit()
else
  echo "${numb_files} to process"
endif

#parameters for routine that creates CMAQ OMI.dat file
#Flag to replace missing with previous date
setenv PREV_DATE T
 
#Should be an odd number so output data in includes the equator
#Minimum value and Default value is 17
#Maximum value dependent on input satellite data
setenv NLAT_OMI 179

#Set number of longitude points of ASCII OMI.dat file
#Should be an odd number so first and last longitude point equal
#Minimum value and Default value is 17
#Maximum value dependent on input satellite data
setenv NLON_OMI 361

#Set the degrees between the first latitude point from adjacent pole
#Minimum value dependent on input satellite data but greater zero
setenv LAT_BORDER 1.0

#output directory
set OUTDIR = ${OUT_ROOT}"/omi_"${COMPILER}"_"${YEAR}"_"${NLAT_OMI}"X"${NLON_OMI}

#set output directory, make if needed
 if( ! ( -d $OUTDIR ) )mkdir -p $OUTDIR
#change to output directory
 if( -d $OUTDIR  )then
    cd $OUTDIR
 else
   echo "failure make and/or change output directory"
   \ls $OUTDIR
   exit()
 endif

pwd

set INFILE = ${input_dir}/${infile} 
if( -e $INFILE )then 
    setenv OMI_FILE_LIST ${INFILE}
else
   \ls ${INFILE}
   exit()
endif  
 
#full resolution OMI data in ascii format
set omi_full_dat = omi_full_${YEAR}.dat
setenv  OMI_FULL_DAT ${OUTDIR}/${omi_full_dat}

#subset of OMI data for CMAQ in ascii format
set omi_cmaq_dat = omi_cmaq_${YEAR}.dat
setenv  OMI_CMAQ_DAT ${OUTDIR}/${omi_cmaq_dat}

#full resolution OMI data in ascii format
set omi_full_ncf = omi_full_${YEAR}.ncf
setenv  OMI_FULL_NCF ${OUTDIR}/${omi_full_ncf}

#subset of OMI data for CMAQ in ascii format
set omi_cmaq_ncf = omi_cmaq_${YEAR}.ncf
setenv  OMI_CMAQ_NCF ${OUTDIR}/${omi_cmaq_ncf}

#exit()
 ${XBASE}/${EXEC}

#remove fort.* files
 \rm -f fort.*
 
cd $BASE

#report on output directories contents
\ls -h -l ${OUTDIR}/*

exit()
