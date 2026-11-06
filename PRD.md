# Prospect — Product Requirements Document (PRD)

**Owner:** Jaydon Davies · **Version:** 1.0 · **Date:** 2026-11-06

---

## 1. Summary

Prospect is a small web app that acts like a recruiter. The user (the "boss") gives it **5 LinkedIn prospects** and a set of **requirements**. Prospect summarises each prospect, ranks them against the requirements, names the **best match**, and gives short, clear reasons why the others fall short.

## 2. Goals

| Goal | How we know it works |
|---|---|
| Paste 5 LinkedIn URLs quickly | All 5 fields validate as `linkedin.com/in/...` links |
| Build a "prospect requirements" brief with as much detail as the user wants | Free-text + tag fields, plus suggested keywords to click |
| Find the closest match, even when wording differs | Synonym + fuzzy matching (e.g. "HubSpot" counts towards "CRM") |
| Explain mismatches concisely | Every prospect gets a short "Why not" list covering every requirement it misses |
| Hosted publicly on GitHub and republished after every change | Live GitHub Pages URL; each change is committed and pushed |

**Non-goals (v1):** user accounts, saving searches to a server, contacting prospects, automatic scraping of LinkedIn.

## 3. Key constraint: getting the profile data

LinkedIn profiles sit behind a login and block automated reading. A website **cannot fetch a LinkedIn profile from its URL alone** (blocked by LinkedIn and by browser security rules). Paid data APIs exist but cost money and need a server.

**v1 approach (free, private, works today):** each prospect has its URL **plus** one of:
1. **Paste profile text** — open the profile, select all, copy, paste. Prospect strips noise like "People also viewed".
2. **Upload LinkedIn PDF** — on a profile, *More → Save to PDF*, then drop the file in. This is the cleanest source.

All processing happens in the browser. Nothing is sent anywhere.

**Why not "Sign in with LinkedIn"?** (looked at 2026-11-06) LinkedIn's sign-in only gives a website the *signed-in person's own* basic details (name, email, photo). It does not give access to other members' profiles. Reading other profiles through LinkedIn's API is limited to approved partners (e.g. recruiting software in LinkedIn's Talent partner programme). A website also can't borrow the visitor's LinkedIn login to load pages: the browser blocks this on purpose (same-origin policy). Asking for LinkedIn passwords or session cookies to do it on a server would be unsafe and breaks LinkedIn's rules against scraping.

**Phase 2 options** (decision for later):
- **AI mode:** send the profile text + requirements to Claude for richer summaries and reasoning (needs an API key and a tiny server or serverless function to keep the key secret).
- **Auto-fetch:** connect a LinkedIn data provider so the URL alone is enough (paid; needs a server).

## 4. User flow

1. **Step 1 — Prospects.** Five slots. Each has a LinkedIn URL field and an "Add profile details" area (paste text or upload PDF). A "Try with demo prospects" button fills sample data.
2. **Step 2 — Requirements** (opens once all 5 URLs are valid):
   - Role / job title
   - Must-have skills or keywords (tags)
   - Nice-to-have skills (tags)
   - Qualifications / education (tags)
   - Minimum years of experience
   - Location / area of residence + "remote is fine" toggle
   - Anything else (free text — extra keywords are pulled from it)
   - **Suggested keywords:** clickable chips grouped by theme, plus "related" suggestions based on what the user has typed
3. **Step 3 — Results:**
   - **Top match** card with score, summary, and why they fit
   - Ranked list of all 5: score, summary (headline, location, est. experience, notable skills), ✓ matched requirements, ✗ concise "Why not" reasons
   - Edit requirements and re-run at any time

## 5. Matching engine (client-side)

- **Normalise:** lowercase, strip punctuation, light stemming ("managing" → "manag").
- **Synonyms:** built-in groups (e.g. *CRM ≈ Salesforce ≈ HubSpot*, *JS ≈ JavaScript*, *degree ≈ bachelor ≈ BSc*, *lead ≈ head of ≈ manager*).
- **Fuzzy:** small typos still match (edit distance ≤ 1–2 on longer words).
- **Phrases:** multi-word requirements match when their key words appear together.
- **Experience:** estimated from LinkedIn durations ("3 yrs 2 mos") or date ranges ("2018 – Present").
- **Location:** matches the profile's location line or text; remote toggle softens a mismatch.

**Weighting** (only for sections the user filled in, then rescaled to 100):

| Section | Weight |
|---|---|
| Must-haves | 35 |
| Role / title | 15 |
| Qualifications | 15 |
| Experience | 15 |
| Location | 10 |
| Nice-to-haves | 5 |
| Free-text keywords | 5 |

Exact match = full credit, synonym = 90%, fuzzy = 75%. Missing a must-have also lowers the overall ranking so a prospect lacking essentials can't win on extras.

## 6. Design

- Single page, three clear steps, calm professional look (deep green / ink with a fresh accent), light + dark mode.
- Works on phones (16px side gutter, no sideways scrolling).
- Plain HTML, CSS and JavaScript in one file — no build step. PDF reading via pdf.js from a CDN.

## 7. Tech & hosting

- **Code:** `index.html` at the repo root (the whole site).
- **Repo:** GitHub, public.
- **Hosting:** GitHub Pages, serving the repo root (`/`) of the `main` branch.
- **Republish rule:** after every change → commit → push → GitHub Pages redeploys automatically (about 1 minute). `publish.sh` does this in one command.
- `MEMORY.md` and `CLAUDE.md` are personal notes and are kept **out** of the public repo (`.gitignore`).

## 8. Milestones

1. ✅ PRD
2. Build v1 site (inputs, requirements, matching, results)
3. Test in browser (desktop + mobile, demo data)
4. Create GitHub repo, enable Pages, share live link
5. Phase 2: decide on AI mode / auto-fetch

## 9. Risks

| Risk | Mitigation |
|---|---|
| Users only paste URLs, no profile text | Clear prompt in each slot; result marks the prospect "Not enough info" instead of guessing |
| Pasted text includes other people (sidebar) | Strip text after "People also viewed", "More profiles for you", etc. |
| Keyword matching misses meaning | Synonym groups + fuzzy matching now; AI mode in Phase 2 |
| Privacy | Everything stays in the browser; nothing is stored or sent |
