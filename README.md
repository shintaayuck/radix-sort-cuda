RADIX SORT USING CUDA
-----------------------

## Daftar Isi

<!--ts-->
   * [Daftar Isi](#daftar-isi)
   * [Instalasi](#instalasi)
   * [Solusi](#solusi)
      * [Deskripsi Solusi](#deskripsi-solusi)
      * [Analisis Solusi](#analisis-solusi)
      * [Jumlah Thread](#jumlah-thread)
      * [Pengukuran Kinerja](#pengukuran-kinerja)
        * [Studi Kasus 1](#studi-kasus-1)
        * [Studi Kasus 2](#studi-kasus-2)
        * [Studi Kasus 3](#studi-kasus-3)
        * [Studi Kasus 4](#studi-kasus-4)
        * [Studi Kasus 5](#studi-kasus-5)
      * [Analisis Perbandingan Kinerja](#analisis-perbandingan-kinerja)
   * [Pembagian Tugas](#pembagian)
<!--te-->

## Instalasi
1. Jalankan pada terminal
```make```
2. Salin perintah yang muncul di terminal
3. Jalankan perintah tersebut
4. Untuk menjalankan program, jalankan
```./radix_sort <Jumlah Elemen Array>```
## Solusi
### Deskripsi Solusi
Implementasi penyelesaian radix sort yang diterapkan pada program kami mengikuti implementasi prefix sum dari [referensi](https://www.cs.cmu.edu/~guyb/papers/Ble93.pdf) dengan sedikit penyesuaian. Secara garis besar, implementasi radix sort yang kami gunakan menggunakan bitwise sort, yaitu membandingkan tiap bit dimulai dari *least significant bit*. Setelah itu, kami membuat semua iterasi yang memungkinkan diproses paralel untuk dijalankan secara paralel. Kami mendefinisikan kriteria iterasi yang bisa diparalelkan sebagai iterasi yang berisi *assignment* dan tidak bergantung dengan elemen lain.

### Analisis solusi
Diterapkan asumsi bahwa bila seluruh iterasi yang bisa diparalelkan diterapkan paralel, maka kinerjanya akan lebih cepat. Untuk algoritma yang dipilih, mungkin ada yang lebih baik tapi kami belum menemukannya. Algoritma yang kami pilih sudah cukup optimal karena memparalelkan hanya di lokasi yang tepat dan secara komputasi sudah lebih cepat dari serial pada jumlah proses tertentu.

### Jumlah thread
Jumlah thread per block yang kami anggap paling optimal adalah 256, karena berdasarkan uji coba yang dilakukan, jumlah thread yang memberikan nilai terbaik dengan konsistensi yang sama baiknya adalah 256. Bila jumlah thread per block dikurangi atau ditambah, pengerjaan paralel tidak optimal.

### Pengukuran kinerja
Untuk setiap studi kasus, dilakukan tiga kali komputasi dan yang kami cantumkan adalah waktu rata-rata dari tiga kali percobaan.

#### Studi Kasus 1
N = 5.000

Waktu sorting serial = 15,203 ms

Waktu sorting paralel = 193,549333333 ms


#### Studi Kasus 2
N = 50.000

Waktu sorting serial = 109,144 ms

Waktu sorting paralel = 227, 7963 ms

#### Studi Kasus 3
N = 100.000

Waktu sorting serial = 211,574 ms

Waktu sorting paralel = 238,3423 ms

#### Studi Kasus 4
N = 200.000

Waktu sorting serial = 419,473 ms

Waktu sorting paralel = 262,979 ms

#### Studi Kasus 5
N = 400.000

Waktu sorting serial = 838,413 ms

Waktu sorting paralel = 338,842 ms

### Analisis Perbandingan kinerja
Berdasarkan percobaan yang dilakukan, performa sorting parallel bekerja lebih cepat dibandingkan serial untuk jumlah elemen array yang sangat besar, yaitu kurang lebih diatas 100.000 elemen. Namun parallel akan lebih lambat untuk jumlah array yang lebih kecil. Berdasarkan analisis kami, hal tersebut dikarenakan operasi parallel memiliki overhead time ketika melakukan alokasi memori. Sehingga, untuk jumlah elemen yang sedikit, waktu overhead tersebut akan membuat proses parallel lebih lambat.

## Pembagian Tugas
| Shinta (13516029) | Naufal (13516110) |
|--- | --- |
|Implementasi program parallel |Implementasi program serial |
|Membuat Readme.MD | Membuat Readme.MD |

### Credits
- Shinta Ayu Chandra Kemala (13516029)
- Naufal Putra Pamungkas (13516110)
