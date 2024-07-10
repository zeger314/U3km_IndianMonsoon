; ==================================================================
; S2_Plt_Fig3_UVW_diff.ncl
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
area_name = "HrdlyCir2"
area_latlon = (/-35., 25., 70., 90./)
g = 9.78


input_path = "/storage/aemolcore02/dongze/U3km_data/midDataForPaper/"
shortname_arr = (/"ERA5", "U60km", "U3km"/)
nday = 29
;;------------------U60km-------------------------
f_u = addfile(input_path + shortname_arr(1) + "_avg/uzonal_850hPa.U60km2ERA5.nc", "r")
u850_u60 = f_u->uzonal_850hPa
f_v = addfile(input_path + shortname_arr(1) + "_avg/umeridional_850hPa.U60km2ERA5.nc", "r")
v850_u60 = f_v->umeridional_850hPa
f_w = addfile(input_path + shortname_arr(1) + "_avg/w_500hPa.U60km2ERA5.nc", "r")
w500_u60 = f_w->w_500hPa
f_z1 = addfile(input_path + shortname_arr(1) + "_avg/height_850hPa.U60km2ERA5.nc", "r")
h850_u60 = f_z1->height_850hPa
f_z2 = addfile(input_path + shortname_arr(1) + "_avg/height_500hPa.U60km2ERA5.nc", "r")
h500_u60 = f_z2->height_500hPa
f_t = addfile(input_path + shortname_arr(1) + "_avg/ter.U60km2ERA5.nc", "r")
ter_u60 = f_t->ter
f_u60 = addfile(input_path + shortname_arr(1) + "_avg/uvzw_lvp." + \
                area_name + ".avg.nc", "r")
v_trans_u60 = f_u60->v
w_trans_u60 = f_u60->w
delete([/f_u, f_v, f_w, f_z1, f_z2, f_u60/])
;;------------------U3km-------------------------
f_u = addfile(input_path + shortname_arr(2) + "_avg/uzonal_850hPa.U3km2ERA5.nc", "r")
u850_u3 = f_u->uzonal_850hPa
f_v = addfile(input_path + shortname_arr(2) + "_avg/umeridional_850hPa.U3km2ERA5.nc", "r")
v850_u3 = f_v->umeridional_850hPa
f_w = addfile(input_path + shortname_arr(2) + "_avg/w_500hPa.U3km2ERA5.nc", "r")
w500_u3 = f_w->w_500hPa
f_z1 = addfile(input_path + shortname_arr(2) + "_avg/height_850hPa.U3km2ERA5.nc", "r")
h850_u3 = f_z1->height_850hPa
f_z2 = addfile(input_path + shortname_arr(2) + "_avg/height_500hPa.U3km2ERA5.nc", "r")
h500_u3 = f_z2->height_500hPa
f_t = addfile(input_path + shortname_arr(2) + "_avg/ter.U3km2ERA5.nc", "r")
ter_u3 = f_t->ter
f_u3 = addfile(input_path + shortname_arr(2) + "_avg/uvzw_lvp." + \
               area_name + ".avg.nc", "r")
v_trans_u3 = f_u3->v
w_trans_u3 = f_u3->w
delete([/f_u, f_v, f_w, f_z1, f_z2, f_u3/])

u850_u60 = where(h850_u60 .le. ter_u60, u850_u60@_FillValue, u850_u60)
v850_u60 = where(h850_u60 .le. ter_u60, v850_u60@_FillValue, v850_u60)
w500_u60 = where(h500_u60 .le. ter_u60, w500_u60@_FillValue, w500_u60)

u850_u3 = where(h850_u3 .le. ter_u3, u850_u3@_FillValue, u850_u3)
v850_u3 = where(h850_u3 .le. ter_u3, v850_u3@_FillValue, v850_u3)
w500_u3 = where(h500_u3 .le. ter_u3, w500_u3@_FillValue, w500_u3)

u850 = u850_u60 - u850_u3
v850 = v850_u60 - v850_u3
w500 = (w500_u60 - w500_u3) * 100.
v_trans = v_trans_u60 - v_trans_u3
w_trans = (w_trans_u60 - w_trans_u3) * 100.
W_trans = (w_trans_u60 - w_trans_u3) * 500.

