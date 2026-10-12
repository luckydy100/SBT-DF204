E01 | 
Original file: `History` (Chrome browser history SQLite database)
Source: https://raw.githubusercontent.com/frankwxu/digital-forensics-lab/main/Digital_Currency/LabFiles/History
Download date/time: 2026-10-12 05:19:27–05:19:28
File size: 196,608 bytes (192 KB)
File type: SQLite 3.x database, last written using SQLite version 3036000, 41 database pages, schema 4, UTF-8
SHA-256: b991b0fa69662c44caf599e468c8088576ebd9cebbf46d02c89cf51bcde3fd19
SHA-1:   e14ad4c53c44cafd286c78bd4073e1fd02d1af00
MD5:     0c594e9de87348c089554953a67e2c74
Working copy: `History_working` created via `cp History ../working/History_working`; SHA-256 matches original exactly
Original permissions: read-only (444 / -r--r--r--) applied immediately after hashing
Finding: Original evidence file acquired and preserved; byte-identical working copy created.
Why it matters: Establishes evidence integrity and chain of custody for all subsequent SQL analysis. 
Without a documented hash and a read-only original, an examiner cannot prove the database was not altered during examination. 
SQLite databases are live, writable files that can be modified by client software, 
which makes this preservation step essential.


E02a | Database schema: 17 tables listed via `SELECT name FROM sqlite_master WHERE type='table'`
Tables: clusters, clusters_and_visits, content_annotations, context_annotations, 
downloads, downloads_reroute_info, downloads_slices, downloads_url_chains, 
keyword_search_terms, meta, segment_usage, segments, sqlite_sequence, 
typed_url_sync_metadata, urls, visit_source, visits
Finding: The working database contains 17 tables. 
Four are relevant to this investigation: urls (57 rows), visits (74 rows), 
downloads (1 row), downloads_url_chains (1 row). keyword_search_terms (4 rows) 
provides supplementary user-input evidence.
Why it matters: Establishes the complete schema of the evidence file and 
identifies which tables carry the artefacts needed to answer the investigation questions.

E02b | `PRAGMA table_info(urls)` output
Columns (id, name, type, notnull, dflt_value, pk): 
id/INTEGER/PK, url/LONGVARCHAR, title/LONGVARCHAR, visit_count/INTEGER, 
typed_count/INTEGER, last_visit_time/INTEGER, hidden/INTEGER
Finding: The urls table stores one row per distinct URL, with id as primary key 
and last_visit_time as a WebKit (microsecond) timestamp.
Why it matters: urls.id is the foreign key referenced by visits.url — 
the JOIN dependency for building the visit timeline.

E02c | `PRAGMA table_info(visits)` output
Columns: id/INTEGER/PK, url/INTEGER, visit_time/INTEGER, from_visit/INTEGER, 
transition/INTEGER, segment_id/INTEGER, visit_duration/INTEGER, 
incremented_omnibox_typed_score/BOOLEAN, opener_visit/INTEGER
Finding: The visits table records one row per visit event, 
with visit_time in WebKit format, from_visit linking to a prior visit id, 
and transition encoding the navigation type.
Why it matters: visits is the core table for reconstructing the chronology 
and navigation sequence (Q3 and Q4).

E02d | `PRAGMA table_info(downloads)` output
Columns include: id, guid, current_path, target_path, start_time, received_bytes, 
total_bytes, state, danger_type, mime_type, referrer, tab_url, site_url, http_method, 
etag, last_modified
Finding: One download record exists (id=1), named proof_of_payment.png, with target path 
C:\Users\FSCS_User\Desktop\proof_of_payment.png, size 33844 bytes, MIME image/png.
Why it matters: A downloaded image labelled "proof_of_payment" is directly relevant to 
the alleged payment phase of the scenario (Q6).

E02e | Row counts across the five core tables
urls=57, visits=74, downloads=1, downloads_url_chains=1, keyword_search_terms=4
Finding: The dataset is small and entirely human-navigable. Four keyword searches appear: 
craigslist, gmail, blockchain explorer, kraken — each corresponding to a distinct stage 
of the alleged activity.
Why it matters: Confirms the corpus is complete enough for full review and that the 
search terms independently corroborate the case hypothesis.

E02f | First 20 rows of the urls table (ordered by id)
Findings (selected):
  id=1  URL: https://www.google.com/search?q=craigslist...  Title: craigslist - Google Search
  id=5  URL: https://accounts.craigslist.org/login/home     Title: craigslist account
  id=7–15 Craigslist posting workflow URLs (?s=type, ?s=cat, ?s=edit, ?s=geoverify, 
  ?s=editimage, ?s=preview)
  id=15 URL: https://post.craigslist.org/manage/7473121658  Title: baltimore | manage posting
  id=16 URL: https://baltimore.craigslist.org/hab/d/baltimore-cheaper-than-rx-supplements/747...  
   Title: cheaper than Rx supplements - health and beauty - by owner
  id=19–20 Title: Inbox (12) - unsub.fscs@gmail.com - Gmail
