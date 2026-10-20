## What does this PR do?

<!-- One or two sentences. What changed and why. -->

Closes #

## Type

- [ ] Feature
- [ ] Bug fix
- [ ] Chore / tooling
- [ ] Docs
- [ ] Contract change (needs **1 frontend + 1 backend** approval)

## How did you test it?

<!-- Be specific. "It works" is not testing.
     UI    -> what you clicked, and screenshots below
     API   -> the actual request and response, pasted
     Both  -> which browser / which tool -->

## Evidence

<!-- UI: screenshots or a short recording. Include the empty and error states.
     API: paste the request + response.
     A PR that changes the UI with no screenshot will be sent back. -->

## Checklist

- [ ] Branched from the latest `dev`, and targets `dev`
- [ ] `npm run build` passes locally
- [ ] `npx tsc --noEmit` is clean — no new `any`
- [ ] Lint passes
- [ ] CI is green
- [ ] Loading, error, and empty states handled (UI) / all error paths return the
      contract's error shape (API)
- [ ] Matches the merged API contract exactly — path, method, field names, status codes
- [ ] Ownership / permission checked, if this mutates data
- [ ] `.env.example` updated, if a variable was added
- [ ] No secrets, no `console.log`, no commented-out dead code
- [ ] Acceptance criteria in the linked issue are all met

## Anything the reviewer should know?

<!-- Known gaps, a decision you were unsure about, a follow-up ticket you filed. -->
