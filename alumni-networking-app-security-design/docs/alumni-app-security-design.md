# Alumni Networking App — Security Design Document

*FC331-332 Software Security · University of Prince Mugrin*

## 1. Introduction

The Alumni Networking App is a web platform connecting university alumni with current
students for mentorship and career guidance. Students search alumni by program, graduation
year, industry, or location, and send mentorship/networking requests.

Because the system handles sensitive personal details, contact information, and private
communications, security requirements, threat modeling, and protective controls were
considered from the analysis and design phases onward (Secure-by-Design), rather than
added after implementation.

## 2. System Requirements

### 2.1 Functional Requirements

| ID | Requirement |
|---|---|
| FR1 | Register as Student, Alumni, or Administrator via email/password |
| FR2 | Authenticate users before granting access to protected features |
| FR3 | Create/update profiles (basic info, professional info, optional contact links) |
| FR4 | Search/filter alumni by program, graduation year, industry, location |
| FR5 | Send mentorship/networking requests with a short message |
| FR6 | Alumni view, accept, or reject incoming requests |
| FR7 | Basic messaging between accepted student–alumni pairs |
| FR8 | Admin views/deactivates accounts and reviews activity logs |
| FR9 | Notify users when request status or account status changes |

### 2.2 Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR1 | Simple, intuitive UI for non-technical users |
| NFR2 | Typical operations respond in under 3 seconds under normal load |
| NFR3 | Remains available during normal working hours with graceful error handling |
| NFR4 | Scales without major redesign (presentation/data layers separated) |
| NFR5 | Modular codebase — components can be updated independently |
| NFR6 | Security-relevant events logged in structured form for auditing |

### 2.3 Security Requirements

| ID | Requirement |
|---|---|
| SR1 | Confidentiality — profile/communication data accessible only per role |
| SR2 | Strong authentication — complex passwords, secure credential handling |
| SR3 | Role-based access control (student / alumni / admin) |
| SR4 | Integrity — stored records protected from unauthorized modification |
| SR5 | Protection against SQLi, XSS, CSRF, insecure direct object references |
| SR6 | All client–server traffic encrypted |
| SR7 | Rate limiting on login and request submission to mitigate abuse/DoS |
| SR8 | Security event logging available to authorized admins |

## 3. System Architecture

Three-tier web architecture, chosen to separate concerns and apply security consistently:

- **Presentation Layer (client)** — Student, Alumni, and Administrator interact via a web
  browser or mobile app. Handles display/input capture only; no security decisions are made
  client-side.
- **Application / Business Layer (server API)** — Web Server/API Gateway terminates HTTPS,
  routes requests, and applies generic security checks. Authentication & Authorization
  verifies credentials, manages sessions, and enforces RBAC. Separate components handle
  Profile Management, Alumni Search, and Mentorship Request Management.
- **Data Layer (database)** — A relational database stores Users, Profiles, Requests,
  Messages, and Audit Logs. Only the application layer may access it, via parameterized
  queries and a restricted database account.

All client–server traffic is HTTPS; the server–database connection is also secured.

**Design evaluation:** centralizing auth/authorization server-side enables consistent access
control and simpler auditing, and separating the API gateway from the database reduces the
attack surface and contains successful attacks. A single web server instance is a potential
bottleneck/single point of failure, but the design scales horizontally later via a load
balancer without major redesign.

**Sample flow — Search Alumni:** client sends filter criteria + session token over HTTPS →
API gateway routes to Alumni Search → component validates input, checks authorization, and
issues a parameterized query → database returns matches → application layer filters fields
per security policy → JSON response returned to client.

## 4. Misuse Case Analysis

**Actors:** Student, Alumni, Administrator, External Attacker/Malicious User.

**Normal use cases:** register account, log in, manage profile, search alumni, send
mentorship request, respond to request, admin manage users.

**Misuse cases:**

| ID | Misuse Case |
|---|---|
| MUC1 | Create a fake alumni account to contact students |
| MUC2 | Harvest alumni contact data at scale for spam/phishing |
| MUC3 | Brute-force login attempts to compromise accounts |
| MUC4 | Inject malicious input (SQLi/XSS) via profile fields or messages |
| MUC5 | Send abusive/excessive mentorship requests to one alumnus (harassment / minor DoS) |

