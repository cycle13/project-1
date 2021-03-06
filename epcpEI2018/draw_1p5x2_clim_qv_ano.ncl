;*********************************************************************
;filename:      draw_1p5x2_clim_preci_ano.ncl
;1 calculate the climatology of the var in a cycle of two years
;2 calc the difference of pSSTclim and pSSTpCP to get the preci anomaly
;3 draw the plot
;                                                     by Ql Ren
;                                                    2018/07/04
;*********************************************************************************
begin
;area: east Asia
lats = -30   ;-20 -20 ;
latn = 40  ;60  60  ;
lonl = 40  ;20  20  ;
lonr = 270 ;220 300 ;
lev  = (/1000,925,850,500,200/)  ;can used as right string
lat_spac = 20
lon_spac = 30
nl   = 0
nl2  = 4  ;used to draw 3D countor
siglvl = 0.1
years  = ispan(1979,2004,1)
vcref  = 1
nsample = 10
nmonth  = 2*12

;unit       = "mm/day"   ;this can be used as right string 
;draw_var   = (/"preci"/)  ;this is the variable used to draw, can used as center string
;var_name   = (/"U","V","PRECC","PRECL"/) ;this is the var_name in data file

unit     = "10~S~-6~N~kg~m~S~-2~N~s~S~-1"   ;this can be used as right string 
draw_var = (/"Integrated Moisture Flux"/)  ;this is the variable used to draw, can used as center string
var_name = (/"U","V","Q","PS"/) ;this is the var_name in data file

;the path of the file
path    = "/HOME/sysu_hjkx_ys/WORKSPACE/renql/F/data"
;case    = (/"fSSTclim_noice","fSSTpEP_noice","fSSTpCP_noice"/)
;case    = (/"fSSTclim_noice","fSSTpEP0.8","fSSTpCP0.8"/)
;case    = (/"fSSTclim_noice","fSSTfEP","fSSTfCP"/):
case    = (/"pSSTclim","pSSTpEPnoscs","pSSTpCPnoscs"/)
;case    = (/"pSSTclim","pSSTpEP1.5","pSSTpCP1.5"/)
;case    = (/"pSSTclim","pSSTpEP0.8","pSSTpCP0.8"/)
;case    = (/"pSSTclim","pSSTpEP0.6","pSSTpCP0.6"/)
;case    = (/"pSSTclim","pSSTfEP","pSSTfCP"/)
file_in  = path + "/" + case + "/" + case + ".cam.h0"
fig_name   = path + "/fig/1p5x2_" + nsample + case(1) + "-" + case(0) + "_" + draw_var 
fig_out    ="pdf";"x11"
season   = (/"(a)JJA(0)","(b)SON(0)","(c)DJF(1)","(d)MAM(1)","(e)JJA(1)"/)

f    = addfile(file_in(0) + ".YEAR." + years(0) + ".monthly." + var_name(0) + ".nc","r")
vars = f->$var_name(0)$(0,{lev(nl):lev(nl2)},{lats:latn},{lonl:lonr})
ncase  = dimsizes(case)
nseason = dimsizes(season)
nvar    = dimsizes(var_name)
nlev    = dimsizes(vars&level)
nlat    = dimsizes(vars&lat) 
nlon    = dimsizes(vars&lon)
q    = new((/ncase,nsample,nmonth,nlev,nlat,nlon/),float) ;not include ps
u    = new((/ncase,nsample,nmonth,nlev,nlat,nlon/),float)
v    = new((/ncase,nsample,nmonth,nlev,nlat,nlon/),float)
dp   = new((/ncase,nsample,nmonth,nlev,nlat,nlon/),float)
ps   = new((/ncase,nsample,nmonth,nlat,nlon/),float)

qu1  = new((/ncase,nsample,nseason,nlat,nlon/),float)
qv1  = new((/ncase,nsample,nseason,nlat,nlon/),float)

qu1_diff  = new((/ncase-1,nseason,nlat,nlon/),float)
qv1_diff  = new((/ncase-1,nseason,nlat,nlon/),float)
prob      = new((/ncase-1,nseason,nlat,nlon/),float)

