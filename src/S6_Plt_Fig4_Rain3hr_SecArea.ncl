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
areaname_arr = (/"SecZone", "BroadArea", "MonZone"/)
area_latlon = (/(/-10., 0., 50., 100./), \
                (/-20., 40., 35., 115./), \
                (/15.0, 25.0, 72.5, 92.5/)/)
case_arr = (/"CMORPH", "GPM", "U60km", "U3km"/)
ncase = dimsizes(case_arr)
input_path = "/storage/aemolcore02/dongze/U3km_data/midDataForPaper/"
file_prefix = "Rain3hr.PDF."
pa_prefix = "PA.Rain3hr5Lvs."
lh_prefix = "IntegratedLH.newRain3hrLv."
nlv = 5
index_area = 0
;;------------------U60km-------------------------
PDF = new((/ncase, nlv/), double)
do ic = 0, ncase-1
    datai = asciiread(input_path + file_prefix + case_arr(ic) + "." + \
                        areaname_arr(index_area) + ".txt", -1, "string")
    pdfi = todouble(str_get_field(datai(2:), 2, ","))
    PDF(ic, 0) = todouble(100.) - sum(pdfi(1:4))
    PDF(ic, 1:4) = (/pdfi(1:4)/)
end do
;print(PDF)

PA = new((/ncase, nlv/), double)
do ic = 0, ncase-1
    datai = asciiread(input_path + pa_prefix + case_arr(ic) + "." + \
                      areaname_arr(index_area) + ".txt", -1, "string")
    pai = todouble(str_get_field(datai(2:), 2, ","))
    PA(ic, :) = (/pai/)
end do
;print(PA)



LH = new((/2, nlv/), double)
do ic = 0, 1
    datai = asciiread(input_path + lh_prefix + case_arr(ic+2) + "." + \
                        areaname_arr(index_area) + ".txt", -1, "string")
    lhi = todouble(str_get_field(datai(2:), 2, ","))
    LH(ic, 0:4) = (/lhi/)
end do
print(LH)

print("---")
lh_avg_u60 = sum(PDF(2, :) * LH(0, :))/100.
print("U60km: " + lh_avg_u60)
lh_avg_u3 = sum(PDF(3, :) * LH(1, :))/100.
print("U3km:" + lh_avg_u3)
print("diff: " + (lh_avg_u60 - lh_avg_u3))
; equal to the average latent heat calculated in S2_DP_LH-Pre_Statics.ncl
print("---")
contri_diff = PDF(2, :) * LH(0, :) - PDF(3, :) * LH(1, :)
print("Difference")
print(contri_diff/100.)
contri_diff = contri_diff / 100.
contri = PDF(2:3, :) * LH(0:1, :) / 100.
print("contribution:" + contri)



nfile = 232
; ==================================================================
;                           shared parameters
; ==================================================================
nplt = 5
NRES = 4
setting = set_global_plot_setting(NRES)
;vpX_arr = (/0.08, 0.25, 0.38, 0.68, 0.82/) + 0.005
;vpY_arr = (/0.96, 0.899, 0.96, 0.96, 0.899/)
vpX_arr = (/0.08, 0.25, 0.38, \
            0.08, 0.38/) + 0.005
vpY_arr = (/0.96, 0.92, 0.96, \
            0.77, 0.77/)


vpWid = 0.26
vpHei = 0.16
tmOn = (/True, False, True, False/)
isAddCyc = False
isOutline = True
mpLineThick = 3.0
cnFillOn = True
cnLineOn = False
lbHei = 0.02
lbWid = 0.25


plt_arr = new((/nplt/), graphic)
plt_path = "./plots/"
plt_name = "S6_Fig4_Rain3hr_SecArea"
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
set_res_basic(res, False, setting@gsnFontHei * 0.65)
delete(res@gsnAddCyclic)
cmap  = read_colormap_file("MPL_BrBG")
;color_arr = (/"black", "red", "blue"/)
color_arr = new((/ncase, 3/), float)
color_arr(0, :) = 0.
color_arr(1, :) = (/125, 125, 125/) / 255.
color_arr(2, :) = (/193, 61, 31/) / 255.
color_arr(3, :) = (/21, 83, 183/) / 255.
set_res_tmBasic(res, tmOn, setting@tmThick*1.8, setting@tmFontHei, setting@tmLen*0.8)
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

res@tmXBLabelAngleF = -26.
res@tmXBMinorOn = False
res@tmXBMajorOutwardLengthF = res@tmXBMajorLengthF
res@tmYLMajorOutwardLengthF = res@tmYLMajorLengthF
res@tmXBMajorOutwardLengthF = res@tmXBMajorLengthF
res@tmYLMajorOutwardLengthF = res@tmYLMajorLengthF

res@tmXBMinorOutwardLengthF = res@tmXBMinorLengthF
res@tmYLMinorOutwardLengthF = res@tmYLMinorLengthF
res@tmXBMinorOutwardLengthF = res@tmXBMinorLengthF
res@tmYLMinorOutwardLengthF = res@tmYLMinorLengthF

; ==================================================================
;                     Plot 0
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
                         70., \
                         90./)


