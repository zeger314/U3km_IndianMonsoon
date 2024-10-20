; ==================================================================
; S2_Plt_Fig4_Rain3hrAndLH.ncl
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
areaname_arr = (/"SecZone", "BroadArea"/)
case_arr = (/"CMORPH", "GPM", "U60km", "U3km"/)
ncase = dimsizes(case_arr)
input_path = "/storage/aemolcore02/dongze/U3km_data/midDataForPaper/"
file_prefix = "Rain3hr.PDF."
lh_prefix = "IntegratedLH.newRain3hrLv."
loc_u60 = "/storage/aemolcore02/jungu/mesh/u60km/x1.163842.grid.nc"
loc_u3 = "/storage/aemolcore02/jungu/mesh/u3km/init_static.nc"
pdf_suffix0 = "_allcell_rain3hr_pdf_valLv1.nc"
pdf_suffix1 = ".rain3hrPDF.lv1"
;index_pre = 0
index_pre = 1
if(index_pre .eq. 0) then
    pdf_suffix2 = "2CMORPH.nc"
else
    pdf_suffix2 = "2GPM.nc"
end if
nlv = 5
;;------------------U60km-------------------------
PDF = new((/ncase, nlv/), double)
do ic = 0, ncase-1
    datai = asciiread(input_path + file_prefix + case_arr(ic) + "." + \
                        areaname_arr(1) + ".txt", -1, "string")
    pdfi = todouble(str_get_field(datai(2:), 2, ","))
    PDF(ic, 0) = todouble(100.) - sum(pdfi(1:4))
    PDF(ic, 1:4) = (/pdfi(1:4)/)
end do
print(PDF)


areaname_arr = (/"SecZone", "BroadArea"/)
area_latlon = (/(/-10., 0., 50., 100./), \
                (/-20., 40., 35., 115./)/)
min_lat = -20.0
max_lat = 40.0
min_lon = 35.0
max_lon = 115.0

nfile = 232
if(index_pre .eq. 0) then
    f_pre = addfile(input_path + case_arr(0) + pdf_suffix0, "r")
    drizzle_pre = f_pre->PDF / nfile * 100.
    lat_pre = f_pre->lat
    lon_pre = f_pre->lon
    drizzle_pre!0 = "lat"
    drizzle_pre!1 = "lon"
    drizzle_pre&lat = lat_pre
    drizzle_pre&lon = lon_pre
else
    f_pre = addfile(input_path + case_arr(1) + pdf_suffix0, "r")
    drizzle_pre = f_pre->PDF / nfile * 100.
    lat_pre = f_pre->lat
    lon_pre = f_pre->lon
    drizzle_pre!0 = "lat"
    drizzle_pre!1 = "lon"
    drizzle_pre&lat = lat_pre
    drizzle_pre&lon = lon_pre
end if
f_u60 = addfile(input_path + case_arr(2) + pdf_suffix1 + \
                case_arr(2) + pdf_suffix2, "r")
drizzle_u60 = f_u60->PDF / nfile * 100.
lat_u60 = f_u60->lat
lon_u60 = f_u60->lon
f_u3 = addfile(input_path + case_arr(3) + pdf_suffix1 + \
               case_arr(3) + pdf_suffix2, "r")
drizzle_u3 = f_u3->PDF / nfile * 100.
lat_u3 = f_u3->lat
lon_u3 = f_u3->lon
delete([/f_u60, f_u3/])

diff_6p = drizzle_u60 - drizzle_pre
diff_36 = drizzle_u3 - drizzle_u60
copy_VarCoords(drizzle_pre, diff_6p)
copy_VarCoords(drizzle_pre, diff_36)

ind_lat = ind(lat_u60 .ge. area_latlon(1, 0) .and. \
              lat_u60 .le. area_latlon(1, 1))
ind_lon = ind(lon_u60 .ge. area_latlon(1, 2) .and. \
              lon_u60 .le. area_latlon(1, 3))
print(case_arr(index_pre) + ": " + avg(drizzle_pre(ind_lat, ind_lon)))
print(case_arr(2) + ": " + avg(drizzle_u60(ind_lat, ind_lon)))
print(case_arr(3) + ": " + avg(drizzle_u3(ind_lat, ind_lon)))

rho_u3 = escorc_n(ndtooned(drizzle_u3(ind_lat, ind_lon)), \
                  ndtooned(drizzle_pre(ind_lat, ind_lon)), 0, 0)
