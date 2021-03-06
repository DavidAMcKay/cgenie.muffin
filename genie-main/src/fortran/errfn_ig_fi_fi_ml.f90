program errfn_ig_fi_fi_ml
!
! Calculate the cost function for the ig_fi_fi_ml problem
!
! The binary generated by this code is designed to post-process the 
! netcdf output from the ig_fi_fi_ml model. This binary should
! reside in the same location as the genie.exe binary. The rms error
! values are calculated by comparing the model data and
! observational data. RMS values are weighted by the variance of the
! target data. RMS error values are output in the file
! errfn_ig_fi_fi_ml.err.
!
! Andrew Price - 30/12/06
!
implicit none
include 'netcdf.inc'

INTEGER                         :: ncid, status, yr, mm, lsm_pts, osm_pts
CHARACTER(LEN=4), DIMENSION(10) :: Years
CHARACTER(LEN=2), DIMENSION(6)  :: Months
CHARACTER(LEN=256)              :: filename

REAL, DIMENSION(10,6,64,32)     :: igcm_sensible, igcm_latent, igcm_netsolar, igcm_netlong
REAL, DIMENSION(10,6,64,32)     :: igcm_precip, igcm_runoff, igcm_evap

REAL, DIMENSION(64,32)          :: igcm_sensible_DJF, igcm_latent_DJF, igcm_netsolar_DJF, igcm_netlong_DJF
REAL, DIMENSION(64,32)          :: igcm_precip_DJF, igcm_runoff_DJF, igcm_evap_DJF, igcm_PRE_DJF

REAL, DIMENSION(64,32)          :: igcm_sensible_JJA, igcm_latent_JJA, igcm_netsolar_JJA, igcm_netlong_JJA
REAL, DIMENSION(64,32)          :: igcm_precip_JJA, igcm_runoff_JJA, igcm_evap_JJA, igcm_PRE_JJA

REAL, DIMENSION(64,32,3)        :: HadCM3_sensible, HadCM3_latent, HadCM3_netsolar, HadCM3_netlong
REAL, DIMENSION(64,32,3)        :: HadCM3_PRE

REAL, DIMENSION(64,32)          :: HadCM3_sensible_DJF, HadCM3_latent_DJF, HadCM3_netsolar_DJF, HadCM3_netlong_DJF
REAL, DIMENSION(64,32)          :: HadCM3_PRE_DJF

REAL, DIMENSION(64,32)          :: HadCM3_sensible_JJA, HadCM3_latent_JJA, HadCM3_netsolar_JJA, HadCM3_netlong_JJA
REAL, DIMENSION(64,32)          :: HadCM3_PRE_JJA

REAL                            :: HadCM3_sensible_DJF_var, HadCM3_latent_DJF_var, HadCM3_netsolar_DJF_var, HadCM3_netlong_DJF_var
REAL                            :: HadCM3_PRE_DJF_var

REAL                            :: HadCM3_sensible_JJA_var, HadCM3_latent_JJA_var, HadCM3_netsolar_JJA_var, HadCM3_netlong_JJA_var
REAL                            :: HadCM3_PRE_JJA_var

REAL, DIMENSION(2048)           :: weights_list
REAL, DIMENSION(32,64)          :: weights_atm
REAL, DIMENSION(64,32)          :: weights

REAL, DIMENSION(64,32)          :: landmask
LOGICAL, DIMENSION(64,32)       :: lsm, osm

REAL, DIMENSION(10)             :: rmserror

Years=(/ "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010" /)
Months=(/ "12", "01", "02", "06", "07", "08" /)

do yr=1,10

   do mm=1,6

      filename='./main/genie_'//Years(yr)//'_'//Months(mm)//'_30_atm.nc'

      status=nf_open(filename, 0, ncid)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)

      call get2d_data_nc(ncid, 'sensible', 64, 32, igcm_sensible(yr,mm,:,:), status)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
      call get2d_data_nc(ncid, 'latent', 64, 32, igcm_latent(yr,mm,:,:), status)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
      call get2d_data_nc(ncid, 'netsolar', 64, 32, igcm_netsolar(yr,mm,:,:), status)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
      call get2d_data_nc(ncid, 'netlong', 64, 32, igcm_netlong(yr,mm,:,:), status)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
      call get2d_data_nc(ncid, 'precip', 64, 32, igcm_precip(yr,mm,:,:), status)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
      call get2d_data_nc(ncid, 'runoff', 64, 32, igcm_runoff(yr,mm,:,:), status)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
      call get2d_data_nc(ncid, 'evap', 64, 32, igcm_evap(yr,mm,:,:), status)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)

      status=nf_close(ncid)
      IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)

   enddo
