;***************************************************************************
;use the reanalysis data to calculate diabatic heating, transient eddy heating
;and Transient eddy vorticity forcing 
;                                            by Ql_Ren
;                                           2020/02/04
;******************************************************************************
begin
path1   = "/home/ys17-19/data-observation/ERA-interim/pressure/"
;path1  = "/home/ys17-19/data-observation/NCEP_NCAR/daily/"
path2   = "/home/ys17-19/renql/project/2020MiddleEastJet/data/"
path3   = "/home/ys17-19/renql/model/AMIP-CTRL/AMIP_C5PM.cam.h1.YEAR.1979.daily.U.nc" ;to get time attribute
var_name = (/"uwnd","vwnd","air"/)
fileout  = path2 + "ERA-Interim_DJF_e_vector-year.nc"
year_option = True;False 

g  = 9.8 ;m/(s*s)
cp = 1004.0 ; J/(K kg)  [ m2/(K s2) ] 
R  = 287.0  ; J/(kg*K) for dry air
a  = 6378388 ;the radius of earth, m
pi = atan(1.0)*4
print(pi)
years    = ispan(1979,2016,1)
years@calendar = "standard"

;area: east Asia
lats =  0  ;-20
latn =  90 ;60
lonl =  0  ;20
lonr = 360 ;220
lev  = (/1000,925,850,700,600, 500,400,350,300,250, 200,175,150,125,100/)

;==========================================================
;create an array(nvar,ncase,nyear) to store the data
;============================================================
f_model = addfile(path3,"r")
time = cd_calendar(f_model->time,0)
delete(f_model)
printVarSummary(time)

f    = addfile(path1+var_name(0)+"/"+var_name(0)+".interim."+years(0)+".nc", "r")
vars = f->$var_name(0)$(0,{lev},{lats:latn},{lonl:lonr})
nlat  = dimsizes(vars&lat)
nlon  = dimsizes(vars&lon)
nyear = dimsizes(years)
nvar  = dimsizes(var_name)

iyear = 0
itime = 1
ilev  = 2
ilat  = 3
ilon  = 4
lat  = vars&lat
lon  = vars&lon
lat  = lat*pi/180.0
lon  = lon*pi/180.0
opt    = 0     ;used by center_finite_diff_n, no meanging 
loncyc = True ;used by center_finite_diff_n
cyclic = False ;used by center_finite_diff_n
;means NOT treated as cyclic in differenced coordinates
;the end values will use a one-sided difference scheme for the end points. 

;==========================================================
;read the data
;============================================================
nlev  = dimsizes(lev)
select_time  = ind(time(:,1).eq.12.or.time(:,1).le.2)
select_time1 = select_time
select_time1(58:89) = select_time(58:89) + 1
ntime = dimsizes(select_time)
u     := new((/nyear,ntime,nlev,nlat,nlon/),float)
v     := new((/nyear,ntime,nlev,nlat,nlon/),float)
t     := new((/nyear,ntime,nlev,nlat,nlon/),float)

do nt = 0,nyear-1,1
print("read: " + years(nt))
if(isleapyear(years(nt))) then ;leap year,366 day
    nv = 0
    f      = addfile(path1+var_name(nv)+"/"+var_name(nv)+".interim."+years(nt)+".nc","r")
    u(nt,:,:,:,:)  = f->$var_name(nv)$(select_time1,{lev},{lats:latn},{lonl:lonr})
    nv = 1
    f      = addfile(path1+var_name(nv)+"/"+var_name(nv)+".interim."+years(nt)+".nc","r")
    v(nt,:,:,:,:)  = f->$var_name(nv)$(select_time1,{lev},{lats:latn},{lonl:lonr})
    nv = 2
    f      = addfile(path1+var_name(nv)+"/"+var_name(nv)+".interim."+years(nt)+".nc","r")
    t(nt,:,:,:,:)  = f->$var_name(nv)$(select_time1,{lev},{lats:latn},{lonl:lonr})