rho_u60 = escorc_n(ndtooned(drizzle_u60(ind_lat, ind_lon)), \
                   ndtooned(drizzle_pre(ind_lat, ind_lon)), 0, 0)
print(case_arr(2) + ", rho:" + rho_u60)
print(case_arr(3) + ", rho:" + rho_u3)

; ==================================================================
;                           shared parameters
; ==================================================================
nplt = 4
NRES = 4
setting = set_global_plot_setting(NRES)
;vpX_arr = (/0.08, 0.49/) + 0.02
;vpY_arr = (/0.96, 0.96/)
vpX_arr = (/0.08, 0.26, 0.37, 0.66/) + 0.005
vpY_arr = (/0.96, 0.87, 0.96, 0.96/)
;vpX_arr = (/0.08, 0.26, 0.37, 0.08, 0.37/) + 0.005
;vpY_arr = (/0.96, 0.87, 0.96, 0.96/)


vpWid = 0.28
vpHei = 0.21
tmOn = (/True, False, True, False/)
isAddCyc = False
isOutline = True
mpLineThick = 3.0
cnFillOn = True
cnLineOn = False
lbHei = 0.02
lbWid = 0.35


;plt_arr = new((/nplt, ncase/), graphic)
plt_arr = new((/nplt/), graphic)
plt_path = "./plots/"
plt_name = "S6_Fig2_Rain3hr_BroadArea_withDiff"
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
;set_res_basic(res, False, setting@gsnFontHei * 0.72)
set_res_basic(res, False, 0.015)
delete(res@gsnAddCyclic)
cmap  = read_colormap_file("MPL_BrBG")
;color_arr = (/"black", "red", "blue"/)
color_arr = new((/ncase, 3/), float)
color_arr(0, :) = 0.
color_arr(1, :) = (/125, 125, 125/) / 255.
color_arr(2, :) = (/193, 61, 31/) / 255.
color_arr(3, :) = (/21, 83, 183/) / 255.
set_res_tmBasic(res, tmOn, setting@tmThick*1.8, setting@tmFontHei*1.2, setting@tmLen*0.8)
res@trXMaxF = nlv + 0.6
res@trXMinF = 0.4
res@tmXBMode = "Explicit"
res@tmXBValues = ispan(1, nlv, 1)
res@tmXBLabelsOn = True
;res@tmXBLabels = (/"~F25~<0.01", "~F25~0.01-0.1", \
;                   "~F25~0.1-3", "~F25~3-10", \
;                   "~F25~10-20", "~F25~>20"/)
;res@tmXBLabels = (/"~F25~<0.1~C~few", \
;                   "~F25~0.1~F34~*~F25~3~C~light", \
;                   "~F25~  3~F34~*~F25~10~C~moderate", \
;                   "~F25~10~F34~*~F25~20~C~heavy", \
;                   "~F25~   >20~C~torrential"/)
res@tmXBLabels = (/"~F25~little~C~<0.1", \
                   "~F25~light~C~0.1~F34~*~F25~3", \
                   "~F25~moderate~C~  3~F34~*~F25~10", \
                   "~F25~heavy~C~10~F34~*~F25~20", \
                   "~F25~torrential~C~   >20"/)
res@tmXBLabelDeltaF = -1.1

res@tmXBLabelAngleF = -35.
res@tmXBMinorOn = False
res@tmXBMajorOutwardLengthF = res@tmXBMajorLengthF
res@tmYLMajorOutwardLengthF = res@tmYLMajorLengthF
res@tmXBMajorOutwardLengthF = res@tmXBMajorLengthF
res@tmYLMajorOutwardLengthF = res@tmYLMajorLengthF

res@tmXBMinorOutwardLengthF = res@tmXBMinorLengthF
res@tmYLMinorOutwardLengthF = res@tmYLMinorLengthF
res@tmXBMinorOutwardLengthF = res@tmXBMinorLengthF
res@tmYLMinorOutwardLengthF = res@tmYLMinorLengthF

cnres = True ; Plot mods desired.
set_res_basic(cnres, False, setting@gsnFontHei * 0.72)
set_res_mpBasic(cnres, isOutline, mpLineThick)
cnres@trGridType = "TriangularMesh"  ; This is required to allow
cnres@mpShapeMode = "FreeAspect"
cnres@mpMinLatF = min_lat
cnres@mpMaxLatF = max_lat
cnres@mpMinLonF = min_lon
cnres@mpMaxLonF = max_lon
set_res_tmBasic(cnres, tmOn, setting@tmThick*1.8, setting@tmFontHei*1.2, setting@tmLen*0.8)
cnres@tmXBMinorOn = True
cnres@tmXBValues = (/40.0, 60.0, 80.0, 100.0/)
cnres@tmXBMinorValues = (/35.0, \
                        45.0, 50.0, 55.0, \
                        65.0, 70.0, 75.0, \
                        85.0, 90.0, 95.0, \
                        105.0, 110.0, 115.0/)