res0@tmYLLabelsOn = True
res0@tmXBLabelsOn = False
res0@tiYAxisOn = False
res0@tiYAxisString = "~F25~Frequency (%)"
;res0@gsnCenterString = "~F25~Frequency (%)"
res0@tiXAxisOn = False
res0@tiXAxisString = "~F25~Level (mm 3hr~S~-1~N~)"
res0@tiYAxisFontHeightF = 0.015
res0@tiXAxisFontHeightF = 0.015
res0@vpXF = vpX_arr(iplt)
res0@vpYF = vpY_arr(iplt)
res0@vpHeightF = vpHei
res0@vpWidthF = vpWid

res0@xyMarkLineMode = "MarkLines"
res0@xyLineColors = color_arr
res0@xyDashPattern = 0
res0@xyMarker = 16
res0@xyLineThicknessF = 15.0
res0@xyMarkerSizeF = 0.008
res0@xyMarkerColors = color_arr
res0@xyMarkerThicknessF = 8.0
plt_arr(iplt) = gsn_csm_xy(wks, ispan(1, nlv, 1), PDF, res0)
print(PDF)
; ==================================================================

; ==================================================================
;                     Plot 1: Rain3hr_HeavyRain
; ==================================================================
iplt = 1
res1 = res
res1@tmYMajorGrid = False
res1@tmYLMode = "Explicit"
res1@trYMaxF = 3.2
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
res1@tmYLValues = (/0, 1, 2, 3.0/)
res1@tmYLLabels = "~F25~" + \
                  (/"0", "1.0", "2.0", "3.0"/)

res1@tmYLMinorOn = True
res1@tmYLMinorValues = (/0.5, 1.5, 2.5/)

res1@tmYLLabelsOn = True
res1@tmXBLabelsOn = True
res1@tmYLLabelFontHeightF = res@tmYLLabelFontHeightF * 0.8
res1@tmXBLabelFontHeightF = res@tmYLLabelFontHeightF * 0.8
res1@tiYAxisOn = False
res1@vpXF = vpX_arr(iplt)
res1@vpYF = vpY_arr(iplt)
res1@vpHeightF = vpHei * 0.5
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
;                     Plot 2: U60km,PA
; ==================================================================
iplt = 2
res2 = res
res2@tmYMajorGrid = True
res2@tmYLMode = "Explicit"
res2@trYMaxF = 200.
res2@trYMinF = 0.
res2@tmYLValues = (/0, 40.0, 80.0, 120.0, 160.0, 200/)
res2@tmYLLabels = "~F25~" + \
                  (/"0", "40", "80", "120", "160", "200"/)

res2@tmYLMinorOn = True
res2@tmYLMinorValues = (/20., 60., 100., 140., 180./)

res2@tmYLLabelsOn = True
res2@tmXBLabelsOn = False
res2@tiYAxisOn = False
res2@tiYAxisString = "~F25~Rain amount (mm)"
;res2@gsnCenterString = "~F25~Rain amount (mm)"
res2@tiXAxisOn = False
res2@tiXAxisString = "~F25~Level (mm 3hr~S~-1~N~)"
res2@tiYAxisFontHeightF = 0.015
res2@tiXAxisFontHeightF = 0.015
res2@vpXF = vpX_arr(iplt)
res2@vpYF = vpY_arr(iplt)
res2@vpHeightF = vpHei
res2@vpWidthF = vpWid

res2@xyMarkLineMode = "MarkLines"
res2@xyLineColors = color_arr
res2@xyDashPattern = 0
res2@xyMarker = 16
res2@xyLineThicknessF = 15.0
res2@xyMarkerSizeF = 0.008
res2@xyMarkerColors = color_arr
res2@xyMarkerThicknessF = 8.0
plt_arr(iplt) = gsn_csm_xy(wks, ispan(1, nlv, 1), PA, res2)
; ==================================================================

; ==================================================================
;                     Plot 3: U3km,PDF
; ==================================================================
iplt = 3
res3 = res
res3 = res
res3@tmYLOn = True
res3@tmYLLabelsOn = True
res3@tmYRLabelsOn = False
res3@tmYROn = False
res3@tmYMajorGrid = True
res3@tmXBLabelsOn = True
res3@tiYAxisOn = False
res3@tiYAxisSide = "Right"
res3@tiYAxisString = "~F25~Averaged latent heat (K s~S~-1~N~)"
;res3@gsnCenterString = "~F25~Latent heat (K s~S~-1~N~)"
res3@tiXAxisOn = False
res3@tiXAxisString = "~F25~Level (mm 3hr~S~-1~N~)"
res3@tiYAxisFontHeightF = 0.015
res3@tiXAxisFontHeightF = 0.015

res3@xyYStyle = "Log"
res3@tmYRMode = "Explicit"
res3@trYMaxF = 0.001
res3@trYMinF = 0.0000001
res3@tmYRValues = (/1., 10., 100., 1000., 10000./) * 0.0000001
res3@tmYRLabels = "~F25~" + \
                  (/"10~S~-7~N~", "10~S~-6~N~", "10~S~-5~N~", \
                    "10~S~-4~N~", "10~S~-3~N~"/)

