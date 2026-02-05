# Post-Meeting Summary: {{ company_name }}
**Meeting:** {{ meeting_title }}
**Date:** {{ meeting_date }}
**Attendees:** {{ attendee_names }}
**Transcript Source:** Fathom → Google Drive

---

## Decisions Made
{{ #each decisions }}
- {{ this }}
{{ /each }}

## Action Items
| Owner | Task | Deadline | Status |
|-------|------|----------|--------|
{{ #each action_items }}
| {{ owner }} | {{ task }} | {{ deadline }} | Pending |
{{ /each }}

## Objections / Concerns Raised
{{ #each objections }}
- **{{ raised_by }}:** {{ concern }}
  - **Suggested response:** {{ suggested_response }}
{{ /each }}

## Competitive Mentions
{{ #each competitive_mentions }}
- **{{ competitor }}** — Context: {{ context }}
{{ /each }}

## Technical Requirements Discussed
- **Current ATS:** {{ current_ats }}
- **Integrations Needed:** {{ integrations }}
- **Volume:** {{ onboarding_volume }}
- **Other:** {{ other_technical }}

## Next Steps
{{ #each next_steps }}
1. **{{ action }}** — Owner: {{ owner }}, By: {{ timing }}
{{ /each }}

## Deal Stage Signal
- **Current Stage:** {{ current_stage }}
- **Recommended:** {{ recommended_stage }}
- **Reasoning:** {{ stage_reasoning }}

## New Stakeholders Identified
{{ #each new_stakeholders }}
- **{{ name }}** — {{ title }} ({{ role_in_deal }})
{{ /each }}

---

## Follow-Up Email Draft
{{ follow_up_email_draft }}

---

*Processed by Onboarded GTM Engine — Script 5 (Post-Meeting Processor)*