cnres@tmXBLabels = "~F25~" + \
                 (/"40~S~o~N~E", "60~S~o~N~E", \
                   "80~S~o~N~E", "100~S~o~N~E"/)
cnres@tmYLMinorOn = True
cnres@tmYLValues = (/-20.0, 0.0, 20.0, 40.0/)
cnres@tmYLMinorValues = (/-15.0, -10.0, -5.0, \
                        5.0, 10.0, 15.0, \
                        25.0, 30.0, 35.0/)
cnres@tmYLLabels = "~F25~" + \
                 (/"20~S~o~N~S", "0~S~o~N~", \
                   "20~S~o~N~N", "40~S~o~N~N"/)

set_res_cnBasic(cnres, cnFillOn, cnLineOn)
cnres@cnRasterSmoothingOn = False
cmap = read_colormap_file("MPL_BrBG")
;colors = cmap(35:125:10, :)
;cnlvs = (/10, 20, 30, 40, 50, \
;          60, 70, 80, 90/) * 1.
;cnres@cnFillColors = colors
;cnlvs = (/-50., -40., -30, -20., -10, -5, 0, 5, \
;          10, 20., 30, 40, 50/)
cnlvs = (/-60., -50., -40., -30, -20., -10, 0, \
          10, 20., 30, 40, 50, 60/)
cnres@cnLevelSelectionMode = "ExplicitLevels"
cnres@cnLevels = cnlvs
cnres@cnFillPalette = cmap ; Don't use white
; ==================================================================

; ==================================================================
;                     Plot 0: Rain3hr
; ==================================================================
iplt = 0
res0 = res
res0@tmYMajorGrid = True
;res0@tmYMajorGridThicknessF = res0@tmXBMajorThicknessF * 0.8
res0@tmYLMode = "Explicit"
res0@trYMaxF = 100.
res0@trYMinF = 0.
res0@tmYLValues = (/0, 20.0, 40.0, 60.0, 80.0, 100.0/)
res0@tmYLLabels = "~F25~" + \
                  (/"0", "20", "40", \
                    "60", "80", "100"/)

res0@tmYLMinorOn = True
res0@tmYLMinorValues = (/10., \
                         30., \
                         50., \
                         70.0, \
                         90.0/)


res0@tmYLLabelsOn = True
res0@tmXBLabelsOn = True
res0@tiYAxisOn = False
res0@tiYAxisString = "~F25~Frequency (%)"
res0@gsnCenterString = "~F25~Frequency (%)"
res0@tiXAxisOn = False
res0@tiXAxisString = "~F25~Level (mm 3hr~S~-1~N~)"
res0@tiYAxisFontHeightF = 0.015
res0@tiXAxisFontHeightF = 0.015
res0@vpXF = vpX_arr(iplt)
res0@vpYF = vpY_arr(iplt)
res0@vpHeightF = vpHei
res0@vpWidthF = vpWid
;do ic = 0, ncase-1
;    res0@gsnXYBarChartColors = color_arr(ic)
;    plt_arr(iplt, ic) = gsn_csm_xy(wks, \
;                                   fspan(1.00+(ic-1)*res0@gsnXYBarChartBarWidth, \
;                                         6.00+(ic-1)*res0@gsnXYBarChartBarWidth, nlv), \
;                                   PDF(ic, :), res0)
;    draw(plt_arr(iplt, ic))
;end do
res0@xyMarkLineMode = "MarkLines"
res0@xyLineColors = color_arr
res0@xyDashPattern = 0
res0@xyMarker = 16
res0@xyLineThicknessF = 15.0
res0@xyMarkerSizeF = 0.008
res0@xyMarkerColors = color_arr
res0@xyMarkerThicknessF = 8.0
plt_arr(iplt) = gsn_csm_xy(wks, ispan(1, nlv, 1), PDF, res0)
;draw(plt_arr(iplt))

; ==================================================================

