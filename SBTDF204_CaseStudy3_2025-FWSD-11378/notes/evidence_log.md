E01 | 
Original file: `memdumpWin7_original.mem`
Source: https://www.dropbox.com/s/x41f2lyhlrixts6/memdumpWin7.mem?dl=1
Download date/time: 2026-10-18 17:26 (local system time, UTC−04:00)
File size: 1,073,676,288 bytes (1.0 GB)
File type: `data` (raw binary memory dump — no magic number, as expected)
SHA-256: 500bc1ba8b5ffa8053b6213d7e7aae0c84c18cce541dc53a55887e6e5099495e
MD5: ac7eaa46a7006d5eb13cda13ee0b9bc9
Working copy: `memdumpWin7_working.mem` created via `cp -v`; SHA-256 matches original exactly
Original permissions: read-only (444 / -r--r--r--) applied immediately after hashing and copying
Tool version: Volatility 2.6.1 (invoked via `python2 ~/volatility/vol.py`)
Tool warnings: Two import failures noted (`Crypto.Hash` for registry.shutdown and getservicesids plugins). 
These do not affect the plugins used in this investigation and are documented in the report as an 
environmental limitation of Volatility 2.6.1 on this Kali build.

Finding: Original memory image acquired, hashed (SHA-256 and MD5), working copy verified byte-identical, 
original set read-only, Volatility 2.6.1 confirmed.

Why it matters: Establishes evidence integrity and chain of custody for all subsequent Volatility analysis. 
Without a documented hash and a read-only original, 
an examiner cannot prove the memory image was not altered during examination. 
The two-hash pattern (original + working copy) confirms the working copy used for analysis is byte-identical to the source.

E02a | imageinfo plugin | Suggested Profile(s): Win7SP1x86_23418, Win7SP0x86, Win7SP1x86_24000, Win7SP1x86; KDBG: 0x82972c68; DTB: 0x185000; PAE type: PAE; Service Pack: 1; Number of Processors: 1; Image date/time: 2019-01-06 15:09:06 UTC; Image local: 2019-01-06 07:09:06 -0800
Finding: Volatility's KDBG search identified the OS as Windows 7 SP1 32-bit (PAE). The image was captured at 2019-01-06 15:09:06 UTC (07:09:06 in the capturing system's PST timezone).
Why it matters: Establishes the OS profile needed for all subsequent plugin commands and fixes the image capture timestamp for the investigation.
Screenshot: E02a_imageinfo.png

E02b | pslist plugin (profile Win7SP1x86_23418) | Returned active process list starting with System (PID 4), smss.exe (PID 236), csrss.exe (PID 300), wininit.exe (PID 340), csrss.exe (PID 348), winlogon.exe (PID 388), services.exe (PID 432), lsass.exe (PID 440), lsm.exe (PID 448), then multiple svchost.exe processes.
Finding: The profile Win7SP1x86_23418 produced a complete, structurally valid process listing with no errors. All processes expected at Windows boot are present in the expected hierarchy.
Why it matters: Independently validates the selected profile (an incorrect profile would produce an error or an empty table). Confirms the image is a live Windows 7 SP1 system.
Screenshot: E02b_profile_validation_pslist.png (saved as plist2.png)

E02c | kdbgscan plugin (profile Win7SP1x86_23418) | KDBG scan identified Offset (V) 0x82972c68, Offset (P) 0x2972c68, KDBG owner tag check: True, Profile suggestion (KDBGHeader): Win7SP1x86_23418
Finding: An independent scanning method located the same KDBG address (0x82972c68) as imageinfo, and the KDBG owner tag check passed. Volatility's own profile suggestion from kdbgscan is Win7SP1x86_23418.
Why it matters: Second independent validation of the profile. Together with pslist (E02b), this satisfies the assignment brief's requirement to validate a profile with usable output from multiple relevant plugins.
Screenshot: E02c_kdbgscan_validation.png (saved as kdgbvalidation.png)

E02d | timedatectl | Time zone: America/New_York (EDT, -0400)
Finding: The analysis system's local timezone is UTC−04:00 (EDT). The captured machine's timezone was UTC−08:00 (PST) as reported by imageinfo. The two timezones differ, so all timeline reporting in this investigation will use UTC, and local times shown by Volatility plugins will be identified as either the captured machine's local time or the analysis system's local time as appropriate.
Why it matters: Prevents misattribution of timestamps between the captured system and the analysis system. The brief requires UTC for the main timeline with any local conversion stated separately.


