; ==================================================================
; S2_Plt_Fig2_Wind.ncl
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
area_name = "HrdlyCir"
area_latlon = (/-15., 25., 70., 90./)
g = 9.78
min_lat = -20.0
max_lat = 40.0
min_lon = 35.0
max_lon = 115.0



input_path = "/storage/aemolcore02/dongze/U3km_data/midDataForPaper/"
shortname_arr = (/"ERA5", "U60km", "U3km"/)
nday = 29
;;------------------ERA5-------------------------
f_u = addfile(input_path + shortname_arr(0) + "_avg/uvzw.avg.nc", "r")
u3d = f_u->u
v3d = f_u->v
z3d = f_u->z
w3d = f_u->w
lv_era = f_u->level
lat_era = f_u->latitude
lon_era = f_u->longitude

u850_era = u3d(30, :, :)
v850_era = v3d(30, :, :)
h850_era = z3d(30, :, :)

ind_lat = ind(lat_era .ge. area_latlon(0) .and. \
              lat_era .le. area_latlon(1))
ind_lon = ind(lon_era .ge. area_latlon(2) .and. \
              lon_era .le. area_latlon(3))
v_trans_era = dim_avg_n_Wrap(v3d(:, ind_lat, ind_lon), 2)
w_trans_era = dim_avg_n_Wrap(w3d(:, ind_lat, ind_lon), 2)
delete([/f_u, u3d, v3d, w3d/])

;;------------------U60km-------------------------
f_u = addfile(input_path + shortname_arr(1) + "_avg/uzonal_850hPa.U60km2ERA5.nc", "r")
u850_u60 = f_u->uzonal_850hPa
f_v = addfile(input_path + shortname_arr(1) + "_avg/umeridional_850hPa.U60km2ERA5.nc", "r")
v850_u60 = f_v->umeridional_850hPa
f_z1 = addfile(input_path + shortname_arr(1) + "_avg/height_850hPa.U60km2ERA5.nc", "r")
h850_u60 = f_z1->height_850hPa
f_t = addfile(input_path + shortname_arr(1) + "_avg/ter.U60km2ERA5.nc", "r")
ter_u60 = f_t->ter
f_u60 = addfile(input_path + shortname_arr(1) + "_avg/uvzw_lvp.HrdlyCir2.avg.nc", "r")
v_trans_u60 = f_u60->v
w_trans_u60 = f_u60->w
delete([/f_u, f_v, f_z1, f_u60/])
;;------------------U3km-------------------------
f_u = addfile(input_path + shortname_arr(2) + "_avg/uzonal_850hPa.U3km2ERA5.nc", "r")
u850_u3 = f_u->uzonal_850hPa
f_v = addfile(input_path + shortname_arr(2) + "_avg/umeridional_850hPa.U3km2ERA5.nc", "r")
v850_u3 = f_v->umeridional_850hPa
f_z1 = addfile(input_path + shortname_arr(2) + "_avg/height_850hPa.U3km2ERA5.nc", "r")
h850_u3 = f_z1->height_850hPa
f_t = addfile(input_path + shortname_arr(2) + "_avg/ter.U3km2ERA5.nc", "r")
ter_u3 = f_t->ter
f_u3 = addfile(input_path + shortname_arr(2) + "_avg/uvzw_lvp.HrdlyCir2.avg.nc", "r")
v_trans_u3 = f_u3->v
w_trans_u3 = f_u3->w
delete([/f_u, f_v, f_z1, f_u3/])


u850_era = where(h850_era/g .le. ter_u60, u850_era@_FillValue, u850_era)
v850_era = where(h850_era/g .le. ter_u60, v850_era@_FillValue, v850_era)
wind850_era = sqrt(u850_era^2 + v850_era^2)


u850_u60 = where(h850_u60 .le. ter_u60, u850_u60@_FillValue, u850_u60)
v850_u60 = where(h850_u60 .le. ter_u60, v850_u60@_FillValue, v850_u60)
wind850_u60 = sqrt(u850_u60^2 + v850_u60^2)

