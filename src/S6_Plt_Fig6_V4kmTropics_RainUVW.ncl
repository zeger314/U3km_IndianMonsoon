; ==================================================================
; S2_Plt_Fig1_Rain.ncl
; 
; Introduction:
; ==================================================================

; ==================================================================
;                           load scripts
; ==================================================================
load "/work/dongze/myNCLFuns/plt_SetRes.ncl"
; ==================================================================

begin
; ==================================================================
;                           Data Processing
; ==================================================================
input_path = "/storage/aemolcore02/dongze/U3km_data/midDataForPaper/"
nday = 29

input_path = "/storage/aemolcore02/dongze/U3km_data/midDataForPaper/"
shortname_arr = (/"cmorph", "gpcp", "u3km", "v4km", "U60km"/)
nday = 29
;;------------------U50km-------------------------
f_cm = addfile(input_path + shortname_arr(0) + \
               "_total_rain_20200611-0709.nc", "r")
lat_cm = f_cm->lat
lon_cm = f_cm->lon
rain_cm = f_cm->rain / nday
rain_cm!0 = "lat"
rain_cm!1 = "lon"
rain_cm&lat = lat_cm
rain_cm&lon = lon_cm

index_pre = 0
if(index_pre .eq. 0) then
    f_u60 = addfile(input_path + "U60km.totalRain0611-0709.U60km2CMORPH.nc", "r")
    f_v4 = addfile(input_path + "V4kmTropics.totalRain0611-0709.V4kmTropics2CMORPH.nc", "r")
else
    f_u60 = addfile(input_path + "U60km.totalRain0611-0709.U60km2GPM.nc", "r")
    f_v4 = addfile(input_path + "V4kmTropics.totalRain0611-0709.V4kmTropics2GPM.nc", "r")
end if
rain_u60 = f_u60->rain / nday
rain_v4 = f_v4->rain * 24.
rain_46 = rain_v4 - rain_u60

lat_u60 = f_u60->lat
lon_u60 = f_u60->lon

rain_46!0 = "lat"
rain_46!1 = "lon"
rain_46&lat = lat_u60
rain_46&lon = lon_u60

;;------------------V4km-------------------------
shortname = "V4kmTropics"
f_u = addfile(input_path + shortname + "_0611-0709_Avg_uzonal_850hPa.V4kmTropics2ERA5.nc", "r")
u850_v4t = f_u->uzonal_850hPa
f_v = addfile(input_path + shortname + "_0611-0709_Avg_umeridional_850hPa.V4kmTropics2ERA5.nc", "r")
v850_v4t = f_v->umeridional_850hPa
f_z1 = addfile(input_path + shortname + "_0611-0709_Avg_height_850hPa.V4kmTropics2ERA5.nc", "r")
h850_v4t = f_z1->height_850hPa
f_t = addfile(input_path + shortname + "_ter.V4kmTropics2ERA5.nc", "r")
ter_v4t = f_t->ter
f_v4t = addfile(input_path + shortname + "_uvzw_lvp.HrdlyCir.nc", "r")
v_trans_v4t = f_v4t->v_p
w_trans_v4t = f_v4t->w_p
delete([/f_u, f_v, f_z1, f_t, f_v4t/])
u850_v4t = where(h850_v4t .le. ter_v4t, u850_v4t@_FillValue, u850_v4t)
v850_v4t = where(h850_v4t .le. ter_v4t, v850_v4t@_FillValue, v850_v4t)
wind850_v4t = sqrt(u850_v4t^2 + v850_v4t^2)

copy_VarCoords(h850_v4t, u850_v4t)
copy_VarCoords(h850_v4t, v850_v4t)
copy_VarCoords(h850_v4t, wind850_v4t)
v_trans_v4t&pressure = v_trans_v4t&pressure * -1.
w_trans_v4t&pressure = w_trans_v4t&pressure * -1.
w_trans_v4t = w_trans_v4t * 100.
W_trans_v4t = w_trans_v4t * 10.
copy_VarCoords(v_trans_v4t, w_trans_v4t)
copy_VarCoords(v_trans_v4t, W_trans_v4t)

; ==================================================================

; ==================================================================
;                           shared parameters
; ==================================================================
min_lat = -20.0
max_lat = 40.0
min_lon = 35.0
max_lon = 115.0

nplt = 3

vpX_arr = (/0.08, 0.38, 0.70, 0.08, 0.38, 0.715/) - 0.01
vpY_arr = (/0.96, 0.96, 0.96, 0.705, 0.705, 0.705/)
vpHei = 0.21
vpWid = 0.28
isAddCyc = False
gsnFontHei = 0.015
isOutline = True
mpLineThick = 3.0
tmOn = (/True, False, True, False/)
tmThick = 8.0
tmFontHei = 0.012
tmLen = 0.005
cnFillOn = True
cnLineOn = False
lbThick = 2.0
lbLabelFontHei = 0.015
lbTiFontHei = 0.016
lbHei = 0.03
lbWid = 0.4
NRES = 4
setting = set_global_plot_setting(NRES)

