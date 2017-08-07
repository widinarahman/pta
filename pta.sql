-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Aug 05, 2017 at 07:27 
-- Server version: 10.1.21-MariaDB
-- PHP Version: 7.1.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pta`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_LaporanKeuangan` (`varBulan` INT, `varBulanKemarin` INT, `varTahun` INT, `varTahunKemarin` INT)  BEGIN

SELECT a.kode_pembayaran,b.nama_pembayaran,
        SUM(CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)=varBulan and EXTRACT(YEAR FROM a.tanggal_transaksi)=varTahun and a.jenis_transaksi='Pemasukan' THEN a.jumlah ELSE 0 END) as 'Penerimaan BI',
        sum(CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)=varBulanKemarin and EXTRACT(YEAR FROM a.tanggal_transaksi)=varTahunKemarin and a.jenis_transaksi='Pemasukan' THEN a.jumlah ELSE 0 END) as 'Penerimaan BK',
        sum(CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)<=varBulan and EXTRACT(YEAR FROM a.tanggal_transaksi)<=varTahun and a.jenis_transaksi='Pemasukan' THEN a.jumlah ELSE 0 END) as 'Penerimaan SBI',

        SUM(CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)=varBulan and EXTRACT(YEAR FROM a.tanggal_transaksi)=varTahun and a.jenis_transaksi='Pengeluaran' THEN a.jumlah ELSE 0 END) as 'Pengeluaran BI',
        sum(CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)=varBulanKemarin and EXTRACT(YEAR FROM a.tanggal_transaksi)=varTahunKemarin and a.jenis_transaksi='Pengeluaran' THEN a.jumlah ELSE 0 END) as 'Pengeluaran BK',
        sum(CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)<=varBulan and EXTRACT(YEAR FROM a.tanggal_transaksi)<=varTahun and a.jenis_transaksi='Pengeluaran' THEN a.jumlah ELSE 0 END) as 'Pengeluaran SBI',

        SUM((CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)<=varBulan and EXTRACT(YEAR FROM a.tanggal_transaksi)<=varTahun and a.jenis_transaksi='Pemasukan' THEN a.jumlah ELSE 0 END)-(CASE WHEN EXTRACT(MONTH FROM a.tanggal_transaksi)<=varBulan and EXTRACT(YEAR FROM a.tanggal_transaksi)<=varTahun and a.jenis_transaksi='Pengeluaran' THEN a.jumlah ELSE 0 END)) as 'Sisa Saldo'

    FROM transaksi a
    JOIN pembayaran b ON a.kode_pembayaran=b.kode_pembayaran
    group by a.kode_pembayaran
    ORDER BY b.nama_pembayaran;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_PemasukanPengeluaran` (`varTahun` INT, `varBulan` INT)  BEGIN

    SELECT b.tanggal_transaksi, a.nama_pembayaran, b.jenis_transaksi,SUM(b.jumlah)
    FROM pembayaran a
    JOIN transaksi b ON a.kode_pembayaran = b.kode_pembayaran
    JOIN tahun_ajaran c ON b.kode_tahun_ajaran = c.kode_tahun_ajaran 
    where EXTRACT(YEAR FROM b.tanggal_transaksi) = varTahun and
    EXTRACT(MONTH FROM b.tanggal_transaksi) = varBulan
    GROUP BY b.jenis_transaksi,b.tanggal_transaksi,b.kode_pembayaran
    order by b.jenis_transaksi, b.tanggal_transaksi desc ,b.kode_transaksi desc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TransaksiPembayaran` (`varTahun` INT, `varBulan` INT)  BEGIN

    SELECT a.tanggal_transaksi, a.kode_transaksi, b.nis, b.nama_siswa, c.nama_pembayaran, e.bulan, f.semester,g.tahun_ajaran, a.jumlah 
    FROM siswa b 
    JOIN detail_pembayaran d ON b.nis = d.nis 
    JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi 
    JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran 
    LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan 
    LEFT JOIN semester f ON d.kode_semester = f.kode_semester 
    left join tahun_ajaran g on a.kode_tahun_ajaran=g.kode_tahun_ajaran
    where EXTRACT(YEAR FROM a.tanggal_transaksi) = varTahun and
    EXTRACT(MONTH FROM a.tanggal_transaksi) = varBulan
    order by a.tanggal_transaksi,a.kode_transaksi desc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TransaksiPengeluaran` (`varTahun` INT, `varBulan` INT)  BEGIN

    SELECT c.tanggal_transaksi, c.kode_transaksi,d.nama_pembayaran,a.nama_pengeluaran,e.tahun_ajaran, c.jumlah,c.keterangan 
    FROM pengeluaran a 
    JOIN detail_pengeluaran b ON a.kode_pengeluaran = b.kode_pengeluaran 
    JOIN transaksi c ON c.kode_transaksi = b.kode_transaksi 
    JOIN pembayaran d ON c.kode_pembayaran = d.kode_pembayaran 
    left join tahun_ajaran e on c.kode_tahun_ajaran=e.kode_tahun_ajaran
    where EXTRACT(YEAR FROM c.tanggal_transaksi) = varTahun and
    EXTRACT(MONTH FROM c.tanggal_transaksi) = varBulan
    order by c.tanggal_transaksi,c.kode_transaksi desc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TunggakanPerbulan` (IN `varKodePembayaran` VARCHAR(14), IN `varKodeTahunAjaran` INT)  BEGIN
	SELECT a.nis,a.nama_siswa,b.nama_kelas,
	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Juli'),'lunas','-') as Jul,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Agustus'),'lunas','-') as Agu,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='September'),'lunas','-') as Sept,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Oktober'),'lunas','-') as Okt,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='November'),'lunas','-') as Nov,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Desember'),'lunas','-') as Des,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Januari'),'lunas','-') as Jan,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Februari'),'lunas','-') as Feb,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Maret'),'lunas','-') as Mar,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='April'),'lunas','-') as Apr,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Mei'),'lunas','-') as Mei,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND e.bulan='Juni'),'lunas','-') as Jun,

        if(a.nis is not null,
            (SELECT sum(e.jumlah)
            FROM siswa c
            JOIN detail_pembayaran d ON c.nis = d.nis
            JOIN transaksi e ON d.kode_transaksi = e.kode_transaksi
            JOIN pembayaran f ON f.kode_pembayaran = e.kode_pembayaran
            JOIN tahun_ajaran g ON e.kode_tahun_ajaran = g.kode_tahun_ajaran
            WHERE e.kode_pembayaran = varKodePembayaran
            AND e.kode_tahun_ajaran = varKodeTahunAjaran AND d.nis=a.nis),0)as sudahBayar

	FROM siswa a
        left join kelas b ON a.kode_kelas=b.kode_kelas
        where a.kode_kelas NOT IN ('do','lulus')
        order by b.nama_kelas, a.nama_siswa;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TunggakanPersemester` (`varKodePembayaran` VARCHAR(14), `varKodeTahunAjaran` INT)  BEGIN
	SELECT a.nis,a.nama_siswa,b.nama_kelas,
	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND f.semester='Genap'),'lunas','-') as Genap,

	if(a.nis in (SELECT b.nis
	FROM siswa b
	JOIN detail_pembayaran d ON b.nis = d.nis
	JOIN transaksi a ON d.kode_transaksi = a.kode_transaksi
	JOIN pembayaran c ON c.kode_pembayaran = a.kode_pembayaran
	LEFT JOIN bulan e ON d.kode_bulan = e.kode_bulan
	LEFT JOIN semester f ON d.kode_semester = f.kode_semester
	LEFT JOIN tahun_ajaran g ON a.kode_tahun_ajaran = g.kode_tahun_ajaran
	WHERE a.kode_pembayaran = varKodePembayaran
	AND a.kode_tahun_ajaran = varKodeTahunAjaran AND f.semester='Ganjil'),'lunas','-') as Ganjil,

        if(a.nis is not null,
            (SELECT sum(e.jumlah)
            FROM siswa c
            JOIN detail_pembayaran d ON c.nis = d.nis
            JOIN transaksi e ON d.kode_transaksi = e.kode_transaksi
            JOIN pembayaran f ON f.kode_pembayaran = e.kode_pembayaran
            JOIN tahun_ajaran g ON e.kode_tahun_ajaran = g.kode_tahun_ajaran
            WHERE e.kode_pembayaran = varKodePembayaran
            AND e.kode_tahun_ajaran = varKodeTahunAjaran AND d.nis=a.nis),0)as sudahBayar

	FROM siswa a
        left join kelas b ON a.kode_kelas=b.kode_kelas
        where a.kode_kelas NOT IN ('do','lulus')
        order by b.nama_kelas, a.nama_siswa;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TunggakanPertahun` (`varKodePembayaran` VARCHAR(14), `varKodeTahunAjaran` INT)  BEGIN
	SELECT a.nis,a.nama_siswa,b.nama_kelas,
	if(a.nis is not null,
            (SELECT sum(e.jumlah)
            FROM siswa c
            JOIN detail_pembayaran d ON c.nis = d.nis
            JOIN transaksi e ON d.kode_transaksi = e.kode_transaksi
            JOIN pembayaran f ON f.kode_pembayaran = e.kode_pembayaran
            JOIN tahun_ajaran g ON e.kode_tahun_ajaran = g.kode_tahun_ajaran
            WHERE e.kode_pembayaran = varKodePembayaran
            AND e.kode_tahun_ajaran = varKodeTahunAjaran AND d.nis=a.nis),0)as sudahBayar

	FROM siswa a
        left join kelas b ON a.kode_kelas=b.kode_kelas
        where a.kode_kelas NOT IN ('do','lulus')
        order by b.nama_kelas, a.nama_siswa;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TunggakanTahunPertama` (`varKodePembayaran` VARCHAR(14), `varKodeTahunAjaran` INT, `varTahunAjaran` VARCHAR(14))  BEGIN
	SELECT a.nis,a.nama_siswa,b.nama_kelas,a.tahun_ajaran_masuk as Angkatan,
	if(a.nis is not null,
            (SELECT sum(e.jumlah)
            FROM siswa c
            JOIN detail_pembayaran d ON c.nis = d.nis
            JOIN transaksi e ON d.kode_transaksi = e.kode_transaksi
            JOIN pembayaran f ON f.kode_pembayaran = e.kode_pembayaran
            JOIN tahun_ajaran g ON e.kode_tahun_ajaran = g.kode_tahun_ajaran
            WHERE e.kode_pembayaran = varKodePembayaran
            AND e.kode_tahun_ajaran = varKodeTahunAjaran AND d.nis=a.nis),0)as sudahBayar

	FROM siswa a
        left join kelas b ON a.kode_kelas=b.kode_kelas
        where a.tahun_ajaran_masuk = varTahunAjaran and a.kode_kelas NOT IN ('do','lulus')
        order by b.nama_kelas, a.nama_siswa;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id_admin` int(11) NOT NULL,
  `user_name` char(15) NOT NULL,
  `password` varchar(100) NOT NULL,
  `nama_admin` varchar(100) NOT NULL,
  `alamat` varchar(150) NOT NULL,
  `no_telepon` char(12) DEFAULT NULL,
  `status` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id_admin`, `user_name`, `password`, `nama_admin`, `alamat`, `no_telepon`, `status`) VALUES
(3, 'admin', '9cf54a74b140c20d41554a6570af4f41751be3dd', 'Rahman', 'Desa Sari reja RT02/RT02, Tanjung', '0899898909', 'Admin'),
(13, 'kunto', '9cf54a74b140c20d41554a6570af4f41751be3dd', 'Kunto', 'Ds Sarireja RT O2/RT 02 Tanjung', '089082788', 'Staff TU'),
(14, 'anton', '9cf54a74b140c20d41554a6570af4f41751be3dd', 'Anton Hariri', 'Ciledug RT03 02 Cirebon', '086729280', 'Staff TB');

-- --------------------------------------------------------

--
-- Table structure for table `bulan`
--

CREATE TABLE `bulan` (
  `kode_bulan` int(11) NOT NULL,
  `bulan` char(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `bulan`
--

INSERT INTO `bulan` (`kode_bulan`, `bulan`) VALUES
(1, 'Juli'),
(2, 'Agustus'),
(3, 'September'),
(4, 'Oktober'),
(5, 'November'),
(6, 'Desember'),
(7, 'Januari'),
(8, 'Februari'),
(9, 'Maret'),
(10, 'April'),
(11, 'Mei'),
(12, 'Juni');

-- --------------------------------------------------------

--
-- Table structure for table `detail_pembayaran`
--

CREATE TABLE `detail_pembayaran` (
  `id_detail` int(11) NOT NULL,
  `nis` char(10) NOT NULL,
  `kode_transaksi` int(11) NOT NULL,
  `kode_semester` int(11) DEFAULT NULL,
  `kode_bulan` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `detail_pembayaran`
--

INSERT INTO `detail_pembayaran` (`id_detail`, `nis`, `kode_transaksi`, `kode_semester`, `kode_bulan`) VALUES
(81, '4826', 93, 1, NULL),
(82, '4826', 94, 2, NULL),
(86, '4845', 98, 2, NULL),
(93, '1861', 105, 1, NULL),
(94, '1861', 106, 2, NULL),
(109, '4889', 121, 1, NULL),
(110, '4889', 122, 2, NULL),
(111, '4891', 123, 1, NULL),
(112, '4891', 124, 2, NULL),
(113, '4903', 125, 1, NULL),
(114, '4903', 126, 2, NULL),
(115, '4905', 127, 1, NULL),
(116, '4905', 128, 2, NULL),
(117, '4908', 129, 1, NULL),
(118, '4908', 130, 2, NULL),
(119, '4910', 131, 1, NULL),
(120, '4910', 132, 2, NULL),
(121, '4919', 133, 1, NULL),
(122, '4919', 134, 2, NULL),
(123, '4923', 135, 1, NULL),
(124, '4923', 136, 2, NULL),
(125, '4924', 137, 1, NULL),
(126, '4924', 138, 2, NULL),
(127, '4927', 139, 1, NULL),
(128, '4927', 140, 2, NULL),
(129, '4928', 141, 1, NULL),
(130, '4928', 142, 2, NULL),
(131, '4929', 143, 1, NULL),
(132, '4929', 144, 2, NULL),
(133, '4930', 145, 1, NULL),
(134, '4930', 146, 2, NULL),
(135, '4932', 147, 1, NULL),
(136, '4932', 148, 2, NULL),
(137, '4935', 149, 1, NULL),
(138, '4935', 150, 2, NULL),
(139, '4944', 151, 1, NULL),
(140, '4944', 152, 2, NULL),
(452, '4891', 464, NULL, 12),
(459, '4910', 471, NULL, 7),
(460, '4910', 472, NULL, 8),
(463, '4910', 475, NULL, 11),
(464, '4910', 476, NULL, 12),
(467, '4919', 479, NULL, 3),
(468, '4919', 480, NULL, 4),
(469, '4919', 481, NULL, 5),
(470, '4919', 482, NULL, 6),
(471, '4919', 483, NULL, 7),
(472, '4919', 484, NULL, 8),
(473, '4919', 485, NULL, 9),
(474, '4919', 486, NULL, 10),
(635, '1861', 647, NULL, NULL),
(637, '4908', 649, NULL, NULL),
(639, '4908', 651, NULL, NULL),
(643, '4910', 655, NULL, NULL),
(645, '4919', 657, NULL, NULL),
(646, '4927', 658, NULL, NULL),
(647, '4944', 659, NULL, NULL),
(648, '4924', 660, NULL, NULL),
(650, '4910', 662, NULL, NULL),
(651, '4903', 663, NULL, NULL),
(652, '4923', 664, NULL, NULL),
(653, '4923', 665, NULL, NULL),
(654, '4935', 666, NULL, NULL),
(655, '4889', 667, NULL, NULL),
(656, '4891', 668, NULL, NULL),
(657, '4905', 669, NULL, NULL),
(658, '4929', 670, NULL, NULL),
(659, '4930', 671, NULL, NULL),
(660, '4944', 672, NULL, NULL),
(661, '4982', 673, NULL, 1),
(662, '4982', 675, 1, NULL),
(663, '4826', 676, NULL, NULL),
(666, '5072', 679, NULL, 1),
(667, '5072', 680, 1, NULL),
(668, '5077', 682, NULL, NULL),
(669, '4826', 684, NULL, NULL),
(670, '5077', 732, NULL, NULL),
(672, '5072', 734, NULL, NULL),
(673, '5072', 735, 0, 0),
(674, '1861', 19, NULL, NULL),
(675, '5072', 736, NULL, NULL),
(676, '5072', 737, NULL, NULL),
(677, '5072', 738, 0, 0),
(678, '5077', 739, NULL, NULL),
(679, '5077', 740, 0, 0),
(680, '5077', 741, 0, 0),
(682, '5077', 743, 0, 0),
(683, '5077', 715, NULL, NULL),
(684, '5077', 744, NULL, NULL),
(685, '5072', 745, NULL, NULL),
(686, '5072', 746, NULL, NULL),
(687, '5072', 747, NULL, NULL),
(688, '5077', 748, NULL, NULL),
(689, '5072', 749, NULL, NULL),
(690, '5072', 750, 1, NULL),
(691, '5072', 751, 2, NULL),
(692, '5072', 752, 1, NULL),
(693, '5072', 753, 2, NULL),
(694, '5112', 754, NULL, NULL),
(695, '5112', 755, NULL, NULL),
(696, '5112', 756, NULL, NULL),
(697, '5112', 757, NULL, NULL),
(698, '5072', 758, NULL, 0),
(699, '5072', 759, NULL, 1),
(700, '5072', 760, NULL, 2),
(701, '5072', 767, NULL, 3),
(702, '5072', 768, NULL, 0),
(703, '5077', 769, 2, NULL),
(704, '5077', 770, 0, NULL),
(708, '5072', 774, NULL, NULL),
(710, '5072', 776, 1, NULL),
(712, '5072', 778, 1, NULL),
(713, '5077', 779, 2, NULL),
(714, '5077', 780, NULL, 1),
(715, '5077', 781, 1, NULL),
(716, '5077', 782, NULL, 1),
(717, '5072', 783, NULL, 1),
(718, '5072', 784, NULL, 2),
(719, '5072', 785, NULL, 3),
(720, '5072', 786, 1, NULL),
(721, '5077', 787, 1, NULL),
(722, '5077', 788, 1, NULL),
(723, '5077', 789, NULL, 1),
(724, '5077', 790, 1, NULL),
(725, '5077', 791, 1, NULL),
(726, '5077', 792, 1, NULL),
(727, '5072', 793, 1, NULL),
(728, '5072', 794, 2, NULL),
(729, '5072', 795, NULL, 1),
(730, '5072', 796, NULL, NULL),
(731, '5072', 797, NULL, NULL),
(732, '5077', 798, NULL, NULL),
(733, '5072', 799, NULL, NULL),
(734, '5072', 800, NULL, NULL),
(735, '5077', 801, NULL, 2),
(736, '5080', 802, NULL, 1),
(737, '5080', 803, NULL, 2),
(738, '5080', 804, 1, NULL),
(739, '5080', 805, 2, NULL),
(740, '5101', 806, 1, NULL),
(741, '5101', 807, 2, NULL),
(742, '5077', 808, NULL, 3),
(743, '5077', 809, NULL, 0),
(744, '5080', 810, 0, NULL),
(745, '5080', 811, 0, NULL),
(746, '5080', 812, 1, NULL),
(747, '5080', 813, NULL, NULL),
(748, '5080', 814, NULL, NULL),
(749, '5077', 815, NULL, NULL),
(750, '5080', 816, NULL, NULL),
(751, '5077', 817, NULL, NULL),
(752, '5107', 818, NULL, NULL),
(753, '5107', 819, NULL, NULL),
(754, '5112', 820, 1, NULL),
(755, '5112', 821, 0, NULL),
(756, '5119', 822, 1, NULL),
(758, '5119', 824, 0, NULL),
(759, '5119', 825, 1, NULL),
(760, '5119', 826, 2, NULL),
(761, '5112', 827, 0, NULL),
(762, '5112', 828, 1, NULL),
(764, '5072', 830, NULL, NULL),
(767, '5107', 833, 1, NULL),
(768, '5107', 834, 1, NULL),
(769, '5107', 835, 2, NULL),
(770, '5112', 836, NULL, 1),
(771, '5112', 837, NULL, 1),
(772, '5112', 838, NULL, 2),
(773, '5066', 839, 1, NULL),
(774, '4982', 840, 1, NULL),
(775, '4982', 841, NULL, NULL),
(776, '4982', 842, NULL, NULL),
(777, '5072', 843, NULL, NULL),
(778, '5101', 844, NULL, 1),
(779, '5072', 845, NULL, NULL),
(780, '5072', 846, NULL, NULL),
(781, '5101', 847, NULL, 2),
(782, '5077', 848, NULL, NULL),
(783, '5112', 849, NULL, NULL),
(784, '5080', 850, NULL, NULL),
(785, '5080', 851, NULL, NULL),
(786, '5072', 852, NULL, 5),
(787, '5072', 853, NULL, 4),
(788, '5072', 854, NULL, 8),
(789, '5072', 855, NULL, 6),
(790, '5072', 856, NULL, 11),
(791, '5119', 857, NULL, NULL),
(792, '5119', 858, NULL, NULL),
(793, '5002', 859, NULL, NULL),
(794, '5112', 860, 2, NULL),
(795, '5002', 861, NULL, NULL),
(796, '5112', 862, NULL, NULL),
(797, '5066', 863, NULL, NULL),
(798, '5080', 864, NULL, NULL),
(799, '5080', 865, NULL, NULL),
(802, '5072', 868, NULL, NULL),
(803, '2323', 876, NULL, NULL),
(804, '2323', 877, NULL, NULL),
(805, '2323', 878, NULL, 1),
(806, '2323', 879, NULL, NULL),
(808, '2323', 880, 1, NULL),
(809, '5072', 881, NULL, 7),
(810, '5072', 882, NULL, 8),
(811, '5077', 883, NULL, 4),
(812, '5077', 884, NULL, 5),
(813, '5077', 885, NULL, 6);

-- --------------------------------------------------------

--
-- Table structure for table `detail_pengeluaran`
--

CREATE TABLE `detail_pengeluaran` (
  `kode_detail` int(11) NOT NULL,
  `kode_pengeluaran` int(11) NOT NULL,
  `kode_transaksi` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `detail_pengeluaran`
--

INSERT INTO `detail_pengeluaran` (`kode_detail`, `kode_pengeluaran`, `kode_transaksi`) VALUES
(1, 1, 674),
(2, 1, 683),
(3, 5, 761),
(4, 5, 762),
(5, 1, 763),
(6, 1, 764),
(7, 1, 765),
(8, 5, 766);

-- --------------------------------------------------------

--
-- Table structure for table `kelas`
--

CREATE TABLE `kelas` (
  `kode_kelas` char(10) NOT NULL,
  `nama_kelas` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `kelas`
--

INSERT INTO `kelas` (`kode_kelas`, `nama_kelas`) VALUES
('lulus', 'LULUS'),
('0021', 'TIE'),
('001', 'X TKR 1'),
('002', 'X TKR 2'),
('003', 'X TKR 3'),
('004', 'X TKR 4'),
('005', 'XI JASA BOGA 1'),
('006', 'XI JASA BOGA 2'),
('007', 'XI TATA BUSANA 1'),
('008', 'XI TATA BUSANA 2'),
('011', 'XII MULTIMEDIA 1'),
('012', 'XII MULTIMEDIA 2'),
('009', 'XII TATA BUSANA 1'),
('010', 'XII TATA BUSANA 2');

-- --------------------------------------------------------

--
-- Table structure for table `no_tabungan`
--

CREATE TABLE `no_tabungan` (
  `no_rekening` char(25) NOT NULL,
  `saldo` int(15) NOT NULL,
  `nis` char(10) CHARACTER SET utf8 NOT NULL,
  `kode` char(10) NOT NULL,
  `tgl_kepemilikan` date NOT NULL,
  `status` char(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `no_tabungan`
--

INSERT INTO `no_tabungan` (`no_rekening`, `saldo`, `nis`, `kode`, `tgl_kepemilikan`, `status`) VALUES
('1-0717-1', 28100, '5072', '', '2017-07-24', 'Aktif'),
('1-0717-2', 0, '5077', '', '2017-07-29', 'Aktif'),
('1-0717-3', 0, '5002', '', '2017-07-29', 'Aktif'),
('1-1707-0', 0, '5112', '', '2017-07-24', 'Aktif');

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran`
--

