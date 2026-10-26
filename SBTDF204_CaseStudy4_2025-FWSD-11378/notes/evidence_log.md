E00 | Case materials: DFRWS2005-RODEO.zip
Source: Google Drive link from Rhion_Possession_1 slide 12 (https://drive.google.com/file/d/1kZrWI1_hyJEgpjiuNf_iAwdpJvQlEkKS/view?usp=sharing)
Note: The raw.githubusercontent.com URL from slides 3 and 13 returned HTTP 404 at acquisition time. The Google Drive link was used as the handout's designated source.

Archive size: 3,614,418 bytes (3.5 MB)
Archive uncompressed size (per unzip -v): 259,506,176 bytes (247 MB)
File type: Zip archive data, made by v2.3 UNIX

Extracted contents:
  - RHINOUSB.dd  | 259,506,176 bytes | MD5: 80348c58eec4c328ef1f7709adc56a54 | SHA-256: ce550424200a997c61b413941c8ef4df9619a2f96579674952294a176a32be65
  - rhino.log    |   3,187,907 bytes | MD5: c0d0093eb1664cd7b73f3a5225ae3f30 | SHA-256: 64e6d55b76660eb3aaa41572c1d04e4452510a343bbf42e844424827dedfddb2
  - rhino2.log   |     292,604 bytes | MD5: cd21eaf4acfb50f71ffff857d7968341 | SHA-256: 41939d5de0556b70279056572dee44b6fd84cd05b0788cfd0b6f52f37b161dde
  - rhino3.log   |     226,094 bytes | MD5: 7e29f9d67346df25faaf18efcd95fc30 | SHA-256: 7b0304f5e88a30c305a99b5a1e2977bced5b9c94da6f458f887bb39966bbfc46

MD5 verification: All four MD5 values match the published reference values from the course handout (Rhion_Possession_1 slide 14). This authenticates the evidence as the intended course material.

Working copies created: rhino_working.log, rhino2_working.log, rhino3_working.log, RHINOUSB_working.dd
Working copy verification: SHA-256 of each working copy matches the SHA-256 of its original.

Original file permissions: read-only (444 / -r--r--r--)

Tools verified:
  - PhotoRec 7.2 (February 2024)
  - The Sleuth Kit 4.14.0 (mmls, fls, fsstat, icat)
  - exiftool 13.55
  - steghide 0.6.0
  - StegSeek 0.6
  - binwalk 2.4.3
  - fcrackzip 1.0
  - unzip 6.00

Finding: All four case materials acquired, verified against published MD5 hashes, SHA-256 recorded, byte-identical working copies created, originals set read-only.

Why it matters: This establishes the integrity foundation for all subsequent analysis. Every finding in later phases can be traced back to one of these four files with its documented hash.

Screenshots: working.dir.png, tools.ver.png, evidence_download.png, evidence_unzip.png, evidence_hash.png, 256_hashes.png, working_copy.png


E01 | USB disk image structure analysis (RHINOUSB_working.dd)
Source file: RHINOUSB.dd | 259,506,176 bytes | SHA-256: ce550424200a997c61b413941c8ef4df9619a2f96579674952294a176a32be65

Partition layout (fdisk -l):
  Disk RHINOUSB_working.dd: 247.48 MiB, 259,506,176 bytes, 506,848 sectors
  Disklabel type: dos; Disk identifier: 0x00000000
  NO PARTITIONS listed — image is a raw FAT16 filesystem, not a partitioned disk

Partition layout (mmls):
  Empty output (confirms no partition table entries) — offset 0 is correct for all Sleuth Kit tools

Filesystem metadata (fsstat -o 0):
  File System Type: FAT16
  OEM Name: mkdosfs
  Volume ID: 0x4092d9d1
  Sector Size: 512 bytes
  Cluster Size: 4,096 bytes
  Total Cluster Range: 2 – 63,290
  Root Directory: sectors 497–528
  Cluster Area: sectors 529–506,840
  FATs: FAT0 at sectors 1–248, FAT1 at sectors 249–496

Root directory listing (fls -o 0):
  r/r 4: gumbo1.txt      (allocated regular file)
  r/r 6: gumbo2.txt      (allocated regular file)
  v/v 8101619: $MBR      (virtual system entry)
  v/v 8101620: $FAT1     (virtual system entry)
  v/v 8101621: $FAT2     (virtual system entry)
  V/V 8101622: $OrphanFiles  (virtual directory)

Recursive listing (fls -r -p -o 0): Same as above — no subdirectories.

Deleted file listing (fls -d -o 0): EMPTY — no deleted directory entries
  Interpretation: The user deleted files whose directory entries have been reused or overwritten. Data remains in unallocated space.

Extraction validation (icat -o 0):
  icat RHINOUSB_working.dd 4 > gumbo1_test.txt — 2.8 KB extracted, readable text ("SHRIMP AND TASSO GUMBO")
    SHA-256: ecb06cec73218f66d19cccfd1e45ab7144b02eb5344d9ede14e1c8428d76713c
  icat RHINOUSB_working.dd 6 > gumbo2_test.txt — 1.3 KB extracted, readable text ("SHRIMP AND ANDOUILLE SAUSAGE GUMBO")
    SHA-256: 84cc7105cc6d663d230574d32256dd42bf96d7f077456e357ec9daacd59f87aa

Unallocated space (blkls -o 0 RHINOUSB_working.dd > unallocated.raw):
  Size: 248 MB (nearly the entire disk)
  Only ~4 KB is allocated (two text files) — the rest is unallocated space, where deleted files reside.

Raw JPEG magic-number scan (xxd + grep FFD8 FFE0):
  7 JPEG headers found at offsets:
    0x32cf200  0x32e7200  0x334d200  0x33b2200  0x33f3200  0x33f5200  0x0a39d200
  All 7 have JFIF marker immediately after FFD8 FFE0 — valid JPEG structure.
  Interpretation: At least 7 JPEG files were deleted from the USB. They reside in unallocated space and are candidates for recovery via photorec.

Finding: The USB image contains a FAT16 filesystem with two live text files (gumbo recipes) and at least 7 deleted JPEG files recoverable from unallocated space. The image has no partition table (raw filesystem at offset 0).

Why it matters: Establishes the forensic baseline before recovery. The 7 JPEG magic numbers prove that JPEG data physically exists in unallocated space (not just in directory entries). This is the foundation for Phase 2 (photorec recovery) and directly supports the case's possession claim — the suspect deleted at least 7 images.

E02 | PhotoRec 7.2 recovery
Tool version: PhotoRec 7.2 (February 2024)
Input: RHINOUSB_working.dd (SHA-256: ce550424200a997c61b413941c8ef4df9619a2f96579674952294a176a32be65)
Recovery scope: Whole partition (per deck guidance)
Output folder: recovered/recup_dir.1/

Total files recovered: 135 (124 txt, 7 jpg, 2 gif, 1 doc, 1 xml)

Recovered images — dimensions and hashes:

| # | Filename | Dimensions | SHA-256 (first 16) | Subject | Rhino? |
|---|---|---|---|---|---|
| 1 | f0104057.jpg | 528x792 | 2261020a0b31fe10... | Alligator in swamp | No |
| 2 | f0104249.jpg | 1349x900 | 8cdb89c6778d3409... | Crocodile in water | No |
| 3 | f0105065.jpg | 1686x1122 | 452075313c93ae31... | Alligator on rocks | No |
| 4 | f0105873.jpg | 1024x768 | f92654d9ee17ab6b... | Rhino in grassland | YES |
| 5 | f0106393.jpg | 169x228 | 568457ed594c4e98... | Rhino mother + baby | YES |
| 6 | f0106409.jpg | 1024x685 | b4f6bbb8d846d650... | Rhino sketch | YES |
| 7 | f0335081.jpg | 1024x768 | f92654d9ee17ab6b... | DUPLICATE of f0105873.jpg | (dup) |
| 8 | f0106865.gif | 290x246 | 8a67d406ed130c9b... | Alligator hatchling | No |
| 9 | f0106889.gif | 150x87 | 71e9f6b94e0496cc... | Blue cartoon rhino | YES |

UNIQUE RHINO COUNT FROM PHOTOREC: 4
  - f0105873.jpg (== f0335081.jpg, byte-identical duplicate)
  - f0106393.jpg
  - f0106409.jpg
  - f0106889.gif

Non-rhino images (decoys): 4 alligators/crocodiles

Cross-validation:
  - Phase 1 raw magic-number scan found 7 JPEG headers (FFD8 FFE0) in the raw image
  - PhotoRec recovered 7 JPG files — 1:1 match, confirms complete carving
  - GIFs carved: 2 files, both valid GIF89a

Duplicate detection:
  - f0105873.jpg and f0335081.jpg are byte-identical (same SHA-256: f92654d9ee17ab6b...)
  - Same dimensions (1024x768), same file size (264,600 bytes)
  - Interpretation: The same physical image was carved from two distinct locations in unallocated space. This confirms carving consistency and does not represent two separate rhino images.

Finding: PhotoRec recovered 9 image files, of which 4 are unique rhino images and 4 are non-rhino animals (alligators/crocodiles). One file is a duplicate of another (counting the same rhino twice).

Case significance: 4 rhinos from photorec falls short of the 9+ rhino threshold. Additional rhino images must be found via steganography (Phase 3-4).

Why it matters: Establishes the visible, recoverable rhino count as the baseline. Demonstrates that photorec alone does not meet the case threshold — corroborating the case hypothesis that the suspect hid rhino images using steganography.

Screenshots: recup1.png, recup1_hash.png, recup1_hash_gif.png, contact_sheet_labeled.jpg


E03 | Steganography analysis of recovered images (photorec output)
Tested: 7 JPGs from recovered/recup_dir.1/

Test 1 — Stegseek (steghide detection + cracking):
  Command: stegseek <file> (using /usr/share/wordlists/rockyou.txt, 134 MB)
  Result: All 7 JPGs returned "Could not find a valid passphrase" after testing the full wordlist.
  Interpretation: No JPG contains steghide-format steganographic content (or password is not in rockyou).

Test 2 — JPHS magic marker scan:
  Command: strings -a <file> | grep -i JPHS
  Result: Zero matches across all 7 JPGs.
  Interpretation: No ASCII JPHS marker present in the photorec output.

Test 3 — Binwalk signature scan (completed in Phase 2, E02 context):
  Result: All 7 JPGs contain only JPEG/JFIF data at offset 0; no appended or embedded signatures.
  Interpretation: No camouflage/appendx-style stego.

Test 4 — Stegdetect build attempt:
  Multiple attempts to build stegdetect 0.6 from poizan42 and redNixon forks failed at the bundled jpeg-6b configure step ("C compiler cannot create executables") with modern GCC 14 on Kali.
  Workarounds attempted: installing libjpeg-dev, libjpeg62-turbo-dev, autoconf/automake/libtool, patching progname conflict, removing jpeg-6b from SUBDIRS.
  Outcome: stegdetect/stegbreak/jpseek binaries were not produced.
  Interpretation: Documented limitation. Steganography analysis of the photorec output was performed via stegseek + JPHS marker + binwalk; jphide extraction requires jpseek (Windows binary under wine), which was not available.

FINDING: The photorec-recovered JPGs do NOT contain detectable steganographic content. This is consistent with the case narrative: the deleted USB images were the suspect's **visible** rhino collection; hidden rhinos (stego) are expected to be in the FTP/HTTP traffic, which will be processed in Phases 5–7.


E06 | HTTP traffic analysis (rhino2_working.log + rhino3_working.log)

rhino2.log SHA-256: 41939d5de0556b70279056572dee44b6fd84cd05b0788cfd0b6f52f37b161dde
rhino3.log SHA-256: 7b0304f5e88a30c305a99b5a1e2977bced5b9c94da6f458f887bb39966bbfc46

=== rhino2.log — Image downloads ===

HTTP GET requests of interest:
  Frame 49:  2004-04-28 17:08:38 UTC-0400  137.30.123.234 → 137.30.120.37  GET /~gnome/rhino4.jpg  (stream 1)
  Frame 217: 2004-04-28 17:08:44 UTC-0400  137.30.123.234 → 137.30.120.37  GET /~gnome/rhino5.gif  (stream 2)

Image responses:
  Frame 215: image/jpeg  153,191 bytes  (rhino4.jpg)
  Frame 312: image/gif    85,137 bytes  (rhino5.gif)

Extracted objects:
  rhino4.jpg  | 153,191 bytes | 1531x2286 JPEG | SHA-256: e1c01da391669adf3559d2d87bf2157b37e27a936a1ae66c77b61e6b5b7bc4a6 | NEW unique rhino
  rhino5.gif  |  85,137 bytes | 400x275 GIF89a | SHA-256: f36ecc12967d5622cdc70e73d2468fab28a65db944d3157256a7212afa05b056 | NEW unique rhino

Method: Follow TCP Stream via tshark `-z follow,tcp,raw,<stream>`, then Python to carve file from HTTP headers (FFD8...FFD9 for JPEG, GIF89a...0x3B for GIF). Note: stream 2 contained TWO GIF89a markers (a small icon at byte 553 + rhino5.gif at byte 1494) — used the LAST (rhino5.gif).

=== rhino3.log — EXE download ===

HTTP GET request of interest:
  Frame 110: 2004-04-28 17:16:23 UTC-0400  137.30.123.234 → 137.30.120.37  GET /~gnome/rhino.exe  (stream 3)

Extracted object:
  rhino.exe | 145,920 bytes | PE32 executable (console) Intel i386, 3 sections
  MD5:    d62d9989535c4c8db14e50b58c9f25a0
  SHA-256: 93e70049b60bf5691b43d9e256ca8f459f6bfac832097985bcc6a9040b5ca555

Interpretation: MD5 d62d9989... matches the published hash for Microsoft's Disk Partitioning Utility (diskpart.exe) per the course deck. This is a legitimate system tool, not malware. The download is not a rhino image.

FINDING: HTTP traffic from rhino2.log yielded 2 NEW unique rhinos (rhino4.jpg and rhino5.gif). HTTP traffic from rhino3.log yielded one legitimate system tool (diskpart.exe) — not a rhino.

Do NOT execute rhino.exe. Do NOT submit it to VirusTotal or any online service.

Screenshots: http_protocol.png, http_response.png, rhino4_extracted.png, rhino5_extracted.png, rhino_exe.png, rhino_exe_hash.png
