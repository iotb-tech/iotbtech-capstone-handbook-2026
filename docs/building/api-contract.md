# 08 — The API Contract

> **Read this if:** you build **or** consume an endpoint — frontend and backend both.  
> **Skip if:** Nobody. This is the one document the two repos share.  
> **~8 min.** Long code and setup blocks are collapsed — expand what you need.

Two repos, two groups of developers, one interface between them. The contract is
that interface, written down and agreed **before** either side builds against
it.

**LocalLink already does this** — they have a `contract/` package in their
backend repo holding shared types and constants. This document generalises their
approach for every team.

---

## Why this exists

Without a contract, this happens in week 2 of every student project:

> FE built the card expecting `{ name, amount }`. BE shipped
> `{ title, price }`. Three days of work, a tense call, and somebody rewrites
> an afternoon's code.

With a contract, the shape is agreed in a 15-minute conversation, written into
one file, reviewed by both sides, and then **both sides build in parallel
without talking to each other again.** The frontend does not wait for the
backend; it builds against a mock of the agreed shape
([06](frontend.md#working-before-the-backend-exists)).

**The contract changes before the code does.** This is the single rule.

---

## The golden sequence

```
1. FE says what the screen needs           (handoff 4 in 05)
2. BE and FE agree the shape               (15-minute conversation)
3. Contract PR  — 1 FE + 1 BE approval     ← merges FIRST
4. BE implements the endpoint, deploys to staging
5. FE swaps the mock for the real call
```

Skipping step 3 is what causes the problem above. It is also an instant
request-changes on review.

---

## Where it lives

In the **backend** repo, at `src/contract/`, and copied into the frontend's
`src/types/` + `src/lib/routes.ts`.

```
src/contract/
├── index.ts          # re-exports everything
├── constants.ts      # route paths, error codes, enums
├── common.ts         # the response envelope, pagination
├── listing.ts        # one file per domain
└── user.ts
```

Keeping it in the backend repo makes ownership clear: the server defines what it
serves. Keeping a **copy** in the frontend keeps the frontend typed without a
package registry.

> Copying by hand means it can drift. Two defences: the contract PR always
> states "FE copy updated in `<frontend PR link>`", and a drift check is part of
> the integration checkpoint. (Publishing it as a private npm package is the
> professional answer — out of scope for nine days.)

---

## Response envelope — identical for every endpoint

Every success:

```json
{ "data": <the thing>, "meta": { } }
```

Every list:

```json
{
  "data": [ ... ],
  "meta": { "page": 1, "pageSize": 20, "total": 137 }
}
```

Every error:

```json
{ "error": { "code": "VALIDATION_ERROR", "message": "Price must be greater than zero", "field": "price" } }
```

Three rules:

1. **Never return a bare array.** `[ ... ]` at the top level leaves nowhere to
   put pagination later without breaking every caller.
2. **`message` is shown to users.** Write it for a human: "Price must be greater
   than zero", not "ZodError: expected number".
3. **`code` is for code.** The frontend branches on `code`, never on `message`.

```ts
// src/contract/common.ts
export type ApiSuccess<T> = { data: T; meta?: Record<string, unknown> };
export type ApiList<T>    = { data: T[]; meta: { page: number; pageSize: number; total: number } };
export type ApiError      = { error: { code: ErrorCode; message: string; field?: string } };
```

---

## Status codes

| Code | When | Not when |
|---|---|---|
| `200` | Successful GET / PATCH / DELETE | — |
| `201` | Created — returns the created resource | Don't use 200 for a create |
| `400` | Validation failed | Not for "not signed in" |
| `401` | Not signed in / bad session | Not for "signed in but not allowed" |
| `403` | Signed in, but not allowed to do this | — |
| `404` | Resource does not exist | — |
| `409` | Conflict — duplicate email, slot already booked | — |
| `422` | Semantically invalid but well-formed (optional; 400 is fine) | — |
| `500` | Your bug | Never for a user mistake |

**401 vs 403 is a real distinction and reviewers check it.** 401 = we don't know
who you are. 403 = we know, and no.

---

## Error codes

Fixed list. Add to it by PR, do not invent codes inline.

/// details | src/contract/constants.ts — error codes
    type: example

```ts
// src/contract/constants.ts
export const ERROR_CODES = {
  VALIDATION_ERROR: "VALIDATION_ERROR",
  UNAUTHORIZED:     "UNAUTHORIZED",
  FORBIDDEN:        "FORBIDDEN",
  NOT_FOUND:        "NOT_FOUND",
  CONFLICT:         "CONFLICT",
  INTERNAL_ERROR:   "INTERNAL_ERROR",
} as const;

export type ErrorCode = (typeof ERROR_CODES)[keyof typeof ERROR_CODES];
```
///

---

## Route constants

Paths are defined once, so a rename is one edit instead of a grep across two
repos.

/// details | src/contract/constants.ts — route paths
    type: example

```ts
// src/contract/constants.ts
export const API_PREFIX = "/api/v1";

export const ROUTES = {
  listings: {
    list:   "/listings",
    create: "/listings",
    detail: (id: string) => `/listings/${id}`,
    update: (id: string) => `/listings/${id}`,
    remove: (id: string) => `/listings/${id}`,
  },
} as const;
```
///

Version the prefix (`/api/v1`) from the start. It costs nothing now and you will
be glad of it the first time a shape has to change.

---

## Types per domain

/// details | src/contract/listing.ts
    type: example

```ts
// src/contract/listing.ts
export type ListingStatus = "ACTIVE" | "SOLD" | "DRAFT";

export type Listing = {
  id: string;
  title: string;
  description: string;
  price: number;            // integer, kobo. see 07.
  status: ListingStatus;
  category: string;
  ownerId: string;
  createdAt: string;        // ISO 8601 string, not a Date
  updatedAt: string;
};

export type CreateListingInput = Pick<
  Listing, "title" | "description" | "price" | "category"
>;

export type UpdateListingInput = Partial<CreateListingInput> & {
  status?: ListingStatus;
};

export type ListListingsQuery = {
  status?: ListingStatus;
  search?: string;
  page?: number;
  pageSize?: number;
};
```
///

Conventions that prevent the most common integration bugs:

- **Dates are ISO 8601 strings**, never `Date`. JSON has no date type; `Date`
  in a shared type is a lie that breaks the moment it crosses the wire.
- **Money is an integer** in the smallest unit.
- **`camelCase` everywhere** — both sides, no exceptions, no `snake_case`
  leaking out of SQL.
- **Enums are `SCREAMING_CASE` string unions** matching the Prisma enum exactly.
- Input types derive from the entity with `Pick`/`Partial` — one source of truth.

---

## A contract entry, in full

This is what a contract PR adds. Write it in `docs/api.md` (or the
`API_CONTRACT.md` template) alongside the types.

/// details | A full contract entry
    type: example

```md
### GET /api/v1/listings

List active listings, newest first. Paginated.

**Auth:** optional. Signed-in users also see their own DRAFT listings.

**Query**
| Param | Type | Default | Notes |
|---|---|---|---|
| `status` | `ACTIVE \| SOLD \| DRAFT` | — | omit for all visible |
| `search` | string | — | case-insensitive match on title |
| `page` | number | 1 | min 1 |
| `pageSize` | number | 20 | max 100 |

**200**
{ "data": [ { "id": "clz1", "title": "Study desk", "price": 2500000,
             "status": "ACTIVE", "category": "furniture",
             "ownerId": "clu9", "createdAt": "2026-10-18T09:12:00Z",
             "updatedAt": "2026-10-18T09:12:00Z" } ],
  "meta": { "page": 1, "pageSize": 20, "total": 37 } }

**400** VALIDATION_ERROR — `page` or `pageSize` out of range
**500** INTERNAL_ERROR

**Owner:** @backend-dev   **FE consumer:** @frontend-dev   **Status:** agreed / built / deployed
```
///

That last line matters more than it looks. `agreed` means the FE can start
mocking. `deployed` means the FE can switch the flag. Nobody has to ask.

---

## Changing the contract once it is built

Two kinds of change:

**Additive — safe.** Adding an optional field, a new optional query param, a new
endpoint. Contract PR, merge, implement. Nothing breaks.

**Breaking — needs coordination.** Renaming or removing a field, changing a
type, changing a status code. Procedure:

1. Contract PR describing the change **and who it breaks**.
2. Both FE and BE approve. The PM is informed — it is rework and affects the
   schedule.
3. Merge contract -> ship backend -> ship frontend, **in that order**, within
   the same day if you can. Cross-link all three PRs.
4. If it cannot be same-day: support both shapes temporarily (return old and new
   field), then remove the old one in a follow-up. This is what professionals
   do, and it is worth a Demo Day slide.

**Never silently change a shape.** A backend dev renaming `price` to `amount`
without a contract PR will break the frontend with no warning, and the frontend
dev will spend an hour assuming their own code broke.

---

## Checklist for a contract PR

- [ ] Types added/updated in `src/contract/`
- [ ] Written entry: path, method, auth, params, success example, every error
- [ ] Field names `camelCase`; dates ISO strings; money integer
- [ ] Status codes correct — especially 401 vs 403
- [ ] Pagination included on every list endpoint, with a max `pageSize`
- [ ] Error codes drawn from `ERROR_CODES` only
- [ ] **1 FE approval + 1 BE approval**
- [ ] Labelled `area:contract`
- [ ] Frontend copy updated (linked PR)
- [ ] Breaking? Migration plan stated, PM informed
