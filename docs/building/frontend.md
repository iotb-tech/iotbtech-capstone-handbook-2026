# 06 — Frontend Guide

> **Read this if:** you build screens.  
> **Skip if:** you are backend-only — but still read [API contract](api-contract.md).  
> **~10 min.** Long code and setup blocks are collapsed — expand what you need.

Next.js 15, App Router, TypeScript, Tailwind. Exactly the stack from Classes
22–30. Nothing here needs a class you have not had.

---

## Step 1 — Scaffold

From the folder where you keep projects (**not** inside another repo):

```bash
npx create-next-app@latest <product>-frontend \
  --typescript --tailwind --eslint --app --src-dir \
  --import-alias "@/*" --use-npm
```

Then:

```bash
cd <product>-frontend
npm run dev          # confirm http://localhost:3000 loads before you commit
```

Push it per [ops/repo-setup.md](../ops/repo-setup.md) Step 2.

### Dependencies, in one go

```bash
npm i @tanstack/react-query react-hook-form zod @hookform/resolvers
npm i next-auth@beta                       # Auth.js v5 — Class 37
npm i -D prettier prettier-plugin-tailwindcss
```

Add shadcn/ui if you want a component base (encouraged — it saves days):

```bash
npx shadcn@latest init
npx shadcn@latest add button input card dialog form skeleton toast
```

