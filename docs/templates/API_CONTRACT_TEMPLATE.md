# <PRODUCT> — API Contract

**Base URL**

| Environment | URL |
|---|---|
| Local | `http://localhost:4000/api/v1` |
| Staging | `https://<product>-api-staging.up.railway.app/api/v1` |
| Production | `https://<product>-api.up.railway.app/api/v1` |

**The contract changes before the code does.** A contract PR needs **one
frontend and one backend approval**. See building/api-contract.md.

---

## Conventions

- Success: `{ "data": <thing>, "meta": {} }` — never a bare array
- List: `{ "data": [...], "meta": { "page", "pageSize", "total" } }`
- Error: `{ "error": { "code", "message", "field?" } }`
- `message` is shown to users. `code` is what the frontend branches on.
- `camelCase` fields. Dates are ISO 8601 **strings**. Money is an **integer** in
  the smallest unit (kobo).
- Enums are `SCREAMING_CASE`, matching the Prisma enum exactly.

## Error codes

| Code | Status | Meaning |
|---|---|---|
| `VALIDATION_ERROR` | 400 | Bad input. `field` names the offender. |
| `UNAUTHORIZED` | 401 | Not signed in / bad session |
| `FORBIDDEN` | 403 | Signed in, but not allowed |
| `NOT_FOUND` | 404 | Does not exist |
| `CONFLICT` | 409 | Duplicate, or state collision |
| `INTERNAL_ERROR` | 500 | Our bug |

## Endpoint status

| Endpoint | Owner | FE consumer | Status |
|---|---|---|---|
| `GET /listings` | @ | @ | agreed / built / deployed |

`agreed` = frontend may start mocking. `deployed` = frontend may switch off the
mock. Keep this table current — it is how people avoid asking.

---

# Endpoints

<!-- Copy the block below for each endpoint. -->

## GET /listings

<!-- One line: what it returns and in what order. -->

**Auth:** none / required / optional (what changes if signed in)

**Query**

| Param | Type | Required | Default | Notes |
|---|---|---|---|---|
| `status` | `ACTIVE \| SOLD \| DRAFT` | no | — | |
| `search` | string | no | — | case-insensitive, matches title |
| `page` | number | no | 1 | min 1 |
| `pageSize` | number | no | 20 | **max 100** |

**200**

```json
{
  "data": [
    {
      "id": "clz1abc",
      "title": "Study desk",
      "price": 2500000,
      "status": "ACTIVE",
      "ownerId": "clu9xyz",
      "createdAt": "2026-10-18T09:12:00Z"
    }
  ],
  "meta": { "page": 1, "pageSize": 20, "total": 37 }
}
```

**Errors**

| Status | Code | When |
|---|---|---|
| 400 | `VALIDATION_ERROR` | `page` or `pageSize` out of range |
| 500 | `INTERNAL_ERROR` | — |

---

## POST /listings

**Auth:** required

**Body**

```json
{ "title": "Study desk", "description": "Barely used", "price": 2500000, "category": "furniture" }
```

| Field | Type | Required | Rules |
|---|---|---|---|
| `title` | string | yes | 5–100 chars |
| `description` | string | yes | min 20 chars |
| `price` | integer | yes | > 0, kobo |
| `category` | string | yes | one of the agreed categories |

**201** — returns the created listing in `data`.

**Errors**

| Status | Code | When |
|---|---|---|
| 400 | `VALIDATION_ERROR` | any field rule fails; `field` names it |
| 401 | `UNAUTHORIZED` | not signed in |

---

## Changelog

Every contract change gets a line. Breaking changes say what they break.

| Date | Change | Breaking? | PR |
|---|---|---|---|
| | | | |