; ==================================================================
;                     Plot 1: Rain3hr_HeavyRain
; ==================================================================
iplt = 1
res1 = res
res1@tmYMajorGrid = False
res1@tmYLMode = "Explicit"
res1@trYMaxF = 1.2
res1@trYMinF = 0.
res1@trXMaxF = 5.5
res1@trXMinF = 3.5
res1@tmXBLabels = (/"~F25~<0.1", \
                   "~F25~0.1~F34~*~F25~3", \
                   "~F25~3~F34~*~F25~10", \
                   "~F25~10~F34~*~F25~20", \
                   "~F25~>20"/)
res1@tmXBLabelAngleF = -20.
res1@tmXBLabelDeltaF = -0.9
res1@tmYLValues = (/0, 1.0/)
res1@tmYLLabels = "~F25~" + \
                  (/"0", "1.0"/)

res1@tmYLMinorOn = True
res1@tmYLMinorValues = (/0.2, 0.4, 0.6, \
                         0.8, 1.2/)

res1@tmYLLabelsOn = True
res1@tmXBLabelsOn = True
res1@tmYLLabelFontHeightF = res@tmYLLabelFontHeightF * 0.8
res1@tmXBLabelFontHeightF = res@tmXBLabelFontHeightF * 0.8
res1@tiYAxisOn = False
res1@vpXF = vpX_arr(iplt)
res1@vpYF = vpY_arr(iplt)
res1@vpHeightF = vpHei * 0.4
res1@vpWidthF = vpWid * 0.3

res1@xyMarkLineMode = "MarkLines"
res1@xyLineColors = color_arr
res1@xyDashPattern = 0
res1@xyMarker = 16
res1@xyLineThicknessF = 15.0
res1@xyMarkerSizeF = 0.008
res1@xyMarkerColors = color_arr
res1@xyMarkerThicknessF = 8.0
plt_arr(iplt) = gsn_csm_xy(wks, ispan(1, nlv, 1), PDF, res1)
; ==================================================================

; ==================================================================
;                     Plot 2: U60km,PDF
; ==================================================================
iplt = 2
res2 = cnres
res2@lbLabelBarOn = False

;res2@gsnLeftString = "~F25~U60km"
;res2@gsnRightString = "~F25~0.1~F34~*~F25~3 (mm 3hr~S~-1~N~)"
;res2@vpXF = vpX_arr(iplt)
;res2@vpYF = vpY_arr(iplt)
;res2@vpHeightF = vpHei
;res2@vpWidthF = vpWid
;res2@tmXBLabelsOn = True
;res2@tmYLOn = False
;res2@tmYROn = False
;res2@tmYLLabelsOn = False
;res2@sfYArray = lat_u60
;res2@sfXArray = lon_u60
;plt_arr(iplt) = gsn_csm_contour_map(wks, drizzle_u60, res2)
res2@gsnCenterString= "~F25~U60km-CMORPH"
;res2@gsnRightString = "~F25~0.1~F34~*~F25~3 (mm 3hr~S~-1~N~)"
res2@vpXF = vpX_arr(iplt)
res2@vpYF = vpY_arr(iplt)
res2@vpHeightF = vpHei
res2@vpWidthF = vpWid
res2@tmXBLabelsOn = True
res2@tmYLOn = False
res2@tmYROn = False
res2@tmYLLabelsOn = False
plt_arr(iplt) = gsn_csm_contour_map(wks, diff_6p, res2)
; ==================================================================

; ==================================================================
;                     Plot 3: U3km,PDF
; ==================================================================
iplt = 3
res3 = cnres
res3@lbLabelBarOn = True
set_res_lbBasic(res3, setting@lbThick, \
                setting@lbLabelFontHei, \
                setting@lbTiFontHei, lbHei, lbWid)
res3@lbTitleOn = False
res3@lbTitlePosition = "Bottom"
res3@lbTitleString = "~F25~Frequency of light rain (%)" ; add in 21-09-05 @dongze
res3@pmLabelBarOrthogonalPosF = 0.15
res3@pmLabelBarParallelPosF = -0.025


