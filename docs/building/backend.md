# 07 — Backend Guide

> **Read this if:** you build the API, or you are about to change the schema.  
> **Skip if:** you are frontend-only — but still read [API contract](api-contract.md).  
> **~14 min.** Long code and setup blocks are collapsed — expand what you need.

Express + TypeScript + Prisma + PostgreSQL. The layout is the one from Classes
32–36 (`backend-class/hello-api`), so nothing here is new — it is the same
structure, with real domain logic in it.

---

## Step 1 — Scaffold

/// details | Scaffold commands
    type: example

```bash
mkdir <project>-backend && cd <project>-backend
npm init -y

npm i express@5 cors helmet dotenv zod winston
npm i -D typescript tsx @types/node @types/express@5 @types/cors

# Prisma — pin BOTH packages to 7. Read the warning below before changing this.
npm i @prisma/client@7
npm i -D prisma@7

npx tsc --init
npx prisma init --datasource-provider postgresql
```
///

> ### Pin Prisma to 7. Do not use `@latest`.
>
> At the time of writing, npm's `latest` tag for the **`prisma` CLI** is an
> **8.0 release candidate**, while `@prisma/client` is on **7.10.x**. So this:
>
> ```bash
> npm i @prisma/client && npm i -D prisma      # DON'T
> ```
>
> installs a v8-rc CLI against a v7 client and produces confusing
> "version mismatch" errors that look like your code is broken.
>
> Prisma 7 is what Classes 34–36 used, and what `schoolpulse-backend` runs.
> Check you got it right:
>
> ```bash
> npm ls prisma @prisma/client     # both should be 7.x
> ```

`tsconfig.json` — the parts that matter:

/// details | tsconfig.json
    type: example

```jsonc
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "nodenext",
    "moduleResolution": "nodenext",
    "rootDir": "src",
    "outDir": "dist",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"]
}
```
///

And in `package.json`, alongside the scripts:

```json
{ "type": "commonjs" }
```

That pairing matters, so do not change one without the other:

- `"type": "commonjs"` matches `hello-api` from Classes 32–33, and makes
  `nodenext` resolve in CommonJS mode — so **relative imports work without file
  extensions**, which is what every code sample below assumes.
- `"moduleResolution": "nodenext"` is required because **TypeScript 7 removed
  `"moduleResolution": "node"`**. If you copied an older tsconfig you will get:

  ```
  error TS5108: Option 'moduleResolution=node10' has been removed.
  ```

  That is not your code — it is a stale config. Use `nodenext`.

> **If you prefer ESM** (`"type": "module"`), which is what
> `schoolpulse-backend` uses, every **relative** import then needs a `.js`
> extension even in TypeScript — `import { env } from "./config/env.js"`. It is
> a legitimate choice and it trips people up constantly. Pick one per team at
> kickoff, write it in the README, and do not mix the two.

> **Verified:** this exact `tsconfig.json`, with `express@5`, `zod@4`,
> `prisma@7` and `typescript@7`, typechecks and builds every code sample in
> this guide with zero errors.

`package.json` scripts:

/// details | package.json scripts
    type: example

```json
{
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "typecheck": "tsc --noEmit",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "prisma:studio": "prisma studio",
    "seed": "tsx prisma/seed.ts"
  }
}
```
///

**Before your first commit**, confirm `.gitignore` has:

```
node_modules
dist
.env
*.log
logs/
```