Why it matters: Provides the primary URL inventory and the identity of both the 
suspect posting ("cheaper than Rx supplements") and the suspect email account 
(unsub.fscs@gmail.com).

E02g | First 15 rows of the visits table (raw WebKit timestamps)
Findings: visit ids 1–15 span multiple transitions including 805306373, 805306368, 
268435456, -1610612736, -2147483648, 805306375. First visit (id=1) has 
from_visit=0 (chain start). Subsequent visits chain via from_visit to prior visit ids.
Why it matters: These are the raw records on which the timeline (Q3) and transition 
decoding (Q4) are built.

E02h | Single row in the downloads table
id=1, current_path=C:\Users\FSCS_User\Desktop\proof_of_payment.png, 
target_path=C:\Users\FSCS_User\Desktop\proof_of_payment.png, 
start_time=13294853818494344 (WebKit), received_bytes=33844, 
total_bytes=33844, mime_type=image/png
Finding: The download completed fully (received=total=33844 bytes) 
and is an image named "proof_of_payment.png" saved to the Windows Desktop of user FSCS_User.
Why it matters: Provides a concrete artefact linking the browsing session to 
a retained file that itself references "proof of payment" — 
directly relevant to the alleged transaction phase.

E02i | 
keyword_search_terms table (4 rows)
Findings:
  url_id=1  term=craigslist
  url_id=17 term=gmail
  url_id=40 term=blockchain explorer
  url_id=45 term=kraken
Why it matters: Search terms are direct user input captured by Chrome. 
Their sequence maps onto the four stages of the alleged activity 
(post ad → communicate → verify payment → exchange funds), 
corroborating the case hypothesis independently of the URL titles.

E03a | 
Query: SELECT v.id AS visit_id, u.id AS url_id, u.url, u.title,
datetime(v.visit_time/1000000 + strftime('%s','1601-01-01'), 'unixepoch') AS visit_utc,
v.from_visit, v.transition, v.visit_duration/1000.0 AS duration_ms
FROM visits AS v JOIN urls AS u ON v.url = u.id ORDER BY v.visit_time;
Finding: The complete browser history consists of 74 visit events spanning 2022-04-19 
13:54:18 UTC to 15:02:56 UTC (a duration of 4,118 seconds, approximately 68.6 minutes). 
All activity occurred on a single calendar date.
Why it matters: Establishes the total scope of the browsing session and the chronological 
backbone for all subsequent findings. The single-date, ~69-minute span is consistent 
with a single continuous session by one user (subject to the attribution caveats in Q8).
Output file: notes/timeline_utc.txt (74 rows)

E03b | 
Query comparing UTC and local-time conversion of the same WebKit values:
datetime(v.visit_time/1000000 + strftime('%s','1601-01-01'), 'unixepoch') AS visit_utc,
datetime(v.visit_time/1000000 + strftime('%s','1601-01-01'), 'unixepoch', 
'localtime') AS visit_local
FROM visits ORDER BY v.visit_time LIMIT 5;
Finding: For visit_id=1, visit_utc=2022-04-19 13:54:18 and visit_local=2022-04-19 09:54:18. 
The 4-hour offset confirms the analysis system's local timezone is UTC−04:00 (EDT). 
The same 4-hour offset holds across all sampled rows.
Why it matters: Demonstrates the WebKit → UTC conversion was applied correctly and 
documents the local-time offset for reproducibility. The brief requires UTC for the main 
timeline, with local-time conversion stated separately.

E03c | 
Query: SELECT datetime(MIN(v.visit_time)/1000000 + strftime('%s','1601-01-01'), 'unixepoch') 
AS first_visit_utc,
datetime(MAX(v.visit_time)/1000000 + strftime('%s','1601-01-01'), 
'unixepoch') AS last_visit_utc,
COUNT(*) AS total_visits, (MAX(v.visit_time) - MIN(v.visit_time))/1000000 
AS span_seconds FROM visits v;
Finding: first_visit_utc=2022-04-19 13:54:18, last_visit_utc=2022-04-19 15:02:56, 
total_visits=74, span_seconds=4118.
Why it matters: Provides the exact boundary timestamps and the arithmetic for the 
session's duration. All activity occurred within a single ~69-minute window on 2022-04-19 UTC.

E03d | 
Full timeline CSV export:
SELECT v.id, u.id, u.url, u.title, datetime(...), v.from_visit, v.transition, 
v.visit_duration
FROM visits v JOIN urls u ON v.url = u.id ORDER BY v.visit_time;
(Export: notes/timeline.csv, 75 lines = 1 header + 74 rows)
Finding: The complete chronological record has been preserved as CSV for reuse in 
the timeline appendix.
Why it matters: Ensures the reconstructed timeline is reproducible and can 
be independently verified by another examiner. The full URL and title are preserved here 
(unlike the truncated preview).
File: notes/timeline.csv