else   ;non-leap year, 365 day
    nv = 0
    f      = addfile(path1+var_name(nv)+"/"+var_name(nv)+".interim."+years(nt)+".nc","r")
    u(nt,:,:,:,:)  = f->$var_name(nv)$(select_time,{lev},{lats:latn},{lonl:lonr})
    nv = 1
    f      = addfile(path1+var_name(nv)+"/"+var_name(nv)+".interim."+years(nt)+".nc","r")
    v(nt,:,:,:,:)  = f->$var_name(nv)$(select_time,{lev},{lats:latn},{lonl:lonr})
    nv = 2
    f      = addfile(path1+var_name(nv)+"/"+var_name(nv)+".interim."+years(nt)+".nc","r")
    t(nt,:,:,:,:)  = f->$var_name(nv)$(select_time,{lev},{lats:latn},{lonl:lonr})
end if
end do
t  = pot_temp(lev*100, t, ilev, False)

if (any(ismissing(u))) then
    print("uwnd has missing")
end if
if (any(ismissing(v))) then
    print("vwnd has missing")
end if
if (any(ismissing(t))) then
    print("air has missing")
end if

;--------------------------------------
;DJF
;---------------------------------------------------
u2     := new((/nyear-1,ntime,nlev,nlat,nlon/),float)
v2     := new((/nyear-1,ntime,nlev,nlat,nlon/),float)
t2     := new((/nyear-1,ntime,nlev,nlat,nlon/),float)
do ny = 0,nyear-2,1
    u2(ny,0:30,:,:,:) = u(ny,59:89,:,:,:)
    v2(ny,0:30,:,:,:) = v(ny,59:89,:,:,:)
    t2(ny,0:30,:,:,:) = t(ny,59:89,:,:,:)
    u2(ny,31:89,:,:,:) = u(ny+1,0:58,:,:,:)
    v2(ny,31:89,:,:,:) = v(ny+1,0:58,:,:,:)
    t2(ny,31:89,:,:,:) = t(ny+1,0:58,:,:,:)
end do
u := u2
v := v2
t := t2
printVarSummary(u)

;==========================================================
;calc forcing factors: Qeddy, Qd, A, dimension is 5d
;============================================================
clm_t = dim_avg_n(t,itime) 
f0  = conform(clm_t, 2*(2*pi/24.0/3600.0)*sin(lat), ilat-1)
coslat4d = conform(clm_t,cos(lat),ilat-1)

ca = 10.0 ;day
fca = 1.0/ca
fcf = fspan(0, 0.5, ntime/2) 
hgh_cf = ind(fcf.ge.fca)
low_cf = ind(fcf.lt.fca)

ez_all  := new((/3,nyear-1,nlev,nlat,nlon/),float)
ey_all  := new((/3,nyear-1,nlev,nlat,nlon/),float)
ex_all  := new((/3,nyear-1,nlev,nlat,nlon/),float)

do neddy = 0,2,1
if(neddy.eq.0) then
clm_u = dim_avg_n(u,itime)
clm_v = dim_avg_n(v,itime) 
edd_u = u - conform(u, clm_u, (/0,2,3,4/))
edd_v = v - conform(v, clm_v, (/0,2,3,4/))   
edd_t = t - conform(t, clm_t, (/0,2,3,4/))   
delete([/clm_u,clm_v/])
end if
if(neddy.eq.1) then ;low-frequency
    cf = ezfftf_n(u,itime)
    cf(:,:,hgh_cf,:,:,:) = 0.0  
    edd_u = ezfftb_n(cf,0,itime+1)
    cf = ezfftf_n(v,itime)
    cf(:,:,hgh_cf,:,:,:) = 0.0  
    edd_v = ezfftb_n(cf,0,itime+1)
    cf = ezfftf_n(t,itime)
    cf(:,:,hgh_cf,:,:,:) = 0.0  
    edd_t = ezfftb_n(cf,0,itime+1)
    delete(cf)