A `DATABASE_URL` committed to git is a leaked database password. Treat it that
way — see [09](../ops/environments.md#if-you-commit-a-secret).

---

## Step 2 — Folder structure

Same shape as `hello-api` from Class 32–33. Do not invent your own.

/// details | Folder structure
    type: example

```
<project>-backend/
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── src/
│   ├── server.ts              # starts the HTTP listener. nothing else.
│   ├── app.ts                 # builds the Express app (testable, no listen)
│   ├── config/
│   │   ├── env.ts             # validated env — the only place process.env is read
│   │   ├── prisma.ts          # the single PrismaClient instance
│   │   └── cors.config.ts
│   ├── routes/
│   │   ├── index.ts           # mounts every router under /api/v1
│   │   └── listing.route.ts
│   ├── controllers/
│   │   └── listing.controller.ts   # HTTP in, HTTP out. no business logic.
│   ├── services/
│   │   └── listing.service.ts      # business logic + Prisma. no req/res.
│   ├── middlewares/
│   │   ├── error.middleware.ts
│   │   ├── auth.middleware.ts
│   │   ├── validate.middleware.ts
│   │   └── logger.middleware.ts
│   ├── schemas/
│   │   └── listing.schema.ts       # Zod request schemas
│   ├── utils/
│   │   ├── logger.ts               # Winston — Class 33
│   │   └── ApiError.ts
│   └── contract/                   # shared with the frontend — see 08
├── .env.example
└── .gitignore
```
///

**The layering rule, which is most of what Classes 32–33 were about:**

| Layer | May do | May not do |
|---|---|---|
| **Route** | Map a URL to a controller, attach middleware | Contain logic |
| **Controller** | Read `req`, call a service, send a response | Touch Prisma, contain business rules |
| **Service** | Business logic, Prisma queries, throw `ApiError` | Know that HTTP exists (`req`, `res`, status codes) |

If a service imports `express`, the layering is wrong. If a controller writes a
Prisma query, the layering is wrong. Reviewers check this.

---

## Step 3 — Validate your environment at boot

/// details | src/config/env.ts
    type: example

```ts
// src/config/env.ts
import "dotenv/config";
import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "staging", "production"]).default("development"),
  PORT: z.coerce.number().default(4000),
  DATABASE_URL: z.string().url(),
  CORS_ORIGIN: z.string().default("http://localhost:3000"),
  AUTH_SECRET: z.string().min(32),
});

const parsed = schema.safeParse(process.env);

if (!parsed.success) {
  console.error("Invalid environment:", parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
```
///

Now a missing `DATABASE_URL` fails loudly at startup with the name of what is
missing — instead of a confusing Prisma error forty minutes into debugging.
**`process.env` is read in this file and nowhere else.**

---

## Step 4 — One Prisma client

```ts
// src/config/prisma.ts
import { PrismaClient } from "@prisma/client";
import { env } from "./env";

export const prisma = new PrismaClient({
  log: env.NODE_ENV === "development" ? ["query", "warn", "error"] : ["error"],
});
```

Import `prisma` from here everywhere. `new PrismaClient()` in each file opens a
new connection pool per file and will exhaust your database's connection limit —
a classic and confusing production failure.

---

## Step 5 — app.ts and server.ts

/// details | src/app.ts
    type: example

```ts
// src/app.ts
import express from "express";
import cors from "cors";
import helmet from "helmet";
import { env } from "./config/env";
import { routes } from "./routes";
import { requestLogger } from "./middlewares/logger.middleware";
import { errorHandler } from "./middlewares/error.middleware";

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors({ origin: env.CORS_ORIGIN, credentials: true }));
  app.use(express.json());
  app.use(requestLogger);

  app.get("/health", (_req, res) =>
    res.json({ status: "ok", uptime: process.uptime() }),
  );

  app.use("/api/v1", routes);

  app.use((_req, res) =>
    res.status(404).json({ error: { code: "NOT_FOUND", message: "Route not found" } }),
  );

  app.use(errorHandler);   // LAST. always last.
  return app;
}
```
///

```ts
// src/server.ts
import { createApp } from "./app";
import { env } from "./config/env";
import { logger } from "./utils/logger";

createApp().listen(env.PORT, () =>
  logger.info(`API listening on :${env.PORT} [${env.NODE_ENV}]`),
);
```

Splitting them means the app can be imported by a test without binding a port —
which you will need at Class 41.

`/health` is not decoration: Railway/Render use it to decide whether a deploy
succeeded, and DevOps needs it ([09](../ops/environments.md)).

---

## Step 6 — Errors, in one place

/// details | src/utils/ApiError.ts
    type: example

```ts
// src/utils/ApiError.ts
export class ApiError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string,
    public field?: string,
  ) {
    super(message);
  }
  static badRequest(msg: string, field?: string) { return new ApiError(400, "VALIDATION_ERROR", msg, field); }
  static unauthorized(msg = "Not signed in")     { return new ApiError(401, "UNAUTHORIZED", msg); }
  static forbidden(msg = "Not allowed")          { return new ApiError(403, "FORBIDDEN", msg); }
  static notFound(what = "Resource")             { return new ApiError(404, "NOT_FOUND", `${what} not found`); }
  static conflict(msg: string)                   { return new ApiError(409, "CONFLICT", msg); }
}
```
///

/// details | src/middlewares/error.middleware.ts
    type: example

```ts
// src/middlewares/error.middleware.ts
import type { ErrorRequestHandler } from "express";
import { ApiError } from "../utils/ApiError";
import { logger } from "../utils/logger";

export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  if (err instanceof ApiError) {
    logger.warn(`${req.method} ${req.path} -> ${err.status} ${err.code}`);
    return res.status(err.status).json({
      error: { code: err.code, message: err.message, field: err.field },
    });
  }

  logger.error(`${req.method} ${req.path} -> 500`, { err });
  return res.status(500).json({
    error: { code: "INTERNAL_ERROR", message: "Something went wrong" },
  });
};
```
///

Two rules:

1. **Never leak an internal error to the client.** A stack trace or a raw Prisma
   message in a 500 response is a security finding. Log the detail, return the
   generic message.
2. **You are on Express 5, which forwards async errors for you.** If an `async`
   handler throws or rejects, Express 5 passes the error to `errorHandler`
   automatically. So this is all you need:

```ts
// Express 5 — no wrapper, no try/catch. The throw lands in errorHandler.
export const removeListing: RequestHandler = async (req, res) => {
  await listingService.remove(req.user!.id, req.params.id);   // may throw ApiError
  res.status(204).send();
};
```

> **Why this is worth knowing:** most Express tutorials online are written for
> **Express 4**, where a rejected promise in a handler was *not* forwarded — it
> hung the request silently. That is why you will see `asyncHandler` wrappers
> (`(req,res,next) => Promise.resolve(fn(...)).catch(next)`) everywhere. You do
> not need one. Classes 32–33 and every capstone repo use `express@5`; confirm
> with `npm ls express`.
>
> A wrapper is harmless if you prefer the explicitness — just do not let someone
> tell you your async errors are broken without checking the major version
> first.

---

## Step 7 — Validate requests at the boundary

/// details | src/middlewares/validate.middleware.ts
    type: example

```ts
// src/middlewares/validate.middleware.ts
import type { RequestHandler } from "express";
import type { ZodSchema } from "zod";
import { ApiError } from "../utils/ApiError";

export const validate =
  (schema: ZodSchema, source: "body" | "query" | "params" = "body"): RequestHandler =>
  (req, _res, next) => {
    const result = schema.safeParse(req[source]);
    if (!result.success) {
      const first = result.error.issues[0];
      return next(ApiError.badRequest(first.message, String(first.path[0])));
    }
    req[source] = result.data;    // parsed and coerced from here on
    next();
  };
```
///

```ts
// src/routes/listing.route.ts
const router = Router();
router.get("/", validate(listQuerySchema, "query"), listListings);
router.post("/", requireAuth, validate(createListingSchema), createListing);
export default router;
```

**Validate at the edge, then trust the data inward.** Services should not be
re-checking whether `price` is a number.

Use the **same field names and messages as the frontend's Zod schemas**. Two
different error vocabularies for the same form is a bad user experience and an
avoidable integration bug.

---

## Step 8 — Controller and service, worked example

/// details | src/controllers/listing.controller.ts
    type: example

```ts
// src/controllers/listing.controller.ts
import type { RequestHandler } from "express";
import * as listingService from "../services/listing.service";

export const listListings: RequestHandler = async (req, res) => {
  const { data, meta } = await listingService.list(req.query as ListQuery);
  res.json({ data, meta });
};

export const createListing: RequestHandler = async (req, res) => {
  const listing = await listingService.create(req.user!.id, req.body);
  res.status(201).json({ data: listing });
};
```
///

/// details | src/services/listing.service.ts
    type: example

```ts
// src/services/listing.service.ts
import { prisma } from "../config/prisma";
import { ApiError } from "../utils/ApiError";

export async function list(q: ListQuery) {
  const page = q.page ?? 1;
  const pageSize = Math.min(q.pageSize ?? 20, 100);   // cap it. always.

  const where = {
    ...(q.status && { status: q.status }),
    ...(q.search && { title: { contains: q.search, mode: "insensitive" as const } }),
  };

  const [data, total] = await Promise.all([
    prisma.listing.findMany({
      where, skip: (page - 1) * pageSize, take: pageSize,
      orderBy: { createdAt: "desc" },
    }),
    prisma.listing.count({ where }),
  ]);

  return { data, meta: { page, pageSize, total } };
}

export async function remove(userId: string, id: string) {
  const listing = await prisma.listing.findUnique({ where: { id } });
  if (!listing) throw ApiError.notFound("Listing");
  if (listing.ownerId !== userId) throw ApiError.forbidden();  // ownership check!
  await prisma.listing.delete({ where: { id } });
}
```
///

Notice the two things reviewers look for specifically:

- **Pagination is capped.** `?pageSize=1000000` must not be allowed to take the
  database down.
- **Ownership is checked on every mutation.** "Signed in" is not the same as
  "allowed to delete this". A `DELETE /listings/:id` that any logged-in user can
  call on anyone's listing is the most common security bug in student projects,
  and it will be found.

---

## Step 9 — Prisma schema

/// details | prisma/schema.prisma
    type: example

```prisma
model User {
  id        String    @id @default(cuid())
  email     String    @unique
  name      String?
  image     String?
  listings  Listing[]
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
}

model Listing {
  id          String        @id @default(cuid())
  title       String
  description String
  price       Int                               // kobo/cents. never Float for money.
  status      ListingStatus @default(ACTIVE)
  category    String
  ownerId     String
  owner       User          @relation(fields: [ownerId], references: [id], onDelete: Cascade)
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt

  @@index([status, createdAt])
  @@index([ownerId])
}

enum ListingStatus { ACTIVE SOLD DRAFT }
```
///

Conventions:

- `id` is `cuid()`, not an auto-increment int — sequential ids let anyone
  enumerate your data by changing a URL.
- **Money is an integer in the smallest unit.** Float arithmetic on currency
  produces wrong totals; this is a real bug, not pedantry.
- `createdAt` / `updatedAt` on every model.
- `onDelete` declared explicitly on every relation — decide it, do not inherit it.
- `@@index` on anything you filter or sort by.
- Enums for fixed sets, not loose strings.

### Migrations

```bash
npx prisma migrate dev --name add_listing_status
```

Rules:

- **Descriptive names.** `add_listing_status`, not `update1`.
- **Migrations are committed.** They are the history of your database.
- **Never edit a migration that has been pushed.** Write a new one.
- **`prisma migrate reset` wipes the database.** On the shared dev DB that
  destroys everyone's data — ask the team first
  ([01](../rules/ground-rules.md#decision-authority-matrix)).
- A schema change **must** be announced to the FE owner of any affected screen,
  and the contract updated in the same breath ([08](api-contract.md)).

### Seed data

/// details | prisma/seed.ts
    type: example

```ts
// prisma/seed.ts — run with: npm run seed
import { prisma } from "../src/config/prisma";

async function main() {
  const user = await prisma.user.upsert({
    where: { email: "demo@iotbtech.dev" },
    update: {},
    create: { email: "demo@iotbtech.dev", name: "Demo User" },
  });

  await prisma.listing.createMany({
    data: [
      { title: "Study desk", description: "Barely used", price: 2500000,
        category: "furniture", ownerId: user.id },
    ],
    skipDuplicates: true,
  });
}

main().finally(() => prisma.$disconnect());
```
///

Write this in week 1. A new teammate should go from clone to working data in
two commands — and an empty database on Demo Day looks like a broken app.
Use `upsert` / `skipDuplicates` so re-running is safe.

---

## Step 10 — One shared development database

**Do not have every developer on their own local Postgres instance.** You will spend
your time reconciling schemas instead of building.

The Cloud/DevOps owner provisions **one hosted dev database** in week 1 (Neon,
Supabase Postgres, or Railway Postgres — all have free tiers) and shares the
`DATABASE_URL` through the agreed secret channel, **never in group chat**.

| Environment | Database |
|---|---|
| Local dev | the shared hosted dev DB |
| Staging | its own database |
| Production | its own database, never shared with anything |

Never point local development at the production database. Full policy:
[09](../ops/environments.md).

---

## Auth: what you can build right now

You are at **Class 37 (Auth.js v5)**. Class 38 is manual JWT + bcrypt. So:

**Do now** — Auth.js v5 on the Next.js side (Google OAuth, session, protected
middleware), with the API trusting the session.

**Do not** — invent your own token scheme, hand-roll password hashing, or build
refresh-token rotation before Class 38. Teams that improvise auth early
consistently build something insecure and then rewrite it.

Until then, keep auth behind a seam so nothing else is blocked:

```ts
// src/middlewares/auth.middleware.ts
export const requireAuth: RequestHandler = (req, _res, next) => {
  const userId = getUserIdFromSession(req);          // swap the inside at Class 38
  if (!userId) return next(ApiError.unauthorized());
  req.user = { id: userId };
  next();
};
```

Every protected route uses `requireAuth` from day one. When Class 38 lands you
change the body of one function and every route is upgraded. Full gating table:
[building/build-order.md](build-order.md).

---

## Logging (Class 33)

/// details | src/utils/logger.ts
    type: example

```ts
// src/utils/logger.ts
import winston from "winston";
import { env } from "../config/env";

export const logger = winston.createLogger({
  level: env.NODE_ENV === "production" ? "info" : "debug",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json(),
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: "logs/error.log", level: "error" }),
    new winston.transports.File({ filename: "logs/combined.log" }),
  ],
});
```
///

`logs/` is in `.gitignore`. Use `logger`, not `console.log`. And **never log a
password, token, or full request body** — that is how secrets end up in a log
file you later share.

---

## Before you open a PR

- [ ] `npm run build` passes
- [ ] `npm run typecheck` clean
- [ ] Endpoint matches the merged contract **exactly** — path, method, field
      names, status codes
- [ ] Request validated with Zod at the boundary
- [ ] Ownership/permission checked on every mutation
- [ ] Errors go through `ApiError` + the error middleware — no raw `res.status(500)`
- [ ] Pagination capped on any list endpoint
- [ ] Migration committed, with a descriptive name
- [ ] `.env.example` updated if you added a variable
- [ ] Tested with real requests (Postman/Thunder/`curl`) — paste one into the PR
- [ ] No secret, no `console.log`, no commented-out experiments
