RADIX SORT USING OPENMPI
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
```mpirun -np <jumlah-proses> mpi_parallel <jumlah-data>```
## Solusi
### Deskripsi Solusi
Implementasi penyelesaian radix sort yang diterapkan pada program kami mengikuti implementasi prefix sum dari [referensi](https://www.cs.cmu.edu/~guyb/papers/Ble93.pdf) dengan sedikit penyesuaian. Secara garis besar, implementasi radix sort yang kami gunakan menggunakan bitwise sort, yaitu membandingkan tiap bit dimulai dari *least significant bit*. Setelah itu, kami membuat semua iterasi yang memungkinkan diproses paralel untuk dijalankan secara paralel. Kami mendefinisikan kriteria iterasi yang bisa diparalelkan sebagai iterasi yang berisi *assignment* dan tidak bergantung dengan elemen lain.

### Analisis solusi
Diterapkan asumsi bahwa bila seluruh iterasi yang bisa diparalelkan diterapkan paralel, maka kinerjanya akan lebih cepat. Untuk algoritma yang dipilih, mungkin ada yang lebih baik tapi kami belum menemukannya. Algoritma yang kami pilih sudah cukup optimal karena memparalelkan hanya di lokasi yang tepat dan secara komputasi sudah lebih cepat dari serial pada jumlah proses tertentu.

### Jumlah thread
Jumlah thread per block yang kami anggap paling optimal adalah X, karena berdasarkan uji coba yang dilakukan, jumlah thread yang memberikan nilai terbaik dengan konsistensi yang sama baiknya adalah X. Bila jumlah thread per block dikurangi, pengerjaan paralel tidak optimal, namun bila jumlah thread per block ditambah, overhead untuk menggabungkan hasil perhitungan paralel juga bertambah.

### Pengukuran kinerja
Untuk setiap studi kasus, dilakukan tiga kali komputasi dan yang kami cantumkan adalah waktu rata-rata dari tiga kali percobaan.
#### Studi Kasus 1
N = 5.000

Waktu sorting serial = 15,203 ms

Waktu sorting paralel = 7,424 ms


#### Studi Kasus 2
N = 50.000

Waktu sorting serial = 109,144 ms

Waktu sorting paralel = 80,622 ms

#### Studi Kasus 3
N = 100.000

Waktu sorting serial = 211,574 ms

Waktu sorting paralel = 154,029 ms

#### Studi Kasus 4
N = 200.000

Waktu sorting serial = 419,473 ms

Waktu sorting paralel = 294,324 ms

#### Studi Kasus 5
N = 400.000

Waktu sorting serial = 838,413 ms

Waktu sorting paralel = 614,840 ms

### Analisis Perbandingan kinerja
Berdasarkan percobaan yang dilakukan, secara garis besar kinerja program paralel lebih cepat di kisaran 50%-115%, hal ini terjadi karena operasi pada senarai dibagi ke beberapa proses sehingga memotong waktu pemrosesan, dengan overhead penggabungan hasil operasi yang tidak terlalu besar sehingga tetap lebih efisien.

## Pembagian Tugas
| Shinta (13516029) | Naufal (13516110) |
|--- | --- |
|Implementasi program serial |Implementasi program paralel |
|Membuat Readme.MD |  |

### Credits
- Shinta Ayu Chandra Kemala (13516029)
- Naufal Putra Pamungkas (13516110)