plt_arr = new((/nplt/), graphic)
vc_arr = new((/nplt/), graphic)
hardcir_arr = new((/nplt/), graphic)
oc_zone = new((/nplt/), graphic)
india_zone = new((/nplt/), graphic)
plt_path = "./plots/"
plt_name = "S6_Fig6_V4kmTropics_RainUVW"
plt_type = "png"
if(plt_type .eq. "png") then
    plt_type@wkWidth = 4096
    plt_type@wkHeight = 4096
end if
wks = gsn_open_wks(plt_type, plt_path + plt_name)
setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize" : 200000000
end setvalues

res = True ; Plot mods desired.
set_res_basic(res, isAddCyc, setting@gsnFontHei*0.8)
set_res_mpBasic(res, isOutline, mpLineThick)
res@trGridType = "TriangularMesh"  ; This is required to allow
res@mpShapeMode = "FreeAspect"
res@mpMinLatF = min_lat
res@mpMaxLatF = max_lat
res@mpMinLonF = min_lon
res@mpMaxLonF = max_lon
set_res_tmBasic(res, tmOn, setting@tmThick, setting@tmFontHei*1.2, setting@tmLen*0.8)
res@tmXBMinorOn = True
res@tmXBValues = (/40.0, 60.0, 80.0, 100.0/)
res@tmXBMinorValues = (/35.0, \
                        45.0, 50.0, 55.0, \
                        65.0, 70.0, 75.0, \
                        85.0, 90.0, 95.0, \
                        105.0, 110.0, 115.0/)
res@tmXBLabels = "~F25~" + \
                 (/"40~S~o~N~E", "60~S~o~N~E", \
                   "80~S~o~N~E", "100~S~o~N~E"/)
res@tmYLMinorOn = True
res@tmYLValues = (/-20.0, 0.0, 20.0, 40.0/)
res@tmYLMinorValues = (/-15.0, -10.0, -5.0, \
                        5.0, 10.0, 15.0, \
                        25.0, 30.0, 35.0/)
res@tmYLLabels = "~F25~" + \
                 (/"20~S~o~N~S", "0~S~o~N~", \
                   "20~S~o~N~N", "40~S~o~N~N"/)
res@tmXBMinorOutwardLengthF = res@tmXBMinorLengthF
res@tmYLMinorOutwardLengthF = res@tmYLMinorLengthF

set_res_cnBasic(res, cnFillOn, cnLineOn)
res@cnRasterSmoothingOn = False
cmap = read_colormap_file("MPL_BrBG")
cnlvs = (/-20., -17.5, -15.0, -12.5, \
          -10.0, -7.5, -5.0, -2.5, \
          0, 2.5, 5.0, 7.5, \
          10.0, 12.5, 15.0, 17.5, 20./)
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = cnlvs
res@cnFillPalette = cmap ; Don't use white

cnLv_wind = (/8., 10., 12., 16., 18., 20./)
cnLv = (/-0.02, -0.01, -0.006, \
         -0.002, 0.002, \
         0.006, 0.01, 0.02/) * 100.


resnew = True ; Plot mods desired.
set_res_basic(resnew, isAddCyc, setting@gsnFontHei * 0.8)
set_res_cnBasic(resnew, cnFillOn, cnLineOn)
cmapuv  = read_colormap_file("MPL_BrBG")
set_res_cnMap(resnew, False, -1, cmapuv(10:122, :))
set_res_tmBasic(resnew, tmOn, setting@tmThick, setting@tmFontHei*1.2, setting@tmLen)
cmap_new = cmapuv(62:, :)
cmap_new(0, :) = 0.
resnew@tmXBMinorOutwardLengthF = resnew@tmXBMinorLengthF
resnew@tmXBMajorOutwardLengthF = resnew@tmXBMajorLengthF
resnew@tmYLMinorOutwardLengthF = resnew@tmYLMinorLengthF
resnew@tmYLMajorOutwardLengthF = resnew@tmYLMajorLengthF


resuv = resnew
set_res_mpBasic(resuv, isOutline, setting@mpLineThick * 1.0)
;resuv@mpGeophysicalLineColor = "grey"
resuv@trGridType = "TriangularMesh"  ; This is required to allow
resuv@mpShapeMode = "FreeAspect"
resuv@mpMinLatF = min_lat
resuv@mpMaxLatF = max_lat
resuv@mpMinLonF = min_lon
resuv@mpMaxLonF = max_lon
resuv@tmXBMinorOn = True
resuv@tmXBValues = (/40.0, 60.0, 80.0, 100.0/)
resuv@tmXBMinorValues = (/35.0, \
                        45.0, 50.0, 55.0, \
                        65.0, 70.0, 75.0, \
                        85.0, 90.0, 95.0, \
                        105.0, 110.0, 115.0/)