;================================================================
;read data
;====================================================================
var = 0
do nc = 0,ncase-1,1
    nv = 0
    files := systemfunc("ls " + file_in(nc) + "*" + var_name(nv) + ".nc")
    do nt = 0,nsample-1,1
        print(files(2*(nt+3):(2*(nt+3)+1)))
        f     := addfiles(files(2*(nt+3):(2*(nt+3)+1)),"r")
        u(nc,nt,:,:,:,:) = f[:]->$var_name(nv)$(:,{lev},{lats:latn},{lonl:lonr})
    end do

    nv = 1
    files := systemfunc("ls " + file_in(nc) + "*" + var_name(nv) + ".nc")
    do nt = 0,nsample-1,1
        print(files(2*(nt+3):(2*(nt+3)+1)))
        f     := addfiles(files(2*(nt+3):(2*(nt+3)+1)),"r")
        v(nc,nt,:,:,:,:) = f[:]->$var_name(nv)$(:,{lev},{lats:latn},{lonl:lonr})
    end do
    
    nv = 2
    files := systemfunc("ls " + file_in(nc) + "*" + var_name(nv) + ".nc")
    do nt = 0,nsample-1,1
        print(files(2*(nt+3):(2*(nt+3)+1)))
        f     := addfiles(files(2*(nt+3):(2*(nt+3)+1)),"r")
        q(nc,nt,:,:,:,:) = f[:]->$var_name(nv)$(:,{lev},{lats:latn},{lonl:lonr})
    end do

    nv = 3
    files := systemfunc("ls " + file_in(nc) + "*" + var_name(nv) + ".nc")
    do nt = 0,nsample-1,1
        print(files(2*nt:(2*nt+1)))
        f     := addfiles(files(2*(nt+3):(2*(nt+3)+1)),"r")
        ListSetType(f,"cat")
        ps(nc,nt,:,:,:) = f[:]->$var_name(nv)$(:,{lats:latn},{lonl:lonr})
        dp(nc,nt,:,:,:,:)  = dpres_plevel_Wrap(lev*100,ps(nc,nt,:,:,:),20000,1)  ;unit is Pa, get dp (year,time,lev,lat,lon)
    end do
end do

qu = dim_sum_n(q*u*dp,3)/g ;get integrated qu(ncase,nsample,ntime,lat,lon)
qv = dim_sum_n(q*v*dp,3)/g 

do ns = 0,nseason-1,1
    nms = ns*3 + 5
    nme = ns*3 + 7 
    qu1(:,:,ns,:,:) = dim_avg_n(qu(:,:,nms:nme,:,:),2) ;calc the season average
    qv1(:,:,ns,:,:) = dim_avg_n(qv(:,:,nms:nme,:,:),2) ;calc the season average
end do

var_ave  = dim_avg_n(var1,2)        ;get(ncase,nvar,nseason,nlat,nlon)
var_vari = dim_variance_n(var1,2)   ;get(ncase,nvar,nseason,nlat,nlon)
var_vari = where(var_vari.le.0.000001.and.var_vari.ge.-0.000001,0.1,var_vari)
do nc = 0,ncase-2,1
var_diff(nc,:,:,:,:) = var_ave(nc+1,:,:,:,:) - var_ave(0,:,:,:,:) ;get the EI anomaly
prob(nc,:,:,:,:)     = ttest(var_ave(nc+1,:,:,:,:),var_vari(nc+1,:,:,:,:),nsample,var_ave(0,:,:,:,:),var_vari(0,:,:,:,:),nsample,True,False)
end do

prob(:,2,:,:,:)   = mask(prob(:,2,:,:,:),prob(:,2,:,:,:).lt.siglvl,True)
w_prob = var_diff(:,1,:,:,:)
w_prob = where(((prob(:,1,:,:,:).lt.siglvl).or.(prob(:,0,:,:,:).lt.siglvl)),3,0)
var_diff(:,0,:,:,:) = mask(var_diff(:,0,:,:,:),w_prob.eq.3,True)
var_diff(:,1,:,:,:) = mask(var_diff(:,1,:,:,:),w_prob.eq.3,True)
copy_VarMeta(vars,prob(0,0,0,:,:))
copy_VarMeta(vars,var_diff(0,0,0,:,:))
copy_VarMeta(vars,w_prob(0,0,:,:))
printVarSummary(var_diff)
printVarSummary(prob)

;==============================================================
;draw figure in twelve months (one month is a fgure)
;==================================================================
;the number of the panel plot
    plot     = new((/nseason*(ncase-1)/),graphic)
    plot2    = new((/nseason*(ncase-1)/),graphic)
    plotvc   = new((/nseason*(ncase-1)/),graphic)

;define the thickness and height of the title,tick and label
   tick_font      = 0.02
   subtitle_font  = 0.02
   title_font     = 0.03
   vcref_font     = 0.015
   tick_thick     = 5.0
   subtitle_thick = 5.0  ;not have this attribute
   title_thick    = 5.0
   mp_thick       = 3.0
   vc_thick       = 2
   font_index     = 22

