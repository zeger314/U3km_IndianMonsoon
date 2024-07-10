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

f_gp = addfile(input_path + shortname_arr(1) + \
               "_total_rain_20200611-0709.nc", "r")
lat_gp = f_gp->latitude
lon_gp = f_gp->longitude
rain_gp = f_gp->rain / nday
rain_gp!0 = "lat"
rain_gp!1 = "lon"
rain_gp&lat = lat_gp
rain_gp&lon = lon_gp



index_pre = 0
pre_arr = (/"CMORPH", "GPM"/)
if(index_pre .eq. 0) then
    f_u3 = addfile(input_path + "U3km.totalRain0611-0709.U3km2CMORPH.nc", "r")
    f_v4 = addfile(input_path + "V4km.totalRain0611-0709.V4km2CMORPH.nc", "r")
    f_u60 = addfile(input_path + "U60km.totalRain0611-0709.U60km2CMORPH.nc", "r")
else
    f_u3 = addfile(input_path + "U3km.totalRain0611-0709.U3km2GPM.nc", "r")
    f_v4 = addfile(input_path + "V4km.totalRain0611-0709.V4km2GPM.nc", "r")
    f_u60 = addfile(input_path + "U60km.totalRain0611-0709.U60km2GPM.nc", "r")
end if
rain_u3 = f_u3->rain / nday
rain_v4 = f_v4->rain / nday
rain_u60 = f_u60->rain / nday

rain_3c = rain_u3 - rain_cm
rain_4c = rain_v4 - rain_cm
rain_6c = rain_u60 - rain_cm

rain_46 = rain_v4 - rain_u60
rain_36 = rain_u3 - rain_u60

lat_u3 = f_u3->lat
lon_u3 = f_u3->lon

rain_u3!0 = "lat"
rain_u3!1 = "lon"
rain_u3&lat = lat_u3
rain_u3&lon = lon_u3
copy_VarCoords(rain_u3, rain_v4)
copy_VarCoords(rain_u3, rain_u60)
copy_VarCoords(rain_u3, rain_3c)
copy_VarCoords(rain_u3, rain_4c)
copy_VarCoords(rain_u3, rain_6c)
copy_VarCoords(rain_u3, rain_36)
copy_VarCoords(rain_u3, rain_46)

f_v4 = addfile("/storage/aemolcore02/dongze/U3km_data/v4km_mesh/grid_4-60km_23N80E.nc", "r")
dens = f_v4->meshDensity
dist = 4.0 / (dens ^ 0.25)

; ==================================================================

; ==================================================================
;                           shared parameters
; ==================================================================
min_lat = -20.0
max_lat = 40.0
min_lon = 35.0
max_lon = 115.0

ind_lat = ind(lat_u3 .ge. min_lat .and. \
              lat_u3 .le. max_lat)
ind_lon = ind(lon_u3 .ge. min_lon .and. \
              lon_u3 .le. max_lon)
rho_u3 = escorc_n(ndtooned(rain_u3(ind_lat, ind_lon)), \
                  ndtooned(rain_cm(ind_lat, ind_lon)), 0, 0)
rho_v4 = escorc_n(ndtooned(rain_v4(ind_lat, ind_lon)), \
                  ndtooned(rain_cm(ind_lat, ind_lon)), 0, 0)
rho_u60 = escorc_n(ndtooned(rain_u60(ind_lat, ind_lon)), \
                   ndtooned(rain_cm(ind_lat, ind_lon)), 0, 0)
print("RHO, u3: " + rho_u3)
print("RHO, v4: " + rho_v4)
print("RHO, u60: " + rho_u60)
print("RMSE, u3: " + sqrt(avg(rain_3c^2)))
print("RMSE, v4: " + sqrt(avg(rain_4c^2)))
print("RMSE, u60: " + sqrt(avg(rain_6c^2)))


nplt = 6

vpX_arr = (/0.08, 0.38, 0.68, 0.08, 0.38, 0.715/) + 0.02
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