E04a | 
Query: SELECT transition, COUNT(*) AS occurrences FROM visits GROUP BY transition 
ORDER BY occurrences DESC;
Findings: Nine distinct transition values appear in the dataset:
  805306368 (×21), -2147483648 (×13), 268435456 (×12), -1610612736 (×9),
  805306375 (×7), 1073741824 (×5), 1610612736 (×3), 838860805 (×3), 805306373 (×1)
Why it matters: Establishes the complete vocabulary of navigation types used 
in this browsing session. The high counts of link+redirect combinations and the 
presence of form-submit transitions confirm an active interactive session rather 
than passive browsing.

E04b | 
Decoded all nine unique transition values by masking with 0xFFFFFFFF and 
extracting base = value & 0xFF and qualifier bits at 0x10000000 (CHAIN_START), 
0x20000000 (CLIENT_REDIRECT), 0x40000000 (SERVER_REDIRECT), 0x80000000 (FORWARD_BACK).
Findings:
  - 268435456 → base=LINK (click), qualifier=CHAIN_START
  - 805306368 → base=LINK, qualifiers=CHAIN_START + CLIENT_REDIRECT
  - 805306373 → base=OMNIBOX (typed search), qualifiers=CHAIN_START + CLIENT_REDIRECT
  - 805306375 → base=FORM_SUBMIT, qualifiers=CHAIN_START + CLIENT_REDIRECT
  - 838860805 → base=OMNIBOX, qualifiers=CHAIN_START + CLIENT_REDIRECT + SERVER_REDIRECT
  - 1073741824 → base=LINK, qualifier=SERVER_REDIRECT
  - 1610612736 → base=LINK, qualifiers=SERVER_REDIRECT + CLIENT_REDIRECT
  - -1610612736 → base=LINK, qualifiers=CLIENT_REDIRECT + FORWARD_BACK
  - -2147483648 → base=LINK, qualifier=FORWARD_BACK
  No TYPED (base=1) transitions exist in the dataset — the user never typed a complete 
URL directly.
Why it matters: Provides the framework for interpreting user behaviour (Q4). 
The absence of TYPED transitions and prevalence of OMNIBOX transitions indicate the user relied on search rather than direct URL entry.

E04c | 
Query: full decoded timeline with visit_id, url_id, visit_utc, from_visit, base type, 
hex transition, title — 74 rows.
Findings: The complete navigation sequence is preserved with decoded transition types, 
ready for narrative reconstruction.
Why it matters: Provides the master reference for all subsequent timeline discussion. 
Output saved to notes/timeline_decoded.txt and notes/timeline_full_decoded.txt.

E04d | 
Query: SELECT visits where (transition & 0xFF) = 7 — the FORM_SUBMIT events.
Findings: Seven FORM_SUBMIT transitions occur in the dataset, all clustered during the 
Craigslist posting workflow:
  visit 8  | 2022-04-19 13:54:39 UTC | Craigslist login (accounts.craigslist.org/login/home)
  visit 14 | 2022-04-19 13:55:10 UTC | Posting: choose category (?s=cat)
  visit 15 | 2022-04-19 13:55:15 UTC | Posting: create posting (?s=edit)
  visit 16 | 2022-04-19 13:58:13 UTC | Posting: add map (?s=geoverify)
  visit 17 | 2022-04-19 13:58:17 UTC | Posting: edit image (?s=editimage)
  visit 18 | 2022-04-19 13:58:19 UTC | Posting: preview (?s=preview)
  visit 19 | 2022-04-19 13:58:22 UTC | Posting: confirmation
Why it matters: FORM_SUBMIT is the strongest evidence of direct user input in Chrome history. 
These seven events demonstrate that the user actively logged into Craigslist and 
stepped through the posting workflow by filling and submitting forms. 
This is not passive browsing.

E04e | 
Query: SELECT visits where (transition & 0xFF) = 5 — the OMNIBOX (search) events.
Findings: Four OMNIBOX transitions occur, each capturing a user-typed search:
  visit 1  | 2022-04-19 13:54:18 UTC | "craigslist"
  visit 22 | 2022-04-19 13:58:38 UTC | "gmail"
  visit 51 | 2022-04-19 14:58:59 UTC | "blockchain explorer"
  visit 59 | 2022-04-19 14:59:38 UTC | "kraken"
Why it matters: Search terms are captured by Chrome directly from the omnibox and represent 
explicit user input. Their sequence maps one-to-one onto the four phases of the alleged 
activity: locate platform → communicate → verify payment → exchange/bank.

E04f | 
Query: SELECT visits where from_visit = 0 — the "chain start" events.
Findings: 22 visit events have from_visit = 0, marking navigation chain starts. 
Notable chain starts include:
  visit 1  | 13:54:18 UTC | Google search: craigslist (start of session)
  visit 21 | 13:58:31 UTC | "cheaper than Rx supplements" live posting
  visit 22 | 13:58:38 UTC | Google search: gmail
  visit 43 | 14:04:12 UTC | Email "order" opened
  visit 48 | 14:56:47 UTC | Email "txid: 517b2156..." opened
  visit 49 | 14:56:52 UTC | Imgur proof of payment
  visit 51 | 14:58:59 UTC | Google search: blockchain explorer
  visit 59 | 14:59:38 UTC | Google search: kraken