;draw the figure
    wks = gsn_open_wks(fig_out,fig_name)
    gsn_define_colormap(wks,"BlWhRe")
    ;blue and red, has 101 colors,2-51 is blue
    ;gsn_define_colormap(wks,"BlueDarkRed18")
    ;blue and red, has 18 colors,2-10 is blue
    ;blue and red, has 20 colors, 2-11 is bule, 12-21 is red
    ;gsn_define_colormap(wks,"matlab_jet") 
    ;has 64 colors blue green yellow,red

    res                  = True
    res@gsnFrame         = False
    res@gsnDraw          = False
    res@gsnMaximize      = True
    res@gsnAddCyclic     = False
    res@gsnPaperOrientation = "portrait"
    ;res@vpHeightF        = 0.25
    ;res@vpWidthF         = 0.8

;-------set the attribute of the map-------------------
    res@mpCenterLonF     = 180.
    res@mpMaxLatF        = latn
    res@mpMinLatF        = lats
    res@mpMaxLonF        = lonr
    res@mpMinLonF        = lonl
    res@gsnMajorLatSpacing = lat_spac
    res@gsnMajorLonSpacing = lon_spac
    res@mpFillOn         = False
    ;res@mpLandFillColor = "gray"
    ;res@mpFillDrawOrder = "PreDraw"
    res@mpGeophysicalLineThicknessF = mp_thick
    res@mpGeophysicalLineColor      = "black";"white"

;--------set the form of the coordinate-----------------
    res@tmBorderThicknessF  = mp_thick
    res@tmXBLabelFont   = font_index
    res@tmYLLabelFont   = font_index
    res@tmXBLabelFontHeightF     = tick_font
    ; res@tmXBLabelFontAspectF   = 1.6
    res@tmXBLabelFontThicknessF  = tick_thick
    res@tmYLLabelFontHeightF     = tick_font
    ; res@tmYLLabelFontAspectF   = 1.3
    res@tmYLLabelFontThicknessF  = tick_thick
    
    ;  res@tmXBMajorOutwardLengthF = -0.
    ;  res@tmYLMajorOutwardLengthF = -0.
    ;  res@tmYRMajorOutwardLengthF = -0.
      
    ;  res@tmXBMinorOutwardLengthF = -0.
    ;  res@tmYLMinorOutwardLengthF = -0.
    ;  res@tmYRMinorOutwardLengthF = -0.

;---------set the attribute of the contour-----------------
    res@cnFillOn         = True
    res@cnLinesOn        = False ;True
    res@cnLineLabelsOn   = False
    res@cnInfoLabelOn    = False
    ;res@cnLineThicknessF = 0
    ;res@gsnContourZeroLineThicknessF = 4.0
    ;res@cnLineColor      = "blue"
   
    ;res@cnLevelSelectionMode = "AutomaticLevels"   ; set manual contour levels
    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;res@cnLevels             = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;res@cnLevels             = ispan(0,60,10)
    ;res@cnFillColors         = (/-1,20,47,57,94,127,152/)
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =-4         ; set min contour level -3 ;
    res@cnMaxLevelValF        =2        ; set max contour level    3 ;
    res@cnLevelSpacingF       =0.2       ; set contour interval  0.2 ;

    res@gsnSpreadColors      = True              ; turn of the full color map
    res@gsnSpreadColorStart  = 2              ; start at color 17
    res@gsnSpreadColorEnd    = -25                ; end at color 200
    
    res@lbLabelBarOn         = False ;True   ; the label bar
    res@lbOrientation        = "vertical"
    res@lbLabelFontHeightF   = tick_font              ; make labels smaller
    res@lbLabelFont          = font_index              ; make labels smaller
    res@lbLabelStride        = 1
    res@lbBoxLineThicknessF  = mp_thick-1

;----------Set res sig-----------
    res_sig                  = True
    res_sig@gsnDraw          = False
    res_sig@gsnFrame         = False
    res_sig@cnFillOn         = True       ; Fill contours
    res_sig@cnLinesOn        = False;True      ; turn off contour lines
    res_sig@cnLineLabelsOn   = False      ; turn off contour line labels
    res_sig@cnInfoLabelOn    = False
    ;res_sig@cnLineThicknessF = 2
    ;res_sig@cnLineColor     = "black"
    res_sig@cnMonoFillPattern= True;False
    res_sig@cnFillPattern    = 11
    res_sig@cnMonoFillScale  = True
    res_sig@cnFillScaleF     = 0.8
    res_sig@cnMonoFillColor  = True
    res_sig@cnFillColor      = "white" ;"darkslategray"
    res_sig@cnFillDotSizeF   = 0.1
    res_sig@lbLabelBarOn     = False;True   ; turn off the label bar
    ;res_sig@cnLevelSelectionMode ="ExplicitLevels"
    ;res_sig@cnLevels             = (/0.01/)
    ;res_sig@cnFillPattern        = "GMT_gray"
    ;res_sig@cnFillColors         = (/"grey30","grey50"/) ;
    
    res_sig@gsnCenterString      = ""
    res_sig@gsnRightStringFontHeightF = subtitle_font
    res_sig@gsnLeftStringFontHeightF  = subtitle_font
    res_sig@gsnLeftString    = " "
    res_sig@gsnRightString   = " "