Each misuse case was mapped ("threatens") against the normal use case it targets in a UML
misuse-case diagram.

## 5. Threat Modeling (STRIDE)

**Assets & priority:** user credentials (High), alumni profiles (High), student
profiles/requests (High), application logs (Medium), system availability (High),
configuration/source code (Medium–High).

**Application decomposition:** client → web server/API → auth & authorization module →
business logic components → database → email/notification service.

**Threats by STRIDE category:**

- **Spoofing** — stolen/guessed credentials (S1); fake alumni identity registration (S2)
- **Tampering** — manipulated request/profile parameters (T1); SQL injection (T2)
- **Repudiation** — denying having sent a request/message (R1); denying an admin action (R2)
- **Information Disclosure** — unencrypted traffic interception (I1); insecure direct object
  references exposing private fields (I2); XSS leaking session tokens (I3)
- **Denial of Service** — brute-force lockouts (D1); request flooding (D2)
- **Elevation of Privilege** — access-control flaw exposing admin functionality (E1);
  exploiting misconfiguration for privileged server operations (E2)

## 6. Security Controls

| ID | Control | Addresses |
|---|---|---|
| SC1 | Strong authentication (salted hashing, lockout/throttling, secure sessions) | S1 |
| SC2 | Role-based access control, least privilege, server-side checks | E1, E2, I2 |
| SC3 | Input validation & output encoding | T1, T2, I3 |
| SC4 | HTTPS/TLS everywhere | I1 |
| SC5 | Structured logging/audit trails | R1, R2 |
| SC6 | Rate limiting / request throttling | D1, D2 |
| SC7 | Email + optional manual verification for new (esp. alumni) accounts | S2, MUC1 |
| SC8 | Secure configuration & hardening (secure defaults, patched deps, least-privilege DB) | E2 |
| SC9 | Regular backups | data loss / integrity incidents |

## 7. DREAD Risk Scoring (Examples)

| Threat | Damage | Reproducibility | Exploitability | Affected Users | Discoverability | Initial Score | Mitigations | Residual Risk |
|---|---|---|---|---|---|---|---|---|
| SQL Injection on search (T2) | 9 | 8 | 7 | 9 | 7 | 8.0 (High) | SC3, SC8 | Medium/Low |
| Brute-force login (D1) | 7 | 9 | 8 | 7 | 8 | 7.8 (High) | SC1, SC6, SC5 | Medium |
| Fake alumni accounts (S2/MUC1) | 8 | 6 | 7 | 7 | 5 | 6.6 (Med-High) | SC7, SC2, SC5 | Medium |
| Unauthorized profile access (I2/E1) | 8 | 7 | 6 | 8 | 6 | 7.0 (High) | SC1, SC3, SC4 | Medium |

## 8. Control Justification Highlights

- **Authentication (SC1):** essential since access to profiles/communications is restricted
  to registered users — strong policies and lockout prevent spoofing and credential stuffing.
- **Input validation (SC3):** profile fields and messages accept free text, making them
  prime injection/XSS targets — centralized validation and encoding minimize that risk.
- **Encryption (SC4):** alumni/student exchanges may include sensitive career information —
  HTTPS/TLS protects confidentiality in transit.
- **RBAC (SC2):** different user types need different privileges; RBAC prevents students
  from seeing hidden alumni data or admin functions, and stops privilege escalation.
- **Logging (SC5):** required to detect suspicious activity, investigate incidents, and
  resolve repudiation disputes.
- **Rate limiting (SC6):** protects availability against brute-force and spam-like abuse.
- **Backups (SC9):** protects data integrity/availability against loss or corruption.
- **Hardening (SC8):** secure defaults and patched dependencies reduce the attack surface
  and limit the blast radius of successful exploits.

## References

1. OWASP Foundation, *OWASP Top Ten Web Application Security Risks*. https://owasp.org
2. Microsoft Corporation, *Threat Modeling — STRIDE Approach*, Microsoft Learn.
3. M. Souppaya, K. Scarfone, D. Dodson, *Secure Software Development Framework (SSDF) v1.1*,
   NIST SP 800-218, 2022.
4. S. A. Ebad, "Exploring how to apply secure software design principles," *IEEE Access*,
   vol. 10, 2022.
5. G. McGraw, *Software Security: Building Security In*, Addison-Wesley, 2006.