Why it matters: Each chain start represents a fresh navigation event, 
useful for segmenting the timeline into meaningful activity phases. 
The from_visit = 0 pattern gives clear boundaries for the reconstructed timeline.

E04g | 
Master decoded timeline with transition hex values, 
saved to notes/timeline_full_decoded.txt (74 rows).
Findings: Complete navigation record with per-visit transition hex, decoded base type, 
chain qualifier flags, and URL title.
Why it matters: Provides the audit-ready artifact for the appendix, 
allowing any examiner to verify every interpretation against the raw transition values.
File: notes/timeline_full_decoded.txt


E05a | 
Query: SELECT v.id, u.id, u.url, u.title, datetime(...) AS visit_utc, v.from_visit, 
transition_decoded, v.visit_duration FROM visits v JOIN urls u ON v.url=u.id 
WHERE u.url LIKE '%craigslist%' ORDER BY v.visit_time;
Findings: 21 visits touch Craigslist-related URLs, spanning 2022-04-19 
13:54:18 UTC to 13:58:31 UTC (approximately 4 minutes 13 seconds). 
These cover: the initial Google search for "craigslist", navigation through redirects 
to the Baltimore Craigslist homepage, login, the posting workflow (7 steps), 
the manage posting page, and the published ad.
Why it matters: Provides the complete evidence set for the "posting" phase of the 
investigation. The tight time window (≈4 min 13 s) and sequential from_visit chain show 
a single continuous session rather than sporadic browsing.
File: notes/q5_craigslist.txt

E05b | 
Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.url 
LIKE '%cheaper-than-rx-supplements%';
Finding (visit 21):
  visit_id = 21
  url_id = 16
  url = https://baltimore.craigslist.org/hab/d/baltimore-cheaper-than-rx-supplements/7473121658.html
  title = cheaper than Rx supplements - health and beauty - by owner -...
  visit_utc = 2022-04-19 13:58:31 UTC
  from_visit = 0
  transition = 805306368 (0x30000000 — LINK + CHAIN_START + CLIENT_REDIRECT)
Interpretation: The URL's slug ("cheaper-than-rx-supplements"), the title 
("cheaper than Rx supplements - health and beauty - by owner"), the /hab/ category path, 
and the numeric posting ID (7473121658) together describe a publicly listed classified ad. 
Only the ad's declared subject is captured — the body content is not available in the 
browser history.
Why it matters: This is the central artefact for Q5 — the URL and title record the 
existence and declared subject of a public ad on Craigslist. It supports the case 
hypothesis that the user posted an advertisement for "cheaper than Rx supplements" in the 
Health and Beauty category.

E05c | 
Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.url LIKE '%/manage/%';
Finding (visit 20):
  visit_id = 20
  url_id = 15
  url = https://post.craigslist.org/manage/7473121658
  title = baltimore | manage posting
  visit_utc = 2022-04-19 13:58:27 UTC
  from_visit = 19
  transition = 805306368 (0x30000000 — LINK + CHAIN_START + CLIENT_REDIRECT)
Interpretation: The /manage/<posting_id> URL is only reachable by the authenticated author 
of that posting. The posting ID (7473121658) matches the ID in the published ad URL (E05b), 
proving they are the same posting. The from_visit=19 chain link shows the user arrived 
at /manage from the immediately preceding posting-confirmation page.
Why it matters: This is decisive evidence of authorship — the browser profile accessed the 
manage page for a posting it had just created. A third party viewing the ad 
could not reach /manage/7473121658.

E05d | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE v.id = 21;
Finding: Same record as E05b, isolated for clarity.
Interpretation: The published ad was viewed by the browser profile 4 seconds after 
the manage page (13:58:27 → 13:58:31 UTC). The from_visit=0 chain start suggests a 
fresh navigation (new tab or link click from manage page).