h850_diff = (h850_u60 - h850_u3)
h850_diff = where(h850_u60 .le. ter_u60 .or. \
                  h850_u3 .le. ter_u3, h850_diff@_FillValue, h850_diff)
copy_VarCoords(h850_u60, u850)
copy_VarCoords(h850_u60, v850)
copy_VarCoords(h850_u60, w500)
copy_VarCoords(h850_u60, h850_diff)
v_trans_u3&nVertLevels = v_trans_u3&nVertLevels * -1.
copy_VarCoords(v_trans_u3, v_trans)
copy_VarCoords(v_trans_u3, w_trans)
copy_VarCoords(v_trans_u3, W_trans)
delete([/h850_u60, h500_u60, ter_u60, u850_u60, v850_u60, w500_u60, \
         h850_u3, h500_u3, ter_u3, u850_u3, v850_u3, w500_u3/])
; ==================================================================

; ==================================================================
;                           shared parameters
; ==================================================================
;min_lat = -40.0
min_lat = -20.0
max_lat = 40.0
min_lon = 35.0
max_lon = 115.0
nplt = 2

NRES = 4
setting = set_global_plot_setting(NRES)
vpX_arr = (/0.08, 0.41/) + 0.02
vpY_arr = (/0.96, 0.96, 0.96, 0.69, 0.69, 0.69/)
vpHei = 0.21
vpWid = 0.28
isAddCyc = False
isOutline = True
tmOn = (/True, False, True, False/)
cnFillOn = True
cnLineOn = False
isSmooth = False
lbHei = 0.03
lbWid = 0.28
;cnLv = (/-0.02, -0.015, -0.010, -0.006, -0.003, \
;         0, 0.003, 0.006, 0.010, 0.015, 0.02/) * 100.
cnLv = (/-0.02, -0.016, -0.012, -0.008, -0.004, \
         0, 0.004, 0.008, 0.012, 0.016, 0.02/) * 100.


plt_arr = new((/nplt/), graphic)
vc_arr = new((/nplt/), graphic)
india_zone = new((/nplt/), graphic)
oc_zone = new((/nplt/), graphic)
plt_path = "./plots/"
plt_name = "S3_Fig5_UVW_diff"
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
set_res_cnMap(res, False, -1, cmap)
set_res_tmBasic(res, tmOn, setting@tmThick, setting@tmFontHei*1.1, setting@tmLen)

resuv = res
set_res_mpBasic(resuv, isOutline, setting@mpLineThick * 1.1)
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

resuv@tmXBMajorOutwardLengthF = resuv@tmXBMajorLengthF
resuv@tmYLMajorOutwardLengthF = resuv@tmYLMajorLengthF
resvw@tmXBMajorOutwardLengthF = resvw@tmXBMajorLengthF
resvw@tmYLMajorOutwardLengthF = resvw@tmYLMajorLengthF
print(resuv@tmXBMajorLengthF)
print(resvw@tmXBMajorLengthF)
; ==================================================================

; ==================================================================
;                     Plot 0: U60km
; ==================================================================
iplt = 1
res0 = resuv
res0@tmYLLabelsOn = True
res0@tmXBLabelsOn = True
res0@lbLabelBarOn = True
set_res_lbBasic(res0, setting@lbThick, setting@lbLabelFontHei, \
                setting@lbTiFontHei*0.8, lbHei, lbWid)
;set_res_lbTitle(res0, "Geopotential height at 850hPa (gpm)", "Bottom")
res0@pmLabelBarOrthogonalPosF = 0.1
res0@vpXF = vpX_arr(iplt)
res0@vpYF = vpY_arr(iplt)
res0@vpHeightF = vpHei
res0@vpWidthF = vpWid
cnLv_gh = (/-20.0, -16.0, -12.0, -8.0, -4.0, 0.0, \
            4.0, 8.0, 12.0, 16.0, 20.0/)
set_res_cnExplicitLevel(res0, cnLv_gh)
plt_arr(iplt) = gsn_csm_contour_map(wks, h850_diff, res0)

vres0 = vres
vres0@vcRefMagnitudeF = 5.0
set_res_vcString(vres0, True, "5 m s~S~-1~N~", False, "m s~S~-1~N~")
vc_arr(iplt) = gsn_csm_vector(wks, u850, v850, vres0)
delete([/w500, u850, v850/])
; ==================================================================