enddo

! Calculate the DJF and JJA averages over the 10 years of the model data
igcm_sensible_DJF=sum( sum( igcm_sensible(:,1:3,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_latent_DJF  =sum( sum( igcm_latent(:,1:3,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_netsolar_DJF=sum( sum( igcm_netsolar(:,1:3,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_netlong_DJF =sum( sum( igcm_netlong(:,1:3,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_precip_DJF  =sum( sum( igcm_precip(:,1:3,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_runoff_DJF  =sum( sum( igcm_runoff(:,1:3,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_evap_DJF    =sum( sum( igcm_evap(:,1:3,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_PRE_DJF     = igcm_precip_DJF + igcm_runoff_DJF + igcm_evap_DJF

igcm_sensible_JJA=sum( sum( igcm_sensible(:,4:6,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_latent_JJA  =sum( sum( igcm_latent(:,4:6,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_netsolar_JJA=sum( sum( igcm_netsolar(:,4:6,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_netlong_JJA =sum( sum( igcm_netlong(:,4:6,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_precip_JJA  =sum( sum( igcm_precip(:,4:6,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_runoff_JJA  =sum( sum( igcm_runoff(:,4:6,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_evap_JJA    =sum( sum( igcm_evap(:,4:6,:,:), DIM=2 ), DIM=1 ) / (10.0*3.0)
igcm_PRE_JJA     = igcm_precip_JJA + igcm_runoff_JJA + igcm_evap_JJA

! Load the observational data
filename='./HadCM3_targets_all.nc'
status=nf_open(filename, 0, ncid)
IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
call get3d_data_nc(ncid, 'h', 64, 32, 3, HadCM3_sensible, status)
IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
call get3d_data_nc(ncid, 'le', 64, 32, 3, HadCM3_latent, status)
IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
call get3d_data_nc(ncid, 'sw', 64, 32, 3, HadCM3_netsolar, status)
IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
call get3d_data_nc(ncid, 'lw', 64, 32, 3, HadCM3_netlong, status)
IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
call get3d_data_nc(ncid, 'P_plus_R_plus_E', 64, 32, 3, HadCM3_PRE, status)
IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
status=nf_close(ncid)
IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)

! Copy the DJF and JJA averages for the observational data
HadCM3_sensible_DJF= HadCM3_sensible(:,:,2)
HadCM3_latent_DJF  = HadCM3_latent(:,:,2)
HadCM3_netsolar_DJF= HadCM3_netsolar(:,:,2)
HadCM3_netlong_DJF = HadCM3_netlong(:,:,2)
HadCM3_PRE_DJF     = HadCM3_PRE(:,:,2)

HadCM3_sensible_JJA= HadCM3_sensible(:,:,3)
HadCM3_latent_JJA  = HadCM3_latent(:,:,3)
HadCM3_netsolar_JJA= HadCM3_netsolar(:,:,3)
HadCM3_netlong_JJA = HadCM3_netlong(:,:,3)
HadCM3_PRE_JJA     = HadCM3_PRE(:,:,3)

! Load the land surface mask
! filename='../../genie-igcm3/data/input/limit_pelt_0_new.nc'
! status=nf_open(filename, 0, ncid)
! IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
! call get3d_data_nc(ncid, 'lsm', 64, 32, 1, landmask, status)
! IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
! status=nf_close(ncid)
! IF (STATUS .NE. NF_NOERR) CALL CHECK_ERR(STATUS)
! lsm=landmask>0
! osm=not(lsm)

! Infer the landmask from the target data set. This avoids potential problems if
! the mask in the target data does not match the model mask in the file limit_pelt_0_new.nc
! (as is the case with HadCM3_targets_all.nc)
lsm=(HadCM3_PRE_DJF<-100.0)
osm=.not.(lsm)

! Load the grid weightings data
OPEN(106,FILE='weight_atm.dat')
READ (106,102) weights_list
102 FORMAT(g18.9)
CLOSE(106)
weights_atm=reshape(weights_list,(/32,64/))
weights=transpose(weights_atm)

! Weight all grid cells equal
! weights=1.0

! Calculate the number of land and ocean cells in the grid
lsm_pts=count(lsm)
osm_pts=count(osm)

! Calculate the variance in the target data
HadCM3_sensible_DJF_var = sum((weights*HadCM3_sensible_DJF)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_sensible_DJF, MASK=osm)/osm_pts)**2
HadCM3_sensible_JJA_var = sum((weights*HadCM3_sensible_JJA)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_sensible_JJA, MASK=osm)/osm_pts)**2
HadCM3_latent_DJF_var   = sum((weights*HadCM3_latent_DJF)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_latent_DJF, MASK=osm)/osm_pts)**2
HadCM3_latent_JJA_var   = sum((weights*HadCM3_latent_JJA)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_latent_JJA, MASK=osm)/osm_pts)**2
HadCM3_netsolar_DJF_var = sum((weights*HadCM3_netsolar_DJF)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_netsolar_DJF, MASK=osm)/osm_pts)**2
HadCM3_netsolar_JJA_var = sum((weights*HadCM3_netsolar_JJA)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_netsolar_JJA, MASK=osm)/osm_pts)**2
HadCM3_netlong_DJF_var  = sum((weights*HadCM3_netlong_DJF)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_netlong_DJF, MASK=osm)/osm_pts)**2
HadCM3_netlong_JJA_var  = sum((weights*HadCM3_netlong_JJA)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_netlong_JJA, MASK=osm)/osm_pts)**2
HadCM3_PRE_DJF_var      = sum((weights*HadCM3_PRE_DJF)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_PRE_DJF, MASK=osm)/osm_pts)**2
HadCM3_PRE_JJA_var      = sum((weights*HadCM3_PRE_JJA)**2, MASK=osm)/osm_pts - (sum(weights*HadCM3_PRE_JJA, MASK=osm)/osm_pts)**2

! Calculate the 10 RMS error values
rmserror(1) = sqrt( sum( (weights*(igcm_sensible_DJF - HadCM3_sensible_DJF))**2, MASK=osm) / (osm_pts*HadCM3_sensible_DJF_var) )
rmserror(2) = sqrt( sum( (weights*(igcm_sensible_JJA - HadCM3_sensible_JJA))**2, MASK=osm) / (osm_pts*HadCM3_sensible_JJA_var) )
rmserror(3) = sqrt( sum( (weights*(igcm_latent_DJF - HadCM3_latent_DJF))**2, MASK=osm) / (osm_pts*HadCM3_latent_DJF_var) )
rmserror(4) = sqrt( sum( (weights*(igcm_latent_JJA - HadCM3_latent_JJA))**2, MASK=osm) / (osm_pts*HadCM3_latent_JJA_var) )
rmserror(5) = sqrt( sum( (weights*(igcm_netsolar_DJF - HadCM3_netsolar_DJF))**2, MASK=osm) / (osm_pts*HadCM3_netsolar_DJF_var) )
rmserror(6) = sqrt( sum( (weights*(igcm_netsolar_JJA - HadCM3_netsolar_JJA))**2, MASK=osm) / (osm_pts*HadCM3_netsolar_JJA_var) )
rmserror(7) = sqrt( sum( (weights*(igcm_netlong_DJF - HadCM3_netlong_DJF))**2, MASK=osm) / (osm_pts*HadCM3_netlong_DJF_var) )
rmserror(8) = sqrt( sum( (weights*(igcm_netlong_JJA - HadCM3_netlong_JJA))**2, MASK=osm) / (osm_pts*HadCM3_netlong_JJA_var) )
rmserror(9) = sqrt( sum( (weights*(igcm_PRE_DJF - HadCM3_PRE_DJF))**2, MASK=osm) / (osm_pts*HadCM3_PRE_DJF_var) )
rmserror(10)= sqrt( sum( (weights*(igcm_PRE_JJA - HadCM3_PRE_JJA))**2, MASK=osm) / (osm_pts*HadCM3_PRE_JJA_var) )

! Write the 20 objective function values to file
OPEN(150,FILE='errfn_ig_fi_fi_ml.err',FORM='formatted')
WRITE(150,*) '% errfn_ig_fi_fi_ml.err'
WRITE(150,*) '%'
WRITE(150,*) '% FORMAT:'
WRITE(150,*) '% line 01:  osm_pts (Number of ocean grid cells)'
WRITE(150,*) '% line 02:  rmserror sensible (DJF)'
WRITE(150,*) '% line 03:  rmserror sensible (JJA)'
WRITE(150,*) '% line 04:  rmserror latent   (DJF)'
WRITE(150,*) '% line 05:  rmserror latent   (JJA)'
WRITE(150,*) '% line 06:  rmserror netsolar (DJF)'
WRITE(150,*) '% line 07:  rmserror netsolar (JJA)'
WRITE(150,*) '% line 08:  rmserror netlong  (DJF)'
WRITE(150,*) '% line 09:  rmserror netlong  (JJA)'
WRITE(150,*) '% line 10:  rmserror PRE      (DJF)'
WRITE(150,*) '% line 11:  rmserror PRE      (JJA)'
WRITE(150,103) osm_pts
WRITE(150,102) rmserror
103 FORMAT(i6)
CLOSE(150)

end program errfn_ig_fi_fi_ml
