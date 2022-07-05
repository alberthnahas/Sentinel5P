**********************************************************************************************
* This is a GrADS script to visualize Total Column NO2 from Sentinel-5P                      *
* Outputs of this script is a daily map covering Indonesia with spatial resolution of 0.1deg *
* Created by: Alberth Nahas (alberth.nahas@bmkg.go.id)                                       *
* Version 1.0 (2022-06-26 6:00 pm WIB)                                                       *
* Changes from previous versions:                                                            *
*    - Not changes made                                                                      *
**********************************************************************************************

reinit


****** set map area
*** setting background color and clearing the area	
*** gridlines are disabled
'set display white'
'clear'
'set grid off'
****** end mapping area


****** open file
'sdfopen no2.sentinel-5p.nc'
****** end opening file


****** set boundaries 
*** lat-lon given covers Indonesia
'set lon  90. 145.'
'set lat -15. 10.'
'set xlopts 1 2 0.10'
'set ylopts 1 2 0.10'
****** end setting boundaries


****** set color legend
'clear'
'set rgb 200  200  200  200  100'
'color 2 12 0.1 -kind white->lime->yellow->orange->red->purple'
****** end setting map attributes


****** display total column NO2 and titles
'set gxout shaded'
'set mpt 1 off'
'd tropcolumn_no2'
'q time'
  day = substr(result,11,2)
  month = substr(result,13,3)
  year = substr(result,16,4)
  time = substr(result,8,2)    
'set strsiz 0.15'
'set string 1 r 2 0'
'draw string 10.5 7.2 'day' 'month' 'year
'set strsiz 0.11'
'set string 1 c 2 0'
'draw string 5.5 1. x10`a15 `nmolecules/cm`a2'
'set strsiz 0.11'
'set string 1 l 2 90'
'draw string 10.6 1.53 ESA/SENTINEL-5P'
'set strsiz 0.17'
'set string 1 l 5 0'
'draw string 0.5 7.2 Total Column NO`b2'
'set gxout shp'
'set line 1 1 2'
'set shpopts -1'
'draw shp IDN_adm1.shp'
'set shpopts 200'
'draw shp world_excl_idn.shp'
**
****** end displaying total column NO2 and titles


****** set color bar
'set strsiz 0.12'
'color 2 12 0.1 -kind white->lime->yellow->orange->red->purple -xcbar 0.5 10.5 0.7 0.9 -fs 10 -fh 0.1 -fw 0.1 -edge triangle'
****** end setting color bar


****** produce figure
'printim no2.sentinel-5p.png'
****** end producing figure

