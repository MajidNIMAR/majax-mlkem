<p align="center">
  <img src="docs/majax-logo.png" alt="Majax" width="136">
</p>

<h1 align="center">MAJAX ML-KEM</h1>

<p align="center">
  <strong>Post-Quantum Cryptographic Engine</strong><br>
  Rust library, executable engine and integration tools for ML-KEM-512, ML-KEM-768 and ML-KEM-1024.
</p>

<p align="center">
  <a href="https://github.com/MajidNIMAR/majax-mlkem/actions/workflows/verify.yml"><img alt="Engine verification" src="https://github.com/MajidNIMAR/majax-mlkem/actions/workflows/verify.yml/badge.svg?branch=main"></a>
  <img alt="Parameter sets" src="https://img.shields.io/badge/ML--KEM-512%20%2F%20768%20%2F%201024-20b7e8">
  <img alt="Interfaces" src="https://img.shields.io/badge/interfaces-Rust%20%2F%20CLI%20%2F%20HTTP-9ba8b8">
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0-f0a52b"></a>
</p>

---

## Cryptographic engine and architecture

MAJAX ML-KEM provides working key generation, encapsulation and decapsulation
through a typed Rust library and a JSON command-line interface. Applications
can select ML-KEM-512, ML-KEM-768 or ML-KEM-1024 through the same API;
ML-KEM-1024 is the default parameter set.

The project combines cryptographic implementation, integration and verification
engineering. It includes a complete ML-KEM-1024 HTTP execution path with
HKDF-SHA-256 and AES-256-GCM, portable and native performance backends, a
downstream Rust consumer, and reproducible build and assurance tools. The
library and executable can be used independently of Majax Messenger.

| Component | Current implementation | Source or guide |
|---|---|---|
| KEM library | Typed KeyGen, Encaps and Decaps for all three ML-KEM parameter sets | [Rust API](engine/src/lib.rs), [integration guide](INTEGRATION.md) |
| Executable engine | JSON CLI over the public library operations | [CLI](engine/src/main.rs) |
| Cryptographic backend | Pinned `pqcrypto-mlkem` / PQClean implementations, portable, AVX2 and AArch64/NEON | [Backend engineering](docs/development/step-05-performance-backends.md) |
| HTTP service | ML-KEM-1024 exchange, HKDF derivation, AES-256-GCM protection and negative checks | [Service](server.mjs), [web interface](public/index.html) |
| Verification and integration | Conformance fixtures, downstream consumer, fuzzing, memory and timing diagnostics, build evidence | [Engineering record](DEVELOPMENT.md) |

## What is available on main

The default branch contains the engine and the eight integrated engineering
milestones below.

1. A typed library API for KeyGen, Encaps and Decaps
2. One interface for ML-KEM-512, ML-KEM-768 and ML-KEM-1024
3. Deterministic conformance, rejection and negative tests
4. Fuzzing, memory checks and automated timing analysis
5. Portable, AVX2 and AArch64/NEON performance backends
6. Reproducible build checks and a release workflow for SBOMs, signatures and provenance
7. A tested downstream integration contract and adoption evidence policy
8. Public governance, maintenance, disclosure and roadmap documents

Each milestone is preserved as a separate commit and documented in
[`DEVELOPMENT.md`](DEVELOPMENT.md). The supplied Docker service activates
one ML-KEM-1024 engine per request; the Rust library and CLI expose all three
parameter sets.

## Complete ML-KEM-1024 execution

Each HTTP request creates fresh material and performs the following path.

1. Generate one ephemeral ML-KEM-1024 key pair
2. Encapsulate a shared secret with the public key
3. Decapsulate the ciphertext with the private key
4. Verify reciprocal agreement between both secrets
5. Derive an AES-256-GCM key with HKDF-SHA-256 and protect a user-supplied message
6. Alter the ML-KEM ciphertext and verify that the resulting secret diverges
7. Confirm that the divergent key cannot authenticate the protected envelope
8. Report standardized object dimensions, timings and SHA-256 fingerprints

The HTTP API never returns the private key or either shared secret. Ephemeral
material is held in memory for the request execution. The Rust API and CLI
return cryptographic objects to their caller for application integration;
their handling contract is documented in [`INTEGRATION.md`](INTEGRATION.md).

## Run the complete test

Docker is the only required host dependency.

```sh
sh scripts/test-all.sh
```

Windows PowerShell users can run the equivalent command.

```powershell
.\scripts\majax-engine.ps1 test
```

The default image compiles the Rust engine directly from `engine/` inside
digest-pinned Rust and Node environments. The automated verification performs
six cryptographic and integration checks before returning a successful result.

## Run the HTTP interface

Start the isolated service and open `http://127.0.0.1:6062`.

```sh
sh scripts/start.sh
```

The service binds to loopback by default. Public exposure requires a separate
TLS reverse proxy, explicit rate limiting and normal operational monitoring.

## Build for another Linux architecture

