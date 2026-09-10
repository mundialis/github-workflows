#!/usr/bin/env python3
"""Merge pip-licenses output with a SBOM into one
THIRD_PARTY_LICENSES.json file.

Python libary licences created with pip-licenses (incl. LicenseText, URL etc.),
all other system licences (apt/dpkg, apk, rpm, npm, gem, cargo,
go modules, ...) created via Syft SBOM. Python entries from
SBOM are discarded to avoid duplicates.

Usage:
    merge-licenses.py <pip-licenses.json> <syft.json> <output.json>
"""
import json
import sys

SOURCE_LABELS = {
    "deb": "apt/dpkg (OS package)",
    "apk": "apk (OS package)",
    "rpm": "rpm (OS package)",
    "npm": "npm",
    "gemspec": "gem",
    "go-module": "go module",
    "rust-crate": "cargo",
    "java-archive": "java (jar)",
}

# Ecosystems that are ignored by the Syft SBOM because they are already
# covered by pip-licenses.
EXCLUDE_SYFT_TYPES = {"python"}


def load_pip_licenses(path):
    with open(path) as f:
        data = json.load(f)
    entries = []
    for pkg in data:
        entries.append({
            "Name": pkg.get("Name"),
            "Version": pkg.get("Version"),
            "License": pkg.get("License", "UNKNOWN"),
            "Source": "python (pip)",
            "URL": pkg.get("URL"),
            "LicenseText": pkg.get("LicenseText"),
        })
    return entries


def extract_license(licenses):
    """Depending on the version, Syft’s ‘licence’ field takes different forms:
    either a list of strings, or a list of objects with a 'value' field.
    Both are handled here."""
    if not licenses:
        return "UNKNOWN"
    values = []
    for lic in licenses:
        if isinstance(lic, dict):
            values.append(lic.get("value") or lic.get("spdxExpression") or "UNKNOWN")
        else:
            values.append(str(lic))
    return ", ".join(sorted(set(values))) if values else "UNKNOWN"


def load_syft(path, exclude_types=EXCLUDE_SYFT_TYPES):
    with open(path) as f:
        data = json.load(f)
    entries = []
    for artifact in data.get("artifacts", []):
        pkg_type = artifact.get("type", "unknown")
        if pkg_type in exclude_types:
            continue
        entries.append({
            "Name": artifact.get("name"),
            "Version": artifact.get("version"),
            "License": extract_license(artifact.get("licenses")),
            "Source": SOURCE_LABELS.get(pkg_type, pkg_type),
        })
    return entries


def dedupe(entries):
    seen = set()
    result = []
    for entry in entries:
        key = (entry.get("Name"), entry.get("Version"), entry.get("Source"))
        if key in seen:
            continue
        seen.add(key)
        result.append(entry)
    return result


def main():
    if len(sys.argv) != 4:
        print(
            "Usage: merge-licenses.py <pip-licenses.json> <syft.json> <output.json>",
            file=sys.stderr,
        )
        sys.exit(1)

    pip_path, syft_path, out_path = sys.argv[1:4]

    entries = []
    entries += load_pip_licenses(pip_path)
    entries += load_syft(syft_path)
    entries = dedupe(entries)
    entries.sort(key=lambda e: (e.get("Source") or "", (e.get("Name") or "").lower()))

    with open(out_path, "w") as f:
        json.dump(entries, f, indent=2)

    print(f"Wrote {len(entries)} license entries to {out_path}")


if __name__ == "__main__":
    main()
