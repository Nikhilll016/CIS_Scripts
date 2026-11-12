
# CIS Scripts

A collection of Bash-based Linux security auditing scripts designed to help administrators review system configurations against selected security baseline checks.

## Current Tools

### Linux Baseline Security Audit

File: `linux_baseline_audit.sh`

This script performs read-only checks for:

- Permissions and ownership of critical Linux account files.
- SSH root login configuration.
- SSH password authentication configuration.
- Basic audit results with PASS, WARN and SKIP counts.

## Requirements

- Linux operating system.
- Bash.
- Standard Linux utilities such as `stat` and `awk`.
- OpenSSH server tools for SSH configuration checks.

## Usage

Clone the repository:

```bash
git clone https://github.com/Nikhilll016/CIS_Scripts.git
cd CIS_Scripts
```

Make the script executable:

```bash
chmod +x linux_baseline_audit.sh
```

Run the audit:

```bash
./linux_baseline_audit.sh
```

Some checks may require elevated privileges to read protected system files.

## Security Notes

- The script is designed to be read-only.
- It does not automatically modify system configurations.
- Review warnings manually before applying changes.
- Results are not a certification of CIS Benchmark compliance.

## Scope and Limitations

This is an initial baseline auditing tool. It does not implement a complete CIS Benchmark and has not yet been validated across all Linux distributions.

## Contributions

Bug reports, testing feedback and improvements are welcome through GitHub issues and pull requests.

## License

See the LICENSE file when one is added.
