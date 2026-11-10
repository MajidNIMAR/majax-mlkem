# Security policy

## Engine and integration scope

MAJAX ML-KEM provides a Rust library and JSON CLI for ML-KEM-512, ML-KEM-768
and ML-KEM-1024, plus a standalone HTTP execution service using ML-KEM-1024,
HKDF-SHA-256 and AES-256-GCM. The public engine can be integrated independently
of Majax Messenger. It contains no production key, token, credential, user
record, endpoint configuration or operational secret from that service.

Successful execution proves only the properties checked by the included test
suite. It does not constitute an audit, certification or security assessment of
Majax or of any system using this engine.

## Supported versions

Security corrections are applied to the latest stable release and the current
`main` revision. Older revisions are retained for traceability but are not
supported. The complete branch and release policy appears in
`MAINTENANCE.md`.

## Reporting a vulnerability

Please use the private security advisory feature of the GitHub repository. Do
not disclose a suspected vulnerability in a public issue before a correction is
available.

The project does not promise a fixed response time. Private security reports
receive priority over routine issues, and material corrections follow a
coordinated disclosure process appropriate to their impact.

Include the affected revision, the execution platform, the observed behaviour,
the expected behaviour and the smallest reproducible test case. Do not include
real credentials, production data or secrets in the report.

## Operational boundaries

The service binds to loopback by default. Public exposure requires a separate
TLS reverse proxy, explicit rate limiting and normal operational monitoring.

In the HTTP service, the private key and shared secrets exist only inside a
short-lived execution. The HTTP API does not return them or persist them.
The Rust library and JSON CLI deliberately provide key material and shared
secrets to their caller for integration; the caller is responsible for their
storage, use and lifetime as described in `INTEGRATION.md`.

The supplied x86-64 binary can be checked against the checksum recorded in
`CHECKSUMS.sha256`. Users who require an independently built artifact should use
the default source-based Docker build.