u850_u3 = where(h850_u3 .le. ter_u3, u850_u3@_FillValue, u850_u3)
v850_u3 = where(h850_u3 .le. ter_u3, v850_u3@_FillValue, v850_u3)
wind850_u3 = sqrt(u850_u3^2 + v850_u3^2)

copy_VarCoords(h850_era, u850_era)
copy_VarCoords(h850_era, v850_era)
copy_VarCoords(h850_era, wind850_era)
v_trans_era&level := v_trans_era&level * -1.
w_trans_era&level := w_trans_era&level * -1.
w_trans_era = w_trans_era * 100.
W_trans_era = w_trans_era * 5.
copy_VarCoords(v_trans_era, w_trans_era)
copy_VarCoords(v_trans_era, W_trans_era)

copy_VarCoords(h850_u60, u850_u60)
copy_VarCoords(h850_u60, v850_u60)
copy_VarCoords(h850_u60, wind850_u60)
v_trans_u60&nVertLevels = v_trans_u60&nVertLevels * -1.
w_trans_u60&nVertLevels = w_trans_u60&nVertLevels * -1.
w_trans_u60 = w_trans_u60 * 100.
W_trans_u60 = w_trans_u60 * 5.
copy_VarCoords(v_trans_u60, w_trans_u60)
copy_VarCoords(v_trans_u60, W_trans_u60)

copy_VarCoords(h850_u3, u850_u3)
copy_VarCoords(h850_u3, v850_u3)
copy_VarCoords(h850_u3, wind850_u3)
v_trans_u3&nVertLevels = v_trans_u3&nVertLevels * -1.
w_trans_u3&nVertLevels = w_trans_u3&nVertLevels * -1.
w_trans_u3 = w_trans_u3 * 100.
W_trans_u3 = w_trans_u3 * 5.
copy_VarCoords(v_trans_u3, w_trans_u3)
copy_VarCoords(v_trans_u3, W_trans_u3)
delete([/h850_era, h850_u60,  ter_u60, \
         h850_u3, ter_u3/])

;------------
ind_area_lat = ind(lat_era .ge. min_lat .and. \
                   lat_era .le. max_lat)
lat_sub = lat_era(ind_area_lat)
nlat = dimsizes(ind_area_lat)
ind_area_lon = ind(lon_era .ge. min_lon .and. \
                   lon_era .le. max_lon)
lon_sub = lon_era(ind_area_lon)
nlat = dimsizes(ind_area_lat)
nlon = dimsizes(ind_area_lon)
wind850_sub = wind850_era(ind_area_lat, ind_area_lon)
ind2d = ind_resolve(maxind(ndtooned(wind850_sub)), (/nlat, nlon/))
print("era max wind:" + wind850_sub(ind2d(0, 0), ind2d(0, 1)))
delete([/wind850_sub/])
print("u60 max wid:" + max(wind850_u60(ind_area_lat, ind_area_lon)))
print("u3 max wid:" + max(wind850_u3(ind_area_lat, ind_area_lon)))
; ==================================================================

; ==================================================================
;                           shared parameters
; ==================================================================
nplt = 6

NRES = 4
setting = set_global_plot_setting(NRES)
;vpX_arr = (/0.08, 0.38, 0.68, 0.08, 0.38, 0.68/)
;vpY_arr = (/0.96, 0.96, 0.96, 0.63, 0.63, 0.63/)
vpX_arr = (/0.08, 0.36, 0.64, 0.08, 0.36, 0.64/)
vpY_arr = (/0.96, 0.96, 0.96, 0.7, 0.7, 0.7/)
vpHei = 0.195
vpWid = 0.26
isAddCyc = False
isOutline = True
tmOn = (/True, False, True, False/)
cnFillOn = True
cnLineOn = False
isSmooth = False
lbHei = 0.24
lbWid = 0.05
cnLv_wind = (/8., 10., 12., 16., 18., 20./)
;cnLv = (/-0.10, -0.06, -0.02, -0.01, -0.006, -0.004, \
;         -0.002, 0.002, \
;         0.004, 0.006, 0.01, 0.02, 0.06, 0.10/) * 100.
cnLv = (/-0.02, -0.01, -0.006, \
         -0.002, 0.002, \
         0.006, 0.01, 0.02/) * 100.