res3@vpXF = vpX_arr(iplt)
res3@vpYF = vpY_arr(iplt)
res3@vpHeightF = vpHei
res3@vpWidthF = vpWid

res3@xyMarkLineMode = "MarkLines"
res3@xyLineColors = color_arr(2:, :)
res3@xyDashPattern = 0
res3@xyMarker = 16
res3@xyLineThicknessF = 15.0
res3@xyMarkerSizeF = 0.008
res3@xyMarkerColors = color_arr(2:, :)
res3@xyMarkerThicknessF = 8.0
plt_arr(iplt) = gsn_csm_xy(wks, ispan(1, nlv, 1), LH, res3)
; ==================================================================

; ==================================================================
;                     Plot 4: Contribution
; ==================================================================
iplt = 4
res4 = res
;res4@gsnCenterString = "~F25~Contribution (10~S~-6~N~K s~S~-1~N~)"
;res4@gsnStringFontHeightF = 0.009
res4@tmYMajorGrid = True
res4@tmYLMode = "Explicit"
res4@trYMaxF = 30
res4@trYMinF = 0.
res4@trXMaxF = 5.5
res4@trXMinF = 0.5
;res4@tmXBLabels = (/"~F25~<0.1", \
;                   "~F25~0.1~F34~*~F25~3", \
;                   "~F25~3~F34~*~F25~10", \
;                   "~F25~10~F34~*~F25~20", \
;                   "~F25~>20"/)
;res4@tmXBLabelAngleF = -25.
res4@tmXBLabelDeltaF = -0.9
res4@tmYLValues = (/0, 10, 20, 30.0/)
res4@tmYLLabels = "~F25~" + \
                  (/"0", "10", "20", "30"/)

res4@tmYLMinorOn = True
res4@tmYLMinorValues = (/5, 15, 25/)

res4@tmYLLabelsOn = True
res4@tmXBLabelsOn = True
;res4@tmYLLabelFontHeightF = res@tmYLLabelFontHeightF * 0.8
;res4@tmXBLabelFontHeightF = res@tmYLLabelFontHeightF * 0.8
res4@tiYAxisOn = False
res4@vpXF = vpX_arr(iplt)
res4@vpYF = vpY_arr(iplt)
;res4@vpHeightF = vpHei * 0.5
;res4@vpWidthF = vpWid * 0.43
res4@vpHeightF = vpHei
res4@vpWidthF = vpWid 


res4@xyMarkLineMode = "MarkLines"
res4@xyLineColors = color_arr(2:, :)
res4@xyDashPattern = 0
res4@xyMarker = 16
res4@xyLineThicknessF = 15.0
res4@xyMarkerSizeF = 0.008
res4@xyMarkerColors = color_arr(2:, :)
res4@xyMarkerThicknessF = 8.0
;plt_arr(iplt) = gsn_csm_xy(wks, ispan(1, nlv, 1), contri_diff*10000000., res4)
plt_arr(iplt) = gsn_csm_xy(wks, ispan(1, nlv, 1), contri*1000000., res4)
; ==================================================================

do iplt = 0, nplt-1
    draw(plt_arr(iplt))
end do
xpos = (/0.525, 0.525, 0.525, 0.525/) + 0.025;- 0.28
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
txres@txFontHeightF = 0.013
tilabel = "~F25~Intensity (mm 3hr~S~-1~N~)"
xx = (vpX_arr(0) + vpX_arr(0) + vpWid) / 2.0
yy = (vpY_arr(3) - vpHei - 0.05)
gsn_text_ndc(wks, tilabel, xx, yy, txres)
xx = (vpX_arr(2) + vpX_arr(2) + vpWid) / 2.0
yy = (vpY_arr(3) - vpHei - 0.05)
gsn_text_ndc(wks, tilabel, xx, yy, txres)


tilabel = "~F25~Frequency (%)"
xx = vpX_arr(0) + vpWid/2.0
yy = vpY_arr(0) + 0.012
gsn_text_ndc(wks, tilabel, xx, yy, txres)

tilabel = "~F25~Rain amount (mm)"
xx = vpX_arr(2) + vpWid/2.0
yy = vpY_arr(2) + 0.012
gsn_text_ndc(wks, tilabel, xx, yy, txres)

tilabel = "~F25~Latent heat (K s~S~-1~N~)"
xx = vpX_arr(3) + vpWid/2.0
yy = vpY_arr(3) + 0.012
gsn_text_ndc(wks, tilabel, xx, yy, txres)

tilabel = "~F25~Contribution (10~S~-6~N~K s~S~-1~N~)"
xx = vpX_arr(4) + vpWid/2.0
yy = vpY_arr(4) + 0.012
gsn_text_ndc(wks, tilabel, xx, yy, txres)



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
frame(wks)
if(plt_type .eq. "png") then
    cmd = "convert -alpha off -background white -geometry 4096x4096 -density 300 -trim " + \
          plt_path + plt_name + "." + plt_type + " " + \
          plt_path + plt_name + ".jpg"
    system(cmd)
end if
end
