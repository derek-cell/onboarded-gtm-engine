#!/bin/bash
###############################################################################
# Onboarded GTM Engine — Full GitHub Setup Script
#
# This script:
#   1. Creates a new GitHub repo (onboarded-gtm-engine)
#   2. Pushes all code files
#   3. Creates labels for issue organization
#   4. Creates milestones for 4-week implementation roadmap
#   5. Creates all GitHub Issues (scripts, tasks, decisions)
#   6. Creates a GitHub Project board with columns
#
# Usage:
#   export GITHUB_TOKEN="ghp_your_token_here"
#   bash setup_github.sh
#
# Requirements:
#   - curl, git, jq installed
#   - GitHub PAT with repo + project scopes
###############################################################################

set -euo pipefail

# --- Configuration ---
GITHUB_TOKEN="${GITHUB_TOKEN:?Set GITHUB_TOKEN environment variable}"
REPO_NAME="onboarded-gtm-engine"
REPO_DESC="Onboarded GTM Engine v2 — 7-engine automation system for Attio CRM, Fathom, Clay, ActiveCampaign"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

API="https://api.github.com"
AUTH="Authorization: token $GITHUB_TOKEN"
ACCEPT="Accept: application/vnd.github+json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }
info() { echo -e "${BLUE}[→]${NC} $1"; }

# --- Get Current User ---
info "Verifying GitHub token..."
OWNER=$(curl -sf -H "$AUTH" -H "$ACCEPT" "$API/user" | jq -r '.login')
[ "$OWNER" = "null" ] || [ -z "$OWNER" ] && err "Invalid GitHub token"
log "Authenticated as: $OWNER"

REPO_FULL="$OWNER/$REPO_NAME"

###############################################################################
# STEP 1: Create Repository
###############################################################################
echo ""
info "Creating repository: $REPO_FULL"

REPO_EXISTS=$(curl -sf -o /dev/null -w "%{http_code}" -H "$AUTH" -H "$ACCEPT" "$API/repos/$REPO_FULL")

if [ "$REPO_EXISTS" = "200" ]; then
    warn "Repository already exists — skipping creation"
else
    curl -sf -H "$AUTH" -H "$ACCEPT" \
        -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESC\",\"private\":true,\"auto_init\":false}" \
        "$API/user/repos" > /dev/null
    log "Repository created: https://github.com/$REPO_FULL"
fi

###############################################################################
# STEP 2: Push Code
###############################################################################
echo ""
info "Pushing code to repository..."

cd "$SCRIPT_DIR"

if [ ! -d ".git" ]; then
    git init -q
    git checkout -q -b main
fi

git add -A
git commit -q -m "Initial commit: Onboarded GTM Engine v2

Complete 7-engine GTM automation system with:
- 8 Python script skeletons
- YAML configuration files (ICP, Attio schema, messaging, pipeline, competitive)
- Markdown templates (meeting prep, post-meeting, pipeline health, competitive)
- Outbound sequence templates
- GitHub issue templates
- Environment and dependency config

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>" 2>/dev/null || warn "Nothing to commit"

git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_TOKEN}@github.com/${REPO_FULL}.git"
git push -uf origin main 2>/dev/null
log "Code pushed to main branch"

###############################################################################
# STEP 3: Create Labels
###############################################################################
echo ""
info "Creating labels..."

declare -A LABELS
LABELS=(
    ["script-1-intelligence"]="0075ca:Script 1: Account Intelligence Engine"
    ["script-2-committee"]="0075ca:Script 2: Buying Committee Builder"
    ["script-3-outbound"]="0075ca:Script 3: Outbound Generator"
    ["script-4-meeting-prep"]="0075ca:Script 4: Meeting Prep Brief"
    ["script-5-post-meeting"]="0075ca:Script 5: Post-Meeting Processor"
    ["script-6-pipeline"]="0075ca:Script 6: Pipeline Health Monitor"
    ["script-7-competitive"]="0075ca:Script 7: Competitive Intelligence"
    ["script-8-event"]="0075ca:Script 8: Event GTM Orchestrator"
    ["week-1-foundation"]="5319e7:Week 1: Foundation (Quick Wins)"
    ["week-2-automation"]="5319e7:Week 2: Automation"
    ["week-3-optimization"]="5319e7:Week 3: Optimization"
    ["week-4-scale"]="5319e7:Week 4+: Scale"
    ["decision-needed"]="d93f0b:Decision needed from team"
    ["high-impact"]="b60205:High impact"
    ["quick-win"]="0e8a16:Quick win"
    ["integration"]="fbca04:Integration work"
    ["data-flow"]="c5def5:Data flow / architecture"
    ["attio"]="1d76db:Attio CRM"
    ["fathom"]="1d76db:Fathom / Transcripts"
    ["activecampaign"]="1d76db:ActiveCampaign"
    ["clay"]="1d76db:Clay Enrichment"
    ["google-drive"]="1d76db:Google Drive"
    ["slack"]="1d76db:Slack"
)

