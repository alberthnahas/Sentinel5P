## Sentinel-5P Total Kolom NO<sub>2</sub>

![https://sentinels.copernicus.eu/web/sentinel/missions/sentinel-5p](https://www.esa.int/var/esa/storage/images/esa_multimedia/images/2017/06/sentinel-5p/17040704-2-eng-GB/Sentinel-5P_pillars.jpg)

### Nitrogen dioksida (NO<sub>2</sub>) sebagai indikator emisi dari transportasi
Sebagai salah satu polutan udara, emisi gas NO<sub>2</sub> dapat berdampak negatif pada saluran cardiovascular dan pernapasan. Gas NO<sub>2</sub> sangat reaktif di udara dan terbentuk karena reaksi kimia dari nitrogen monoksida (NO) dan oksigen (O<sub>2</sub>). Dalam kajian kualitas udara, NO<sub>2</sub> digunakan sebagai indikator untuk menentukan wilayah yang terdampak dari sumber emisi polutan udara dari sektor transportasi.

### Pemantauan profil NO<sub>2</sub> berbasis informasi satelit 
Pemantauan konsentrasi NO<sub>2</sub> menggunakan instrumen yang terpasang di permukaan di suatu lokasi memiliki keterbatasan dalam memberikan informasi secara spasial karena data yang diberikan hanya dapat merepresentasikan kondisi NO<sub>2</sub> pada lokasi tersebut. Informasi NO<sub>2</sub> yang berasal dari satelit dapat dijadikan sebagai sumber data yang menggambarkan kondisi spasial dari sebaran NO<sub>2</sub> dan menjadi profil dari polutan ini pada suatu wilayah di waktu tertentu. 
Hasil pemantauan NO<sub>2</sub> dari satelit berbeda dengan dari instrumen di permukaan karena pemantauan dari satelit menyatakan NO<sub>2</sub> sebagai total kolom dalam dimensi jumlah per satuan luas, sedangkan instrumen di permukaan memberikan konsentrasi dalam dimensi jumlah per satuan volume.

### Sentinel-5P
Sentinel-5P merupakan identitas misi peluncuran instrumen pengukuran komposisi kimiaatmosfer yang dilakukan pada tanggal 13 Oktober 2017 menggunakan _polar-orbiting satellite_. Misi ini merupakan hasil kolaborasi antara European Space Agency dan Netherlands Space Office. Misi Sentinel-5P didedikasikan untuk melakukan pemantauan komposisi kimia atmosfer, polusi udara, dan lapisan ozon. Pemantauan ini dilakukan dengan mengaplikasikan instrumen TROPOMI (_TROPOspheric Monitoring Instrument_) yang bekerja pada panjang gelombang ultraviolet (UV), visible (VIS), near- (NIR) and - short-wavelength infrared (SWIR). Parameter kimia atmosfer yang dipantau meliputi ozon (O<sub>3</sub>), metana (CH<sub>4</sub>), formaldehida (CH<sub>2</sub>O), aerosol, karbon monoksida (CO), nitrogen dioksida (NO<sub>2</sub>), dan sulfur dioksida (SO<sub>2</sub>) di atmosfer. TROPOMI melakukan pengukuran setiap detik dengan resolusi spasial 3,5 x 7 km<sup>2</sup>.

### Workflow Pengolahan Data
Data TROPOMI Total Kolom NO<sub>2</sub> di wilayah Indonesia (90BT-145BT, 10LU-15LS) melalui SENTINEL-5P dikumpulkan setiap hari pada periode pemantauan antara pukul 13:00 WIB dan 16:30 WIB. Data satelit ini kemudian ditransformasi menjadi informasi spasial dengan resolusi 0,1 derajat x 0,1 derajat (~10 km) dengan menggunakan R. Informasi spasial ini disimpan sebagai data dengan format NetCDF (.nc) sehingga dapat digunakan sebagai input data pada aplikasi berbasis Sistem Informasi Geografis (GIS). Informasi spasial dapat diolah menjadi gambar dengan format PNG (.png) menggunakan GrADS atau aplikasi lainnya yang sejenis.

### Pranala Luar
Misi Sentinel-5P: https://sentinels.copernicus.eu/web/sentinel/missions/sentinel-5p<br>
Akses data: https://s5phub.copernicus.eu/dhus/#/home<br>
Data harian Total Kolom NO<sub>2</sub>: https://cews.bmkg.go.id/NO2-daily-analysis-sentinel/