E05e | 
Query: SELECT visit_id, url_id, visit_utc, transition_base, tran_hex, from_visit, 
url, title FROM visits JOIN urls WHERE visit_id BETWEEN 6 AND 21 ORDER BY visit_utc;
Findings — the complete posting workflow in order:
  visit 6  | 13:54:22 | LINK | https://accounts.craigslist.org/login/home
  visit 7  | 13:54:22 | LINK | https://accounts.craigslist.org/login?rp=%2Flogin%2Fhome&rt=L
  visit 8  | 13:54:39 | FORM | https://accounts.craigslist.org/login/home  (login submission)
  visit 9  | 13:55:03 | LINK | https://www.craigslist.org/
  visit 10 | 13:55:03 | LINK | https://baltimore.craigslist.org/
  visit 11 | 13:55:05 | LINK | https://post.craigslist.org/c/bal
  visit 12 | 13:55:05 | LINK | https://post.craigslist.org/k/sHbOUOi_7BG68qUDIbeTbQ/bQTi5
  visit 13 | 13:55:05 | LINK | .../bQTi5?s=type
  visit 14 | 13:55:10 | FORM | .../bQTi5?s=cat
  visit 15 | 13:55:15 | FORM | .../bQTi5?s=edit
  visit 16 | 13:58:13 | FORM | .../bQTi5?s=geoverify
  visit 17 | 13:58:17 | FORM | .../bQTi5?s=editimage
  visit 18 | 13:58:19 | FORM | .../bQTi5?s=preview
  visit 19 | 13:58:22 | FORM | .../bQTi5  (posting confirmation)
  visit 20 | 13:58:27 | LINK | https://post.craigslist.org/manage/7473121658
  visit 21 | 13:58:31 | LINK | published ad URL
Why it matters: This sequence reconstructs the full posting workflow. 
Seven FORM submissions show sustained user input. 
Every step's from_visit links to the prior step, forming an unbroken chain from login → 
posting → confirmation → manage → ad view.
File: notes/q5_posting_workflow.csv

E05f | Query: SELECT u.id, u.url, u.title FROM urls u WHERE u.url LIKE '%7473121658%';
Findings:
  url_id 15 | https://post.craigslist.org/manage/7473121658 | title "baltimore | 
manage posting"
  url_id 16 | https://baltimore.craigslist.org/hab/d/baltimore-cheaper-than-rx-supplements/7473121658.html | 
title "cheaper than Rx supplements - health and beauty - by owner -..."
The posting ID 7473121658 appears in both URLs.
Why it matters: The match confirms that the manage page and the published ad refer to the 
same underlying Craigslist posting. This links authorship (via /manage/) to the public 
artefact (the ad URL).



E06a | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.title LIKE '%fscs@gmail%' OR u.url LIKE '%mail.google.com%' ORDER BY v.visit_time;
Findings: 25 visits to Gmail-related URLs between 2022-04-19 13:58:40 UTC and 15:02:56 UTC. The page titles of url_ids 19, 20, 30–33 all contain the string "Inbox (12) - unsub.fscs@gmail.com - Gmail", indicating the browser profile was logged into that Gmail account.
Why it matters: Establishes the communications channel for the investigation — the browser profile was operating an authenticated session with the account unsub.fscs@gmail.com.
Screenshot: E06a_gmail_evidence.png
File: notes/q6_gmail.txt

E06b | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.url LIKE '%WhctKKXXDrfCqXBGCnHkHGxZnZbkXK%';
Findings — the "order" email chain:
  visit 43 | 14:04:12 | Open email "cheaper than Rx supplements - order" | transition 0x10000000 (LINK + CHAIN_START)
  visit 44 | 14:04:35 | Compose reply (URL contains ?compose=JHrtff...) | transition 0x40000000 (SERVER_REDIRECT)
  visit 45 | 14:04:46 | Compose another reply (?compose=DXDwS...) | transition 0x40000000 (SERVER_REDIRECT)
  visit 46 | 14:04:52 | Return to "order" email | transition 0x60000000
Interpretation: The user read the buyer's "order" email and composed two separate replies within 20 seconds. This is consistent with active engagement with the buyer — potentially containing the seller's payment details.
Why it matters: Provides the communication-phase evidence. The double-compose sequence is unusual and warrants noting — two separate reply drafts suggest either an initial reply and a correction, or two distinct messages to two parties.
Screenshot: E06b_order_email.png
File: notes/order_email.txt

E06c | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.url LIKE '%WhctKKXXDrfCqvtRjhGdkMBqVNFnwt%';
Findings — the "txid" email chain:
  visit 48 | 14:56:47 | Open email "cheaper than Rx supplements -- txid: 517b2156..." | transition 0x10000000
  visit 72 | 15:02:32 | Compose reply (?compose=JHrtffdgkFjdsFdVFrNv...)
  visit 73 | 15:02:44 | Compose another reply (?compose=xQTrpQHKFJPcWTcvdCm...)
  visit 74 | 15:02:56 | Return to "txid" email
Interpretation: The TXID is embedded in the email's page title, meaning Chrome captured it directly from the page. The user opened the payment-notification email and composed two further replies.
Why it matters: The txid email is the pivotal payment-communication artefact. Combined with the immediate blockchain lookups that follow (visits 55–58), it demonstrates the user received a payment notice and then verified it.
Screenshot: E06c_txid_email.png
File: notes/txid_email.txt

E06d | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE v.id IN (49, 50);
Findings:
  visit 49 | 14:56:52 | https://www.google.com/url?q=https://imgur.com/dTgrkP7&source=gmail&ust=...
  visit 50 | 14:56:52 | https://imgur.com/dTgrkP7 | visit_duration = 18,926,083 µs (18.9 seconds)
