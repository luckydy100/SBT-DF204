rule DownloadsPath {
    strings:
        $d1 = "C:\\Users\\IEUser\\Downloads" ascii wide nocase
        $d2 = "Downloads" ascii wide nocase
    condition:
        any of them
}

rule UsbRoot {
    strings:
        $f1 = "F:\\" ascii wide
        $f2 = "F:\\secret_file.docx" ascii wide nocase
    condition:
        any of them
}

rule RecentDocs {
    strings:
        $r1 = "RecentDocs" ascii wide
        $r2 = "secret_file.docx" ascii wide nocase
    condition:
        all of them
}