plt_arr = new((/nplt/), graphic)
oc_zone = new((/nplt/), graphic)
india_zone = new((/nplt/), graphic)
plt_path = "./plots/"
plt_name = "S3_Rain_Gridded"
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
set_res_basic(res, isAddCyc, gsnFontHei)
set_res_mpBasic(res, isOutline, mpLineThick)
res@trGridType = "TriangularMesh"  ; This is required to allow
res@mpShapeMode = "FreeAspect"
res@mpMinLatF = min_lat
res@mpMaxLatF = max_lat
res@mpMinLonF = min_lon
res@mpMaxLonF = max_lon
set_res_tmBasic(res, tmOn, tmThick, tmFontHei, tmLen)
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

set_res_cnBasic(res, cnFillOn, cnLineOn)
res@cnRasterSmoothingOn = False
;cmap = read_colormap_file("MPL_RdYlBu")
;cmap = read_colormap_file("BlAqGrYeOrReVi200")
;colors = cmap(6:193:17, :)
;cnlvs = (/0.1, 0.5, 1.0, 4.0, 7.0, \
;          10.0, 15.0, 20.0, 25.0, 30.0, \
;          40.0/)
;cmap = read_colormap_file("./MPL_GnBu.rgb")
cmap = read_colormap_file("MPL_BrBG")
;colors = cmap(35:125:10, :)
;cnlvs = (/0.1, 2.5, 5.0, 7.5, \
;          10.0, 12.5, 15.0, 17.5, \
;          20.0/)
;res@cnLevelSelectionMode = "ExplicitLevels"
;res@cnLevels = cnlvs
;res@cnFillColors = colors
;cnlvs = (/-20., -15.0, -10.0, -7.5, -5.0, -2.5, -0.1, 0, \
;          0.1, 2.5, 5.0, 7.5, 10.0, 15.0, 20./)
;cnlvs = (/-20., -15.0, -10.0, -7.5, -5.0, -2.5, 0, \
;          2.5, 5.0, 7.5, 10.0, 15.0, 20./)
cnlvs = (/-20., -17.5, -15.0, -12.5, \
          -10.0, -7.5, -5.0, -2.5, \
          0, 2.5, 5.0, 7.5, \
          10.0, 12.5, 15.0, 17.5, 20./)
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = cnlvs
res@cnFillPalette = cmap ; Don't use white
; ==================================================================

; ==================================================================
;                     Plot 0: Total Precipitation
; ==================================================================
iplt = 0
res0 = res
res0@lbLabelBarOn = False

res0@gsnCenterString = "~F25~GPCP"
res0@vpXF = vpX_arr(iplt)
res0@vpYF = vpY_arr(iplt)
res0@vpHeightF = vpHei
res0@vpWidthF = vpWid
res0@tmXBLabelsOn = False
plt_arr(iplt) = gsn_csm_contour_map(wks, rain_gp, res0)
delete([/rain_gp/])
; ==================================================================

; ==================================================================
;                     Plot 1: Precipitation
; ==================================================================
iplt = 1
res1 = res
res1@tmYLLabelsOn = False
res1@tmXBLabelsOn = False
res1@lbLabelBarOn = False

res1@gsnCenterString = "~F25~CMORPH"
res1@vpXF = vpX_arr(iplt)
res1@vpYF = vpY_arr(iplt)
res1@vpHeightF = vpHei
res1@vpWidthF = vpWid
res1@tmXBLabelsOn = False
plt_arr(iplt) = gsn_csm_contour_map(wks, rain_cm, res1)
delete([/rain_cm/])
; ==================================================================

; ==================================================================
;                     Plot 2: Precipitation
; ==================================================================
iplt = 2
res2 = res
res2@lbLabelBarOn = False
res2@tmYLLabelsOn = False
res2@tmXBLabelsOn = False


res2@gsnCenterString = "~F25~U60km-CMORPH"
res2@vpXF = vpX_arr(iplt)
res2@vpYF = vpY_arr(iplt)
res2@vpHeightF = vpHei
res2@vpWidthF = vpWid
plt_arr(iplt) = gsn_csm_contour_map(wks, rain_6c, res2)
delete([/rain_u60, rain_6c/])
; ==================================================================