Interpretation: The URL in visit 49 contains the query parameter source=gmail, which Google's redirect service adds to links clicked from within Gmail. This confirms the entry point was a Gmail message. The user then spent 18.9 seconds on the Imgur page — a deliberate view, not a fleeting glance.
Why it matters: This artefact directly links the Gmail communications phase to an image-hosting post. The Imgur page is the sole source of the file later downloaded as proof_of_payment.png.
Screenshot: E06d_imgur_proof.png

E06e | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.url LIKE '%blockchain.com%';
Findings:
  visit 53 | 14:59:01 | https://www.blockchain.com/explorer
  visit 55 | 14:59:06 | https://www.blockchain.com/search?search=517b2156...
  visit 56 | 14:59:06 | https://www.blockchain.com/btc/tx/517b2156...
  visit 57 | 14:59:06 | https://www.blockchain.com/btc/tx/517b2156... (repeat)
  visit 58 | 14:59:21 | https://www.blockchain.com/btc/address/38RcsURWCDmCbYocmsZCnGz1FtD7x477mt
Interpretation: The user navigated to blockchain.com and searched for the TXID from the email. The site resolved the search into a transaction detail page. The user then clicked through to the address page for wallet 38RcsURWCDmCbYocmsZCnGz1FtD7x477mt, which appears in the case materials as the suspect's BTC wallet address.
Why it matters: Direct evidence of payment verification. The TXID and wallet address in the URLs are unique identifiers that cannot appear coincidentally.

E06f | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.url LIKE '%kraken.com%';
Findings — Kraken exchange activity:
  visit 61 | 14:59:47 | https://www.kraken.com/en-us/sign-in
  visit 63 | 15:00:21 | https://www.kraken.com/en-us/device-approval
  visit 64 | 15:01:11 | https://www.kraken.com/u/trade?i=true
  visit 65 | 15:01:12 | https://www.kraken.com/u/instant
  visit 66 | 15:01:21 | https://www.kraken.com/u/funding — page title includes "41,543.80 USD"
  visit 71 | 15:02:05 | https://www.kraken.com/u/history/ledger — page title includes "41,563.70 USD"
Interpretation: The user logged into Kraken (including a device-approval step suggesting a new device or IP), then navigated to the trading, instant-buy, funding, and history-ledger pages. The funding and ledger page titles contain dollar balances (41,543.80 and 41,563.70 USD respectively).
Why it matters: The Kraken activity is consistent with the final phase of the alleged activity — moving or reviewing funds received. The balances in the page titles are direct evidence Chrome captured from Kraken's server-rendered page titles, not user input.
File: notes/kraven_activity.txt

E06g | Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE v.id BETWEEN 67 AND 70;
Findings — Kraken → mempool.space redirect chain:
  visit 67 | 15:01:31 | https://www.kraken.com/redirect?url=https%3A%2F%2Fmempool.space%2Ftx%2F517b2156...
  visit 68 | 15:01:33 | http://www.kraken.com/redirect?t=-_F22IhwssFD (transition 0x40000000 SERVER_REDIRECT)
  visit 69 | 15:01:33 | https://www.kraken.com/redirect?t=-_F22IhwssFD (transition 0x80000000 FORWARD_BACK)
  visit 70 | 15:01:33 | https://mempool.space/tx/517b2156...
Interpretation: From Kraken, the user clicked a link that pointed to mempool.space with the transaction ID. Kraken's redirect service bounced the request twice before delivering the user to mempool.space. The page title throughout the redirect chain reads "Transaction: 517b2156... - mempool - Bitcoin Explorer".
Why it matters: Confirms a third independent source for the same TXID. The user was cross-checking the transaction across blockchain.com and mempool.space — a common pattern when verifying cryptocurrency transfers.
File: notes/mempool_redirect.txt

E06h | Query: SELECT id, guid, current_path, target_path, start_time, end_time, received_bytes, total_bytes, state, danger_type, interrupt_reason, mime_type, tab_url, tab_referrer_url, site_url, http_method, etag, last_modified, hex(hash) FROM downloads;
Findings (single record):
  download_id = 1
  guid = 104c5d2b-4cba-40f3-9e11-02b782e54bfa
  current_path / target_path = C:\Users\FSCS_User\Desktop\proof_of_payment.png
  start_utc = 2022-04-19 14:56:58, end_utc = 14:57:10 (12-second download)
  received_bytes = total_bytes = 33844 (complete)
  state = 1 (complete), danger_type = 0 (safe), interrupt_reason = 0 (none)
  mime_type = image/png
  tab_url = https://imgur.com/dTgrkP7   ← download source URL
  etag = "e4e316a7412fbc693e9268127fa8e1e6"
  last_modified = Tue, 19 Apr 2022 14:52:06 GMT
