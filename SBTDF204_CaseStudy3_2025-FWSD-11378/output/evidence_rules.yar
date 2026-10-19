rule SuspiciousIP {
    strings:
        $ip = "192.168.56.5" ascii wide
    condition:
        $ip
}

rule SecretFile {
    strings:
        $doc = "secret_file.docx" ascii wide nocase
    condition:
        $doc
}