plt_arr = new((/nplt/), graphic)
vc_arr = new((/nplt/), graphic)
hardcir_arr = new((/nplt/), graphic)
plt_path = "./plots/"
plt_name = "S3_Fig3_UVW"
plt_type = "png"
if(plt_type .eq. "png") then
    plt_type@wkWidth = 1024 * NRES
    plt_type@wkHeight = 1024 * NRES
end if
wks = gsn_open_wks(plt_type, plt_path + plt_name)
setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize" : 200000000
end setvalues

res = True ; Plot mods desired.
set_res_basic(res, isAddCyc, setting@gsnFontHei * 0.8)
set_res_cnBasic(res, cnFillOn, cnLineOn)
cmap  = read_colormap_file("MPL_BrBG")
set_res_cnMap(res, False, -1, cmap(10:122, :))
set_res_tmBasic(res, tmOn, setting@tmThick, setting@tmFontHei*1.2, setting@tmLen)
cmap_new = cmap(62:, :)
cmap_new(0, :) = 0.

resuv = res
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

resvw = res
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
;                     Plot 0: ERA5, 850hPa
; ==================================================================
iplt = 0
res0 = resuv
res0@lbLabelBarOn = False
res0@tmXBLabelsOn = True

;res0@gsnLeftString = "~F25~ERA5"
;res0@gsnRightString = "~F25~U&V850hPa"
res0@vpXF = vpX_arr(iplt)
res0@vpYF = vpY_arr(iplt)
res0@vpHeightF = vpHei
res0@vpWidthF = vpWid
set_res_cnExplicitLevel(res0, cnLv_wind)
set_res_cnMap(res0, True, -1, cmap_new)
plt_arr(iplt) = gsn_csm_contour_map(wks, wind850_era, res0)

vres0 = vres
vres0@vcRefMagnitudeF = 25.0
set_res_vcString(vres0, True, "25 m s~S~-1~N~", False, "m s~S~-1~N~")
vc_arr(iplt) = gsn_csm_vector(wks, u850_era, v850_era, vres0)
delete([/u850_era, v850_era/])
; ==================================================================

; ==================================================================
;                     Plot 1: U60km
; ==================================================================
iplt = 1
res1 = resuv
res1@tmYLLabelsOn = False
res1@tmXBLabelsOn = True
res1@lbLabelBarOn = False


;res1@gsnLeftString = "~F25~U60km"
;res1@gsnRightString = "~F25~U&V850hPa"
res1@vpXF = vpX_arr(iplt)
res1@vpYF = vpY_arr(iplt)
res1@vpHeightF = vpHei
res1@vpWidthF = vpWid
set_res_cnExplicitLevel(res1, cnLv_wind)
set_res_cnMap(res1, True, -1, cmap_new)
plt_arr(iplt) = gsn_csm_contour_map(wks, wind850_u60, res1)

vres1 = vres
vres1@vcRefMagnitudeF = 25.0
set_res_vcString(vres1, True, "25 m s~S~-1~N~", False, "m s~S~-1~N~")
vc_arr(iplt) = gsn_csm_vector(wks, u850_u60, v850_u60, vres1)
delete([/u850_u60, v850_u60/])
; ==================================================================