;--------set the attribute of vector--------------
    resvc                  = True
    resvc@gsnDraw          = False
    resvc@gsnFrame         = False
    resvc@vcGlyphStyle               = "LineArrow"  ;"CurlyVector"
    resvc@vcVectorDrawOrder          = "PostDraw"
    resvc@vcLineArrowThicknessF      = vc_thick
    resvc@vcMonoLineArrowColor       = True
    resvc@vcLineArrowColor           = "black"
    ;resvc@vcMonoLineArrowColor       = False
    ;resvc@gsnScalarContour = False
    ;resvc@vcUseScalarArray           = True
    ;resvc@vcLevelSelectionMode       = "ExplicitLevels"
    ;resvc@vcLevels                   = (/1,2/)
    ;resvc@vcLevelColors              = (/"black","red","green"/)
    ;resvc@vcLabelsOn                 = False
    ;resvc@vcExplicitLabelBarLabelsOn = False
    resvc@vcMinDistanceF             = 0.03
    resvc@vcRefMagnitudeF            = vcref             ; define vector ref mag
    resvc@vcRefAnnoString2           = vcref + " m/s"
    resvc@vcRefLengthF               = 0.05           ; define length of vec ref
    resvc@vcRefAnnoZone              = 0     ;set the positional origin in the center of the plot
    ;resvc@vcRefAnnoSide              = "Bottom"          
    ;resvc@vcRefAnnoJust              = "TopRight"
    resvc@vcRefAnnoOrthogonalPosF    = -0.5           ; move ref vector along Y-axis
    resvc@vcRefAnnoParallelPosF      = -0.4            ; move ref vector along X-axis
    resvc@vcRefAnnoPerimOn           = False         ;close the border
    resvc@vcRefAnnoFont              = font_index
    resvc@vcRefAnnoFontHeightF       = vcref_font
    resvc@vcRefAnnoString1On         = False
    resvc@vcRefAnnoString2On         = True
    resvc@gsnCenterString      = ""
    resvc@gsnLeftString    = " "
    resvc@gsnRightString   = " "
    resvc@vcLineArrowHeadMinSizeF   = 0.01
    resvc@vcLineArrowHeadMaxSizeF   = 0.01

;------------------------------------------------------------------
;draw the subgraph and change the left and right titles
;-----------------------------------------------------------------------
    res@gsnCenterString       = " "
    res@gsnStringFont         = font_index
    res@gsnStringFontHeightF  = subtitle_font
    res@gsnRightString  = draw_var + " (" + unit + ") siglvl: " + siglvl

    resp  = True    
    resp@gsnMaximize   = True
    resp@gsnPaperOrientation = "portrait"
    resp@gsnPanelLabelBar = True
    resp@pmLabelBarWidthF  = 0.5
    resp@pmLabelBarHeightF = 0.05
    resp@lbLabelFontHeightF = tick_font
    resp@lbLabelFontThicknessF = tick_thick
    resp@txFontHeightF = title_font 
    resp@txFontThicknessF = title_thick

do ns = 0,nseason-1,1
do nc = 0,ncase-2,1
    np = (ncase-1)*ns+nc
    res@gsnLeftString   = season(ns) + " " + case(nc+1)
    plot(np)     = gsn_csm_contour_map_ce(wks,var_diff(nc,2,ns,:,:),res)
    plot2(np)    = gsn_csm_contour(wks,prob(nc,2,ns,:,:),res_sig)
    ;resvc@vcScalarFieldData     = w_prob(nc,ns,:,:)
    ;plotvc(np)   = gsn_csm_vector_scalar(wks,var_diff(nc,0,ns,:,:),var_diff(nc,1,ns,:,:),w_prob(nc,ns,:,:),resvc)
    plotvc(np)   = gsn_csm_vector(wks,var_diff(nc,0,ns,:,:),var_diff(nc,1,ns,:,:),resvc)
    overlay(plot(np),plot2(np))
    overlay(plot(np),plotvc(np))
    print(max(var_diff(nc,2,ns,{lats:latn},{lonl:lonr})))
    print(min(var_diff(nc,2,ns,{lats:latn},{lonl:lonr})))
end do 
end do 

;    resp@txString  = case(1) + " - " + case(0)
    gsn_panel(wks,plot,(/nseason,ncase-1/),resp)
end

