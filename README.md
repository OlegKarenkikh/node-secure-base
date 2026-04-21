# node-secure-base

> Zero-CVE Node.js 24 Alpine base image for production Docker builds

[![Build](https://github.com/OlegKarenkikh/node-secure-base/actions/workflows/build-push.yml/badge.svg)](https://github.com/OlegKarenkikh/node-secure-base/actions/workflows/build-push.yml)

## Usage

```dockerfile
# Instead of:
FROM node:24-alpine

# Use:
FROM olegkarenkikh/node-secure:24-alpine
```

## What's fixed vs `node:24-alpine`

| CVE | Package | Fix |
|-----|---------|-----|
| CVE-2025-15467, CVE-2026-28390 | `libcrypto3` / `libssl3` | `apk upgrade` → 3.5.6-r0 |
| CVE-2026-33671 | `picomatch@4.0.3` (npm bundled) | Patched to 4.0.4 |
| CVE-2026-25547 | `@isaacs/brace-expansion` (npm bundled) | Patched |
| CVE-2025-64756 | `glob@10.4.5` in corepack pnpm cache | `pnpm@10.11.1` (no cached CVEs) |
| CVE-2026-26996/27903 | `minimatch@9.0.5` in corepack cache | `pnpm@10.11.1` |
| CVE-2026-23745/23950 | `tar@6.2.1` in corepack cache | `pnpm@10.11.1` |
| CVE-2025-69262/69263 | `pnpm@9.15.1` in corepack cache | `pnpm@10.11.1` |

## pnpm version compatibility

This image ships **pnpm@10.11.1** via corepack.

If your project uses `packageManager: pnpm@9.x` in `package.json`, add one of:
```bash
# Option A: allow pnpm version mismatch
ENV COREPACK_ENABLE_STRICT=0

# Option B: update packageManager field in your package.json
"packageManager": "pnpm@10.11.1"
```

## Rebuild schedule

Automatically rebuilt every Monday at 03:00 UTC to pick up latest `apk` security patches.