; ==================================================================
;                     Plot 2: U3km
; ==================================================================
iplt = 2
res2 = resuv
res2@tmYLLabelsOn = False
res2@tmXBLabelsOn = True
res2@lbLabelBarOn = True
set_res_lbBasic(res2, setting@lbThick, setting@lbLabelFontHei, \
                setting@lbTiFontHei*0.8, 0.18, lbWid)
;set_res_lbTitle(res2, "(~N~m s~S~-1~N~)", "Bottom")
res2@lbOrientation = "Vertical"
;res2@pmLabelBarOrthogonalPosF = 0.1
;res2@pmLabelBarParallelPosF = 0.6



;res2@gsnLeftString = "~F25~U3km"
;res2@gsnRightString = "~F25~U&V850hPa"
res2@vpXF = vpX_arr(iplt)
res2@vpYF = vpY_arr(iplt)
res2@vpHeightF = vpHei
res2@vpWidthF = vpWid
set_res_cnExplicitLevel(res2, cnLv_wind)
set_res_cnMap(res2, True, -1, cmap_new)
plt_arr(iplt) = gsn_csm_contour_map(wks, wind850_u3, res2)

vres2 = vres
vres2@vcRefMagnitudeF = 25.0
set_res_vcString(vres2, True, "25 m s~S~-1~N~", False, "m s~S~-1~N~")
vc_arr(iplt) = gsn_csm_vector(wks, u850_u3, v850_u3, vres1)
delete([/u850_u3, v850_u3/])
; ==================================================================

; ==================================================================
;                     Plot 3: ERA5, Hardly Circulation
; ==================================================================
iplt = 3
res3 = resvw
res3@tmYLLabelsOn = True
res3@tmXBLabelsOn = True
res3@lbLabelBarOn = False

;res3@gsnLeftString = "~F25~ERA5"
;res3@gsnRightString = "~F25~V&W"
res3@vpXF = vpX_arr(iplt)
res3@vpYF = vpY_arr(iplt)
res3@vpHeightF = vpHei
res3@vpWidthF = vpWid
set_res_cnExplicitLevel(res3, cnLv)
plt_arr(iplt) = gsn_csm_contour(wks, w_trans_era, res3)


vres3 = vres
vres3@vcRefMagnitudeF = 10.0
vres3@vcRefAnnoOn = False
set_res_vcString(vres3, True, "10", False, "")
vc_arr(iplt) = gsn_csm_vector(wks, v_trans_era, W_trans_era, vres3)
delete([/w_trans_era, v_trans_era/])
; ==================================================================

; ==================================================================
;                     Plot 4: U60km, Hardly Circulation
; ==================================================================
iplt = 4
res4 = resvw
res4@tmYLLabelsOn = False
res4@tmXBLabelsOn = True
res4@lbLabelBarOn = False

;res4@gsnLeftString = "~F25~U60km"
;res4@gsnRightString = "~F25~V&W"
res4@vpXF = vpX_arr(iplt)
res4@vpYF = vpY_arr(iplt)
res4@vpHeightF = vpHei
res4@vpWidthF = vpWid
set_res_cnExplicitLevel(res4, cnLv)
plt_arr(iplt) = gsn_csm_contour(wks, w_trans_u60, res4)


vres4 = vres
vres4@vcRefMagnitudeF = 10.0
vres4@vcRefAnnoOn = False
set_res_vcString(vres4, True, "10", False, "")
vc_arr(iplt) = gsn_csm_vector(wks, v_trans_u60, W_trans_u60, vres4)
delete([/w_trans_u60, v_trans_u60/])
; ==================================================================

; ==================================================================
;                     Plot 5: U3km, Hardly Circulatioon
; ==================================================================
iplt = 5
res5 = resvw
res5@tmYLLabelsOn = False
res5@tmXBLabelsOn = True
res5@lbLabelBarOn = True
set_res_lbBasic(res5, setting@lbThick, setting@lbLabelFontHei, \
                setting@lbTiFontHei*0.8, lbHei, lbWid)