;res3@gsnLeftString = "~F25~U3km"
;res3@gsnRightString = "~F25~0.1~F34~*~F25~3 (mm 3hr~S~-1~N~)"
;res3@vpXF = vpX_arr(iplt)
;res3@vpYF = vpY_arr(iplt)
;res3@vpHeightF = vpHei
;res3@vpWidthF = vpWid
;res3@tmXBLabelsOn = True
;res3@tmYLOn = False
;res3@tmYLLabelsOn = False
;res3@tmYROn = True
;res3@tmYRValues = res3@tmYLValues
;res3@tmYRLabelsOn = True
;res3@tmYRLabels = res3@tmYLLabels
;res3@sfYArray = lat_u3
;res3@sfXArray = lon_u3
;plt_arr(iplt) = gsn_csm_contour_map(wks, drizzle_u3, res3)
res3@gsnCenterString = "~F25~U3km-U60km"
res3@vpXF = vpX_arr(iplt)
res3@vpYF = vpY_arr(iplt)
res3@vpHeightF = vpHei
res3@vpWidthF = vpWid
res3@tmXBLabelsOn = True
res3@tmYLOn = False
res3@tmYLLabelsOn = False
res3@tmYROn = True
res3@tmYRValues = res3@tmYLValues
res3@tmYRLabelsOn = True
res3@tmYRLabels = res3@tmYLLabels
plt_arr(iplt) = gsn_csm_contour_map(wks, diff_36, res3)
; ==================================================================
delete([/drizzle_u3, lat_u3, lon_u3, \
         drizzle_u60, lat_u60, lon_u60/])
lres = True
lres@gsLineColor = "red2"
lres@gsLineDashPattern = 14
lres@gsLineThicknessF = 11.0
india_lon  = (/72.5, 92.5, 92.5, 72.5, 72.5/)
india_lat  = (/15.0, 15.0, 25.0, 25.0, 15.0/)
zone1_lon = (/50., 100., 100., 50., 50./)
zone1_lat = (/-10., -10., 0., 0., -10./)
india_zone = new(2, graphic)
oc_zone = new(2, graphic)
do iplt = 2, 3
    india_zone(iplt-2) = gsn_add_polyline(wks, plt_arr(iplt), india_lon, india_lat, lres)
    oc_zone(iplt-2) = gsn_add_polyline(wks, plt_arr(iplt), zone1_lon, zone1_lat, lres)
end do

do iplt = 0, nplt-1
    draw(plt_arr(iplt))
end do
xpos = (/0.525, 0.525, 0.525, 0.525/) - 0.25
ypos = (/0.90, 0.88, 0.86, 0.84/) + 0.045
label = "~F25~" + case_arr
txres = True
txres@txFontHeightF = 0.01
txres@txJust = "CenterLeft"
;txres@txDirection = "down"
gnres = True
gnres@gsMarkerSizeF = 0.008
gnres@gsMarkerThicknessF = 5. * NRES
lnres = True
lnres@gsLineDashPattern = 0
lnres@gsLineThicknessF = res0@xyLineThicknessF
do i = 0, ncase-1
    xp = xpos(i)
    yp = ypos(i)
    gnres@gsMarkerIndex = 16
    gnres@gsMarkerColor = color_arr(i, :)
    gsn_polymarker_ndc(wks, xp, yp, gnres)
    lnres@gsLineColor = color_arr(i, :)
    gsn_polyline_ndc(wks, (/xp-0.01, xp+0.01/), (/yp, yp/), lnres)
    gsn_text_ndc(wks, label(i), xp+0.015, yp, txres)
end do
txres@txJust = "CenterCenter"
txres@txFontHeightF = 0.015
tilabel = "~F25~Intensity (mm 3hr~S~-1~N~)"
gsn_text_ndc(wks, tilabel, 0.225, 0.68, txres)
lblabel = "~F25~Frequency of light rain (%)" ; add in 21-09-05 @dongze
gsn_text_ndc(wks, lblabel, 0.660, 0.68, txres)


resTxt = True
resTxt@txFontHeightF = setting@gsnFontHei
resTxt@txJust = "CenterLeft"
figureIndex = "~F25~" + (/"(a)", "(b)", "(c)", \
                          "(d)", "(e)", "(f)"/)
;figureIndex = "~F25~" + (/"A", "B", "C", \
;                          "D", "E", "F"/)

iplt = 0
gsn_text_ndc(wks, figureIndex(iplt), vpX_arr(iplt)+0.003, vpY_arr(iplt)-0.015, resTxt)
do iplt = 2, nplt-1
    gsn_text_ndc(wks, figureIndex(iplt-1), vpX_arr(iplt)+0.003, vpY_arr(iplt)-0.015, resTxt)
end do
;drawNDCGrid(wks)
frame(wks)
if(plt_type .eq. "png") then
    cmd = "convert -alpha off -background white -geometry 4096x4096 -density 300 -trim " + \
          plt_path + plt_name + "." + plt_type + " " + \
          plt_path + plt_name + ".jpg"
    system(cmd)
end if
end
