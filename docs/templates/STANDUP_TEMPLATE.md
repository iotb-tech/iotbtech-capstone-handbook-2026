# Standup

Post this in the team channel. **Every other day minimum — daily is better.**
Every member, including PM, designer, and DevOps.

Three lines. Two minutes.

```
Yesterday:
Today:
Blocked:
```

## Why it is not busywork

- It is how the person who can unblock you finds out you are stuck.
- It is the written record of who was working, which feeds directly into
  individual assessment (standards/definition-of-done.md).
- It catches a stalled ticket days before a checkpoint instead of on Demo Day.

## Good

```
Yesterday: finished the create-listing form, PR #23 open for review
Today:     wiring POST /listings now the contract is merged
Blocked:   nothing
```

```
Yesterday: drew the booking detail screen, all 4 states, pushed to Figma
Today:     mobile breakpoints for browse + detail
Blocked:   need @PM to confirm whether cancelled bookings show in history
```

```
Yesterday: staging API deployed, health check green; CI passing on both repos
Today:     Vercel preview env vars, then the reviewer-assign workflow
Blocked:   waiting on @backend for the final env var list (asked yesterday)
```

```
Yesterday: nothing — exams
Today:     back on the listing detail page
Blocked:   nothing
```

That last one is fine. Honest is better than absent.

## Not good

```
Yesterday: worked on frontend
Today:     continue
Blocked:   no
```

Nobody can help with "worked on frontend", and it proves nothing at
assessment time. Name the ticket, name the PR, name the person you need.

## Rules

- **Blocked is specific**, with a name: who or what you need.
- **Do not sit on a blocker for more than 2 hours** — post it and switch
  tickets while you wait.
- **Never fabricate a standup.** It is checked against what actually shipped.
- The Tech Lead reads these and owns anything still `blocked` after a day.
