# Linux Security Audit Tool

![Version](https://img.shields.io/badge/version-3.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Linux-red.svg)

A comprehensive bash-based security auditing tool for Linux systems that performs in-depth security analysis and generates detailed reports in multiple formats.

## 📋 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Output Formats](#-output-formats)
- [Audit Sections](#-audit-sections)
- [PDF Generation](#-pdf-generation)
- [Examples](#-examples)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

## 🔍 Overview

Linux Security Audit Tool is a powerful bash script designed to perform comprehensive security audits on Linux systems. It checks system configuration, user accounts, network settings, open ports, and generates detailed security reports with recommendations.

## ✨ Features

### 🔒 System Security Audit
- User account analysis (UID 0 accounts, empty passwords)
- SSH configuration review
- File system permissions (SUID/SGID, world-writable files)
- Kernel security parameters
- Logging and audit configuration
- Package management and security updates
- Cron job analysis
- SELinux/AppArmor status

### 🌐 Network Security Audit
- Network interface analysis
- Firewall configuration (iptables, UFW, firewalld)
- Active network connections
- DNS configuration
- Routing tables
- Network statistics

### 🔌 Port Scanning
- TCP/UDP port analysis
- Service identification
- Process-port mapping
- Nmap integration (optional)
- Fallback port checking

### 📊 Reporting
- **Multiple output formats**: TXT, PDF, or both
- **Timestamped reports**: Automatically named with date/time
- **Color-coded terminal output**: Easy-to-read console display
- **Security recommendations**: Actionable insights
- **Critical findings**: Highlighted security issues

## 📋 Prerequisites

### Required
- **Linux operating system** (any distribution)
- **Bash shell** (version 4.0 or higher)
- **Root/sudo access** (recommended for complete audit)

### Optional (for PDF generation)
Choose one of these tools for PDF output:
- **enscript + ghostscript** (recommended)
- **pandoc**
- **wkhtmltopdf**

## 🚀 Installation

### Method 1: Direct Download
```bash
# Download the script
wget https://raw.githubusercontent.com/MokshSharma2006/Linux-Audit-Tool/main/Linux_Audit_Tool.sh

# Make it executable
chmod +x Linux_Audit_Tool.sh
```

### Method 2: Clone Repository
```bash
# Clone the repository
git clone https://github.com/MokshSharma2006/Linux-Audit-Tool.git

# Navigate to directory
cd Linux-Audit-Tool

# Make it executable
chmod +x Linux_Audit_Tool.sh
```

## 🎯 Usage

### Basic Usage
```bash
# Run with default TXT output
sudo ./Linux_Audit_Tool.sh
```

### Command Line Options
```bash
# Show help
./Linux_Audit_Tool.sh -h
./Linux_Audit_Tool.sh --help

# Verbose mode (more detailed output)
sudo ./Linux_Audit_Tool.sh -v

# Quiet mode (minimal console output)
sudo ./Linux_Audit_Tool.sh -q

# Specify output format
sudo ./Linux_Audit_Tool.sh -f txt    # TXT format only
sudo ./Linux_Audit_Tool.sh -f pdf    # PDF format only
sudo ./Linux_Audit_Tool.sh -f both   # Both TXT and PDF formats
```

### Interactive Mode
When run without command-line arguments, the script will interactively ask for:
1. Output format (TXT/PDF/Both)
2. PDF tool installation (if needed)

## 📁 Output Formats

### Option 1: TXT Format
- **Default format**, always available
- Lightweight and universally readable
- Filename: `Linux_security_audit_YYYYMMDD_HHMMSS.txt`

### Option 2: PDF Format
- Professional document format
- Requires additional tools (will prompt to install if missing)
- Filename: `Linux_security_audit_YYYYMMDD_HHMMSS.pdf`

### Option 3: Both Formats
- Saves report in both TXT and PDF
- Best of both worlds
- Both files saved with same timestamp

## 🔧 Audit Sections

### 1. System Security Audit
```
1.1 - User Accounts
1.2 - Password Hashes
1.3 - Empty Password Accounts
1.4 - UID 0 Accounts
1.5 - Last Logins
1.6 - Failed Login Attempts
1.7 - Password Aging Policy
1.8 - SSH Configuration
1.9 - SSH Root Login Status
1.10 - SSH Protocol Version
1.11 - World Writable Files
1.12 - SUID/SGID Files
1.13 - Unowned Files
1.14 - Critical Directory Permissions
1.15 - Critical File Permissions
1.16 - Core Dump Configuration
1.17 - ASLR Status
1.18 - Kernel Security Parameters
1.19 - Audit Daemon Status
1.20 - Audit Rules
1.21 - System Log Files
1.22 - Recent Authentication Logs
1.23 - Installed Packages Count
1.24 - Security Updates Available
1.25 - System Cron Jobs
1.26 - Active Cron Jobs
1.27 - SELinux Status
1.28 - AppArmor Status
```

### 2. Network Security Audit
```
2.1 - Network Interfaces
2.2 - Active Network Interfaces
2.3 - Listening TCP Services
2.4 - Listening UDP Services
2.5 - All Network Connections
2.6 - IPTables Firewall Rules
2.7 - UFW Firewall Status
2.8 - Firewalld Status
2.9 - DNS Configuration
2.10 - Network Routing Table
2.11 - ARP Table
2.12 - Network Interface Statistics
2.13 - Network Protocol Statistics
```

### 3. Port Scanning Analysis
```
3.1 - Quick Port Scan (Top 1000)
3.2 - Service Version Detection
3.3 - UDP Port Scan
3.4 - Currently Listening Services
3.5 - Process-Port Mapping
```

### 4. Security Summary & Recommendations
- Critical security findings
- Actionable recommendations
- Audit completion statistics

## 📄 PDF Generation

The script supports multiple PDF generation methods and will automatically detect available tools:

### Method 1: enscript + ghostscript (Recommended)
```bash
# Debian/Ubuntu
sudo apt install enscript ghostscript

# Red Hat/CentOS/Fedora
sudo yum install enscript ghostscript
# or
sudo dnf install enscript ghostscript

# Arch Linux
sudo pacman -S enscript ghostscript

# openSUSE
sudo zypper install enscript ghostscript
```

### Method 2: pandoc
```bash
# Debian/Ubuntu
sudo apt install pandoc

# Red Hat/CentOS/Fedora
sudo yum install pandoc
```

### Method 3: wkhtmltopdf
```bash
# Debian/Ubuntu
sudo apt install wkhtmltopdf

# Red Hat/CentOS/Fedora
sudo yum install wkhtmltopdf
```

If PDF tools are not installed, the script will:
1. Detect your Linux distribution
2. Offer to install tools automatically
3. Show installation instructions
4. Allow fallback to TXT format

## 💡 Examples

### Example 1: Basic Audit with TXT Output
```bash
sudo ./Linux_Audit_Tool.sh
```
```
===============================================================
            L I N U X   A U D I T                               
===============================================================
 Version : 3.0
 Author  : Moksh Sharma
===============================================================

[+] Running with root privileges - full audit available

════════════════════════════════════════════════════════════════════
                 CHOOSE OUTPUT FORMAT
════════════════════════════════════════════════════════════════════

[1] Text File (TXT) - Default
[2] PDF Document (PDF) - Professional format
[3] Both Formats (TXT + PDF) - Save in both formats

Select output format [1/2/3] (default: 1): 1
[+] Selected TXT format only

[*] Initializing Linux security audit...
Progress: 25% - System Security Audit

╔══════════════════════════════════════════════════════════════════════════════╗
║                           1. SYSTEM SECURITY AUDIT                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

[*] 1.1 - Checking: User Accounts
[*] 1.2 - Checking: Password Hashes
...
```

### Example 2: PDF Output with Auto-Install
```bash
sudo ./Linux_Audit_Tool.sh -f pdf
```

If PDF tools are missing:
```
[!] PDF generation tools not found.
Would you like to install them?
1) Yes, install PDF tools (recommended)
2) No, continue with TXT format only
3) Exit

Enter your choice [1-3]: 1
[*] Attempting to install PDF tools...
[+] PDF tools installed successfully!
[+] Selected PDF format only
```

### Example 3: Both Formats
```bash
sudo ./Linux_Audit_Tool.sh -f both
```

### Example 4: Quiet Mode (for automation)
```bash
sudo ./Linux_Audit_Tool.sh -q -f pdf
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Contribution Ideas
- Add more security checks
- Improve PDF formatting
- Add support for more Linux distributions
- Create HTML output format
- Add email reporting feature
- Implement scheduling capabilities

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Moksh Sharma**
- GitHub: [@MokshSharma2006](https://github.com/MokshSharma2006)
- Project: [Linux-Audit-Tool](https://github.com/MokshSharma2006/Linux-Audit-Tool)

## 🙏 Acknowledgments

- Thanks to the Linux security community for inspiration
- Built with ❤️ for system administrators and security professionals

## 📞 Support

For issues, questions, or contributions:
- **GitHub Issues**: [Report a bug](https://github.com/MokshSharma2006/Linux-Audit-Tool/issues)
- **GitHub Discussions**: [Start a discussion](https://github.com/MokshSharma2006/Linux-Audit-Tool/discussions)

---

**Stay Secure!** 🔒
