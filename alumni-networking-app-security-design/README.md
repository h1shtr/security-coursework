# Alumni Networking App — Secure-by-Design Case Study

**Course:** FC331-332 – Software Security, University of Prince Mugrin
**Supervisor:** Dr. Syed Kamran

## Overview

This is a secure-software-design exercise: rather than building the full app, the project
designs the **Alumni Networking App** — a platform connecting students with alumni for
mentorship and networking — with security folded into every stage of the SDLC (Secure-by-Design),
instead of bolted on afterward.

The deliverable covers requirements, architecture, misuse-case analysis, STRIDE threat
modeling, and DREAD-based risk scoring, followed by a concrete set of security controls
mapped back to each identified threat.

## System Summary

Students can search alumni by program, graduation year, industry, or location, and send
mentorship/networking requests; alumni can accept/reject requests; admins manage accounts
and review activity logs.

### Architecture

Three-tier design:
- **Presentation layer** — web/mobile client, HTTPS only, no security logic client-side
- **Application layer** — API gateway, auth/authorization, profile management, search,
  and request-management components
- **Data layer** — relational database (users, profiles, requests, messages, audit logs),
  reachable only from the application layer via parameterized queries

### Threat Modeling (STRIDE)

Threats were identified across all six STRIDE categories, including credential-based
spoofing, SQL injection/tampering, repudiation of requests, information disclosure via
insecure direct object references, brute-force denial of service, and privilege-escalation
via access-control flaws.

### Risk Scoring (DREAD)

Four example threats were scored before and after mitigation, e.g. SQL injection on the
search endpoint dropped from a DREAD score of ~8.0 (High) to Medium/Low once input
validation and parameterized queries were applied.

### Security Controls

| Control | Mitigates |
|---|---|
| Strong authentication (salted hashing, lockout/throttling) | Credential spoofing, brute force |
| Role-based access control | Privilege escalation, unauthorized data access |
| Input validation & output encoding | SQL injection, XSS |
| HTTPS/TLS everywhere | Eavesdropping, MITM |
| Structured audit logging | Repudiation, incident investigation |
| Rate limiting | Brute force, request-spam abuse |
| Email/account verification | Fake alumni accounts |
| Secure configuration & hardening | Reduces overall attack surface |
| Regular backups | Data loss / integrity failures |

## What's in this repo

- [`docs/alumni-app-security-design.md`](docs/alumni-app-security-design.md) — the full
  write-up: functional/non-functional/security requirements, architecture diagrams, misuse
  case diagram, STRIDE analysis, and DREAD scoring in detail

## Author

Hisham (group coursework, FC331-332 — Software Security)