end if
if(neddy.eq.2) then ;hgh-frequency
    cf = ezfftf_n(u,itime)
    cf(:,:,low_cf,:,:,:) = 0.0  
    edd_u = ezfftb_n(cf,0,itime+1)
    cf = ezfftf_n(v,itime)
    cf(:,:,low_cf,:,:,:) = 0.0  
    edd_v = ezfftb_n(cf,0,itime+1)
    cf = ezfftf_n(t,itime)
    cf(:,:,low_cf,:,:,:) = 0.0  
    edd_t = ezfftb_n(cf,0,itime+1)
    delete(cf)
end if

ez_all(neddy,:,:,:,:)  = coslat4d*f0*dim_avg_n(edd_v*edd_t,itime)/center_finite_diff_n(clm_t,lev*100,cyclic,opt,ilev-1)
ey_all(neddy,:,:,:,:)  = -coslat4d*dim_avg_n(edd_u*edd_v,itime)
ex_all(neddy,:,:,:,:)  = dim_avg_n(edd_v*edd_v-edd_u*edd_u,itime)
printMinMax(ez_all,True)
printMinMax(ey_all,True)
printMinMax(ex_all,True)
end do
delete([/edd_u,edd_v,edd_t/])
delete([/fcf,fca,hgh_cf,low_cf/])
delete([/u,v,t/])
delete([/f0,clm_t,coslat4d/])

ex_all@long_name = "dim_avg_n(edd_v*edd_v-edd_u*edd_u,itime)"
ex_all@units     = "m2/s2" 
ey_all@long_name = "-dim_avg_n(edd_u*edd_v,itime)"
ey_all@units     = "m2/s2" 
ez_all@long_name = "f0*dim_avg_n(edd_v*edd_t,itime)/(dthdp)"
ez_all@units     = "m*Pa/s2" 

;========================================================================
;save the data
;=======================================================================
system("rm -f " + fileout)
setfileoption("nc","Format","LargeFile") 
ncdf = addfile(fileout,"c")
setfileoption(ncdf,"definemode",True)

;set all field attribute
fileatt =  True
fileatt@creation_date = systemfunc("date")
fileatt@discription   = "DJF mean E vector for total, low-frequency and high-frequency"
fileattdef(ncdf,fileatt)  

;define all coordinate
dimNames = (/"nvar","year" ,"lev","lat","lon"/);
dimSizes = (/  3   ,nyear-1,nlev ,nlat ,nlon/) ;
dimUnlim = (/False ,False  ,False,False,False/);
filedimdef(ncdf, dimNames, dimSizes, dimUnlim)

;define var_names, type(string) and dims_names(string)
filevardef(ncdf,"lev" ,typeof(vars&level),(/"lev"/))
filevardef(ncdf,"lat" ,typeof(vars&lat),getvardims(vars&lat))
filevardef(ncdf,"lon" ,typeof(vars&lon),getvardims(vars&lon))
if(year_option) then 
filevardef(ncdf,"ex_all",typeof(ex_all),(/"nvar","year","lev","lat","lon"/))
filevardef(ncdf,"ey_all",typeof(ey_all),(/"nvar","year","lev","lat","lon"/))
filevardef(ncdf,"ez_all",typeof(ez_all),(/"nvar","year","lev","lat","lon"/))
else
filevardef(ncdf,"ex_all",typeof(ex_all),(/"nvar","lev","lat","lon"/))
filevardef(ncdf,"ey_all",typeof(ey_all),(/"nvar","lev","lat","lon"/))
filevardef(ncdf,"ez_all",typeof(ez_all),(/"nvar","lev","lat","lon"/))
end if

;define var attribute
filevarattdef(ncdf,"lev",vars&level)
filevarattdef(ncdf,"lat",vars&lat)
filevarattdef(ncdf,"lon",vars&lon)
filevarattdef(ncdf,"ex_all",ex_all)
filevarattdef(ncdf,"ey_all",ey_all)
filevarattdef(ncdf,"ez_all",ez_all)

ncdf->lev  = (/lev/)
ncdf->lat  = (/vars&lat/)
ncdf->lon  = (/vars&lon/)
ncdf->ex_all = (/ex_all/)
ncdf->ey_all = (/ey_all/)
ncdf->ez_all = (/ez_all/)
end