Export the standalone engine for Linux x86-64.

```sh
sh scripts/build-engine.sh linux/amd64
```

Export the same engine for Linux ARM64.

```sh
sh scripts/build-engine.sh linux/arm64
```

Generated binaries are written below `dist/` and remain outside version
control. Building ARM64 on an x86-64 host requires Docker Buildx with QEMU
emulation. A native ARM64 Docker host can build it directly.

## Use the supplied x86-64 binary

The repository includes a ready-to-run Linux x86-64 binary at
`bin/linux-x86_64/mlkem-cli` for the supplied HTTP verification path. Build
from `engine/` to use the current source implementation and library API.

Its expected SHA-256 fingerprint is recorded in `CHECKSUMS.sha256`.

```text
88b805e34122f91f98f89d30b01ba560c0a0148133753257011900f4ce7d35ca
```

Run its independent verification path with the following command.

```sh
sh scripts/test-prebuilt.sh
```

```powershell
.\scripts\majax-engine.ps1 test-prebuilt
```

## Reproducibility and evidence

The repository includes the material needed to inspect the build and its
dependencies.

- `engine/Cargo.lock` records exact Rust dependency versions and checksums
- `Dockerfile` compiles the engine from source using digest-pinned images
- `.github/workflows/verify.yml` repeats the complete test on every change
- `CHECKSUMS.sha256` records the supplied prebuilt binary's integrity fingerprint
- `THIRD_PARTY_NOTICES.md` records cryptographic attributions and licenses
- `scripts/generate-sbom.sh` emits SPDX JSON inventories for the source tree
  and final image

Generate the image identity, both SBOMs and their SHA-256 checksums locally.

```sh
sh scripts/generate-sbom.sh
```

The generated evidence is written below `artifacts/` and remains outside
version control.

## Verify release reproducibility

Build the release binary twice in clean, digest-pinned environments and require
the results to be byte-for-byte identical.

```sh
sh scripts/reproducible-build.sh
```

The release workflow is configured to build x86-64 and AArch64 binaries,
generate SPDX and CycloneDX SBOMs and SHA-256 checksums, sign artifacts with
keyless Sigstore bundles, and publish GitHub build provenance when a `v*` tag
is pushed. No release or tag is currently published. The process and its
verification boundary are documented in
[`docs/development/step-06-reproducible-releases.md`](docs/development/step-06-reproducible-releases.md).

## Compare portable and native backends

The main branch can compile either the portable PQClean implementation or
native AVX2 and AArch64/NEON backends. Run both policies on the same host and
produce raw and rendered performance evidence with one command.

```sh
sh scripts/run-benchmarks.sh
```

The report measures KeyGen, Encaps and Decaps for ML-KEM-512, ML-KEM-768 and
ML-KEM-1024. Backend selection and benchmark interpretation are documented in
[`docs/development/step-05-performance-backends.md`](docs/development/step-05-performance-backends.md).

## Integrate the Rust library

The main branch exposes one Rust API for ML-KEM-512, ML-KEM-768 and
ML-KEM-1024. A separate consumer package exercises that public boundary and
generates rustdoc in the same pinned environment used by continuous
integration.

```sh
sh scripts/test-integration.sh
```

Dependency pinning, feature selection, secret lifetime and protocol duties are
covered in [`INTEGRATION.md`](INTEGRATION.md). Independently verifiable adoption
is tracked separately in [`ADOPTERS.md`](ADOPTERS.md). No external adopter is
claimed without an identifiable project and immutable integration evidence.

## Security and verification scope

The engine uses the ML-KEM parameter sets defined by FIPS 203 through its
pinned cryptographic dependencies. Included tests exercise conformance,
rejection, object validation, integration and implementation behavior. Timing,
memory and fuzzing diagnostics retain the scope of their individual checks.

Successful execution establishes the properties exercised by those checks;
it does not constitute an independent audit or certification of this engine
or of an application using it. The repository contains no production keys,
credentials or Majax operational configuration. The security boundary and
private reporting process are documented in [`SECURITY.md`](SECURITY.md).

## Maintenance and contributions

Project decisions and cryptographic review requirements are documented in
[`GOVERNANCE.md`](GOVERNANCE.md). Contribution checks, supported revisions and
release discipline are covered by [`CONTRIBUTING.md`](CONTRIBUTING.md) and
[`MAINTENANCE.md`](MAINTENANCE.md). Planned public work remains visible in
[`ROADMAP.md`](ROADMAP.md).

Public build and integration questions may use GitHub issues. Suspected
vulnerabilities must follow the private process in `SECURITY.md`.

## Project identity

MAJAX ML-KEM is published by Majax as a standalone cryptographic engineering
project. Its public scope includes the executable engine, library API,
integration tools and verification workflow. It shares the author's research
background with Majax Messenger while providing its own public implementation
and integration boundary.

The project is distributed under Apache License 2.0. Third-party components
retain their own licenses and notices.