Interpretation: The file "proof_of_payment.png" was downloaded from the Imgur URL dTgrkP7 
to the Windows Desktop folder of user "FSCS_User". The download started 6 seconds after 
the Imgur page was opened (visit 50 at 14:56:52 vs download at 14:56:58) and completed 
fully (received = total = 33844 bytes).
Why it matters: The download record is the strongest single link between the browser 
session and a retained artefact. The filename "proof_of_payment" is chosen by the site 
or user, and the tab_url field proves the source was the Imgur post linked from Gmail. 
This is the payment-verification artefact retained by the profile.
File: notes/download_record.txt

E06i | 
Query: SELECT ... FROM visits v JOIN urls u ON v.url=u.id WHERE u.url LIKE '%517b2156%' 
OR u.title LIKE '%517b2156%' ORDER BY v.visit_time;
Findings: The 64-character transaction ID 517b2156914944339a96137ad8978408ea52b2fc144c98d3b0b16b21888afdc5 
appears in 9 visit records across 4 independent sources:
  - Gmail email page title (visits 48, 74)
  - blockchain.com search URL (visit 55)
  - blockchain.com transaction URL (visits 56, 57)
  - Kraken redirect to mempool (visits 67, 68, 69)
  - mempool.space transaction URL (visit 70)
Interpretation: A 64-character random identifier appearing 9 times across 4 independent 
systems cannot be coincidental. The same Bitcoin transaction was viewed by the same 
browser profile from Gmail, blockchain.com, Kraken, and mempool.space within a 5-minute 
window.
Why it matters: This is the strongest cross-source corroboration in the case. 
It links the Gmail communication directly to a specific, unique Bitcoin transaction 
that was verified through multiple third-party blockchain explorers.
File: notes/txid_correlation.txt

E06j | 
Query: SELECT v.id, u.url, datetime(...) FROM visits WHERE v.id IN (46, 47, 48, 49);
Findings:
  visit 46 | 2022-04-19 14:04:52 UTC | back to "order" email
  visit 47 | 2022-04-19 14:05:59 UTC | back to Gmail inbox
  --- 50 min 48 sec gap with no browsing activity ---
  visit 48 | 2022-04-19 14:56:47 UTC | open "txid" email
Interpretation: There is a 50-minute 48-second window during which no browser activity was 
recorded. The gap begins after the user returned to the Gmail inbox (14:05:59) and ends 
when the user opened the "txid" email (14:56:47).
Why it matters: Browser history cannot account for user activity during this window. 
Possible but unverified explanations include waiting for a Bitcoin transaction to confirm 
(each confirmation ≈10 minutes; ~5 confirmations = 50 minutes), or the user was engaged 
in non-browser activity. This is a material limitation for the report.
File: notes/time_gap.txt



E07a | Query: stage-grouped timeline (7 stages defined by visit-ID ranges), 74 rows.
Findings — stage distribution:
  1. Posting                 | visits 1–21  | 2022-04-19 13:54:18 – 13:58:31 UTC | 252 s
  2. Communications          | visits 22–47 | 2022-04-19 13:58:38 – 14:05:59 UTC | 440 s
  3. Payment notification    | visit 48     | 2022-04-19 14:56:47 UTC            | 0 s
  4. Imgur proof             | visits 49–50 | 2022-04-19 14:56:52 UTC            | 0 s
  5. Blockchain verification | visits 51–58 | 2022-04-19 14:58:59 – 14:59:21 UTC | 21 s
  6. Exchange                | visits 59–71 | 2022-04-19 14:59:38 – 15:02:05 UTC | 147 s
  7. Final replies           | visits 72–74 | 2022-04-19 15:02:32 – 15:02:56 UTC | 24 s
Why it matters: Segments the 74 visits into seven activity phases that correspond to the case hypothesis stages (posting → communications → payment → verification → exchange). Provides the backbone of the reconstructed timeline in Q7.
File: notes/timeline_stage_grouped.txt

E07b | Query: per-stage summary with visit counts, first/last timestamps, and duration.
Findings: Total session = 74 visits over 4,118 seconds (~68.6 minutes), of which 3,049 seconds (~50.8 minutes) fall inside a single browsing gap (14:05:59 → 14:56:47 UTC). The remaining active browsing time is ~17.8 minutes across 7 discrete stages.
Why it matters: Quantifies the session structure. The dominance of the gap within the overall session duration is a key forensic observation.
Screenshot: E07b_stage_summary.png
File: notes/stage_summary.txt