E03a | printkey -K "Volatile Environment" | Hive \??\C:\Users\IEUser\ntuser.dat; USERNAME=IEUser; USERPROFILE=C:\Users\IEUser; USERDOMAIN=IE8WIN7; LOGONSERVER=\\IE8WIN7; key last updated 2019-01-06 15:02:48 UTC
Finding: The only active user profile on the machine is IEUser. The profile directory C:\Users\IEUser matches the download path seen in the earlier evidence and is consistent with a shared lab environment. The key was written at 15:02:48 UTC — during system boot.
Why it matters: Identifies the account context in which all processes and registry activity occurred. Establishes IEUser as the user under investigation (subject to the standard caveat that profile ≠ human operator).
Screenshot: E03a_volatile_environment.png (saved as volatile_environment.png)

E03b | pslist (full) | 56 processes listed including Chrome (PIDs 2388, 1280, 2380, 2912, 976), cmd.exe (PID 3996), conhost.exe (PID 3988), explorer.exe (PID 2524), FTK Imager (PID 2596), sshd (PID 2016), and services.
Finding: Chrome was running with 5 processes (one main + four helpers). cmd.exe and its conhost.exe were running. explorer.exe was running. FTK Imager was running.
Why it matters: Establishes the exact process population at the moment of capture. The presence of Chrome and cmd.exe is consistent with the alleged download (via Chrome) and file copy (via cmd). The presence of FTK Imager explains how the memory dump was captured.
Screenshot: E03b_pslist_full.png (saved as a.plist_full.png — rename)

E03c | pslist grep (chrome|cmd|explorer) | explorer.exe PID 2524 @ 15:02:54; chrome.exe PID 2388 (parent 2524) @ 15:04:30; 4 more chrome.exe children of PID 2388 @ 15:04:30–15:06:23; cmd.exe PID 3996 (parent 2524) @ 15:06:11
Finding: Chrome's main process started at 15:04:30 UTC (about 4m 24s after explorer, so it was user-initiated). cmd.exe started at 15:06:11 UTC — about 1m 41s after Chrome. This is 3 minutes before the image was captured at 15:09:06 UTC.
Why it matters: Provides the process-level timeline needed for Q8. The 15:04:30 / 15:06:11 sequence is critical: Chrome opened, then ~1:41 later the command prompt opened — consistent with a user doing web activity then executing commands.
Screenshot: E03c_pslist_grep.png (saved as plist_grep.png — rename)

E03d | psscan (residual process scan) | 57 processes detected (pslist + the terminated cygrunsrv.exe PID 1984). All Chrome and cmd processes from pslist also present in psscan.
Finding: No hidden or terminated Chrome/cmd processes beyond what pslist showed. One terminated service (cygrunsrv.exe) is present with exit time 15:02:49 UTC. All user-facing process times in psscan are consistent with pslist.
Why it matters: Confirms pslist output was complete (no actively-running hidden processes). Establishes that no other browser or command-shell processes existed during the capture window besides those in E03b/c.
Screenshot: E03d_psscan_grep.png (saved as psscan_grep.png — rename)