for label in "${!LABELS[@]}"; do
    IFS=':' read -r color desc <<< "${LABELS[$label]}"
    curl -sf -H "$AUTH" -H "$ACCEPT" \
        -d "{\"name\":\"$label\",\"color\":\"$color\",\"description\":\"$desc\"}" \
        "$API/repos/$REPO_FULL/labels" > /dev/null 2>&1 || true
done
log "Created ${#LABELS[@]} labels"

###############################################################################
# STEP 4: Create Milestones
###############################################################################
echo ""
info "Creating milestones..."

create_milestone() {
    local title="$1"
    local desc="$2"
    local due="$3"
    local result
    result=$(curl -sf -H "$AUTH" -H "$ACCEPT" \
        -d "{\"title\":\"$title\",\"description\":\"$desc\",\"due_on\":\"$due\"}" \
        "$API/repos/$REPO_FULL/milestones" 2>/dev/null)
    echo "$result" | jq -r '.number'
}

MS1=$(create_milestone "Week 1: Foundation" "Quick wins — enrichment audit, pipeline scan, meeting prep, Fathom backfill, top 20 account enrichment" "$(date -d '+7 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -v+7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '2026-02-12T23:59:59Z')")
MS2=$(create_milestone "Week 2: Automation" "Buying committees, outbound sequences, daily meeting prep automation" "$(date -d '+14 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -v+14d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '2026-02-19T23:59:59Z')")
MS3=$(create_milestone "Week 3: Optimization" "Competitive intel baseline, weekly pipeline monitor, scoring refinement" "$(date -d '+21 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -v+21d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '2026-02-26T23:59:59Z')")
MS4=$(create_milestone "Week 4+: Scale" "Event GTM, full enrichment expansion, outbound iteration, partner workflows" "$(date -d '+35 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -v+35d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '2026-03-12T23:59:59Z')")

log "Created 4 milestones (MS1=$MS1, MS2=$MS2, MS3=$MS3, MS4=$MS4)"

###############################################################################
# STEP 5: Create Issues
###############################################################################
echo ""
info "Creating issues..."

create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local milestone="$4"
    curl -sf -H "$AUTH" -H "$ACCEPT" \
        -d "{\"title\":\"$title\",\"body\":$(echo "$body" | jq -Rs .),\"labels\":$labels,\"milestone\":$milestone}" \
        "$API/repos/$REPO_FULL/issues" > /dev/null
}

# ─── WEEK 1: Foundation ──────────────────────────────────────────────

create_issue \
    "[Script 1] Account Enrichment Audit — find all companies with empty AI fields" \
    "## Task
Run Script 1 in **audit mode** to identify all companies in Attio with empty AI enrichment fields.

