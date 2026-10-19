rule CopySuccessMessage {
    strings:
        $s1 = "1 file(s) copied" ascii nocase
        $s2 = "1 file(s) copied." ascii wide nocase
        $s3 = "copied." ascii wide nocase
        $s4 = "copied" ascii wide nocase
    condition:
        any of them
}

rule WorkingDirectory {
    strings:
        $cd = "cd Downloads" ascii wide nocase
        $cdup = "cd .." ascii wide
    condition:
        any of them
}

rule IpConfigOutput {
    strings:
        $hw = "Windows IP Configuration" ascii wide
        $ad = "IPv4 Address" ascii wide
    condition:
        any of them
}