resuv@tmXBLabels = "~F25~" + \
                 (/"40~S~o~N~E", "60~S~o~N~E", \
                   "80~S~o~N~E", "100~S~o~N~E"/)
resuv@tmYLMinorOn = True
resuv@tmYLValues = (/-20.0, 0.0, 20.0, 40.0/)
resuv@tmYLMinorValues = (/-15.0, -10.0, -5.0, \
                        5.0, 10.0, 15.0, \
                        25.0, 30.0, 35.0/)
resuv@tmYLLabels = "~F25~" + \
                 (/"20~S~o~N~S", "0~S~o~N~", \
                   "20~S~o~N~N", "40~S~o~N~N"/)


resvw = resnew
resvw@tiYAxisOn = False
resvw@tiXAxisOn = False

resvw@trXMaxF = 25.
resvw@trXMinF = -15.
resvw@tmXBMode = "Explicit"
resvw@tmXBValues = (/-10., 0., 10., 20./)
resvw@tmXBLabelsOn = True
resvw@tmXBLabels = "~F25~" + (/"10~S~o~N~S", "0~S~o~N~", \
                               "10~S~o~N~N", "20~S~o~N~N"/)
resvw@tmXBMinorValues = (/-14., -12., -8., -6., -4., -2., \
                          2., 4., 6., 8., 10., 12., 14., \
                          16., 18., 20., 22., 24./)
resvw@tmXBLabelAngleF = 0.

resvw@trYMaxF = -100.
resvw@trYMinF = -950.
resvw@tmYLMode = "Explicit"
resvw@tmYLValues = (/-900., -800., -700., -600., \
                     -500., -400., -300., -200., \
                     -100./)
resvw@tmYLLabels = (/"~F25~900", "~F25~800", "~F25~700", \
                     "~F25~600", "~F25~500", "~F25~400", \
                     "~F25~300", "~F25~200", "~F25~100"/)


vres = True
set_res_basic(vres, isAddCyc, setting@gsnFontHei)
set_res_tmBasic(vres, (/False, False, False, False/), \
                setting@tmThick, setting@tmFontHei, setting@tmLen)
vcMinDist = 0.025
vcRefLen = 0.05
set_res_vcBasic(vres, vcMinDist, vcRefLen, setting@vcLineThick*1.5, \
                setting@vcPerimThick, setting@vcPerimSpace, \
                setting@vcRefFontHei, setting@vcRefFontThick)
vres@vcRefAnnoOrthogonalPosF = -0.185
; ==================================================================

; ==================================================================
;                     Plot 0: Total Precipitation
; ==================================================================
iplt = 0
res0 = res
res0@lbLabelBarOn = True
set_res_lbBasic(res0, setting@lbThick, setting@lbLabelFontHei, \
                setting@lbTiFontHei*0.8, lbHei, lbWid*0.75)
res0@lbTitleOn = True
res0@lbTitlePosition = "Bottom"
res0@lbTitleString = "~F25~(mm day~S~-1~N~)" ; add in 21-09-05 @dongze
res0@pmLabelBarOrthogonalPosF = 0.15


;res0@gsnCenterString = "~F25~V4kmTropics-CMORPH"
res0@vpXF = vpX_arr(iplt)
res0@vpYF = vpY_arr(iplt)
res0@vpHeightF = vpHei
res0@vpWidthF = vpWid
res0@tmXBLabelsOn = True
plt_arr(iplt) = gsn_csm_contour_map(wks, rain_46, res0)
delete([/rain_46/])
; ==================================================================

; ==================================================================
;                     Plot 1: V4kmTropics
; ==================================================================
iplt = 1
res1 = resuv
res1@tmYLLabelsOn = False
res1@tmXBLabelsOn = True
res1@lbLabelBarOn = True
set_res_lbBasic(res1, setting@lbThick, setting@lbLabelFontHei, \
                setting@lbTiFontHei*0.8, lbHei, lbWid*0.6)
set_res_lbTitle(res1, "(~N~m s~S~-1~N~)", "Bottom")
;res1@lbOrientation = "Vertical"
res1@pmLabelBarOrthogonalPosF = 0.15
;res1@pmLabelBarParallelPosF = 0.6