**Do not add anything else without the Tech Lead's agreement**
([01](../rules/ground-rules.md#decision-authority-matrix)). A
UI library per developer is how a codebase becomes unmaintainable in nine days.

### Turn on strict TypeScript

In `tsconfig.json`:

```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  }
}
```

`strict` is on by default from the scaffold — leave it on. Every `any` you add
is a point lost on the rubric, and usually a bug you have postponed rather than
avoided.

---

## Step 2 — Folder structure

Agree this on day one. Everyone inventing their own structure is the single
biggest source of merge conflicts.

/// details | Folder structure
    type: example

```
src/
├── app/                        # routing only — thin files
│   ├── layout.tsx
│   ├── page.tsx
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx
│   │   └── listings/
│   │       ├── page.tsx            # browse
│   │       ├── new/page.tsx        # create
│   │       └── [id]/page.tsx       # detail
│   └── api/auth/[...nextauth]/route.ts
│
├── components/
│   ├── ui/                     # Button, Input, Card, Skeleton, EmptyState
│   └── layout/                 # Navbar, Sidebar, Footer
│
├── features/                   # the real work lives here, by domain
│   └── listings/
│       ├── components/         # ListingCard, ListingForm, ListingFilters
│       ├── hooks/              # useListings, useCreateListing
│       └── api.ts              # the fetch calls for this feature
│
├── lib/
│   ├── api-client.ts           # the ONE place fetch is called
│   ├── query-client.ts
│   ├── auth.ts                 # Auth.js config
│   └── utils.ts
│
├── schemas/                    # Zod schemas — shared by forms and parsing
├── types/                      # types mirrored from the API contract
└── mocks/                      # mock data, until the API exists
```
///

The rule: **`app/` is for routing, `features/` is for logic.** A page file
should be short — read the params, render a feature component. When `page.tsx`
hits 300 lines of JSX and handlers, the logic belongs in `features/`.

**Ownership:** each dev owns one `features/<domain>` folder. Conflicts collapse
to near zero, and your contribution is visible in the diff.

---

## Step 3 — One fetch boundary

Every network call goes through `lib/api-client.ts`. Nobody calls `fetch`
directly from a component.

/// details | src/lib/api-client.ts
    type: example

```ts
// src/lib/api-client.ts
const BASE_URL = process.env.NEXT_PUBLIC_API_URL;

export type ApiError = { code: string; message: string; field?: string };

export class ApiRequestError extends Error {
  constructor(public status: number, public error: ApiError) {
    super(error.message);
  }
}

export async function apiFetch<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    ...init,
    headers: { "Content-Type": "application/json", ...init?.headers },
    credentials: "include",
  });

  const body = await res.json().catch(() => null);

  if (!res.ok) {
    throw new ApiRequestError(res.status, body?.error ?? {
      code: "UNKNOWN",
      message: "Something went wrong",
    });
  }
  return body.data as T;
}
```
///

Why it matters: when the error envelope changes, or you need to add an auth
header, or you want to log every failure — you change one file instead of
forty. This is the kind of decision worth a slide on Demo Day.

The response envelope (`{ data, meta }` / `{ error }`) is defined in
[building/api-contract.md](api-contract.md).

---

## Step 4 — Data fetching with TanStack Query

Provider, once, in a client component wrapped around the app:

/// details | src/app/providers.tsx
    type: example

```tsx
// src/app/providers.tsx
"use client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState } from "react";

export function Providers({ children }: { children: React.ReactNode }) {
  const [client] = useState(
    () => new QueryClient({
      defaultOptions: { queries: { staleTime: 30_000, retry: 1 } },
    }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
```
///

A feature hook:

/// details | src/features/listings/hooks/useListings.ts
    type: example

```ts
// src/features/listings/hooks/useListings.ts
import { useQuery } from "@tanstack/react-query";
import { apiFetch } from "@/lib/api-client";
import type { Listing } from "@/types/listing";

export function useListings(filters: { status?: string; page?: number } = {}) {
  const params = new URLSearchParams(
    Object.entries(filters).filter(([, v]) => v != null)
      .map(([k, v]) => [k, String(v)]),
  );

  return useQuery({
    queryKey: ["listings", filters],      // filters in the key, or caching lies to you
    queryFn: () => apiFetch<Listing[]>(`/listings?${params}`),
  });
}
```
///

A mutation that invalidates:

/// details | A mutation that invalidates the cache
    type: example

```ts
export function useCreateListing() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateListingInput) =>
      apiFetch<Listing>("/listings", {
        method: "POST",
        body: JSON.stringify(input),
      }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["listings"] }),
  });
}
```
///

Two mistakes that cost marks: **filters missing from the `queryKey`** (stale
results after filtering), and **not invalidating after a mutation** (user
creates something and it doesn't appear).

---

## Step 5 — Four states per screen. Always.

A list view is not done until all four exist. This is the most common thing
reviewers send back.

/// details | All four states in one component
    type: example

```tsx
export function ListingsList() {
  const { data, isLoading, isError, error, refetch } = useListings();

  if (isLoading) return <ListingsSkeleton />;              // 1. loading

  if (isError)                                              // 2. error
    return (
      <ErrorState
        message={error instanceof ApiRequestError ? error.error.message
                                                  : "Could not load listings"}
        onRetry={refetch}
      />
    );

  if (!data?.length)                                        // 3. empty
    return (
      <EmptyState
        title="No listings yet"
        action={<Link href="/listings/new">Create the first one</Link>}
      />
    );

  return (                                                  // 4. data
    <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {data.map((l) => <ListingCard key={l.id} listing={l} />)}
    </ul>
  );
}
```
///

Build `<Skeleton>`, `<ErrorState>`, and `<EmptyState>` as shared components on
day one. You will use each of them a dozen times.

---

## Step 6 — Forms: React Hook Form + Zod

One Zod schema, used for validation **and** the TypeScript type.

/// details | src/schemas/listing.ts
    type: example

```ts
// src/schemas/listing.ts
import { z } from "zod";

export const createListingSchema = z.object({
  title: z.string().min(5, "Title must be at least 5 characters").max(100),
  price: z.coerce.number().positive("Price must be greater than zero"),
  description: z.string().min(20, "Give buyers at least 20 characters"),
  category: z.enum(["furniture", "electronics", "books", "other"]),
});

export type CreateListingInput = z.infer<typeof createListingSchema>;
```
///

/// details | The form component
    type: example

```tsx
const form = useForm<CreateListingInput>({
  resolver: zodResolver(createListingSchema),
  defaultValues: { title: "", price: 0, description: "", category: "other" },
});

const { mutate, isPending } = useCreateListing();

<form onSubmit={form.handleSubmit((values) => mutate(values))}>
  <Input {...form.register("title")} />
  {form.formState.errors.title && (
    <p className="text-sm text-error">{form.formState.errors.title.message}</p>
  )}
  <Button type="submit" disabled={isPending}>
    {isPending ? "Saving…" : "Create listing"}
  </Button>
</form>
```
///

`z.coerce.number()` matters: HTML inputs always give you strings. This is the
single most common 400 error in integration.

**Write error messages a user can act on.** "Invalid" is not a message; "Price
must be greater than zero" is. Rubric notices.

---

## Step 7 — Server vs client components

Default is **server**. Add `"use client"` only when you need:

- `useState` / `useEffect` / `useRef`
- An event handler (`onClick`, `onChange`)
- A browser API (`window`, `localStorage`)
- TanStack Query hooks, React Hook Form

Pattern that works: a **server component** fetches initial data and renders
layout; a small **client component** inside it handles interaction.

```tsx
// app/(dashboard)/listings/page.tsx   — server component
export default async function ListingsPage() {
  return (
    <main className="mx-auto max-w-6xl p-6">
      <h1 className="text-3xl font-bold">Browse listings</h1>
      <ListingsList />        {/* client component, uses TanStack Query */}
    </main>
  );
}
```

Do not put `"use client"` at the top of `layout.tsx` to make one button work —
it turns the entire subtree into client components and throws away the benefit.

---

## Step 8 — Environment variables

`.env.local` (git-ignored). `.env.example` committed and kept current.

```bash
NEXT_PUBLIC_API_URL=http://localhost:4000/api/v1
AUTH_SECRET=generate-with-openssl-rand-base64-32
AUTH_GOOGLE_ID=
AUTH_GOOGLE_SECRET=
NEXTAUTH_URL=http://localhost:3000
```

**`NEXT_PUBLIC_` means public.** Anything with that prefix is compiled into the
JavaScript shipped to the browser and visible to anyone who opens DevTools.
Never prefix a secret. `DATABASE_URL` belongs nowhere near this repo.

Full policy: [ops/environments.md](../ops/environments.md).

---

## Working before the backend exists

**The frontend is never blocked by the backend.** This is the most important
section in this document for the next two weeks.

Once the contract entry is merged, the shape is known — so build against it.

```ts
// src/mocks/listings.ts
import type { Listing } from "@/types/listing";

export const mockListings: Listing[] = [
  { id: "1", title: "Room in Yaba", price: 150000, status: "active",
    category: "other", description: "…", createdAt: "2026-10-18T10:00:00Z" },
];
```

/// details | src/features/listings/api.ts
    type: example

```ts
// src/features/listings/api.ts
import { apiFetch } from "@/lib/api-client";
import { mockListings } from "@/mocks/listings";

const USE_MOCKS = process.env.NEXT_PUBLIC_USE_MOCKS === "true";

export async function fetchListings(): Promise<Listing[]> {
  if (USE_MOCKS) {
    await new Promise((r) => setTimeout(r, 400));   // keeps your skeleton honest
    return mockListings;
  }
  return apiFetch<Listing[]>("/listings");
}
```
///

Set `NEXT_PUBLIC_USE_MOCKS=true` locally, build the whole screen, and flip the
flag when the endpoint lands on staging. The artificial delay matters — without
it you will never see your own loading state and will ship a screen that flashes.

Rules:

- **Mock shapes must match the contract exactly.** A mock that invents fields is
  worse than no mock: it guarantees rework.
- Mocks are for development only. **Nothing with `USE_MOCKS=true` goes to
  staging or `main`**, and the demo runs on real data.
- Delete the mock once the endpoint is wired, in the same PR.

---

## Design: shared tokens

Agree tokens with the designer, put them in `tailwind.config.ts` on day one, and
never hardcode a hex value in a component again.

/// details | tailwind.config.ts tokens
    type: example

```ts
theme: {
  extend: {
    colors: {
      primary: { 50:"#eff6ff",100:"#dbeafe",300:"#93c5fd",
                 500:"#3b82f6",600:"#2563eb",700:"#1d4ed8" },
      neutral: { 50:"#fafafa",100:"#f4f4f5",200:"#e4e4e7",
                 400:"#a1a1aa",600:"#52525b",800:"#27272a",900:"#18181b" },
      success: "#16a34a", warning: "#d97706", error: "#dc2626",
    },
    fontFamily: { sans: ["Inter", "system-ui", "sans-serif"] },
    borderRadius: { DEFAULT: "0.5rem", lg: "0.75rem" },
  },
}
```
///

Pick your own `primary` hue — keep the 50/300/500/600/700 shape. Keep
`neutral`/`success`/`warning`/`error`. Use Tailwind's default spacing scale; do
not invent one.

Type scale:

| Use | Classes |
|---|---|
| Page title | `text-3xl font-bold` |
| Section heading | `text-xl font-semibold` |
| Body | `text-base` |
| Helper / muted | `text-sm text-neutral-600` |
| Label | `text-sm font-medium` |

### Components to build once, on day one

`Button` (primary/secondary/ghost, **disabled and loading** states), `Input` /
`Textarea` / `Select` (with an error slot wired to
`formState.errors`), `Card`, `Navbar` (logged-in vs logged-out), `EmptyState`,
`Skeleton`, `Toast`.

The loading state on `Button` is not optional — every TanStack mutation needs it.

---

## Accessibility and responsive — cheap marks, usually skipped

- Every input has a real `<label>` (not placeholder-as-label)
- Visible focus rings — do not `outline: none` without a replacement
- Buttons are `<button>`, links are `<a>`/`<Link>`
- Images have `alt`
- `aria-label` on icon-only buttons
- Test at 375px wide. Most of your users are on a phone.
- No horizontal scroll on mobile

Run Lighthouse before submission and fix the obvious reds.

---

## Before you open a PR

- [ ] `npm run build` passes locally (not just `npm run dev`)
- [ ] `npx tsc --noEmit` clean — no type errors
- [ ] `npm run lint` clean
- [ ] No `console.log` left behind
- [ ] No `any` added
- [ ] Loading, error, and empty states all present
- [ ] Works at 375px
- [ ] Screenshots in the PR description
- [ ] No secret, no hardcoded URL — env vars only
