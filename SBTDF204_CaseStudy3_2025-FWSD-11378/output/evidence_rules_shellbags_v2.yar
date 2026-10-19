rule BagMRU_Key_Names {
    strings:
        $bagmru = "BagMRU" ascii wide nocase
        $bags = "Bags" ascii wide nocase
    condition:
        any of them
}

rule UserShellBagPath {
    strings:
        $u1 = "Local Settings\\Software\\Microsoft\\Windows\\Shell" ascii wide nocase
        $u2 = "Software\\Microsoft\\Windows\\Shell\\BagMRU" ascii wide nocase
    condition:
        any of them
}

rule ShellItemNames {
    strings:
        $downloads = "Downloads" ascii wide
        $f_drive = "F:\\" ascii wide
        $secret = "secret_file.docx" ascii wide
    condition:
        any of them
}