;res1@gsnLeftString = "~F25~U3km"
;res1@gsnRightString = "~F25~U&V850hPa"
res1@vpXF = vpX_arr(iplt)
res1@vpYF = vpY_arr(iplt)
res1@vpHeightF = vpHei
res1@vpWidthF = vpWid
set_res_cnExplicitLevel(res1, cnLv_wind)
set_res_cnMap(res1, True, -1, cmap_new)
plt_arr(iplt) = gsn_csm_contour_map(wks, wind850_v4t, res1)

vres1 = vres
vres1@vcRefMagnitudeF = 25.0
set_res_vcString(vres1, True, "25 m s~S~-1~N~", False, "m s~S~-1~N~")
vc_arr(iplt) = gsn_csm_vector(wks, u850_v4t, v850_v4t, vres1)
delete([/u850_v4t, v850_v4t/])
; ==================================================================

; ==================================================================
;                     Plot 2: V4kmTropics,Hardly Circulatioon
; ==================================================================
iplt = 2
res2 = resvw
res2@tmYLLabelsOn = True
res2@tmXBLabelsOn = True
res2@lbLabelBarOn = True
set_res_lbBasic(res2, setting@lbThick, setting@lbLabelFontHei, \
                setting@lbTiFontHei*0.8, lbHei, lbWid*0.60/7*9)
set_res_lbTitle(res2, "(~N~10~S~-2~N~m s~S~-1~N~)", "Bottom")
res2@pmLabelBarOrthogonalPosF = 0.04
;res2@pmLabelBarParallelPosF = 0.55


res2@vpXF = vpX_arr(iplt)
res2@vpYF = vpY_arr(iplt)
res2@vpHeightF = vpHei
res2@vpWidthF = vpWid
set_res_cnExplicitLevel(res2, cnLv)
plt_arr(iplt) = gsn_csm_contour(wks, w_trans_v4t, res2)


vres2 = vres
vres2@vcRefMagnitudeF = 10.0
vres2@vcRefAnnoOn = False
set_res_vcString(vres2, True, "10", False, "")
vc_arr(iplt) = gsn_csm_vector(wks, v_trans_v4t, W_trans_v4t, vres2)
delete([/w_trans_v4t, v_trans_v4t/])
; ==================================================================

; ==================================================================
;                    refined region 
; ==================================================================
lres = True
lres@gsLineColor = "red2"
lres@gsLineDashPattern = 14
lres@gsLineThicknessF = 11.0

india_lon  = (/72.5, 92.5, 92.5, 72.5, 72.5/)
india_lat  = (/15.0, 15.0, 25.0, 25.0, 15.0/)
zone1_lon = (/50., 100., 100., 50., 50./)
zone1_lat = (/-10., -10., 0., 0., -10./)
do iplt = 0, nplt-1
    india_zone(iplt) = gsn_add_polyline(wks, plt_arr(iplt), india_lon, india_lat, lres)
    oc_zone(iplt) = gsn_add_polyline(wks, plt_arr(iplt), zone1_lon, zone1_lat, lres)
end do
; ==================================================================
overlay(plt_arr(1), vc_arr(1))
overlay(plt_arr(2), vc_arr(2))

do iplt = 0, nplt-1
    draw(plt_arr(iplt))
end do


resTxt = True
resTxt@txFontHeightF = gsnFontHei + 0.005
resTxt@txJust = "CenterLeft"
figureIndex = "~F25~" + (/"(a)", "(b)", "(c)", \
                          "(d)", "(e)", "(f)"/)

resLeft = resTxt
resLeft@txFontHeightF = setting@gsnFontHei * 0.8
leftstring = "~F25~" + (/"V4kmTropics-U60km", "V4kmTropics", "V4kmTropics"/)


resRight = resTxt
resRight@txFontHeightF = setting@gsnFontHei * 0.8
resRight@txJust = "CenterRight"
rightstring = "~F25~" + (/"Rainfall", "U&V850hPa", "V&W"/)
do iplt = 0, nplt-1
    gsn_text_ndc(wks, figureIndex(iplt), vpX_arr(iplt)+0.003, vpY_arr(iplt)-0.015, resTxt)

    gsn_text_ndc(wks, leftstring(iplt), vpX_arr(iplt)+0.003, vpY_arr(iplt)+0.02, resLeft)
    gsn_text_ndc(wks, rightstring(iplt), vpX_arr(iplt)+vpWid, vpY_arr(iplt)+0.022, resRight)
end do
resTxt@txFontHeightF = setting@gsnFontHei * 0.8
gsn_text_ndc(wks, "~F25~hPa", vpX_arr(2)-0.036, vpY_arr(2)-vpHei-0.01, resTxt)

;drawNDCGrid(wks)
frame(wks)
if(plt_type .eq. "png") then
    cmd = "convert -alpha off -background white -geometry 4096x4096 -density 600 -trim " + \
          plt_path + plt_name + "." + plt_type + " " + \
          plt_path + plt_name + ".jpg"
    system(cmd)
end if
end
