rule HttpHeaders {
    strings:
        $get = "GET /" ascii
        $host_ip = "Host: 192.168.56.5" ascii
        $http = "HTTP/1.1 200 OK" ascii
    condition:
        any of them
}

rule DocxContent {
    strings:
        $pk = { 50 4B 03 04 }   // PK ZIP header (docx is a zip)
    condition:
        $pk
}

rule CopyCommand {
    strings:
        $copy1 = "copy secret_file.docx" ascii wide nocase
        $copy2 = "F:\\" ascii wide
    condition:
        any of them
}
