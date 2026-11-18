package main

import "fmt"

func main() {
    nomorPolisi := "AB 1234 CD"
    jenisKendaraan := "Motor"
    tarifPerJam := 3000
    durasiParkir := 2

    totalBiaya := tarifPerJam * durasiParkir

    fmt.Println("===== INFORMASI PARKIR =====")
    fmt.Println("===== TESSS BOSS =====")
    fmt.Println("Nomor Polisi:", nomorPolisi)
    fmt.Println("Jenis Kendaraan:", jenisKendaraan)
    fmt.Println("Tarif per Jam:", tarifPerJam)
    fmt.Println("Durasi Parkir:", durasiParkir, "jam")
    fmt.Println("Total Biaya:", totalBiaya)
}