;set_res_lbTitle(res5, "w (10~S~-2~N~m s~S~-1~N~)", "Bottom")
res5@lbOrientation = "Vertical"
res5@pmLabelBarOrthogonalPosF = 0.04
res5@pmLabelBarParallelPosF = 0.55


;res5@gsnLeftString = "~F25~U3km"
;res5@gsnRightString = "~F25~V&W"
res5@vpXF = vpX_arr(iplt)
res5@vpYF = vpY_arr(iplt)
res5@vpHeightF = vpHei
res5@vpWidthF = vpWid
set_res_cnExplicitLevel(res5, cnLv)
plt_arr(iplt) = gsn_csm_contour(wks, w_trans_u3, res5)


vres5 = vres
vres5@vcRefMagnitudeF = 10.0
vres5@vcRefAnnoOn = False
set_res_vcString(vres5, True, "10", False, "")
vc_arr(iplt) = gsn_csm_vector(wks, v_trans_u3, W_trans_u3, vres5)
delete([/w_trans_u3, v_trans_u3/])
; ==================================================================
lres = True
lres@gsLineColor = "red2"
lres@gsLineDashPattern = 14
lres@gsLineThicknessF = 11.0
hardcir_lon  = (/70., 90., 90., 70., 70./)
hardcir_lat  = (/-15., -15., 25., 25., -15./)
do iplt = 0, 2
    hardcir_arr(iplt) = gsn_add_polyline(wks, plt_arr(iplt), hardcir_lon, hardcir_lat, lres)
end do
do iplt = 0, nplt-1
    overlay(plt_arr(iplt), vc_arr(iplt))
    draw(plt_arr(iplt))
end do

resTxt = True
resTxt@txFontHeightF = setting@gsnFontHei
resTxt@txJust = "CenterLeft"
figureIndex = "~F25~" + (/"(a)", "(b)", "(c)", \
                          "(d)", "(e)", "(f)"/)
;figureIndex = "~F25~" + (/"A", "B", "C", \
;                          "D", "E", "F"/)
resLeft = resTxt
resLeft@txFontHeightF = setting@gsnFontHei * 0.9
leftstring = "~F25~" + (/"ERA5", "U60km", "U3km", \
                         "ERA5", "U60km", "U3km"/)

resRight = resTxt
resRight@txFontHeightF = setting@gsnFontHei * 0.9
resRight@txJust = "CenterRight"
rightstring = "~F25~" + (/"U&V850hPa", "U&V850hPa", "U&V850hPa", \
                          "V&W", "V&W", "V&W"/)
do iplt = 0, nplt-1
    gsn_text_ndc(wks, figureIndex(iplt), vpX_arr(iplt)+0.003, vpY_arr(iplt)-0.015, resTxt)
    gsn_text_ndc(wks, leftstring(iplt), vpX_arr(iplt)+0.003, vpY_arr(iplt)+0.02, resLeft)
    gsn_text_ndc(wks, rightstring(iplt), vpX_arr(iplt)+vpWid, vpY_arr(iplt)+0.02, resRight)
end do
resTxt@txFontHeightF = setting@gsnFontHei * 0.8
gsn_text_ndc(wks, "~F25~hPa", vpX_arr(3)-0.036, vpY_arr(3)-vpHei-0.01, resTxt)

gsn_text_ndc(wks, "~F25~m s~S~-1~N~", 0.905, 0.77, resTxt)
gsn_text_ndc(wks, "~F25~10~S~-2~N~m s~S~-1~N~", 0.885, 0.48, resTxt)
;drawNDCGrid(wks)
frame(wks)
if(plt_type .eq. "png") then
    cmd = "convert -alpha off -background white -geometry 4096x4096 -density 600 -trim " + \
          plt_path + plt_name + "." + plt_type + " " + \
          plt_path + plt_name + ".jpg"
          ;plt_path + plt_name + "." + plt_type
    system(cmd)
end if
end