; ==================================================================
;                     Plot 4: U60km, Hardly Circulation
; ==================================================================
iplt = 0
res1 = resvw
res1@tmYLLabelsOn = True
res1@tmXBLabelsOn = True
res1@lbLabelBarOn = True
set_res_lbBasic(res1, setting@lbThick, setting@lbLabelFontHei, \
                setting@lbTiFontHei*0.8, lbHei, lbWid)
;set_res_lbTitle(res1, "w (10~S~-2~N~m s~S~-1~N~)", "Bottom")
res1@vpXF = vpX_arr(iplt)
res1@vpYF = vpY_arr(iplt)
res1@vpHeightF = vpHei
res1@vpWidthF = vpWid
set_res_cnExplicitLevel(res1, cnLv)
plt_arr(iplt) = gsn_csm_contour(wks, w_trans, res1)


vres1 = vres
vres1@vcRefMagnitudeF = 5.0
vres1@vcRefAnnoOn = False
vc_arr(iplt) = gsn_csm_vector(wks, v_trans, W_trans, vres1)
delete([/w_trans, W_trans, v_trans/])
; ==================================================================
lres = True
lres@gsLineColor = "red2"
lres@gsLineDashPattern = 14
lres@gsLineThicknessF = 11.0
india_lon  = (/72.5, 92.5, 92.5, 72.5, 72.5/)
india_lat  = (/15.0, 15.0, 25.0, 25.0, 15.0/)
zone1_lon = (/50., 100., 100., 50., 50./)
zone1_lat = (/-10., -10., 0., 0., -10./)
do iplt = 0, 0
    india_zone(iplt) = gsn_add_polyline(wks, plt_arr(iplt), india_lon, india_lat, lres)
    oc_zone(iplt) = gsn_add_polyline(wks, plt_arr(iplt), zone1_lon, zone1_lat, lres)
end do

do iplt = 0, nplt-1
    overlay(plt_arr(iplt), vc_arr(iplt))
    draw(plt_arr(iplt))
end do

resTxt = True
resTxt@txFontHeightF = setting@gsnFontHei * 0.9
resTxt@txJust = "CenterLeft"
figureIndex = "~F25~" + (/"(a)", "(b)", "(c)", \
                          "(d)", "(e)", "(f)"/)
;figureIndex = "~F25~" + (/"A", "B", "C", \
;                          "D", "E", "F"/)

resLeft = resTxt
resLeft@txFontHeightF = setting@gsnFontHei * 0.7
leftstring = "~F25~" + (/"U60km-U3km", "U60km-U3km"/)

resRight = resTxt
resRight@txFontHeightF = setting@gsnFontHei * 0.7
resRight@txJust = "CenterRight"
;rightstring = "~F25~" + (/"U&V850hPa", "V&W"/)
rightstring = "~F25~" + (/"V&W", "U&V850hPa"/)
do iplt = 0, nplt-1
    gsn_text_ndc(wks, figureIndex(iplt), vpX_arr(iplt)+0.005, vpY_arr(iplt)-0.015, resTxt)
    gsn_text_ndc(wks, leftstring(iplt), vpX_arr(iplt)+0.003, vpY_arr(iplt)+0.02, resLeft)
    gsn_text_ndc(wks, rightstring(iplt), vpX_arr(iplt)+vpWid, vpY_arr(iplt)+0.02, resRight)
end do
resTxt@txFontHeightF = setting@gsnFontHei * 0.7
gsn_text_ndc(wks, "~F25~hPa", vpX_arr(0)-0.035, vpY_arr(0)-vpHei-0.005, resTxt)
resTxt@txJust = "CenterCenter"
gsn_text_ndc(wks, "~F25~Geopotential height at 850hPa (gpm)", \
             vpX_arr(1)+vpWid/2.0, vpY_arr(1)-vpHei-0.06, resTxt)
gsn_text_ndc(wks, "~F25~w (10~S~-2~N~m s~S~-1~N~)", \
             vpX_arr(0)+vpWid/2.0, vpY_arr(0)-vpHei-0.06, resTxt)
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