CREATE TABLE `pembayaran` (
  `kode_pembayaran` char(10) NOT NULL,
  `nama_pembayaran` varchar(50) NOT NULL,
  `masa_pembayaran` varchar(15) NOT NULL,
  `saldo_awal` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `pembayaran`
--

INSERT INTO `pembayaran` (`kode_pembayaran`, `nama_pembayaran`, `masa_pembayaran`, `saldo_awal`) VALUES
('001', 'Multimedia', 'Persemester', 0),
('002', 'Pengembangan', 'Tahun Pertama', 0),
('003', 'Perpustakaan', 'Pertahun', 0),
('004', 'SPP', 'Perbulan', 0),
('006', 'Pembayaram Baru', 'Tahun Pertama', 0),
('011', 'contoh2', 'Perbulan', 0),
('5', 'STP2K', 'Pertahun', 0),
('8', 'Buku LKS', 'Persemester', 0),
('99', 'Bismaa', 'Perbulan', 0),
('BK011', 'Perpisahan 2017', 'Perbulan', 0),
('BK01x', 'ljlkjlk', 'Perbulan', 0),
('c1', 'contoh1', 'Persemester', 0);

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran_tahun_ajaran`
--

CREATE TABLE `pembayaran_tahun_ajaran` (
  `kode_tahun_ajaran` int(11) NOT NULL,
  `kode_pembayaran` char(10) NOT NULL,
  `jumlah_pembayaran` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `pembayaran_tahun_ajaran`
--

INSERT INTO `pembayaran_tahun_ajaran` (`kode_tahun_ajaran`, `kode_pembayaran`, `jumlah_pembayaran`) VALUES
(2, '001', 30000),
(2, '002', 1600000),
(2, '003', 40000),
(2, '004', 110000),
(2, '005', 20000),
(1, '001', 25000),
(1, '002', 1550000),
(1, '003', 35000),
(1, '004', 105000),
(1, '005', 150000),
(2, '006', 50000),
(2, '001', 90000),
(0, 'PILIH', 9000),
(1, '1', 9000),
(0, '2', 15000),
(0, '2', 9000),
(0, '2016/2017', 1000),
(0, '2018/2019', 9000),
(3, '001', 60000),
(3, '001', 500),
(2, '008', 90000),
(2, '99', 9000),
(2, 'TBUKU', 75000),
(2, 'c1', 90000),
(2, '011', 90000),
(2, '6', 900000);

-- --------------------------------------------------------

--
-- Table structure for table `pengeluaran`
--

CREATE TABLE `pengeluaran` (
  `kode_pengeluaran` int(11) NOT NULL,
  `nama_pengeluaran` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `pengeluaran`
--

INSERT INTO `pengeluaran` (`kode_pengeluaran`, `nama_pengeluaran`) VALUES
(1, 'Pembelian Buku Baru'),
(2, 'aoe'),
(5, 'pembelian kursi'),
(6, 'Meja Siswa'),
(7, 'Buka Stand Mudik');

-- --------------------------------------------------------

--
-- Table structure for table `profil_sekolah`
--

CREATE TABLE `profil_sekolah` (
  `kode_sekolah` char(10) NOT NULL,
  `nama_sekolah` varchar(100) NOT NULL,
  `alamat_sekolah` varchar(150) NOT NULL,
  `kota_sekolah` varchar(20) NOT NULL,
  `no_telepon` char(15) DEFAULT NULL,
  `kode_pos` char(6) DEFAULT NULL,
  `kepala_sekolah` varchar(100) NOT NULL,
  `nip_kepala_sekolah` varchar(50) DEFAULT NULL,
  `bendahara_sekolah` varchar(50) NOT NULL,
  `nip_bendahara` varchar(50) DEFAULT NULL,
  `logo` longblob
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `profil_sekolah`
--

INSERT INTO `profil_sekolah` (`kode_sekolah`, `nama_sekolah`, `alamat_sekolah`, `kota_sekolah`, `no_telepon`, `kode_pos`, `kepala_sekolah`, `nip_kepala_sekolah`, `bendahara_sekolah`, `nip_bendahara`, `logo`) VALUES
('001', 'SMK NEGERI 1 KERSANA', 'Jl. Raya Jagapura – Kersana – Brebes', 'Brebes', '(0283) 881851', '52264', 'Drs. SAMSUDIN, M.Pd', '196403141989021004', 'Pramonosidi', '19625845 198916 9 056', 0xffd8ffe000104a46494600010100000100010000fffe003e43524541544f523a2067642d6a7065672076312e3020287573696e6720494a47204a50454720763632292c2064656661756c74207175616c6974790affdb004300080606070605080707070909080a0c140d0c0b0b0c1912130f141d1a1f1e1d1a1c1c20242e2720222c231c1c2837292c30313434341f27393d38323c2e333432ffdb0043010909090c0b0c180d0d1832211c213232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232ffc000110800ee00c803012200021101031101ffc4001f0000010501010101010100000000000000000102030405060708090a0bffc400b5100002010303020403050504040000017d01020300041105122131410613516107227114328191a1082342b1c11552d1f02433627282090a161718191a25262728292a3435363738393a434445464748494a535455565758595a636465666768696a737475767778797a838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae1e2e3e4e5e6e7e8e9eaf1f2f3f4f5f6f7f8f9faffc4001f0100030101010101010101010000000000000102030405060708090a0bffc400b51100020102040403040705040400010277000102031104052131061241510761711322328108144291a1b1c109233352f0156272d10a162434e125f11718191a262728292a35363738393a434445464748494a535455565758595a636465666768696a737475767778797a82838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae2e3e4e5e6e7e8e9eaf2f3f4f5f6f7f8f9faffda000c03010002110311003f00e4ec2c21bbb679e79262e659327ce61d18fbd4bf61d2ff00e7e9bff028ff008d163ff204b8ff007a6ffd08d73da168706a96d24b2cb22147da02e3d2bde4a318d38429a6dabea7ccca5394eace756518c656d35dce87ec3a5ffcfd37fe051ff1a3ec3a5ffcfd37fe051ff1aa7ff087d9ff00cfc4ff00a7f851ff00087d9ffcfc4ffa7f8569ecaa7fcf98fdff00f00cbdbd2ffa0897dcff00ccb9f61d2ffe7e9bff00028ff8d1f61d2ffe7e9bff00028ff8d53ff843ecff00e7e27fd3fc28ff00843ecffe7e27fd3fc28f6553fe7cc7efff00801ede97fd044bee7fe65cfb0e97ff003f4dff008147fc68fb0e97ff003f4dff008147fc6a9ffc21f67ff3f13fe9fe147fc21f67ff003f13fe9fe147b2a9ff003e63f7ff00c00f6f4bfe8225f73ff32e7d874bff009fa6ff00c0a3fe347d874bff009fa6ff00c0a3fe354ffe10fb3ff9f89ff4ff000a3fe10fb3ff009f89ff004ff0a3d954ff009f31fbff00e007b7a5ff004112fb9ff9973ec3a5ff00cfd37fe051ff001a3ec3a5ff00cfd37fe051ff001aa7ff00087d9ffcfc4ffa7f851ff087d9ff00cfc4ff00a7f851ecaa7fcf98fdff00f003dbd2ff00a0897dcffccb9f61d2ff00e7e9bff028ff008d1f61d2ff00e7e9bff028ff008d53ff00843ecffe7e27fd3fc28ff843ecff00e7e27fd3fc28f6553fe7cc7eff00f801ede97fd044bee7fe65cfb0e97ff3f4dff8147fc68fb0e97ff3f4dff8147fc6a9ff00c21f67ff003f13fe9fe147fc21f67ff3f13fe9fe147b2a9ff3e63f7ffc00f6f4bfe8225f73ff0032e7d874bff9fa6ffc0a3fe347d874bff9fa6ffc0a3fe354ff00e10fb3ff009f89ff004ff0a3fe10fb3ff9f89ff4ff000a3d954ff9f31fbffe007b7a5ff4112fb9ff009973ec3a5ffcfd37fe051ff1a3ec3a5ffcfd37fe051ff1aa7ff087d9ff00cfc4ff00a7f851ff00087d9ffcfc4ffa7f851ecaa7fcf98fdfff00003dbd2ffa0897dcff00ccb9f61d2ffe7e9bff00028ff8d1f61d2ffe7e9bff00028ff8d53ff843ecff00e7e27fd3fc28ff00843ecffe7e27fd3fc28f6553fe7cc7efff00801ede97fd044bee7fe65cfb0e97ff003f4dff008147fc68fb0e97ff003f4dff008147fc6a9ffc21f67ff3f13fe9fe1595aee8706956d1cb14b23977da4363d2a2a2953839ca8c6cbfaec694650ad354e18895df93ff003372fec21b4b649e09260e258f07ce63d587bd152dff00fc812dff00de87ff00421457066508c6aae456d0f4f279ce7465ceeed37b858ffc812e3fde9bff0042354bc1ff00f1e171ff005d7fa0abb63ff204b8ff007a6ffd08d52f07ff00c785c7fd75fe82bd2a5fc4a1fe17fa1e457fe1623fc4bf36747451457aa7861451450014514500145145001451450014546678c5c2c05bf78ca580f6152503716b70a28a28105145140051451400514514005739e30ff8f0b7ff00aebfd0d7475ce78c3fe3c2dffebaff00435c98ff00f7699df95ffbdc3d7f42edff00fc812dff00de87ff004214517fff00204b7ff7a1ff00d08515e2e67fc58fa23e8b25fe0cbfc4c2c7fe40971fef4dff00a11aa5e0ff00f8f0b8ff00aebfd055db1ff9025c7fbd37fe846a9783ff00e3c2e3febaff00415e852fe250ff000bfd0f2abff0b11fe25f9b3a3a28a2bd53c30a28a2800a28a2800a28a2800acbbbd76daca6314b1cdbc7a2f5fa735a9599af4303e952c92a02c83e43dc1e82a6774ae8eac1c694aaa8d54da7a6873936aecfad2df2860aa400a7aedf4fe75d0dbf882d6ea558a38e62edd06dff00ebd719b1f66fdadb338dd8e2bb0f0e416eba6acd1a0f35890ec7af07a57352949cac7d066b87c353a2a4e3aad15bf53628a28aeb3e5428a28a06145145020a28a2800ae73c61ff001e16ff00f5d7fa1ae8eb9cf187fc785bff00d75fe86b931ffeed33bf2bff007b87afe85dbfff009025bffbd0ff00e8428a2fff00e4096ffef43ffa10a2bc5ccff8b1f447d164bfc197f89858ff00c812e3fde9bff42354bc1fff001e171ff5d7fa0abb63ff00204b8ff7a6ff00d08d52f07ffc785c7fd75fe82bd0a5fc4a1fe17fa1e557fe1623fc4bf36747451457aa78614514d91c4685db381e8339a4da4aec6936ec875048009270053eeb4dbfd2aee38efce1ee6059d63ff9e7c9057dc80173ee6b5bc27a341adeb728bc5125ad9c6b2188f491d89c67d40da78efc578f8acf30d432f96609f3416d6ebadbf33d1a596559e296165a3ebe5a5cc2769c5b47751dacaf6cf208c4e46d424fa13f7ba13c67a5495d2f8eb518aeb55b5d36dd818ec819250bd04846157ea1777fdf42b9aa590e3f119860d62abc79799bb2ecba7de19a61a8e1ab7b1a4ef65abf30a82ead22bc8845302537062a0e338a9e8af69ab9e7c64e2f9a2f52a18e25ba8ed846be5f92df2638c6476a7dad9c364aeb002a8edbb6e7807daa166c6b71affd3bb7fe842af54a4ae6f5653514afa357fc42a399fcb8cb16d8a08dec177155cf271df032715254570c5206700964f9d405c9247238efd3a52a97e476dec654aded23cdb5d0ed42e347b45d52c6192ff50bfcc5f61ba48da18a342012cea48c9e48e41070318e6a8e969b1ee816663bc72cd927e51ffd7a8ef754b8d67586d5355b866bf95429053cb5000c0503d055fd3f4d76486f8ea3a75bc175742cdc4d361a061921dd7fba467bfa7e1f2d84c64e38a4eb376d773ddc453fac49d2c3c6c92f4ea89a8aa57776d06aaf676b35bde4093f94b771e42ca3a92a327a73dcf4abb5f4b43114eba72a6ee91e2d6a13a32e59ee1451456e6015ce78c3fe3c2dff00ebaff435d1d739e30ff8f0b7ff00aebfd0d7263ffdda677e57fef70f52edff00fc812dff00de87ff004214517fff00204b7ff7a1ff00d08515e2e67fc58fa23e8b25fe0cbfc4c2c7fe40971fef4dff00a11aa5e0ff00f8f0b8ff00aebfd055db1ff9025c7fbd37fe846a9783ff00e3c2e3febaff00415e852fe250ff000bfd0f2abff0b11fe25f9b3a3a28a2bd53c30ad6f0ad9c77de2db48e601a38237b9da7a1652a17f22d9fc056324a921708e18a1dac01e86afe8da82e93afd95f4871086314c4f647e33f81da7f0af1b882156ae575e343e2e57b7e27a59538c31b4dd4daff00f0c745f120a4771a43805a6632a0551966076f0077e71f9d71d69757d6d24ff65bd920f34049da061f36338556eb8193961d4f4e064ef78826b9f12f88625d32233ccf1b476a73b56283387989edbcfca0f5daa48ea2a1d7bc22345d0449777ecf7334890c30db8f2d173c9e7a9c286f4fa57c36438dc351c251c0631f336f485af76df5ec979f5bf63ea331c35575655e8e8edacbb25dbcd99091ac6bb54606727d49f53ea69d470073daa05b946765e83b13debf4aa95e8d0e5849a57d91f2787c0e2b16a752941c94756c90ca81c26ecb1a8ae277898000608ea6aa310b21319e01e0d3fcb9a6e4827dcd7ccd4ce7115e33a54a2f9efa72eba1fa1e1f8530383a94b13889af65cbef29e8eef6d3a5bb32ab4e4eb91312377d99bff42ffeb568c170f249b580fa8ac492271e238a2e37188ff5ad430cb19ce08f715557158ea52a7371972a4b9bcfbdca8659936229d5a319c39e57e46f4b2e96d755fe45d32a07d85b069f59658bbe5cfd4d5d6b88e3080720fa76aefc16730adcf2ab68c53d3bebe47819c70955c27b1861af39c93bd96974aeecff0024c95e34950a488aca7a861906b26e2ee0d4747b5d32d74fd3e11673b3b5e04df34fc9e1b3d060e319ec3a56c020804720d41716705cf3227ce3a3af0c3f1aecc7e0de2a0b91a4cf9ac362a7867283d2fa7a7c8a496f2a986ea3b594d9dbcdb24952325236653b4123b9c8e3dc7ad68ddca34f94c37eaf672800f9772a636c1e8707b55392fe2b5f0d1b5d3af7573a9cb76ad7622da20d91b6508f56e14fd41cf6aaf7734fa8ea31bdfde49777770ea2496620b14504e3d871fad78b82c654c335422936dfe3b1df88c2e1d538de4dcadd3ef66be72323a514515f5678415ce78c3fe3c2dffebaff00435d1d739e30ff008f0b7ffaebfd0d7263ff00dda677657fef70f5fd0bb7ff00f204b7ff007a1ffd085145ff00fc812dff00de87ff004214578b99ff00163e88fa2c97f832ff00130b1ff9025c7fbd37fe846a9783ff00e3c2e3febaff0041576c7fe40971fef4dffa11aa5e0fff008f0b8ffaebfd057a14bf8943fc2ff43caaff00c2c47f897e6ce8e83c0cd148c32a47a8c57aacf116e6e7fc228cde0db2d66ce326f3cb33cf18eb346c4b0c7fb4a0f1ea323d2b12de08f53b882d4b8104c0bcd27f76151b9dbf2e3ea457a7f83af23bdf0a69fb48dd042b6f22ff0075906d23f4cfd0d79ecb6a34fb6f11b28c2bde9d32dfd90b192403fe0381f857e539467f8cb6270151fbee568f74e52b3fbaf73ee71996d094a9e256d1577e692ba3a5d0fc47e1fd2f4e7bc96ee16bcbcc4860b71e6346806238f0b9c6d5c0edce6b9dd735bb8f106a29732c660b78415b7809c919eacd8e371fd05334ad0af35a86496dff00d1ec23525ee88fbd8ea231dcfbf41efd2b2eccb1b1b72ec598c6a492792715ef645926594330a9529d4f69561bbe91bec979d97c8f3333cc317530d1528f2465f7b1cd2c65cc6c7f3aa2ca1a42b1e48cf1525c45e5b6776771a9ad22c2f987a9e95d18855f30c52c2d58a8f2bbdfad8faec0bc164596bcc70f51cd4d2493d139f576feb443a1b658c65b05bf954f4515f5387c352c3c39292b23f37c766188c75575b112e66ff0f4ec73f3363c610ffb98ff00c74d74158b2d93378816efcc185206dc76c62b6aa70f5a155cd41dececcebcd70d52846839ab734134432dbac832386f5aa254a3ed70460f35a955eea20c9bc0e56bc7ce32b84e0f11495a4b57e68fa3e14e24ab46b47058995e9cb44fac5f4d7b7e43d64893646a7af4a97a8c567431195f19c639ad1ed5d59462eae2a9b94e2947a58f338a32cc3e5f888d3a751ce6f595f7bbd53f9fe8674da798177d9f18e4c24fca7e9e87f4ab32ea16fa77876da08aef4bd45f549e39a7b3dacb35b18f9dbe603c640da78ee7152cd0acf0bc4f9dae307071590e8b62eb0cfb3cbeb14840038ec7d0d7266b8454ff007d4a3eb6ff0023cfc06339399b57974feba96b52bf92fb53f3b4fb0b7d2239b6aa59c38755c0e589c0ebec076ad0aabf619ac96c751ba31082fed9a4b628fb88556c36ef4fe1ab4082010720f435db945dd0bca577dbb1cf98fb4f697a91b37e415ce78c3fe3c2dffebaff00435d1d739e30ff008f0b7ffaebfd0d7563ff00dda62caffdee1ea5dbff00f9025bff00bd0ffe8428a2ff00fe4096ff00ef43ff00a10a2bc5ccff008b1f447d164bfc197f89858ffc812e3fde9bff0042354bc1ff00f1e171ff005d7fa0abb63ff204b8ff007a6ffd08d52f07ff00c785c7fd75fe82bd0a5fc4a1fe17fa1e557fe1623fc4bf3674750b5cc6970206dc18807763e5e73819f5e0d4d5bde0cb7b6bcd6efaceee249a19ecc6e8dc64361fff00b2a79ce60f2ec1cb14a3cdcb6baf2ba4ce1cbb0b1c5575464ed7bfe467e8dacdd6817cd736cbe6c12e3ed16f9c6fc7f12fa30fd7a1f51a0f69ff0009149e1fb50ac906a17377a8cfd9847bb8cfa12ac17f1aafe27f0f3f86e4596277974e989546739689b190ac7b83d8fe06b420d6ad7c3d73a4bcd04d34aba1c4b14712f52cd9392781f7057c0e73530d8d74b1f95c5ba9539b6dee95b55dd5f73eaf2d8d6c3c6a61f16fdd8dacfc9fe9a1d6788eea1d1bc2b78d1aa4616030c11a8c0dc46d5503ea45792c8863b458d013b405e3daafeb9e20bad5efe0935021577620b68b2522edb89ee79c67df005559a4f29376335ecf0d6472cb32fadf5a95a73f8adaf2ab7e7adce4c4e612c4e6343ead0e6e57eea7a293bfe5a19cdbf387ce47ad6922ed455f4159f249e649bb18f6ad11c815e8f0fa87b6ace2efb59f96a7b3c712abf55c2c6a4546f76d2d93d3fcd8b4523b2a2176202a8c927b0a40ccd8db0cedf4858ff4afa59d48c3e2763f3c8529cfe14d9d9dbf81a19b44172c5c6a0e9e62f3f28ee0115c79041c1eb5e9b06b2c56cee3e65b56b0966788c477ef4641d3aff1118c57994d23bcaf23413aee62706171d7f0af86e10c7e2aad5c4fd6da4b9aeba59b6d35f2b2fe99f4d9f61db851f67795a36eaf45b0948464107bd223ac88190e54f7a757ddbb35e47cc2e68cb4dd1980b2390a483d38ab96bbbcb2181ce7bd540e166df8c8ce6af432f9aa5b18c1c57c8e42a9fb77efeaaf68f4b773f51e34956fa947f74b95a8b73d2e9f6eec92a9a6a37fa6ebb6d736e6dc3424c900961deac70548233ef57298346bed7ee56c74d117dad11a70d2ca10055e0f27a9f9abe87324de1a56763f38c073bae9437fc8aba76b7ae697a95eead6f7b15a5c5def13aa44ad16d273f2a9fbbcf351e942e84603b136c1408f7ae1cfbf1dbf5ab5711681a80d42f74fd463b1b6b35464d3af5cb4b70e17e60a72723774ebcfa0a741730dca930c81b1d40ea3ea2bcac9e9fbee5296bd8f433478884796aea9f5ec4b5ce78c3fe3c2dffebaff00435d1d739e30ff008f0b7ffaebfd0d7b18ff00f7699c395ffbdc3d7f42edff00fc812dff00de87ff004214517fff00204b7ff7a1ff00d08515e2e67fc58fa23e8b25fe0cbfc4c2c7fe40971fef4dff00a11aa5e0ff00f8f0b8ff00aebfd055db1ff9025c7fbd37fe846a9783ff00e3c2e3febaff00415e852fe250ff000bfd0f2abff0b11fe25f9b3a3ab1a7ea13691aadbea302190c5959230799233f780f7e011ee2abd446593cf31adbcb222c6647741bb60040c91d71c8e6ba71f4a856c3ce9627e092b3f99e661255615a33a2af25a9e9bac4b63e29f04ea06ca65991e0664c7549146e008ea0820715c47889889f466542ed26936ea88bd59b24003df245664323c6c6e2cae6482475c19216c6e1e87b30fad753a5da0bdd5bc1370ff32a69d2139fef46140fc8b67f0afcd2796cf863110aea5cf0f7dc7d791eff00723eca962a19b50952b72cb4bfde4d75e145d2fc09a94d385935168c5c4ae3909e590e117d860fd4e4d720e82442a7a1f4af4ef1a5ea59f84ef9188f32e6336d1af72ce36fe8093f857998e062bd7e06af88c6d0c4d5c4fbca72ebd74d7f43cecff970b568ba1eeb8ed6e967a142e1234da108f7e7356ada4df081dc706a16b426538385eb9a891dade520fd08af42955a981c63ad569f2424f974db4ebfd799f5588c3e1f39ca96170f5bdad682e7d77d774ff2f2d2e6be9b15b5d6bda7da5e330b6794493854672634e48c2824e4e17f1af6cff84b7481cbb5e44bfdf96c2745fcca015e29a3eafa968d793de69973146d346b192d08720024e064f7279fa0adf83e22f8a21605e7b2b81dc4b6c467f15615e96330d5f1353da415e3d3547c9e031587c1d3f6355da57d747b9dc49e21d19fc616776356b2368ba6cfba5fb42ed56f322e09cf07dab53fe12dd1db98a5ba9d7fbf0594d2afe6a8457007e2242f20bc97c2b66faaa8dab71e6aed03fde2bb87d3f5acfbaf883e28ba6252f2ded14f45b7b7071f8beeae1a797576dda363d0a99a6120afcf7f4333c4a2d22f165f0b22ff0067b93f6a8c3c4d1952df7c61803f7b27fe0559533ec898f7e82ae6a9aaea9abb5bc9a9ea525c0b762c9ba3418c8c1195507d3f2159134a6790051c7615dd89c5cf0784f652fe23d17f99cf956550cd330f6f1d28c7de937a2d3a7cff00212de34763bc803eb57638c46bb5738f7aaa2d183a82415ee6aef4a59261654a2fdad3e592ebd5dcdf8c332a789a91fab57e784b5e5e8ada2f9bd42b0f51b5b682e9a4b85568a604867e4ab019201f423f956e567d96afa869b25fc8b69a7dec8f135bb437506e0075054e783823fc8aeace250587b4babd0f98cbd2753de972aea4577a65ce913c3a74f6860bc28ad1ac843108c321b209e3afe23157edada3b58f6a72c79673d58fa9aab16ab75068b7769796b677934bb1a3d46ed89b88028002ab73c0c703dcf5ab36770d736e24685a239c61bbfb8f6ae3c9151bcadf17e86f98c629295195e2f7f527ae73c61ff1e16fff005d7fa1ae8eb9cf187fc785bffd75fe86bd5c7ffbb48e7cb3fdee1ea5dbff00f9025bff00bd0ffe8428a2ff00fe4096ff00ef43ff00a10a2bc6ccff008b1f447d164bfc197f899259c0c9637b68dc4914f3c4df50c6b33c1ce3ec9751f759013f88ff00eb5757ad5aff0067f8e7c47644607dafed0a3da401bfad721a07fa27882fed0f01b247e078fd0d76d197f027ea8f36bc3fde69f9a97e3ff04ea6b53c2f702d7c5ba7bb1c2cdbedcffc09723f5515974d7562014731c8ac1d1d7aab039047d0815d39a60febb82ab86fe64d7cfa1e5e0710b0f888557b267a0788fc176f771c97ba522dbdf0f98c6bc473fb11d8ff00b43f1cd61689abc1a7681a1ea5742454b4b9bab4910212ea5b710b8f5f9545747e1ef195a6a691dadfba5a6a3d0a39c24a7d509ebf4ea3f5acaf12d8ac169e21b78d405261d56303d41db27fe819ff008157e334aa62e328e57995d28c95afba4fdd767daceebd0fd0546934f1587b36d74ebd55ce7358d5eeb5ed405ddd2f971c7916f6e0e4460f527d58f73dba0f7a74515fb5e0b05430542342846d147e7789c454c454752a3bb623025480704f7aa4b6cecec1b8c77f5abd45638dcba962e51954be9d3b9ea6539f6272b854850b7bfd6daaf3ff00806706781c80791d476ab0978a461d483ed4dfb2112839cae727351dca2a380ab8e39af9c8c71f97d39548bb453b59ebf71f7f5279267988a7426b9aa4a37738fbb66b7bff00c14cb3f6a8bfbc7f2a635e28fbaa4fd6a2fb3836fe66e39c671496c8af210c09e38ade598e6529c293e58b9ecffab9c54f22c829d1ab8a5cf51526d495faaf92bfde35a49277009ebd0539ada4465039cf71daa43684ca483b56ad8180075a785c9e75dcde2efcd7d1dc9ccb8aa8e0a34a395f2f272eb0b6d75a5dfe6bef1a80aa00cd93eb4ea28afa98c5462a2ba1f9bd4a8ea4dce5bbd482e6ee2b40865dd876da36a93ce33dbe952c1a55a34da7ea1a8eb16d6fa7ea71b11f656f366474538465c70c4e0743d31dc553d4feedb8ee6618fc8ff4cd674f696a924970cde53bedf9c1c1520e411efd3f2af9dce3132f69ec1eda33d3cbe5429ae6a91bb7fe7d8bf6d613a4e4ea50490dd478ff0047950a98fd0907b9f5ad0aa7fda5ab6a5a98babe96e2f37462333cea1595573b4638c8e4f6ef572bd5cb54561e2946c7263b97db3e47eef4f20ae6bc62e3ecb6b1f769091f80ff00ebd74b5cb6bffe97e20b0b41c85c13f89e7f4155983fdc38f7b235cad7fb4a93d95dfe06bde40cf636568bcc92cf044bf52c28ad8d16d7fb43c73e1cb20323ed7f686fa460b7f4a2bc5ccddebd97448fa2c993586e6eedb37fe29d8fd87c7761a80188f51b430b1f592339ff00d048af30d53fe25de2bb6bbe892e371ffc74ff004af7cf8b9a4b5f782dafe04dd71a5cab76b8ea5470e3e9b493f857877896dd6f7474ba8b9f2f0e0ffb27aff4fcab5c349cf0b28ade0eebfafbcc317054f19194be19a717fd7dc6fd154346bcfb76950ca4e5c0daff005157ebdfa73538a92ea7cbd5a6e9cdc25ba1af1a4a852455653d411915a9e1a655f1043693cb2b5ade5bcb6652490b2a861bb807a7ddc71eb596eeb1aee63c74e0724fa0f535a93681f63d3e0bbd6498e7ba9047676401660c7f8dc0e4e064ed1ec0e738af9ce27ad828e11d1aefdf9ab474bbbf75e4ba9ec6474f132aea74fe15bf631ed5b30f965d5de226272a73f329c1fe552b32a296660a07524e2baa3e096d42e2ddec203a459c70889ccaa1a49b1d1b60e14f5e49c9ee38ad31a2f853c3511b8bc29733c6a5f7dcb79afc100954e83191d077af23fd7ac2d3a118c60e756daa5fabf3f2b9db2e1ba93ad27cc940e1ed2d6f75123fb3ec6e6e81fe38d309ff007d1c2feb5bb6be05d76e306792cecd4fab19587e0303f5ae947899af21d561d3e258eeed236f223994fef59739c01d47dde87bd67c76fe23d52e9dee127b7478e4878930b1925b0e06e191b5d79da4fc9db9af0315c5f9b56bf2b8d14be6ff0013d3a19060e9fc49c9f9ff00c0201e06d3add906a1af4bbdfeea279716efa0209fd6a6b1f0cf846f182c53dc5cb6d66f9ae241c0da49c0c7675fceacdaf85eeadeee3bc96e6d2dd6266fdcc6adb150ed38ca94cf2a7ef03f7bbd269ebe16f0ecb1326b96eaf147b3635ca1c92aa09c75c9d8bed5e156cdb1b5d35f59a9397f76f6fc3e47a54f0787a5ac69a5f2206d17c150d85bddc96ee20b8629116966cb30cf18ce73f29e3bd31b45f0611285b7bb5f2e4311d8d7192e0905579f98f07a67a1ab175a97832eeda2b59f5281a389de44c39f959b764838ea371c7a536193c26cf2343e228a395e633093cf8d5d5c96c9048c9cee6eb9ebc5671ad8b8ae694ab27ff6f6d7d3f03471a4f4b47f0097c0da134314b15fde5ba4b8f2dbcf0436467f8c1ec09aa12780a47c9d3f5c866c7f0cd103ff008f21e3f2ae9353d1adbc43a64502ea06548999e37570ff0036d2ab923a81bba1ebdeb2aefc29a86dba7b69adfce9a7336f1952461884c750376c1c37415b6133ec7d25fef724fb4b55bf9f918d5cbb0b53e2a4bf2fc8e6eefc2fafd8e4be9e2e107f1da481ff00f1d386fc81ac732aaca619374530eb1caa5187e079aee9f53d6f44376f2c17b74890aa409226f05801f33150491852c4ff00b58ea055c3aee87ad34f69a8dac4c90c62466990326dda0b3027a0072bf515f4b85e33cca8abe229c6ac7bc747d3e47955f8770d3fe13717f7a3c9f53988bd86348de57446758d065989e981f40c6a6d3e089d45c3389663d491f73d803d3f9d7a6da7836c6c7504d6f4095566921da897399622879f9493b973eb93f4ac983c3ebabdcea1a64d6bf61beb2c3dbdcc2c24408dcf94c4637007380402148c63bf451e30c24f192c44e1ee69bfc51e9b7ddb194f209ac3a8425ef7e0fc8e5e8a7dcdb5cd85e49657b1795731f257a861d994f706995fa250af4f114d55a4ef17b347c955a53a5370a8acd0572ba5ff00c4c7c577377d522ced3ff8e8feb5b7acde7d874a9a5070e46d4fa9acff000d5bad968ef752f1e665c9ff006474febf9d73577ed2bc29f45ef3fd0efc2af6586a957acbdd5f3dcf44f859626fbc777fa81198f4eb41083ff4d2439ffd041a2badf847a4b58f82d6fe75db71aa4ad76d9ea14f083e9b403f8d15f395ea7b4ab29f767d661a97b1a31a7d91dcdc4115d5b4b6f32878a5428ea7a104608af9b65d31f47d4b52f0edd658d9c8510b7f1c2dca1fc8d7d2f5e57f17b40644b5f155a464bda0f26f55472d093c37fc04fe87dab5c157f635537b3d19866186788a0e31dd6abd4f18d1246d275a9f4c98e11cfc84faf6fcc5754eeb1a33b90aaa3249ed5cff00892c7ed16d1ea36c7f79080495eebd41fc2af693a849a8c5697713c42481c3491c91ef05c7438c8e33cd7b34e73a0a7462aed6b1f3f2b9f3d88a70c4a8625bb27a4bc9aebf33d27c1de1631f97ac6a717fa4119b681c7fa907f888fef9fd3f3adff12369b1692d3ea32f902221a1993fd6249db67fb5eddfbf15ca7877c59771ddea136b5a8196da1b65900f2d570dbb185000c93c0c573faa6a975ae5ff00db6f3e50b910419c8857fab1ee7f0e95f994787f34cd7399fd7256e5b7335b2beaa31f97fc13e9659961305828ca8ad1ecbbf9b3bff0a78a135db7305c2f93a844b978ce06f5ecebedea3b1fc09a2de08b312492df5d6cb48e43246a1b1b47392cc7d7e5cfaedf7ae111e68278ae6da530dcc2dba3917b1fea0f7153ea37f7dac4824d4ee4ce01cac406d897e8bfd4e4d7a75b81f134f1afea5514694b76f75e4bf43969711d2742f5a3efae8ba9d84de32d174987ecda2dab5e320c6f8fe58f2001cb9fbdc01c8cf4ac0bdf16ebd7f91f6b4b38cff05aa73f8b364fe58ac7a2be8f01c1b96617dea91f692ef2d7f0d8f23139fe2eb6907cabcbfcc64d18ba7df76f25d3ff007ae24321ff00c789a558d106155547a018a7515f4d4e852a4b969c525e4ac7913ad52a3bce4dfcc290807a807eb4b456b633b908b58564f312311c83a3c7f2b0fc4735ab67afeb96047d9f5496451ff2ceebf7c0fe27e6fd6a8515c38acb3078b56af4a32f548eaa38ec45177a736be676761f108711ead60c83a19adbe75fc57ef0fc335b0ba6f873c470fda6d4c328dbb77db4850af25802148c10c7760f7e6bcd29232f05c0b9b6964b7b81d2589b6b7e3ea3d8e457c6e61c0745dea65d51d3976bdd7f9afc4f7b09c4935eee26375dd6e7a078835e5f0de976fa4d83acba8792a88586444a0637b0fc381dcfb669de0ad6ecaeac869fb3c8d42305e5466c9989eb203fc593d7b8fcabcf98c924d24f3caf34f2b6e9257eac7fcf6a4f9d248e686468a789b74722f543ebff00d6ef50f80e93cb5d2e6fdf3d5cba5fb7a7fc395feb24beb57b7eef6f3f53d53c47e1f835eb1f2c9115d4796b79f1ca37a1f553dc5796324b0cd2dbdcc662b985b64b19fe13fd41ea0f706b4b5ef110d7edf4a8e5262be80c9e7c68c57270b875c763cfd0e45735abde2e9b0c97af34d2dc3a88d3cd959f3e9d4f6ad783f038fcba849e225fbbbbbc5ef169eebc98675530f8ba91a74d5e6ed66b669f731f5b91b56d6a0d3213f221f9c8f5eff90ae922d31f58d4b4df0edae54de4811caff042bcb9fc8562f86ec4dbdb49a8dc9fde4c0905bb2f527f1af5df843a0b3a5d78aaee321eec79364ac395841e5bfe047f97bd7d056aae9d195497c553f046787a31ab888d28fc14bf197fc3fe47a7dbc115adb456f0a048a24088a3a000600a2a5a2bc63e802a2b9b786eed65b6b88d64865428e8c321948c1152d1401f396afa24be13f104da0dc65ad5c196c656ff0096911fe13eebd0d71b3249e19d604d1826ca63c8f41e9f51dabe99f1bf84a0f17686d6c58457b09f36d2e31cc720fe87a1af069addaed2eb49d56030df5bb7973c47aab0e8c3d8f506bd7c355f6f054ef69c7e17fa1e0e328fd56a3ab6bd39e925fa93a24174f15e23171b7e5c1f94fbe3d7fc6ac572363773f876f8d8de64dab9cabf61ee3dbd4575aacaea1d5832919047435eb616b46a27a5a5d5799e1e330f2a4d6b78fd97e42d14515d4719d9eb1a2e9f63a6dcdcda451cf3f970ee8831ff00465651f391dc93f80cd3351f0cc76de198a55b62b796ea92cf26ecef0f9c8c76dbf2fe66b9b5d52f9677985d482478c44ed9fbc980307db814dfed1bc37134e6e24f36752b2be79707a835c4a85656f7b6feac77bc4506dbe4df4e9a79faec75baee93a5a5b6aa96905a89ad3632ac2640e832012fb8ed3d7b5617862d2deef59f2aee347896191c8933b7214904e39c556b9d7b56bb87c9b8bf9e48c904a96e0e3a66a08b52bd86f9af63b975ba6249941e4e7ad3a746ac693837abf3154af465563351d174b2ee75f0e93a5cb716b72b05a34125a4eecc8d2084ba1e382770c0233fa53bfb274a4d40092dad415d3dee1ca990db93b86d65e77118eb8ae4e6d6b52b893cc9af6676d863c96fe13d47e3496facea368b1082f258c44aca983f74139207b66b3fab56b7c5f8b34fadd0bfc1f82f23a2b2b7d2a7fed3b868f4c31c1145b1c09bca04b10723ef67ff00ad568e93a55b3ea73b4168b0ac76cf0b4e6468fe70724053bb048e335cc0f10eaeb3b4c3509848ca119b3c903903f5a48f5fd5a29e59d3509c4b36048dbb25b1d3f2cd0f0d59b7697e2fcbc8238aa092bc7bf45e7e7e6bee3774cb6d2ae0ced25bda1692e445133aca2075c0f951b3956cf396cf5ae5ef6036b7d710326c68a4642bbb76dc1c633deadc7afead0cb2cb1dfceaf2905c86ea40c03f5f7ace7667767762ccc72493924d7451a73849b93d0e6ad569ce09456abc84a28a4665452cc42a81924f415d0732572399a1841b9976af96a72e4720572b0a49e26d60cd2022ca13c0f6f4fa9ef4b7d773f88af858d9e56d54e59fb1f73ede82b7e1b76b45b5d274a80cd7d70de5c110eacc7ab1f61d49af2aa548d76e4f4a71dfcd9ed51a53c345463ad596cbf957f99a5a46892f8b7c410e836f94b54025be957fe59c43f847bb7415f445b5bc3696b15b5bc6b1c31204445180aa0600ae7bc11e1283c23a1adb0612decc7cdbbb8c732487fa0e83ff00af5d3578b89aeebd4737f23e8b07858e1a9282dfaf9b0a28a2b9cea12968a28012b84f883e04ff00848a15d534bdb0eb76cbf231e1675ff9e6dfd0f6aef290f4a71938bbadc99454938c95d33e5d9e08758b796d2ee1782ea162b244e30f0b8ff3f8d625adeddf872ebec77a0bda93f2b0edee3fc2be83f1d7c3d8bc47ff00133d31d6d35b8970b2e3e49c7f724fe87b578e5cc02e259f49d5ed1adafa23892093820ff794f71ee2bd9a35d625a69f2d45f733c0af877844e325cd45f4eb1f42dc33477112cb138746190c0d3eb9078351f0ccc658099ec98f20f4fc7d0fbd743a76ad6ba9c7985f1201f346dd457a54314a6fd9d45cb2edfe478f88c13847dad27cd0efdbd7b17a8a28aeb38428a28a0028a28a0028a28a0028a2a8ea3ab5ae991e667cc847cb1af535339c611e693b234a74e7524a105765b9a68ede269657088a32589ae52eaf6efc4775f63b2052d41f9d8f7f73fe148906a3e26984b39305903c01d3f0f53ef5d0db422de58749d22d1ae6fa5388e08f924ff798f61ee6bcda955d78b949f2d3fc5ffc03d7a346386928c573d5edd23ff048a0821d1ede2b4b485e7ba9982c7120cbcce7fcfe15ecff000fbc09ff0008ec2daa6a9b66d6ee57e761cac0bff3cd7fa9ef4be05f87b17873fe267a9ba5deb72ae1a5c7c900fee47fd4f7aee857918ac57b5b420ad15b23ddc160bd85e73779bdd852d145719de14514500145145001451450015cdf8b7c15a5f8bad152ed1a2bb8b982ee2e2488fd7b8f635d25146c0d5f467ce5ae691ab784ae7ecbaf421ed5ced8b508d73149ecdfdd3ec6b99bff000dabb0bad324f265fbc154e14fd0f6afab2ead2defada4b6ba8239e0906d78e450cac3dc1af29f117c26b9b167bcf09cc3cbfbcda6dc3fca7feb9b9e9f43c7bd7a54f1b19c54312aebbf54791572e9d393a984767d57467925a788ae2ca5fb36ad0bab0e3cc039fc477fa8ae8edee60bb884904ab221eea6aadd08669db4ed5ec9ed6ed7adbdcaed61eea7bfd45634fe1cbab294cfa4dcb03fdc2707f3e87f1af4a9d4ad4d5e0fda47f1ff0082791568d0ab2e59af653ffc95ff0097e4751457310789ae2d24f2354b56561fc6a307f2ff000addb4d46d2f9736f3a39feee7047e15d74b154aae917af67b9c35f055a8eb25a775aa2d514555bbd46d2c573713a21feee724fe15b4a4a2af276473c2129be58abb2d545717305a44649e558d077635cedc789ae2ee4f234bb56663fc6c327f2ff1a483c39757b289f56b9627fb80e4fe7d07e15c6f18e6f968479bcfa1e8472f54d7362a5cabb6efee0bbf115cdecbf66d26176278f308e7f01dbea6a5b0f0daa31bad4e4f3a5fbc558e40fa9ef5a96a218675d3b48b27babc6e96f6cbb98fbb1edf535e85e1df84d737cc979e2c98797f7974db77f947fd7471d7e838f7ae1ad569d37cd5e5cf2edd11e8e1e8d5ab1e5c347d9c3bbdd9c7e87a46ade2db9fb2e83084b543b65d4245c451fb2ff78fb0af69f09782f4bf08da325a234b772f33ddcbcc929faf61ec2b76d6d2dec6da3b6b58238608c6d48e350aaa3d80a9ebccc4626a57779bf91ece17074b0d1b417cfab12968a2b9cea0a28a2800a28a2800a28a2800a28a2800a28a2800a28a2803275cf0de91e24b4fb36ad6315cc7fc2586190faab0e47e15e61acfc28d5f4b2d2f876f85f5b8e7ec77ad8907b2c9d0fe38af65a2b4a756749f341d8caad1a75a3cb515d1f30df32413fd835dd3e5b19ffe795dc7807dd5ba11ee2b2ee7c296f21f36c67685ba819cafe07ad7d4fa869965aadab5b5fda417503758e640c3f5af3ed57e0e698e5a6d06fee74a90f3e567cd849ff75b91f9d77ac742a698885fcd6e798f2da945df0b52de4f547887d87c49ff001edf693e57fcf4de3f9fdeab36de15b78cf9b7d3b4cdd48ce17f13d6baff00f844bc4dff000917f607da34afb46ddff68cc9b76ffbbb7afe95dbe95f0734c42b2ebd7f73aac839f2b3e5420ffbabc9fceaa55f091d52737e7d0ce186c74f46e305d6cb56796d8b24f3fd8342b096fa7ff9e5691e40f766e807b9aee746f851abea8565f115f0b1b73cfd8ec9b321f6693a0fc335eb5a7e9b63a55aadb585a416b02f48e140a3f4ab75cf5b1f56a2e55a2ec8ecc3e594293e66b9a5dd993a1f86f48f0e5a7d9b49b18ada33f78a8cb39f5663c9fc6b56968ae23d00a28a2800a28a2800a28a2800a28a2803ffd9);

-- --------------------------------------------------------

--
-- Table structure for table `semester`
--

CREATE TABLE `semester` (
  `kode_semester` int(11) NOT NULL,
  `semester` char(7) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `semester`
--

INSERT INTO `semester` (`kode_semester`, `semester`) VALUES
(1, 'Ganjil'),
(2, 'Genap');

-- --------------------------------------------------------

--
-- Table structure for table `siswa`
--

CREATE TABLE `siswa` (
  `nis` char(10) NOT NULL,
  `kode_kelas` char(10) NOT NULL,
  `nama_siswa` varchar(30) NOT NULL,
  `no_tlp` char(15) NOT NULL,
  `alamat` varchar(50) DEFAULT NULL,
  `tempat_lahir` varchar(30) NOT NULL,
  `tanggal_lahir` varchar(10) NOT NULL,
  `jenis_kelamin` varchar(10) NOT NULL,
  `tahun_ajaran_masuk` char(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `siswa`
--

INSERT INTO `siswa` (`nis`, `kode_kelas`, `nama_siswa`, `no_tlp`, `alamat`, `tempat_lahir`, `tanggal_lahir`, `jenis_kelamin`, `tahun_ajaran_masuk`) VALUES
('1861', '005', 'Bagus Pambudi', '', 'Banjarharjo Rt 5/4', 'Brebes', '1995-02-13', 'L', '2015/2016'),
('2020', '003', 'widina rahman', '', 'KJJ', 'brebes', '06/19/2017', 'L', '2020/2021'),
('2323', '001', 'uhuk', '', 'dfdfdf', 'hjkhk', '2017-07-17', 'L', '2018/2019'),
('310', '003', 'raman uty', '+62180190911', 'ssss', 'Brebes', '2017-07-31', 'P', '2018/2019'),
('4826', '005', 'Adhitya Kurnianti', '', 'Kubang Pari, Rt 2/2', 'Brebes', '2000-06-03', 'P', '2015/2016'),
('4845', '005', 'Apri Kuncoro', '', 'Dukuh Badag, Rt 2/5', 'Brebes', '2000-04-20', 'L', '2015/2016'),
('4889', '005', 'Iqbal Muhtadin', '', 'Malahayu, Rt 1/4', 'Brebes', '2000-05-03', 'L', '2015/2016'),
('4891', '005', 'Ismail Hasyim', '', 'Tegal Reja, Rt 2/4', 'Brebes', '2000-04-22', 'L', '2015/2016'),
('4903', '005', 'Langgeng Tri Raharjo', '', 'Ciawi, Rt 3/2', 'Brebes', '2000-08-22', 'L', '2015/2016'),
('4905', '005', 'Muslimatun Azizah', '', 'Banjar Lor, Rt 1/2', 'Brebes', '2000-04-25', 'P', '2015/2016'),
('4908', '005', 'Ndayu ocviana', '', 'Pende, Rt 1/1', 'Brebes', '2000-10-16', 'P', '2015/2016'),
('4910', '005', 'Nur Halimah', '', 'Karadenan, Rt 1/5', 'Brebes', '2000-08-10', 'P', '2015/2016'),
('4919', '005', 'Pepy Isromiyah', '', 'Banjarharjo, Rt 4/3', 'Brebes', '2000-11-05', 'P', '2015/2016'),
('4923', '005', 'Prayogi Rizki', '', 'Penanggapan, Rt 1/2', 'Brebes', '2000-02-07', 'L', '2015/2016'),
('4924', '005', 'Puli Widiyati', '', 'Kubang Pari', 'Brebes', '2000-06-04', 'P', '2015/2016'),
('4927', '005', 'Reny Tri Astuti', '', 'Banjar Lor, Rt 1/2', 'Brebes', '2000-08-09', 'P', '2015/2016'),
('4928', '005', 'Rhama Nur Bangkit', '', 'Kertasari, Rt 1/4', 'Brebes', '2000-05-20', 'L', '2015/2016'),
('4929', '005', 'Rian Kustiawan', '', 'Banjarharjo, Rt 3/3', 'Brebes', '2000-06-03', 'L', '2015/2016'),
('4930', '005', 'Rian Syarif Julianto', '', 'Tegal Reja, Rt 2/3', 'Brebes', '2000-07-27', 'L', '2015/2016'),
('4932', '005', 'Ridha Eka Pangestu', '', 'Banjarharjo, Rt 1/3', 'Brebes', '2000-05-20', 'L', '2015/2016'),
('4935', '005', 'Rizqi Yulianto', '', 'Karang Bandung, Rt 1/5', 'Brebes', '2000-07-15', 'L', '2015/2016'),
('4944', '005', 'Rudi Prasetyo', '', 'Baros, Rt 2/3', 'Jakarta', '2000-05-18', 'L', '2015/2016'),
('4982', '002', 'Adi Nurdianto', '', 'Banjarharjo, Rt 3/4', 'Brebes', '2001-06-01', 'L', '2016/2017'),
('5002', '002', 'yyy', '', 'sakshj\r\n', '', '0000-00-00', 'L', '2020/2021'),
('5048', '002', 'Firman Ramadhan', '', 'Banjarharjo, Rt 2/1', 'Brebes', '2001-01-03', 'L', '2016/2017'),
('5059', '002', 'Herri Jamalludin S', '', 'Pare reja, Rt 2/5', 'Brebes', '2001-02-12', 'L', '2016/2017'),
('5066', '002', 'Ines Yulva Ardiani', '', 'Kertasari, Rt 1/4', 'Cirebon', '2001-01-07', 'P', '2016/2017'),
('5072', '001', 'Istiqomah', '', 'Banjar Lor, Rt 2/1', 'Brebes', '2001-03-22', 'P', '2016/2017'),
('50726', '002', 'Rahman UTY', '+626565', 'JJKH', 'JHHJHJ', '2017-07-31', 'L', '2016/2017'),
('5077', '001', 'Kris Saputra', '', 'Penanggapan Rt 1/1', 'Brebes', '2001-09-05', 'L', '2016/2017'),
('5080', '001', 'Laila Nur Kholifah', '', 'Cikuya, Rt 2/4', 'Brebes', '2001-12-30', 'P', '2016/2017'),
('5097', '001', 'Nafilah Rizqi', '', 'Banjar Lor, Rt 1/7', 'Brebes', '2001-11-09', 'P', '2016/2017'),
('5101', '001', 'Nisa Dwi Hanifah', '', 'Karang Bandung', 'Brebes', '2001-03-04', 'P', '2016/2017'),
('5104', '001', 'Nur Anindita Kusuma', '', 'Cikakak, rt 3/10', 'Brebes', '2001-06-11', 'P', '2016/2017'),
('5107', '001', 'Nur Mei Risantari', '', 'Kubangjero, Rt 1/2', 'Brebes', '2001-05-02', 'P', '2016/2017'),
('5112', '001', 'Okli Kusuma Harari', '', 'Sukareja, Rt 1/4', 'Brebes', '2001-10-05', 'P', '2016/2017'),
('5119', '001', 'Rahmah polis Agustina', '', 'Banjarharjo, Rt 3/4', 'Brebes', '2001-08-10', 'P', '2016/2017'),
('99091', '010', 'Ilham Ali', '+6299091', '99091', '99091', '2017-07-31', 'L', '9909/9909');

-- --------------------------------------------------------

--
-- Table structure for table `tabungan`
--

CREATE TABLE `tabungan` (
  `id_tabungan` int(11) NOT NULL,
  `no_rekening` char(20) NOT NULL,
  `tgl_transaksi` date NOT NULL,
  `jumlah_penarikan` int(15) NOT NULL,
  `jumlah_setor` int(15) NOT NULL,
  `keterangan` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tabungan`
--

INSERT INTO `tabungan` (`id_tabungan`, `no_rekening`, `tgl_transaksi`, `jumlah_penarikan`, `jumlah_setor`, `keterangan`) VALUES
(31, '51121706', '2017-02-06', 0, 5000, 'Credit'),
(32, '51121706', '2017-06-06', 0, 5000, 'Credit'),
(33, '51121706', '2017-06-16', 0, 100, 'Credit'),
(34, '51121706', '2017-06-16', 9000, 0, 'Debit'),
(35, '50801706', '2017-06-17', 0, 9000, 'Credit'),
(36, '50801706', '2017-06-17', -5000, 0, 'Debit'),
(37, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(38, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(39, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(40, '1-1707-7', '2017-07-22', 0, 900, 'Credit'),
(41, '1-1707-7', '2017-07-22', 0, -900, 'Credit'),
(42, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(43, '1-1707-7', '2017-07-22', 0, -9000, 'Credit'),
(44, '1-1707-7', '2017-07-22', 0, -9000, 'Credit'),
(45, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(46, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(47, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(48, '1-1707-7', '2017-07-22', 0, -9000, 'Credit'),
(49, '1-1707-7', '2017-07-22', 0, 0, 'Credit'),
(50, '1-1707-7', '2017-07-22', 0, -9000, 'Credit'),
(51, '1-0717-1', '2017-07-26', 0, 8000, 'Credit'),
(52, '1-071', '2017-07-26', 0, 0, 'Debit'),
(53, '1-0717-1a', '2017-07-26', 0, 0, 'Credit'),
(54, '1-0717-1', '2017-07-26', 0, 0, 'Credit'),
(55, '1-0717-1', '2017-07-26', 0, 0, 'Credit'),
(56, '1-0717-1', '2017-07-26', 0, 0, 'Credit'),
(57, '1-0717-1', '2017-07-26', 0, 0, 'Credit'),
(58, '1-0717-1', '2017-07-26', 0, 0, 'Credit'),
(59, '1-0717-1', '2017-07-29', 0, 20000, 'Credit'),
(60, '1-0717-1', '2017-07-30', 0, 100, 'Credit');

-- --------------------------------------------------------

--
-- Table structure for table `tahun_ajaran`
--

CREATE TABLE `tahun_ajaran` (
  `kode_tahun_ajaran` int(11) NOT NULL,
  `status` char(15) NOT NULL,
  `tahun_ajaran` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tahun_ajaran`
--

INSERT INTO `tahun_ajaran` (`kode_tahun_ajaran`, `status`, `tahun_ajaran`) VALUES
(1, 'Tidak Aktif', '2015/2016'),
(2, 'Aktif', '2016/2017'),
(3, 'Tidak Aktif', '2018/2019'),
(12, 'Tidak Aktif', '2017/2018'),
(13, 'Tidak Aktif', '2019/2020');

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `kode_transaksi` int(11) NOT NULL,
  `kode_pembayaran` char(10) NOT NULL,
  `id_admin` int(11) NOT NULL,
  `kode_tahun_ajaran` int(11) NOT NULL,
  `tanggal_transaksi` date NOT NULL,
  `jenis_transaksi` char(15) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `keterangan` varchar(225) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`kode_transaksi`, `kode_pembayaran`, `id_admin`, `kode_tahun_ajaran`, `tanggal_transaksi`, `jenis_transaksi`, `jumlah`, `keterangan`) VALUES
(19, '002', 3, 2, '2016-11-07', 'Pemasukan', 800000, NULL),
(71, '004', 3, 2, '2016-11-07', 'Pemasukan', 110000, NULL),
(72, '004', 3, 2, '2016-11-07', 'Pemasukan', 110000, NULL),
(93, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(94, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(95, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(96, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(98, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(99, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(100, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(101, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(102, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(103, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(104, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(105, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(106, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(107, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(108, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(109, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(110, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(111, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(112, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(113, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(114, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(115, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(116, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(117, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(118, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(119, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(120, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(121, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(122, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(123, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(124, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(125, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(126, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(127, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(128, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(129, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(130, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(131, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(132, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(133, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(134, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(135, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(136, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(137, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(138, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(139, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(140, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(141, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(142, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(143, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(144, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(145, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(146, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(147, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(148, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(149, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(150, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(151, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(152, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(464, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(471, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(472, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(475, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(476, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(479, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(480, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(481, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(482, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(483, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(484, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(485, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(486, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(645, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(647, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(648, '002', 3, 1, '2016-11-07', 'Pemasukan', 30000, NULL),
(649, '002', 3, 1, '2016-11-07', 'Pemasukan', 500000, NULL),
(650, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(651, '002', 3, 1, '2016-11-07', 'Pemasukan', 275000, NULL),
(652, '002', 3, 1, '2016-11-07', 'Pemasukan', 500000, NULL),
(653, '002', 3, 1, '2016-11-07', 'Pemasukan', 275000, NULL),
(654, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(655, '002', 3, 1, '2016-11-07', 'Pemasukan', 400000, NULL),
(656, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(657, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(658, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(659, '002', 3, 1, '2016-11-07', 'Pemasukan', 500000, NULL),
(660, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(661, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(662, '002', 3, 1, '2016-11-07', 'Pemasukan', 375000, NULL),
(663, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(664, '002', 3, 1, '2016-11-07', 'Pemasukan', 700000, NULL),
(665, '002', 3, 1, '2016-11-07', 'Pemasukan', 75000, NULL),
(666, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(667, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(668, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(669, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(670, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(671, '002', 3, 1, '2016-11-07', 'Pemasukan', 775000, NULL),
(672, '002', 3, 1, '2016-11-07', 'Pemasukan', 245000, NULL),
(673, '004', 3, 1, '2016-11-07', 'Pemasukan', 105000, NULL),
(674, '001', 3, 2, '2016-11-07', 'Pengeluaran', 1400000, 'DFDFD'),
(675, '001', 3, 1, '2016-11-07', 'Pemasukan', 25000, NULL),
(676, '002', 3, 1, '2016-11-07', 'Pemasukan', 100000, NULL),
(679, '004', 3, 1, '2016-11-08', 'Pemasukan', 105000, NULL),
(680, '001', 3, 1, '2016-12-09', 'Pemasukan', 25000, NULL),
(681, '006', 3, 1, '2017-04-12', 'Pemasukan', 0, 'Saldo Awal'),
(682, '006', 3, 2, '2017-04-12', 'Pemasukan', 50000, NULL),
(683, '006', 3, 2, '2017-04-12', 'Pengeluaran', 4544, 'rtyrtyertyert'),
(684, '002', 3, 2, '2017-06-11', 'Pemasukan', 1000, NULL),
(690, '002', 3, 2, '2017-06-11', 'Pemasukan', 900, NULL),
(691, '002', 3, 2, '2017-06-11', 'Pemasukan', 900, NULL),
(696, '002', 3, 2, '0000-00-00', 'Pemasukan', 300, ''),
(697, '002', 3, 2, '0000-00-00', 'Pemasukan', 300, ''),
(698, '002', 3, 2, '0000-00-00', 'Pemasukan', 300, ''),
(702, '002', 3, 2, '0000-00-00', 'Pemasukan', 300, ''),
(707, '002', 3, 2, '0000-00-00', 'Pemasukan', 90, ''),
(710, '002', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(711, '002', 3, 2, '0000-00-00', 'Pemasukan', 9, ''),
(714, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(715, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 0, ''),
(716, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(717, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(718, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(719, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(720, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 90, ''),
(721, 'BKL2', 3, 2, '0000-00-00', '', 0, NULL),
(722, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(723, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(724, 'BKL2', 3, 2, '0000-00-00', 'Pemasukan', 90, ''),
(727, '', 3, 2, '0000-00-00', 'Pemasukan', 90, ''),
(728, '', 3, 2, '0000-00-00', 'Pemasukan', 0, ''),
(729, '002', 3, 2, '0000-00-00', 'Pemasukan', 0, ''),
(730, '002', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(731, '002', 3, 2, '0000-00-00', 'Pemasukan', 900, ''),
(732, '006', 3, 2, '2017-06-11', 'Pemasukan', 900, ''),
(733, '', 3, 2, '2017-06-11', 'Pemasukan', 900, ''),
(734, '', 3, 2, '2017-06-11', 'Pemasukan', 900, ''),
(735, '', 3, 2, '2017-06-11', 'Pemasukan', 900, ''),
(736, '', 3, 2, '2017-06-11', 'Pemasukan', 900, ''),
(737, '', 3, 2, '2017-06-11', 'Pemasukan', 900, ''),
(738, '', 3, 2, '2017-06-11', 'Pemasukan', 0, ''),
(739, '', 3, 2, '2017-06-11', 'Pemasukan', 90, ''),
(740, '', 3, 2, '2017-06-11', 'Pemasukan', 9, ''),
(741, '', 3, 2, '2017-06-11', 'Pemasukan', 900, ''),
(742, '', 3, 2, '2017-06-11', 'Pemasukan', 90, ''),
(743, '', 3, 2, '2017-06-11', 'Pemasukan', 9000, ''),
(744, '', 3, 2, '2017-06-11', 'Pemasukan', 90, ''),
(745, '002', 3, 2, '2017-06-13', 'Pemasukan', 9000, ''),
(746, 'PILIH', 3, 2, '2017-06-14', 'Pemasukan', 70000, ''),
(747, 'PILIH', 3, 2, '2017-06-14', 'Pemasukan', 90000, ''),
(748, 'PILIH', 3, 2, '2017-06-14', 'Pemasukan', 99999, ''),
(749, '002', 3, 2, '2017-06-14', 'Pemasukan', 90, ''),
(750, '004', 3, 2, '2017-06-15', 'Pemasukan', 110000, ''),
(751, '004', 3, 2, '2017-06-15', 'Pemasukan', 110000, ''),
(752, '001', 3, 2, '2017-06-15', 'Pemasukan', 30000, ''),
(753, '001', 3, 2, '2017-06-15', 'Pemasukan', 30000, ''),
(754, '', 3, 2, '2017-06-15', 'Pemasukan', 70000, ''),
(755, '', 3, 2, '2017-06-15', 'Pemasukan', 9000, ''),
(756, '', 3, 2, '2017-06-15', 'Pemasukan', 9000, ''),
(757, '002', 3, 2, '2017-06-15', 'Pemasukan', 90, ''),
(758, '004', 3, 2, '2017-06-15', 'Pemasukan', 220000, ''),
(759, '004', 3, 2, '2017-06-15', 'Pemasukan', 110000, ''),
(760, '004', 3, 2, '2017-06-15', 'Pemasukan', 110000, ''),
(761, '', 3, 2, '2017-06-16', 'Pengeluaran', 0, ''),
(762, '006', 3, 2, '2017-06-16', 'Pengeluaran', 110000, ''),
(763, '003', 3, 2, '2017-06-16', 'Pengeluaran', 90000, ''),
(764, '003', 3, 2, '2017-06-16', 'Pengeluaran', 1000000, ''),
(765, '003', 3, 2, '2017-06-16', 'Pengeluaran', 110000, 'iniii'),
(766, '006', 3, 2, '2017-06-16', 'Pengeluaran', 90000, 'Pembelia kursi untuk siswa baru'),
(767, '004', 3, 2, '2017-06-17', 'Pemasukan', 110000, ''),
(768, '004', 3, 2, '2017-06-26', 'Pemasukan', 0, ''),
(769, '001', 3, 2, '2017-07-17', 'Pemasukan', 30000, ''),
(770, '001', 3, 2, '2017-07-17', 'Pemasukan', 0, ''),
(772, '001', 3, 2, '2017-07-18', 'Pemasukan', 0, ''),
(773, '001', 3, 2, '2017-07-18', 'Pemasukan', 0, ''),
(774, '002', 3, 2, '2017-07-18', 'Pemasukan', 60000, ''),
(776, '008', 3, 2, '2017-07-19', 'Pemasukan', 0, ''),
(778, '001', 3, 2, '2017-07-19', 'Pemasukan', 30000, ''),
(779, '001', 3, 2, '2017-07-19', 'Pemasukan', 30000, ''),
(780, '004', 3, 2, '2017-07-21', 'Pemasukan', 0, ''),
(781, '1', 3, 2, '2017-07-21', 'Pemasukan', 30000, ''),
(782, '4', 3, 2, '2017-07-21', 'Pemasukan', 110000, ''),
(783, '99', 3, 2, '2017-07-23', 'Pemasukan', 9000, ''),
(784, '99', 3, 2, '2017-07-23', 'Pemasukan', 9000, ''),
(785, '99', 3, 2, '2017-07-23', 'Pemasukan', 9000, ''),
(786, '1', 3, 2, '2017-07-23', 'Pemasukan', 110000, ''),
(787, '8', 3, 2, '2017-07-23', 'Pemasukan', 90000, ''),
(788, '1', 3, 2, '2017-07-23', 'Pemasukan', 9000, ''),
(789, '99', 3, 2, '2017-07-23', 'Pemasukan', 9000, ''),
(790, 'TBUKU', 3, 2, '2017-07-23', 'Pemasukan', 75000, ''),
(791, 'c1', 3, 2, '2017-07-23', 'Pemasukan', 90000, ''),
(792, '001', 3, 2, '2017-07-23', 'Pemasukan', 30000, ''),
(793, 'TBUKU', 3, 2, '2017-07-23', 'Pemasukan', 75000, ''),
(794, 'c1', 3, 2, '2017-07-23', 'Pemasukan', 90000, ''),
(795, '011', 3, 2, '2017-07-23', 'Pemasukan', 90000, ''),
(796, '6', 3, 2, '2017-07-23', 'Pemasukan', 90000, ''),
(797, '006', 3, 2, '2017-07-23', 'Pemasukan', 4000, ''),
(798, '006', 3, 2, '2017-07-23', 'Pemasukan', 100, ''),
(799, '006', 3, 2, '2017-07-23', 'Pemasukan', 4000, ''),
(800, '006', 3, 2, '2017-07-23', 'Pemasukan', 6000, ''),
(801, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(802, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(803, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(804, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(805, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(806, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(807, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(808, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(809, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(810, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(811, '001', 3, 2, '2017-07-24', 'Pemasukan', 90000, ''),
(812, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(813, '002', 3, 2, '2017-07-24', 'Pemasukan', 600000, ''),
(814, '002', 3, 2, '2017-07-24', 'Pemasukan', 80000, ''),
(815, '002', 3, 2, '2017-07-24', 'Pemasukan', 600000, ''),
(816, '002', 3, 2, '2017-07-24', 'Pemasukan', 1000000, ''),
(817, '002', 3, 2, '2017-07-24', 'Pemasukan', 1000000, ''),
(818, '002', 3, 2, '2017-07-24', 'Pemasukan', 1, ''),
(819, '002', 3, 2, '2017-07-24', 'Pemasukan', 2, ''),
(820, 'c1', 3, 2, '2017-07-24', 'Pemasukan', 90000, ''),
(821, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(822, '001', 3, 2, '2017-07-24', 'Pemasukan', 30001, ''),
(823, '001', 3, 2, '2017-07-24', 'Pemasukan', 20001, ''),
(824, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(825, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(826, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(827, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(828, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(829, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(830, '002', 3, 2, '2017-07-24', 'Pemasukan', 910, ''),
(831, '002', 3, 2, '2017-07-24', 'Pemasukan', 600000, ''),
(832, '002', 3, 2, '2017-07-24', 'Pemasukan', 1, ''),
(833, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(834, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(835, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(836, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(837, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(838, '004', 3, 2, '2017-07-24', 'Pemasukan', 110000, ''),
(839, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(840, '001', 3, 2, '2017-07-24', 'Pemasukan', 30000, ''),
(841, '002', 3, 2, '2017-07-24', 'Pemasukan', 600000, ''),
(842, '002', 3, 2, '2017-07-24', 'Pemasukan', 2000, ''),
(843, '002', 3, 2, '2017-07-25', 'Pemasukan', 30000, ''),
(844, '004', 3, 2, '2017-07-25', 'Pemasukan', 110000, ''),
(845, '003', 3, 2, '2017-07-25', 'Pemasukan', 40000, ''),
(846, '003', 3, 1, '2017-07-26', 'Pemasukan', 5000, ''),
(847, '004', 3, 2, '2017-07-27', 'Pemasukan', 110000, ''),
(848, '003', 3, 2, '2017-07-27', 'Pemasukan', 40000, ''),
(849, '003', 3, 2, '2017-07-27', 'Pemasukan', 40000, ''),
(850, '003', 3, 2, '2017-07-27', 'Pemasukan', 7000, ''),
(851, '003', 3, 2, '2017-07-27', 'Pemasukan', 50000, ''),
(852, '004', 3, 2, '2017-07-27', 'Pemasukan', 110000, ''),
(853, '004', 3, 2, '2017-07-27', 'Pemasukan', 110000, ''),
(854, '004', 3, 2, '2017-07-27', 'Pemasukan', 110000, ''),
(855, '004', 3, 2, '2017-07-27', 'Pemasukan', 110000, ''),
(856, '004', 3, 2, '2017-07-27', 'Pemasukan', 110000, ''),
(857, '003', 3, 2, '2017-07-28', 'Pemasukan', 20000, ''),
(858, '003', 3, 2, '2017-07-28', 'Pemasukan', 40000, ''),
(859, '003', 3, 2, '2017-07-28', 'Pemasukan', 20000, ''),
(860, '001', 3, 2, '2017-07-28', 'Pemasukan', 30000, ''),
(861, '006', 3, 2, '2017-07-30', 'Pemasukan', 60000, ''),
(862, '006', 3, 2, '2017-07-30', 'Pemasukan', 1000, ''),
(863, '006', 3, 2, '2017-07-30', 'Pemasukan', 10000, ''),
(864, '006', 3, 2, '2017-07-30', 'Pemasukan', 1000, ''),
(865, '006', 3, 2, '2017-07-30', 'Pemasukan', 900000, ''),
(866, '006', 3, 2, '2017-07-30', 'Pemasukan', 10000, ''),
(867, '006', 3, 2, '2017-07-30', 'Pemasukan', 20000, ''),
(868, '002', 3, 2, '2017-07-30', 'Pemasukan', 1500002, ''),
(870, '003', 3, 2, '2017-07-31', 'Pemasukan', 9090, ''),
(872, '004', 3, 2, '2017-07-31', 'Pemasukan', 110000, ''),
(873, '001', 3, 2, '2017-07-31', 'Pemasukan', 30000, ''),
(874, '001', 3, 2, '2017-07-31', 'Pemasukan', 30000, ''),
(875, '004', 3, 2, '2017-08-04', 'Pemasukan', 110000, ''),
(876, '002', 3, 2, '2017-08-04', 'Pemasukan', 600000, ''),
(877, '002', 3, 2, '2017-08-04', 'Pemasukan', 1000, ''),
(878, '004', 3, 2, '2017-08-04', 'Pemasukan', 110000, ''),
(879, '002', 3, 2, '2017-08-04', 'Pemasukan', 1000, ''),
(880, '001', 3, 2, '2017-08-05', 'Pemasukan', 30000, ''),
(881, '004', 3, 2, '2017-08-05', 'Pemasukan', 110000, ''),
(882, '004', 3, 2, '2017-08-05', 'Pemasukan', 110000, ''),
(883, '004', 3, 2, '2017-08-05', 'Pemasukan', 110000, ''),
(884, '004', 3, 2, '2017-08-05', 'Pemasukan', 110000, ''),
(885, '004', 3, 2, '2017-08-05', 'Pemasukan', 110000, '');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id_admin`),
  ADD UNIQUE KEY `user_name` (`user_name`);

--
-- Indexes for table `bulan`
--
ALTER TABLE `bulan`
  ADD PRIMARY KEY (`kode_bulan`);

--
-- Indexes for table `detail_pembayaran`
--
ALTER TABLE `detail_pembayaran`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `kode_bulan` (`kode_bulan`),
  ADD KEY `nis` (`nis`),
  ADD KEY `kode_transaksi` (`kode_transaksi`);

--
-- Indexes for table `detail_pengeluaran`
--
ALTER TABLE `detail_pengeluaran`
  ADD PRIMARY KEY (`kode_detail`),
  ADD KEY `kode_pengeluaran` (`kode_pengeluaran`),
  ADD KEY `kode_transaksi` (`kode_transaksi`);

--
-- Indexes for table `kelas`
--
ALTER TABLE `kelas`
  ADD PRIMARY KEY (`kode_kelas`),
  ADD UNIQUE KEY `nama_kelas` (`nama_kelas`);

--
-- Indexes for table `no_tabungan`
--
ALTER TABLE `no_tabungan`
  ADD PRIMARY KEY (`no_rekening`),
  ADD KEY `nis` (`nis`);

--
-- Indexes for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD PRIMARY KEY (`kode_pembayaran`);

--
-- Indexes for table `pembayaran_tahun_ajaran`
--
ALTER TABLE `pembayaran_tahun_ajaran`
  ADD KEY `kode_tahun_ajaran` (`kode_tahun_ajaran`),
  ADD KEY `kode_pembayaran` (`kode_pembayaran`);

--
-- Indexes for table `pengeluaran`
--
ALTER TABLE `pengeluaran`
  ADD PRIMARY KEY (`kode_pengeluaran`);

--
-- Indexes for table `profil_sekolah`
--
ALTER TABLE `profil_sekolah`
  ADD PRIMARY KEY (`kode_sekolah`);

--
-- Indexes for table `semester`
--
ALTER TABLE `semester`
  ADD PRIMARY KEY (`kode_semester`);

--
-- Indexes for table `siswa`
--
ALTER TABLE `siswa`
  ADD PRIMARY KEY (`nis`),
  ADD KEY `kode_kelas` (`kode_kelas`);

--
-- Indexes for table `tabungan`
--
ALTER TABLE `tabungan`
  ADD PRIMARY KEY (`id_tabungan`),
  ADD KEY `no_rekening` (`no_rekening`);

--
-- Indexes for table `tahun_ajaran`
--
ALTER TABLE `tahun_ajaran`
  ADD PRIMARY KEY (`kode_tahun_ajaran`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`kode_transaksi`),
  ADD KEY `id_admin` (`id_admin`),
  ADD KEY `kode_tahun_ajaran` (`kode_tahun_ajaran`),
  ADD KEY `kode_pembayaran` (`kode_pembayaran`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `detail_pembayaran`
--
ALTER TABLE `detail_pembayaran`
  MODIFY `id_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=814;
--
-- AUTO_INCREMENT for table `detail_pengeluaran`
--
ALTER TABLE `detail_pengeluaran`
  MODIFY `kode_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `pengeluaran`
--
ALTER TABLE `pengeluaran`
  MODIFY `kode_pengeluaran` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `semester`
--
ALTER TABLE `semester`
  MODIFY `kode_semester` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `tabungan`
--
ALTER TABLE `tabungan`
  MODIFY `id_tabungan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;
--
-- AUTO_INCREMENT for table `tahun_ajaran`
--
ALTER TABLE `tahun_ajaran`
  MODIFY `kode_tahun_ajaran` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `kode_transaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=886;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_pembayaran`
--
ALTER TABLE `detail_pembayaran`
  ADD CONSTRAINT `detail_pembayaran_ibfk_2` FOREIGN KEY (`nis`) REFERENCES `siswa` (`nis`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detail_pembayaran_ibfk_3` FOREIGN KEY (`kode_transaksi`) REFERENCES `transaksi` (`kode_transaksi`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `detail_pengeluaran`
--
ALTER TABLE `detail_pengeluaran`
  ADD CONSTRAINT `detail_pengeluaran_ibfk_1` FOREIGN KEY (`kode_pengeluaran`) REFERENCES `pengeluaran` (`kode_pengeluaran`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detail_pengeluaran_ibfk_2` FOREIGN KEY (`kode_transaksi`) REFERENCES `transaksi` (`kode_transaksi`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `siswa`
--
ALTER TABLE `siswa`
  ADD CONSTRAINT `siswa_ibfk_1` FOREIGN KEY (`kode_kelas`) REFERENCES `kelas` (`kode_kelas`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_admin`) REFERENCES `admin` (`id_admin`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `transaksi_ibfk_2` FOREIGN KEY (`kode_tahun_ajaran`) REFERENCES `tahun_ajaran` (`kode_tahun_ajaran`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