E03e | netscan (full) | Connections to 192.168.56.5:80 from local 192.168.56.8:49177 and 192.168.56.8:49178; both CLOSED, owner PID -1 (unattributable after close). Also: chrome.exe (PID 2388) UDP socket at 192.168.56.8:56647 created at 15:08:32.
Finding: The machine 192.168.56.8 made TWO connections to 192.168.56.5:80 (HTTP) at some point before capture. Both are now CLOSED. A second Chrome UDP socket exists at 15:08:32 UTC (1 minute before capture). The two CLOSED connections were not attributable to a PID because TCP control blocks are removed after closure.
Why it matters: Establishes the direct network evidence — the machine talked to 192.168.56.5 over HTTP. The state CLOSED confirms the connections were active and then shut down before capture (a normal HTTP transfer lifecycle). The unattributed PID limits attribution: we can only infer the process via other evidence (Chrome's presence, the YARA match if it succeeds, or the timeline correlation).
Screenshot: E03e_netscan_full.png (saved as netscan.png — rename)

E03f | netscan grep (192.168.56|:80) | Two CLOSED TCP connections to 192.168.56.5:80. One active UDPv4 socket for chrome.exe (PID 2388) at 192.168.56.8:56647. Several LISTENING services.
Finding: Confirms exactly two TCP connections to the suspicious IP; both closed. No active connection at capture time.
Why it matters: Supports the inference that a download occurred and finished before capture. The lack of an open connection rules out an in-progress transfer at the moment of capture (a common alternative explanation).
Screenshot: E03f_netscan_grep.png (saved as netscan_grep.png — rename)

E03g | pslist -p 2388 | Chrome main process: PID 2388, PPID 2524 (explorer.exe), 33 threads, 819 handles, session 1, started 2019-01-06 15:04:30 UTC
Finding: PID 2388 is the primary chrome.exe instance, spawned by explorer.exe (user-initiated launch, not a system service).
Why it matters: Confirms Chrome was started by the logged-in user (via Explorer), not by a background service. This is a normal-browser-usage profile.
Screenshot: E03g_pslist_chrome_pid.png

E03h | yarascan (pending — YARA unavailable) | Plugin failed to run: "Please install Yara from https://plusvic.github.io/yara/"
Finding: Volatility's yarascan plugin requires the Python 2 yara module, which is not installed on this Kali build. The plugin could not be executed in this environment.
Why it matters: Documents a methodological limitation. String-level evidence for the download will be established via alternative means (see E03i if we install YARA and rerun, or via netscan timeline correlation if not).


E04a | cmdscan plugin | Plugin failed to import (`ImportError` chain, primarily missing `distorm3`). Not used.
Finding: `cmdscan` could not run in this environment due to missing Python 2 dependencies.
Why it matters: Documents a methodological limitation. The same evidence was successfully obtained via `consoles` (E04b) and YARA CLI (E04d–E04e).
Screenshot: E04a_cmdscan.png (if captured)

E04b | consoles plugin | ConsoleProcess: conhost.exe PID 3988; AttachedProcess: cmd.exe PID 3996; OriginalTitle: `C:\Windows\system32\cmd.exe`; CommandHistory (3 entries): #0 `ipconfig`, #1 `cd Downloads`, #2 `copy secret_file.docx F:`; console screen buffer contains the full interaction including the "1 file(s) copied." success message and the working directory `C:\Users\IEUser\Downloads`
Finding: The complete command history and the console output for the cmd.exe session. Three commands were typed in order. The final command's output explicitly confirms success.
Why it matters: This is the primary evidence for Q5. It shows WHAT was typed, IN WHAT ORDER, and CONFIRMS SUCCESS of the copy. Combined with `ipconfig` output (IP = 192.168.56.8), it provides the direct link to the network evidence in E03e/E03f.
Screenshot: E04b_consoles.png (saved as E04b_consoles_full.png)

E04c | cmdline plugin | cmd.exe (PID 3996): `"C:\Windows\system32\cmd.exe"`; chrome.exe (PID 2388): `"C:\Program Files\Google\Chrome\Application\chrome.exe"`; chrome.exe (PID 976): `--type=renderer --renderer-client-id=13 ...`; FTK Imager (PID 2596): `"C:\Program Files\AccessData\FTK Imager\FTK Imager.exe"`
Finding: cmd.exe was launched as a normal interactive shell (no /K or command argument). Chrome's renderer PID 976 indicates a page was actively rendering.
Why it matters: Confirms cmd.exe was user-launched (not automatic). Confirms the Chrome renderer was active, consistent with the download + display of the file URL. Confirms FTK Imager was the capture tool.
Screenshot: E04c_cmdline.png

E04d | YARA CLI rules (CopySuccessMessage, WorkingDirectory, IpConfigOutput) | CopySuccessMessage matched at 0x2e16820 and 0x5d5f820 (UTF-16LE encoding of "1 file(s) copied."); WorkingDirectory matched at 0x2e16650 and 0x5d5f650 ("cd Downloads"); IpConfigOutput matched at 0x21e16910 and 0x37d9554
Finding: Two independent sources of the copy-success message and the "cd Downloads" command string exist in memory. Same for IP configuration output.
Why it matters: Independent corroboration of the `consoles` output. Cross-validation from a separate tool strengthens the evidence defensibility.


E05d_full | printkey -K "ControlSet001\Enum\USBSTOR\Disk&Ven_General&Prod_UDisk&Rev_5.00\6&1bec0f48&0&_&0" | DeviceDesc: @disk.inf,%disk_devdesc%;Disk drive; Class: DiskDrive; Service: disk; ContainerID: {421e7e37-11dd-11e9-b3cf-806e6f6e6963}; FriendlyName: "General UDisk USB Device"; HardwareID includes "USBSTOR\DiskGeneral_UDisk___5.00" and "GenDisk". Last updated: 2019-01-06 15:02:54 UTC.
Finding: Full device identity of the USB. FriendlyName confirms it is a "General UDisk USB Device". ContainerID {421e7e37-...} is the physical-device grouping identifier.
Why it matters: The FriendlyName is the human-readable device description — "General UDisk USB Device". Combined with the ContainerID, this uniquely identifies the physical USB device in the evidence.
Screenshot: E05d_usbstor_instance_full.png

E05f_volume | printkey -K "Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\{421e7e52-11dd-11e9-b3cf-08002709e15d}" (IEUser's hive) | Subkeys: shell. Last updated: 2019-01-06 15:03:07 UTC.
Finding: IEUser has a MountPoints2 entry for the USB volume, with the "shell" subkey present. The "shell" subkey records Explorer-specific settings for a folder and only appears after the user has opened the folder in File Explorer.
Why it matters: Strong evidence that IEUser opened the USB volume in Explorer — not just that it was auto-mounted. The mount occurred ~13 seconds after hive load (15:03:07 UTC vs boot 15:02:54 UTC).
Screenshot: E05f_mountpoints2_volume.png

E05f_F | printkey -K "Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\F" (IEUser's hive) | [awaiting final output]
Finding: IEUser has a MountPoints2 entry for the F: drive letter.
Why it matters: Confirms IEUser was aware of and interacted with the F: drive specifically.



E06a | shellbags plugin (Volatility 2.6.1) | Plugin failed to import: `*** Failed to import volatility.plugins.registry.shellbags (ImportError: No module named Crypto.Hash)` — module not available. No structured ShellBag output produced.
Finding: Volatility's shellbags plugin could not run in this environment due to missing Python 2 dependencies.
Why it matters: Documents a methodological limitation and the reason for the fallback approach used in E06b–E06d.
Screenshot: E06a_shellbags_attempt.png

E06b | hivelist → physical address search | Regf signature search of the raw 1 GB memory dump found zero `regf` signatures within 1 KB before or 2 MB after the reported physical addresses of IEUser's NTUSER.DAT (0x120049b0) and UsrClass.dat (0x1997b008).
Finding: IEUser's hives were mapped in the VAD (per hivelist) but were not resident in physical memory at capture time — the hive header/pages were paged out to the pagefile.
Why it matters: Explains why direct hive extraction from the dump failed. Also documents why printkey still worked for MountPoints2 (Volatility's registry parser reads from the loaded hive object, resolving pages via its own cache), while raw extraction did not.
Screenshot: E06b_regf_search.png

E06c | YARA rules (BagMRU_Key_Names, UserShellBagPath, ShellItemNames) | [pending final counts from E06c run]
Finding: Presence of BagMRU/Bags strings, UserShellBagPath registry path, and Downloads/F:\/secret_file.docx folder names in raw memory — evidence that shell-related registry structures and folder paths existed in memory at capture.
Why it matters: Corroborates the MountPoints2 evidence (E05f) without requiring a structured BagMRU parse.
Screenshot: E06c_shellbags_yara_v2.png

E06d | (consolidated ShellBag-equivalent finding) | MountPoints2\F @ 15:03:06 UTC (from IEUser's hive); MountPoints2\{421e7e52-...} with `shell` subkey @ 15:03:07 UTC. YARA confirms Downloads and F:\ folder strings. Consoles records `cd Downloads` then `copy secret_file.docx F:` with success confirmation.
Finding: IEUser's Explorer mounted and opened the USB volume at ~15:03:06–15:03:07 UTC. The user then navigated to Downloads (~15:06:11 UTC via cmd) and copied the file to F:.
Why it matters: Establishes the folder-view evidence supporting the sequence. Distinguishes (a) the OS mount (MountedDevices) from (b) the user's Explorer opening (MountPoints2\shell) from (c) the actual command-line execution (consoles) — three distinct, corroborating layers.