## What to do
1. Query all companies in Attio
2. Check which AI enrichment fields are empty (\`ai_account_brief\`, \`ai_icp_rationale\`, \`ai_enriched_tech_stack\`, etc.)
3. Prioritize by tier (Tier 1 first)
4. Generate a gap report showing which fields are missing for each company

## Acceptance Criteria
- [ ] All companies queried from Attio
- [ ] Gap report generated with counts per field
- [ ] Companies prioritized by tier for enrichment
- [ ] Report saved to Google Drive

## Implementation
Roadmap: **Week 1, Day 1**
Script: \`scripts/01_account_intelligence.py --mode audit\`" \
    '["script-1-intelligence","week-1-foundation","quick-win","attio"]' \
    "${MS1:-1}"

create_issue \
    "[Script 6] Pipeline Health Scan — flag stalled deals and missing data" \
    "## Task
Run Script 6 as a **one-time scan** to generate a baseline pipeline health snapshot.

## What to do
1. Pull all active deals from Attio (stages 1-5, 8)
2. Check for stalled deals (no activity beyond stage thresholds)
3. Identify missing fields (no \`ai_account_brief\`, no contacts, no deal amount)
4. Calculate current pipeline metrics

## Stage Velocity Benchmarks
| Stage | Expected Max Days | Stall Alert |
|-------|------------------|-------------|
| Lead | 14 | 7 days no activity |
| Intro Call | 7 | 5 days no meeting |
| Discovery | 21 | 10 days no activity |
| Solutioning | 30 | 14 days no activity |
| Redlines | 21 | 7 days no activity |

## Acceptance Criteria
- [ ] All active deals analyzed
- [ ] Stalled deals flagged with recommended actions
- [ ] Missing data report generated
- [ ] Pipeline metrics calculated (value by stage, coverage ratio, velocity)

## Implementation
Roadmap: **Week 1, Day 1**
Script: \`scripts/06_pipeline_health.py\`" \
    '["script-6-pipeline","week-1-foundation","quick-win","attio"]' \
    "${MS1:-1}"

create_issue \
    "[Script 4] Generate Meeting Prep for this week's meetings" \
    "## Task
Run Script 4 to generate prep briefs for all external meetings this week.

## What to do
1. Pull Google Calendar for external meetings (filter out internal-only)
2. For each meeting attendee:
   - Look up in Attio (company + people records)
   - Search Google Drive for Fathom transcripts
   - Search Gmail for recent email threads
   - Check Attio for deal stage, notes, tasks
3. Generate structured prep brief using template

## Brief sections
- Company snapshot (from \`ai_account_brief\`)
- Attendee profiles
- Relationship history (Fathom transcripts + emails)
- Current deal status
- Talking points (persona-specific)
- Competitive positioning (if competitor mentioned)
- Objection prep

## Acceptance Criteria
- [ ] All external meetings identified
- [ ] Briefs generated for each meeting
- [ ] Briefs saved to Google Drive
- [ ] Attio notes created

## Implementation
Roadmap: **Week 1, Day 2**
Script: \`scripts/04_meeting_prep.py\`
Template: \`templates/meeting_prep_brief.md\`" \
    '["script-4-meeting-prep","week-1-foundation","quick-win","attio","fathom","google-drive"]' \
    "${MS1:-1}"

create_issue \
    "[Script 5] Backfill last 5 Fathom transcripts into Attio" \
    "## Task
Run Script 5 in **backfill mode** to process the 5 most recent Fathom call transcripts and populate Attio with meeting intelligence.

## What to do
1. Find the 5 most recent Fathom transcripts in Google Drive
2. For each transcript, extract:
   - Decisions made
   - Action items (who, what, when)
   - Objections raised
   - Competitive mentions
   - Technical requirements
   - Next steps
   - Deal stage signal
   - New stakeholders
3. Match to Attio company + deal records
4. Create structured notes and tasks in Attio

## Data Flow
\`\`\`
Google Drive (Fathom folder) → Read transcript → Extract intelligence
  → Attio: create note, update deal, create tasks
  → Draft follow-up emails
  → Flag new stakeholders for Script 2
\`\`\`

## Acceptance Criteria
- [ ] 5 most recent transcripts identified and processed
- [ ] Structured notes created in Attio for each
- [ ] Action items converted to Attio tasks
- [ ] Deal stages updated where warranted
- [ ] Follow-up email drafts generated

## Implementation
Roadmap: **Week 1, Day 3**
Script: \`scripts/05_post_meeting_processor.py --mode backfill --backfill-count 5\`" \
    '["script-5-post-meeting","week-1-foundation","high-impact","attio","fathom","google-drive"]' \
    "${MS1:-1}"

create_issue \
    "[Script 1] Enrich top 20 Tier 1 accounts with full intelligence" \
    "## Task
Run Script 1 in **batch mode** to fully enrich the top 20 Tier 1 accounts.

## What to do
1. Identify top 20 priority accounts (Tier 1 staffing organizations)
2. For each account:
   - Call Clay for enrichment (tech stack, funding, headcount, key people)
   - Run web search for recent news, job postings, compliance announcements
   - Score against 3 ICPs
   - Set Next Best Action
   - Set GTM Channel classification
3. Update all Attio AI enrichment fields

## ICP Scoring
1. **Staffing Orgs (70%)** — 500+ onboards/month, multi-state, Bullhorn/Jobvite/TempWorks
2. **Platform Partners (20%)** — ATS/payroll/screening vendors
3. **Enterprise Direct (10%)** — High-volume hourly hiring

## Next Best Actions (set based on analysis)
- Has buying signals + fits ICP → \"Launch Outbound\"
- Fits ICP but no contacts → \"Build Buying Committee\"
- Partner ecosystem match → \"Partner Intro Request\"
- Missing critical data → \"Enrich Missing Data\"
- Low ICP fit → \"Nurture\" or \"Disqualify\"

## Acceptance Criteria
- [ ] 20 accounts fully enriched
- [ ] All AI fields populated
- [ ] ICP scores and rationale set
- [ ] Next Best Action assigned for each
- [ ] GTM Channel classified

## Implementation
Roadmap: **Week 1, Day 4-5**
Script: \`scripts/01_account_intelligence.py --mode batch --tier 1\`" \
    '["script-1-intelligence","week-1-foundation","high-impact","attio","clay"]' \
    "${MS1:-1}"

# ─── WEEK 2: Automation ──────────────────────────────────────────────

create_issue \
    "[Script 2] Build Buying Committees for top 10 accounts" \
    "## Task
Run Script 2 to find and create buying committee contacts for the top 10 target accounts.

## Target Personas (from Messaging Guide)
- VP of HR Operations / Director of Onboarding
- Chief People Officer / CHRO
- Head of Compliance / Risk
- Director of IT / Systems
- COO (for staffing firms — often the operational buyer)

## What to do
1. Query Attio for companies where \`next_bext_action\` = \"Build Buying Committee\"
2. For each company, search Clay for matching personas
3. Create Attio people records with: name, title, email, LinkedIn
4. Link people to company records
5. Map each person to messaging persona (HR Ops, HR Engineer, C-suite)

## Acceptance Criteria
- [ ] 10 accounts processed
- [ ] Key personas found and created in Attio
- [ ] Contacts enriched with email + LinkedIn
- [ ] People linked to company records
- [ ] Persona mapping applied

## Implementation
Roadmap: **Week 2, Day 6-7**
Script: \`scripts/02_buying_committee.py --mode batch\`" \
    '["script-2-committee","week-2-automation","attio","clay"]' \
    "${MS2:-2}"

create_issue \
    "[Script 3] Generate outbound sequences for Launch Outbound accounts" \
    "## Task
Run Script 3 to generate persona-specific email sequences for accounts flagged with NBA = \"Launch Outbound\".

## Messaging Tracks
- **HR Ops** → Speed/efficiency: \"Stop re-entering data across 5 systems\"
- **HR Engineer** → Integration/config: \"Connect any ATS to any payroll without custom code\"
- **C-suite** → ROI/risk: \"Eliminate audit failures, reduce time-to-start by 30-40%\"

## Sequence Structure
4-touch per persona:
1. Pain-aware intro (reference their ATS + industry pain)
2. Value prop + social proof
3. Competitive differentiation
4. Call-to-action with urgency

## Key Messaging Elements
- \"System of Action\" positioning
- \"30-40% improvement in time-to-start\"
- \"Data orchestration layer\" framing
- Industry-specific compliance scenarios

## Acceptance Criteria
- [ ] Sequences generated for all Launch Outbound accounts
- [ ] Each contact matched to correct persona track
- [ ] Account-specific intelligence incorporated
- [ ] Sequences pushed to ActiveCampaign with proper tags
- [ ] Tags applied: ICP tier, industry, persona, sequence version

## Implementation
Roadmap: **Week 2, Day 8-9**
Script: \`scripts/03_outbound_generator.py --mode batch\`
Config: \`templates/outbound_sequences.yaml\`, \`config/messaging_framework.yaml\`" \
    '["script-3-outbound","week-2-automation","high-impact","attio","activecampaign"]' \
    "${MS2:-2}"

create_issue \
    "[Script 4] Set up daily meeting prep automation" \
    "## Task
Configure Script 4 to run automatically at 7 AM Pacific daily.

## What to do
1. Set up scheduled execution (cron / GitHub Actions / external scheduler)
2. Configure Google Calendar API access
3. Set up Fathom transcript search in Google Drive
4. Configure Gmail API for email thread lookup
5. Set up Attio note creation for generated briefs
6. Configure Google Drive save location for briefs

## Data Flow
\`\`\`
7 AM Daily:
Google Calendar → External meetings today
  → For each attendee:
    ├── Attio: company, deal, people records
    ├── Google Drive: Fathom transcripts
    ├── Gmail: recent threads
    └── Attio: notes, tasks
  → Generate brief → Google Drive + Attio note
\`\`\`

## Acceptance Criteria
- [ ] Script runs on schedule (7 AM PT daily)
- [ ] All external meetings detected
- [ ] Multi-source data pulled correctly
- [ ] Briefs generated and saved
- [ ] Team notified (Slack or email)

## Implementation
Roadmap: **Week 2, Day 10**
Script: \`scripts/04_meeting_prep.py\` (scheduled)" \
    '["script-4-meeting-prep","week-2-automation","integration","google-drive","fathom","attio"]' \
    "${MS2:-2}"

# ─── WEEK 3: Optimization ────────────────────────────────────────────

create_issue \
    "[Script 7] Build competitive intelligence baseline" \
    "## Task
Run Script 7 to establish a baseline competitive intelligence report.

## Competitors to Track
1. **ClickBoarding** (Engage2Excel) — Legacy architecture
2. **WorkBright** — Point solution for forms
3. **Bullhorn Onboarding** — ATS-native afterthought
4. **Instawork** — Marketplace model
5. **Fountain** — High-volume hiring platform

## Tracking Signals
- New product announcements / feature releases
- Job postings (hiring = growing, roles = strategic direction)
- Press releases, funding announcements
- Customer wins/losses mentioned publicly
- Pricing changes

## Outputs
- Competitive positioning matrix in Google Drive
- Initial competitor profiles with our differentiation
- Weekly briefing template ready for recurring runs

## Acceptance Criteria
- [ ] All 5 competitors researched
- [ ] Competitive matrix created
- [ ] Differentiation talking points documented
- [ ] Report saved to Google Drive
- [ ] Fathom transcripts scanned for competitor mentions

## Implementation
Roadmap: **Week 3, Day 11-12**
Script: \`scripts/07_competitive_intel.py\`
Config: \`config/competitive_landscape.yaml\`" \
    '["script-7-competitive","week-3-optimization","google-drive"]' \
    "${MS3:-3}"

create_issue \
    "[Script 6] Set up weekly pipeline health monitor → Slack" \
    "## Task
Configure Script 6 to run every Monday morning and post results to Slack.

## What to do
1. Set up scheduled execution (Monday mornings)
2. Configure Slack webhook for pipeline alerts channel
3. Define alert formatting and severity levels
4. Set up Google Drive report storage
5. Test end-to-end flow

## Alert Examples
- \"Deal X has been in Discovery for 23 days with no activity — schedule follow-up?\"
- \"Deal Y is missing a technical contact — run Buying Committee Builder?\"
- \"3 deals are in Redlines with no close date set\"

## Acceptance Criteria
- [ ] Script runs weekly on Monday AM
- [ ] Slack messages formatted and actionable
- [ ] Google Drive report generated
- [ ] Alert thresholds tuned to pipeline velocity benchmarks
- [ ] Team can respond to alerts from Slack

## Implementation
Roadmap: **Week 3, Day 13**
Script: \`scripts/06_pipeline_health.py\` (scheduled)" \
    '["script-6-pipeline","week-3-optimization","slack","attio"]' \
    "${MS3:-3}"

create_issue \
    "[Script 1] Tune ICP scoring model based on team feedback" \
    "## Task
Refine the ICP scoring logic in Script 1 based on team review of initial enrichment results.

## What to do
1. Review Script 1 results from Week 1 (top 20 accounts)
2. Gather team feedback via \`gtm_feedback_status\` field in Attio
3. Identify scoring patterns that need adjustment:
   - False positives (scored high but not a good fit)
   - False negatives (scored low but should be prioritized)
   - Missing signals that indicate fit
4. Update ICP scoring weights and criteria
5. Re-run on feedback accounts to validate

## Feedback Loop
\`\`\`
Attio gtm_feedback_status:
  Pending Review → Team reviews enrichment
  Approved → Scoring was accurate
  Rejected → Scoring was wrong (capture why)
  Needs Update → Partial accuracy, needs refinement
\`\`\`

## Acceptance Criteria
- [ ] Team feedback collected on initial enrichment
- [ ] Scoring patterns analyzed
- [ ] ICP criteria updated in config
- [ ] Re-scored accounts show improved accuracy
- [ ] Changes documented

## Implementation
Roadmap: **Week 3, Day 14-15**
Script: \`scripts/01_account_intelligence.py\` (refinement)
Config: \`config/icp_definitions.yaml\`" \
    '["script-1-intelligence","week-3-optimization","attio"]' \
    "${MS3:-3}"

# ─── WEEK 4+: Scale ──────────────────────────────────────────────────

create_issue \
    "[Script 8] Event GTM prep for upcoming conferences" \
    "## Task
Set up Script 8 for the first upcoming conference/event.

## Target Events
- Unleash 2026 (HR Tech Conference)
- Transform 2026 (Staffing Industry)
- SIA Executive Forum (Staffing Industry Analysts)
- ASA Staffing World (American Staffing Association)

## Pre-Event Workflow
1. Import/enrich attendee lists
2. Score attendees against ICPs
3. Generate personalized pre-event outreach
4. Create meeting requests for target accounts
5. Generate account briefs for scheduled meetings

## Post-Event Workflow
1. Import badge scans / meeting notes
2. Create Attio records for new contacts
3. Trigger follow-up sequences via ActiveCampaign
4. Score and prioritize event leads
5. Generate event ROI report

## Acceptance Criteria
- [ ] Pre-event workflow tested with sample data
- [ ] Post-event workflow tested with sample data
- [ ] ActiveCampaign event tags configured
- [ ] Event-specific messaging templates created

## Implementation
Roadmap: **Week 4+**
Script: \`scripts/08_event_gtm.py\`" \
    '["script-8-event","week-4-scale","activecampaign","attio","clay"]' \
    "${MS4:-4}"

create_issue \
    "[Script 1] Expand enrichment to all active accounts" \
    "## Task
Run Script 1 full batch to enrich all active accounts, not just Tier 1.

## What to do
1. Remove tier filter — process all companies with stale/empty AI fields
2. Set batch processing with rate limiting
3. Monitor Clay credit usage
4. Track enrichment quality across tiers

## Acceptance Criteria
- [ ] All active accounts enriched
- [ ] Credit usage within budget
- [ ] Quality maintained across tiers
- [ ] NBA set for all accounts

## Implementation
Roadmap: **Week 4+**
Script: \`scripts/01_account_intelligence.py --mode batch\`" \
    '["script-1-intelligence","week-4-scale","attio","clay"]' \
    "${MS4:-4}"

create_issue \
    "[Script 3] Refine outbound sequences based on reply/meeting rates" \
    "## Task
Analyze outbound sequence performance and iterate on messaging.

## What to do
1. Pull ActiveCampaign metrics: open rates, reply rates, meeting conversion
2. Segment by persona, industry, and ICP tier
3. Identify top/bottom performing sequences
4. A/B test subject lines and messaging angles
5. Update sequence templates

## Acceptance Criteria
- [ ] Performance data pulled from ActiveCampaign
- [ ] Analysis by persona and industry complete
- [ ] Top/bottom performers identified
- [ ] Updated sequences deployed
- [ ] A/B test framework in place

## Implementation
Roadmap: **Week 4+**
Script: \`scripts/03_outbound_generator.py\` (iteration)" \
    '["script-3-outbound","week-4-scale","activecampaign"]' \
    "${MS4:-4}"

create_issue \
    "Build partner-specific workflows" \
    "## Task
Create specialized workflows for Platform Partner ICP (ATS vendors, payroll providers, screening vendors).

## Context
Onboarded's partner strategy is evolving:
- Past 2.5 years: stealth, white-label/reseller/channel-only
- Current: adding direct sales motion
- Partnership pitches:
  - To ATS vendors: \"If the ATS changes, the integration persists through our layer\"
  - To screening vendors: \"Stable integration regardless of client's ATS\"
  - Key: \"We do the integration work — we don't ask partners to build integrations\"

## What to build
1. Partner-specific enrichment criteria in Script 1
2. Partner buying committee personas in Script 2
3. Partner outreach messaging in Script 3
4. Partner deal pipeline tracking in Script 6
5. Partner event workflows in Script 8

## Acceptance Criteria
- [ ] Partner ICP criteria refined
- [ ] Partner personas defined and searchable
- [ ] Partner messaging sequences created
- [ ] Partner pipeline metrics tracked
- [ ] Integration with partner-specific events

## Implementation
Roadmap: **Week 4+**" \
    '["week-4-scale","data-flow"]' \
    "${MS4:-4}"

# ─── DECISIONS NEEDED ────────────────────────────────────────────────

create_issue \
    "[Decision] Outbound mechanics — who sends, domain warmup, daily limits" \
    "## Decision Needed
Clarify outbound email execution details before Script 3 can be fully deployed.

## Questions
1. **Who on the team is doing outbound?** (Derek + Nate + Meg?)
2. **ActiveCampaign warm-up status** — are sending domains warm?
3. **Daily send limit preferences?**
4. **Using LinkedIn Sales Navigator for outbound?**

## Impact
- Script 3 (Outbound Generator) needs sender assignments
- ActiveCampaign sequence setup depends on domain warmup status
- Send limits affect batch sizing

## Deadline
Before Week 2 (outbound launch)" \
    '["decision-needed","script-3-outbound"]' \
    "${MS2:-2}"

create_issue \
    "[Decision] Deal velocity benchmarks — validate stage timing" \
    "## Decision Needed
Validate or adjust pipeline velocity benchmarks used by Script 6.

## Proposed Benchmarks
| Stage | Expected Max Days | Stall Alert |
|-------|------------------|-------------|
| Lead | 14 | 7 days no activity |
| Intro Call | 7 | 5 days no meeting |
| Discovery | 21 | 10 days no activity |
| Solutioning | 30 | 14 days no activity |
| Redlines | 21 | 7 days no activity |

## Questions
1. Do these day counts feel right?
2. What's the current average deal cycle time?
3. How many active deals are in pipeline today?

## Impact
- Script 6 alert thresholds
- Pipeline health scoring accuracy

## Deadline
Before Week 1 (pipeline health scan)" \
    '["decision-needed","script-6-pipeline"]' \
    "${MS1:-1}"

create_issue \
    "[Decision] Fathom folder structure and naming conventions" \
    "## Decision Needed
Understand Fathom transcript storage to build reliable Script 4/5 search.

## Questions
1. Are Fathom transcripts in a **specific Google Drive folder**, or scattered?
2. Any **naming convention** for Fathom docs?
3. Are **internal-only calls** also in Fathom, or just external?

## Impact
- Script 4 (Meeting Prep) needs to reliably find transcripts
- Script 5 (Post-Meeting) needs to match transcripts to meetings
- Affects Google Drive search logic

## Deadline
Before Week 1 Day 2 (meeting prep)" \
    '["decision-needed","script-4-meeting-prep","script-5-post-meeting","fathom","google-drive"]' \
    "${MS1:-1}"

create_issue \
    "[Decision] Team task assignments — who gets what from automation" \
    "## Decision Needed
Define task routing for automated post-meeting action items and pipeline alerts.

## Questions
1. Which team members should receive which types of **Attio tasks** from Script 5?
2. Who **reviews enrichment data** for accuracy (GTM Feedback Status loop)?
3. Who **manages ActiveCampaign sequences** once generated?

## Impact
- Script 5 task creation and assignment
- GTM Feedback Status workflow
- Script 3 sequence management

## Deadline
Before Week 2 (automation launch)" \
    '["decision-needed","script-5-post-meeting","script-3-outbound"]' \
    "${MS2:-2}"

create_issue \
    "[Decision] Clay credit budget and API rate limits" \
    "## Decision Needed
Set budget and rate limits for enrichment automation.

## Questions
1. **Clay credit budget per month** for enrichment?
2. Any **limits on API calls / automation frequency**?

## Impact
- Script 1 batch sizing and scheduling
- Script 2 persona search volume
- Overall enrichment coverage

## Deadline
Before Week 1 Day 4 (batch enrichment)" \
    '["decision-needed","script-1-intelligence","script-2-committee","clay"]' \
    "${MS1:-1}"

# ─── ARCHITECTURE / INTEGRATION ISSUES ──────────────────────────────

create_issue \
    "Set up Fathom → Google Drive → Attio integration pipeline" \
    "## Task
Build the core Fathom integration that powers Scripts 4 and 5.

## Integration Flow
\`\`\`
Fathom records call
  → Auto-saves transcript as Google Doc in Drive
  → Claude reads transcript via Google Drive API
  → Extracts: decisions, action items, objections, next steps
  → Updates Attio: deal stage, notes, fields, tasks
  → Drafts follow-up email
  → Creates Attio tasks for team members
\`\`\`

## Steps
1. Identify Fathom transcript format and folder location
2. Build Google Drive search/read capability
3. Build Claude transcript processing prompt
4. Build Attio note creation + deal update logic
5. Build task creation with assignee routing
6. Test end-to-end with real transcript

## Acceptance Criteria
- [ ] Can reliably find Fathom transcripts in Google Drive
- [ ] Transcript parsing extracts all target fields
- [ ] Attio records updated correctly
- [ ] Tasks created with proper assignments
- [ ] Follow-up email drafts generated

## This is the highest-impact integration in the entire system." \
    '["integration","data-flow","high-impact","fathom","google-drive","attio"]' \
    "${MS1:-1}"

create_issue \
    "Set up Attio → ActiveCampaign sequence trigger pipeline" \
    "## Task
Build the integration that triggers outbound sequences when accounts are ready.

## Integration Flow
\`\`\`
Attio NBA = \"Launch Outbound\"
  → Script 3 generates persona-specific sequences
  → ActiveCampaign receives contacts + sequences + tags
  → Sends on configured cadence
  → Replies tracked in Gmail
  → Meeting booked → Calendar → Meeting Loop
\`\`\`

## Steps
1. Build Attio NBA query (filter: next_bext_action = \"Launch Outbound\")
2. Build ActiveCampaign API integration (create contacts, add to automations)
3. Configure tag structure (ICP tier, industry, persona, sequence version)
4. Test with sample account
5. Set up reply tracking feedback loop

## Acceptance Criteria
- [ ] Attio query returns correct accounts
- [ ] Contacts created/updated in ActiveCampaign
- [ ] Sequences assigned correctly
- [ ] Tags applied properly
- [ ] Reply tracking configured" \
    '["integration","data-flow","attio","activecampaign"]' \
    "${MS2:-2}"

create_issue \
    "Configure environment and API credentials" \
    "## Task
Set up all API connections needed for the GTM Engine.

## APIs to Configure
- [ ] **Attio** — API key, verify schema access
- [ ] **Clay** — API key, verify enrichment endpoints
- [ ] **ActiveCampaign** — API key + URL, verify automation access
- [ ] **Google APIs** — Service account for Drive, Calendar, Gmail
- [ ] **Slack** — Webhook URL for alerts channel
- [ ] **Anthropic** — Claude API key for intelligence processing

## Steps
1. Create \`.env\` from \`.env.example\`
2. Obtain/verify each API key
3. Test each connection individually
4. Verify Attio schema matches \`config/attio_schema.yaml\`
5. Verify Google Drive Fathom folder access

## Acceptance Criteria
- [ ] All API keys obtained and tested
- [ ] \`.env\` file configured (not committed to git)
- [ ] Each integration verified independently
- [ ] Attio schema validated" \
    '["week-1-foundation","integration","quick-win"]' \
    "${MS1:-1}"

log "All issues created!"

###############################################################################
# STEP 6: Create GitHub Project Board
###############################################################################
echo ""
info "Creating GitHub Project board..."

# Create project using Projects V2 GraphQL API
PROJECT_QUERY='mutation { createProjectV2(input: {ownerId: "USER_ID", title: "Onboarded GTM Engine — Implementation Roadmap"}) { projectV2 { id number url } } }'

# Get user node ID first
USER_NODE_ID=$(curl -sf -H "$AUTH" -H "$ACCEPT" "$API/user" | jq -r '.node_id')

PROJECT_RESULT=$(curl -sf -H "$AUTH" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"mutation { createProjectV2(input: {ownerId: \\\"$USER_NODE_ID\\\", title: \\\"Onboarded GTM Engine — Implementation Roadmap\\\"}) { projectV2 { id number url } } }\"}" \
    "https://api.github.com/graphql" 2>/dev/null)

PROJECT_URL=$(echo "$PROJECT_RESULT" | jq -r '.data.createProjectV2.projectV2.url // empty')

if [ -n "$PROJECT_URL" ]; then
    log "Project board created: $PROJECT_URL"
else
    warn "Project board creation skipped (may need 'project' scope on token)"
    warn "You can create it manually at: https://github.com/$REPO_FULL/projects"
fi

###############################################################################
# DONE
###############################################################################
echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}  Setup complete!${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Repository:  https://github.com/$REPO_FULL"
echo "  Issues:      https://github.com/$REPO_FULL/issues"
echo "  Milestones:  https://github.com/$REPO_FULL/milestones"
[ -n "${PROJECT_URL:-}" ] && echo "  Project:     $PROJECT_URL"
echo ""
echo "  Next steps:"
echo "  1. Review issues and assign team members"
echo "  2. Configure API keys (.env.example → .env)"
echo "  3. Start with Week 1 foundation tasks"
echo ""