; ==================================================================
;                     Plot 3: Precipitation
; ==================================================================
iplt = 3
res3 = res
res3@tmYLLabelsOn = True
res3@tmXBLabelsOn = True
res3@lbLabelBarOn = False

res3@gsnCenterString = "~F25~V4km-U60km"
res3@vpXF = vpX_arr(iplt)
res3@vpYF = vpY_arr(iplt)
res3@vpHeightF = vpHei
res3@vpWidthF = vpWid
plt_arr(iplt) = gsn_csm_contour_map(wks, rain_46, res3)
delete([/rain_v4, rain_4c, rain_46/])
; ==================================================================

; ==================================================================
;                     Plot 4: Precipitation
; ==================================================================
iplt = 4
res4 = res
res4@tmYLLabelsOn = False
res4@tmXBLabelsOn = True
res4@lbLabelBarOn = True
set_res_lbBasic(res4, lbThick, lbLabelFontHei, lbTiFontHei, lbHei, lbWid)
res4@lbTitleOn = True
res4@lbTitlePosition = "Bottom"
res4@lbTitleString = "~F25~(mm day~S~-1~N~)" ; add in 21-09-05 @dongze
res4@pmLabelBarOrthogonalPosF = 0.1
;res4@pmLabelBarParallelPosF = 1.0

res4@gsnCenterString = "~F25~U3km-U60km"
res4@vpXF = vpX_arr(iplt)
res4@vpYF = vpY_arr(iplt)
res4@vpHeightF = vpHei
res4@vpWidthF = vpWid
plt_arr(iplt) = gsn_csm_contour_map(wks, rain_36, res4)
delete([/rain_u3, rain_3c, rain_36/])
; ==================================================================

; ==================================================================
;                     Plot 5: Precipitation
; ==================================================================
case_arr = (/"CMORPH", "GPCP", "U60km", "V4km", "U3km"/)
ncase = dimsizes(case_arr)
filename_series = input_path + "Rain_TwoZone_2Obs3Sim.nc"
fi = addfile(filename_series, "r")
rain_arr = fi->rain_arr
print(rain_arr)
NRES = 4
iplt = 5

res5 = True ; Plot mods desired.
set_res_basic(res5, isAddCyc, gsnFontHei*0.8)
set_res_tmBasic(res5, tmOn, tmThick, tmFontHei, tmLen)
res5@gsnRightString = "~F25~mm day~S~-1~N~"
res5@pmTickMarkDisplayMode = "always"
res5@tiYAxisOn = True
res5@tiYAxisString = "~F25~northern India"
res5@tiYAxisFontHeightF = 0.0035 * NRES
res5@tiXAxisOn = True
res5@tiXAxisString = "~F25~EIO";"~F25~equatorial Indian Ocean"
res5@tiXAxisFontHeightF = 0.0035 * NRES

res5@tmXMajorGrid = True
res5@tmXMajorGridThicknessF = res5@tmBorderThicknessF * 0.6
res5@tmXBMajorThicknessF = res5@tmBorderThicknessF * 0.9
res5@tmXBLabelDeltaF = -0.9
res5@tmYMajorGrid = True
res5@tmYMajorGridThicknessF = res5@tmBorderThicknessF * 0.6
res5@tmYLMajorThicknessF = res5@tmBorderThicknessF * 0.9
res5@tmYLLabelDeltaF = -0.9

res5@trXMaxF = 15.0
res5@trXMinF = 5.
res5@tmXBMode = "Explicit"
res5@tmXBValues = (/5., 10., 15./)
res5@tmXBLabelsOn = True
res5@tmXBLabels = "~F25~" + (/5, 10, 15/)
res5@tmXBMinorValues = (/6, 7, 8, 9, \
                        11, 12, 13, 14/) * 1.
res5@tmXBLabelAngleF = 0.

res5@trYMaxF = 15.0
res5@trYMinF = 5.0
res5@tmYLMode = "Explicit"
res5@tmYLValues = res5@tmXBValues
res5@tmYLLabels = (/"~F25~5", "~F25~10", \
                   "~F25~15"/)
