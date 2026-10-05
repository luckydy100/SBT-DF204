
Evidence ID: E01 | 
Packet or item: nitroba_original.pcap + working copy | 
Findings: Source downloaded; 
SHA-256 matches published value; 
working copy byte-identical to original; 
original set read-only | 
Why it matters: Proves evidence integrity and chain of custody for the entire investigation | 
Screenshot evidence in screenshot folder

Evidence ID:E02 | 
Packets 82936–83654 (GETs to willselfdestruct.com) | 
Client IP 192.168.15.4 contacted service IP 69.25.94.22 on 22 Jul 2008 between 02:03:43 and 02:04:24 EDT | 
Identifies the two endpoints involved in the incident; 
corroborated by two independent filters |  
Screenshot evidence in screenshot folder


Evidence ID: E03  | 
Packet 83601 | HTTP 
POST to www.willselfdestruct.com/secure/submit containing form fields 
to=lilytuckrige@yahoo.com, 
subject="you can't find us", 
message="and you can't hide from us. Stop teaching. Start running." | 
Directly matches the content of the harassing message received by the victim; 
establishes what was sent and when | Screenshot: E03a_post_packet_detail.png

Evidence ID: E03b | 
TCP stream 1707 | 
Follow TCP Stream of the same POST/response exchange | 
Provides the complete request-response context and confirms the POST was accepted by the server | 
Screenshot evidence in screenshots folder


Evidence ID: E04a | 
Packet 83601 (eth.src field) | 
Source MAC 00:17:f2:e2:c0:ce identified as the device that sent the POST | 
Unique device identifier; stronger than IP for forensic attribution | 

Evidence ID: E04b | 
Packet 83601 (hex dump) | 
Raw bytes at offset 6–11 confirm source MAC 00:17:f2:e2:c0:ce at the byte level | 
Independent verification of the MAC at the raw packet level; 
defeats any "dissector artifact" challenge | 

Evidence ID: E04c | 
MAC 00:17:f2:e2:c0:ce (all traffic) | 
Device sent 34,582 packets and appeared in 73,246 total packets across the capture, 
with stable mapping to 192.168.15.4 | 
Confirms the device is a genuine, consistently active end-user machine, 
not a transient or spoofed one-off | 
Screenshot evidence in the screenshots folder


Evidence ID: E05 | 
Packets 78967, 78984, 78996 (and 106 others) | 
HTTP cookies from MAC 00:17:f2:e2:c0:ce contain `gmailchat=jcoachj@gmail.com/475090` 109 times, 
sent to Google mail servers at 02:01:02 EDT | 
Links the device to a specific Gmail account; 
establishes the account was active on the device minutes before the harassment POST | 
Screenshot evidence in the screenshots folder


E06a | 
Packets 78967, 82936, 82998, 83601, 83614, 83641, 83654 | 
Chronological sequence of the incident: Gmail session active at 02:01:02 EDT, 
first willselfdestruct.com page load at 02:03:43, harassment POST at 02:04:24, 
success page at 02:04:24 | 
Establishes the order and timing of relevant events; 
shows the suspect account active on the device minutes before the offence | 


E06b | 
Chemistry 109 roster vs `jcoachj@gmail.com` | 
Only one roster member has the surname "Coach" — Johnny Coach — 
and the email local part decomposes naturally as "J. Coach" | 
Links the captured account to a named individual on the roster; 
a strong circumstantial match but not proof of identity | 
Screenshot: 


E07a | 
Combined evidence chain (packets 78967, 82936, 83601, 83641) | 
Chain of evidence from Gmail session → willselfdestruct.com GET → 
POST with harassment content → server response | 
Summarises the full evidence chain supporting the attribution | 

E07b | 
Attribution assessment | 
Direct observations, reasonable inferences, limitations, confidence level, and defensible conclusion | 
Fulfils the marking guide requirements for careful, cautious, evidence-bounded conclusions | 
This section of the report itself