E07c | Query: key events timeline — 42 observations selected for the report (visit IDs cherry-picked to represent each stage's critical moments).
Findings: The 42 key events trace the complete narrative:
  - 13:54:18 — search "craigslist" (OMNIBOX)
  - 13:54:39 — Craigslist login FORM submitted
  - 13:55:10 – 13:58:22 — seven FORM submissions through the posting pipeline, ending in posting confirmation
  - 13:58:27 — manage posting (author-only page)
  - 13:58:31 — published ad view
  - 13:58:38 — search "gmail"
  - 13:59:26–13:59:31 — Gmail password challenge and inbox load
  - 14:04:12 — open "order" email
  - 14:04:35 & 14:04:46 — compose two replies
  - 14:04:52 — return to order email
  - 14:05:59 — return to inbox (last pre-gap activity)
  - [50m 48s gap]
  - 14:56:47 — open "txid" email
  - 14:56:52 — click source=gmail link → Imgur post
  - 14:58:59 — search "blockchain explorer"
  - 14:59:06 — look up TXID on blockchain.com
  - 14:59:21 — look up wallet address
  - 14:59:38 — search "kraken"
  - 15:00:21 — Kraken device approval
  - 15:01:21 — Kraken funding page (balance 41,543.80 USD)
  - 15:01:31–15:01:33 — redirect chain to mempool.space
  - 15:02:05 — Kraken ledger (balance 41,563.70 USD)
  - 15:02:32 & 15:02:44 — compose two more replies to txid email
  - 15:02:56 — session ends
Why it matters: Provides the report-ready timeline of key events, with the observation/inference separation justified by the raw visit IDs, timestamps, and transition types.
Screenshot: E07c_key_events.png
File: notes/timeline_key_events.txt

E07d | Query: gap markers — visits 46, 47, 48 with markers.
Findings:
  visit 46 | 2022-04-19 14:04:52 | (pre-gap)
  visit 47 | 2022-04-19 14:05:59 | ← gap starts
  visit 48 | 2022-04-19 14:56:47 | ← gap ends
Duration: 50 minutes 48 seconds.
Interpretation: During this window, the browser history records no activity. Possible explanations include: waiting for a Bitcoin transaction to confirm (typical confirmation ≈10 minutes, 5 confirmations ≈50 minutes); user idle; user using non-browser applications. The browser history alone cannot distinguish these.
Why it matters: An explicit gap in the record is a material limitation for the timeline. Naming it and quantifying it is essential to defensible reconstruction.
Screenshot: E07d_gap.png
File: notes/gap.txt

E07e | CSV export: final_timeline.csv, 75 lines (1 header + 74 data rows).
Columns: visit_utc, visit_id, url_id, url, title, from_visit, transition, tran_hex, base_type, visit_duration.
Why it matters: Provides the audit-ready, machine-readable version of the timeline for the appendix. Enables any examiner to re-verify each row against the source database.
File: notes/final_timeline.csv



E08a | Query: SELECT MIN/MAX(visit_time), COUNT(*), COUNT(DISTINCT url), (MAX-MIN)/1000000 FROM visits v JOIN urls u ON v.url=u.id;
Findings: session_start_utc = 2022-04-19 13:54:18, session_end_utc = 2022-04-19 15:02:56, total_visits = 74, distinct_urls = 57, session_span_seconds = 4,118.
Why it matters: Establishes the boundary conditions of the investigation. Any conclusion must be bounded within this session window.
Screenshot: E08a_session_summary.png

E08b | Query: SELECT DISTINCT title FROM urls WHERE title LIKE '%@%' AND title LIKE '%Gmail%';
Findings: Three distinct titles contain both an @ symbol and "Gmail":
  - "Inbox (12) - unsub.fscs@gmail.com - Gmail"
  - "cheaper than Rx supplements - order - unsub.fscs@gmail.com - Gmail"
  - "cheaper than Rx supplements -- txid: 517b2156914944339a96137ad8978408ea52b2fc144c98d3b0b16b21888afdc5 - unsub.fscs@gmail.com - Gmail"
Why it matters: Establishes that the browser profile was operating within the context of the Gmail account unsub.fscs@gmail.com. This is the only human-facing identifier in the database.
Screenshot: E08b_profile_identity.png

E08c | Query: SELECT transition & 0xFF AS base_type, COUNT(*) FROM visits GROUP BY (transition & 0xFF) ORDER BY COUNT(*) DESC;
Findings:
  LINK (click)              = 63 visits (85.1%)
  FORM_SUBMIT (filled form) = 7 visits (9.5%)
  OMNIBOX (typed search)    = 4 visits (5.4%)
  TYPED (typed URL)         = 0
Why it matters: Quantifies the density of direct user input. 11 of 74 visits (14.9%) carry direct user actions (form submission or omnibox search). The absence of any TYPED transitions means the user never typed a complete URL directly — every direct-input action was either a search or a form submission.
Screenshot: E08c_user_input_density.png

E08d | Attribution analysis file (notes/attribution_analysis.md) documenting Tier 1 observations, Tier 2 inferences, Tier 3 limitations, and confidence levels.
Findings:
  Confidence — Profile activity: HIGH
  Confidence — Criminal intent: MEDIUM (consistent with hypothesis, not proven)
  Confidence — Specific named human: LOW (browser history alone insufficient)
  8 distinct limitations identified (exceeds the brief's minimum of 3).
Why it matters: Provides the framework for the report's Section 7 (Attribution Assessment). Demonstrates the observation/inference/limitation separation required by the marking guide.
Screenshot: E08d_attribution_analysis.png
File: notes/attribution_analysis.md