res5@tmYLMinorValues = (/6.0, 7.0, 8.0, 9.0, \
                         11., 12., 13., 14./)

mrk_arr = (/16, 16, 9, 9, 9, 9, \
            4, 4, 4, 4, 4, 4/)
color_arr = (/"black", "brown", \
              "black", "blue", "brown", "red", \
              "black", "blue", "brown", "red", "grey", "green"/)
res5@vpXF = vpX_arr(iplt)
res5@vpYF = vpY_arr(iplt) 
res5@vpHeightF = 0.18
res5@vpWidthF = 0.18
test = rain_arr
test@_FillValue = -999.
test = test@_FillValue
plt_arr(iplt) = gsn_csm_xy(wks, test(:, 1), test(:, 0), res5)

mrk_plt_arr = new(ncase, graphic)
resM = True
resM@gsMarkerSizeF = 0.015
resM@gsMarkerThicknessF = 6. * NRES
do icase = 0, ncase-1
    resM@gsMarkerIndex = mrk_arr(icase)
    resM@gsMarkerColor = color_arr(icase)
    mrk_plt_arr(icase) = gsn_add_polymarker(wks, plt_arr(iplt), \
                                            rain_arr(icase, 1), \
                                            rain_arr(icase, 0), resM)
end do
print(rain_arr(:, 1))

xpos = (/0.925, 0.925, 0.925, 0.925, 0.925/)
ypos = (/0.70, 0.67, 0.64, 0.61, 0.58/) - 0.005
label = "~F25~" + case_arr
txres = True
txres@txFontHeightF = 0.01
txres@txJust = "CenterLeft"
;txres@txDirection = "down"
gnres = True
gnres@gsMarkerSizeF = 0.008
gnres@gsMarkerThicknessF = 5. * NRES
do i = 0, ncase-1
    xp = xpos(i)
    yp = ypos(i)
    gnres@gsMarkerIndex = mrk_arr(i)
    gnres@gsMarkerColor = color_arr(i)
    gsn_polymarker_ndc(wks, xp, yp, gnres)
    gsn_text_ndc(wks, label(i), xp+0.01, yp, txres)
end do
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
do iplt = 0, 4
    india_zone(iplt) = gsn_add_polyline(wks, plt_arr(iplt), india_lon, india_lat, lres)
    oc_zone(iplt) = gsn_add_polyline(wks, plt_arr(iplt), zone1_lon, zone1_lat, lres)
end do
lnres=True
lnres@gsLineColor = "black"
lnres@gsLineDashPattern = 0
lnres@gsLineThicknessF = 8.0
cen_lat = 23.
cen_lon = 80.
circle1 := geolocation_circle(cen_lat, cen_lon, 13.2, 0, 180, False)
circle_lat1 := circle1[0]                   ; For clarity: explicitly extract list elements¬
circle_lon1 := circle1[1]
lnres@gsLineColor = "black"
dum121 = gsn_add_polyline(wks, plt_arr(3), circle_lon1(0,0,:), circle_lat1(0,0,:), lnres)

circle2 := geolocation_circle(cen_lat, cen_lon, 32, 0, 180, False)
circle_lat2 := circle2[0]                   ; For clarity: explicitly extract list elements
circle_lon2 := circle2[1]
;lnres@gsLineColor = "red"
lnres@gsLineDashPattern = 14
dum222 = gsn_add_polyline(wks, plt_arr(3), circle_lon2(0,0,:), circle_lat2(0,0,:), lnres)
; ==================================================================

do iplt = 0, nplt-1
    draw(plt_arr(iplt))
end do

resTxt = True
resTxt@txFontHeightF = gsnFontHei + 0.005
resTxt@txJust = "CenterLeft"
figureIndex = "~F25~" + (/"(a)", "(b)", "(c)", \
                          "(d)", "(e)", "(f)"/)
;figureIndex = "~F25~" + (/"A", "B", "C", \
;                          "D", "E", "F"/)
do iplt = 0, nplt-1
    gsn_text_ndc(wks, figureIndex(iplt), vpX_arr(iplt)+0.003, vpY_arr(iplt)-0.015, resTxt)
end do
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
