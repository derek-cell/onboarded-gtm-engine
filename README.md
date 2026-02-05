# Onboarded GTM Engine v2

**Revised Architecture — Data-Informed, Production-Ready**

A 7-engine GTM automation system for Onboarded, built on Attio CRM, Fathom call intelligence, Google Drive, ActiveCampaign, Clay, and Claude.

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                    ONBOARDED GTM ENGINE v2                        │
│              (Notion-Free / Fathom-Powered / Attio-Native)       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. INTELLIGENCE    →  Enrich via existing Attio AI fields       │
│  2. SCORING         →  ICP fit + buying signals → Next Action    │
│  3. OUTBOUND        →  Persona-specific sequences via AC         │
│  4. PIPELINE OPS    →  Deal progression + task automation        │
│  5. MEETING INTEL   →  Fathom transcripts ↔ Attio ↔ Briefs     │
│  6. COMPETITIVE     →  Web monitoring → Google Drive reports     │
│  7. REPORTING       →  Pipeline health → Slack summaries         │
│                                                                  │
│  DATA FLOWS:                                                     │
│  Fathom → Google Drive → Claude reads → Attio updates           │
│  Clay → Attio enrichment fields (existing schema)               │
│  Attio signals → ActiveCampaign sequences                       │
│  Calendar → Meeting detection → Pre/post call automation        │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## The 8 Scripts

| # | Script | Description | Trigger |
|---|--------|-------------|---------|
| 1 | Account Intelligence Engine | Enrich companies via Clay + web, fill Attio AI fields, score ICP fit | On-demand / Weekly batch |
| 2 | Buying Committee Builder | Find personas via Clay, create Attio people records | NBA = "Build Buying Committee" |
| 3 | Personalized Outbound Generator | Generate persona-specific email sequences → ActiveCampaign | NBA = "Launch Outbound" |
| 4 | Meeting Prep Brief | Pull calendar + Attio + Fathom + Gmail → generate prep briefs | Daily 7 AM PT / On-demand |
| 5 | Post-Meeting Processor | Read Fathom transcripts → extract decisions/actions → update Attio | After meetings / Daily 6 PM PT |
| 6 | Pipeline Health Monitor | Analyze deal velocity, stalls, gaps → Slack alerts | Weekly Monday AM |
| 7 | Competitive Intelligence Tracker | Monitor competitors via web → Google Drive reports → Slack | Weekly |
| 8 | Event GTM Orchestrator | Pre/post event workflows for conferences | Around event dates |

## Stack

| Tool | Role |
|------|------|
| **Attio** | CRM — companies, people, deals (76 company attrs, 26 deal attrs) |
| **Clay** | Contact/company enrichment |
| **ActiveCampaign** | Email marketing & sequences |
| **Fathom** | Call recording → transcripts auto-save to Google Drive |
| **Google Drive** | Docs, Fathom transcripts, strategy docs, competitive intel |
| **Gmail + Calendar** | Email tracking, meeting detection |
| **Slack** | Alerts, deal notifications, weekly reports |
| **Atlassian** | Sprint management |

## ICP Definitions

1. **Staffing Organizations (70%)** — 500+ onboards/month, multi-state, Bullhorn/Jobvite/TempWorks
2. **Platform Partners (20%)** — ATS/payroll/screening vendors wanting embedded onboarding
3. **Enterprise Direct (10%)** — High-volume hourly hiring (healthcare, logistics, retail)

## Pipeline Stages

```
Lead → Intro Call → Discovery "Fit" → Solutioning/Tech → Redlines → Won 🎉
                                                                    → Lost
                                                                    → In Progress
```

## Implementation Roadmap

- **Week 1:** Foundation — enrichment audit, pipeline health scan, meeting prep, Fathom backfill
- **Week 2:** Automation — buying committees, outbound sequences, daily meeting prep
- **Week 3:** Optimization — competitive intel baseline, weekly pipeline monitor, scoring refinement
- **Week 4+:** Scale — event GTM, full enrichment, outbound iteration, partner workflows

## Directory Structure

```
onboarded-gtm-engine/
├── README.md
├── scripts/
│   ├── 01_account_intelligence.py
│   ├── 02_buying_committee.py
│   ├── 03_outbound_generator.py
│   ├── 04_meeting_prep.py
│   ├── 05_post_meeting_processor.py
│   ├── 06_pipeline_health.py
│   ├── 07_competitive_intel.py
│   └── 08_event_gtm.py
├── config/
│   ├── icp_definitions.yaml
│   ├── attio_schema.yaml
│   ├── messaging_framework.yaml
│   ├── pipeline_stages.yaml
│   └── competitive_landscape.yaml
├── templates/
│   ├── meeting_prep_brief.md
│   ├── post_meeting_summary.md
│   ├── outbound_sequences.yaml
│   ├── pipeline_health_report.md
│   └── competitive_report.md
└── .github/
    └── ISSUE_TEMPLATE/
        ├── script_task.md
        └── decision_needed.md
```

## Configuration

All API keys and secrets should be set as environment variables:

```bash
export ATTIO_API_KEY="your-attio-key"
export CLAY_API_KEY="your-clay-key"
export ACTIVECAMPAIGN_API_KEY="your-ac-key"
export ACTIVECAMPAIGN_URL="your-ac-url"
export GOOGLE_SERVICE_ACCOUNT_KEY="/path/to/service-account.json"
export SLACK_WEBHOOK_URL="your-slack-webhook"
export ANTHROPIC_API_KEY="your-claude-key"
```

## Getting Started

1. Clone this repo
2. Copy `.env.example` to `.env` and fill in API keys
3. Install dependencies: `pip install -r requirements.txt`
4. Run individual scripts or set up scheduled execution

See individual script files for detailed usage and Claude Code prompts.

---

*Generated from Onboarded GTM Blueprint v2 — February 2026*
