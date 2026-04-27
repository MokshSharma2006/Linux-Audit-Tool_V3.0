#!/bin/bash

# Linux Audit Tool
# Version: 3.0
# Author: Moksh Sharma

echo " _     _                         _             _ _ _      _____           _"
echo "| |   (_)_ __  _   ___  __      / \  _   _  __| (_) |_   |_   _|__   ___ | |"
echo "| |   | | '_ \| | | \ \/ /____ / _ \| | | |/ _\` | | __|____| |/ _ \ / _ \| |"
echo "| |___| | | | | |_| |>  <_____/ ___ \ |_| | (_| | | ||_____| | (_) | (_) | |"
echo "|_____|_|_| |_|\__,_/_/\_\   /_/   \_\__,_|\__,_|_|\__|    |_|\___/ \___/|_|"

echo ""
echo ""

echo "================================================================"
echo "            L I N U X   A U D I T                               "
echo "================================================================"
echo " Version : 3.0"
echo " Author  : Moksh Sharma"
echo " Project : Linux-Audit-Tool"
echo " GitHub  : https://github.com/MokshSharma2006"
echo "================================================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Global variables
SCRIPT_START_TIME=$(date +%s)
OUTPUT_FORMAT="txt"
OUTPUT_FILE_TXT=""
OUTPUT_FILE_PDF=""
TEMP_FILE="/tmp/security_audit_temp_$$.txt"

# ──────────────────────────────────────────────────────────────────
# Privilege handling
# ──────────────────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Color support detection
if [ -t 1 ] && [ "$TERM" != "dumb" ]; then
    USE_COLORS=1
else
    USE_COLORS=0
fi

print_color() {
    local color=$1
    local message=$2
    if [ $USE_COLORS -eq 1 ]; then
        echo -e "${color}${message}${NC}"
    else
        echo "$message"
    fi
}

banner() {
    if [ $USE_COLORS -eq 1 ]; then
        echo -e "${CYAN}"
        echo "  ╔═══════════════════════════════════════════════════════════╗"
        echo "  ║                LINUX SECURITY AUDIT TOOL                  ║"
        echo "  ║                    Enhanced Version 3.0                   ║"
        echo "  ╚═══════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    else
        echo "  ==============================================================="
        echo "                LINUX SECURITY AUDIT TOOL v3.0                   "
        echo "  ==============================================================="
    fi
    echo -e "${YELLOW}Date: $(date)${NC}"
    echo -e "${YELLOW}Hostname: $(hostname)${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
}

detect_distro() {
    if [ -f /etc/debian_version ]; then echo "debian"
    elif [ -f /etc/redhat-release ]; then echo "redhat"
    elif [ -f /etc/arch-release ]; then echo "arch"
    elif [ -f /etc/fedora-release ]; then echo "fedora"
    elif [ -f /etc/SuSE-release ]; then echo "suse"
    else echo "unknown"
    fi
}

install_pdf_tools() {
    local distro=$(detect_distro)
    echo -e "\n${YELLOW}[!] PDF generation tools are not installed.${NC}"
    echo -e "${CYAN}Choose an option:${NC}"
    echo "1) Install PDF tools automatically"
    echo "2) Show installation instructions"
    echo "3) Continue with TXT format only"
    echo "4) Exit"
    while true; do
        read -p "Enter your choice [1-4]: " install_choice
        case $install_choice in
            1)
                echo -e "${YELLOW}[*] Attempting to install PDF tools...${NC}"
                case $distro in
                    debian)   $SUDO apt update && $SUDO apt install -y enscript ghostscript cups-client vim ;;
                    redhat|fedora) $SUDO yum install -y enscript ghostscript cups-client vim || $SUDO dnf install -y enscript ghostscript cups-client vim ;;
                    arch)     $SUDO pacman -S --noconfirm enscript ghostscript cups vim ;;
                    suse)     $SUDO zypper install -y enscript ghostscript cups-client vim ;;
                    *)
                        echo -e "${RED}[-] Automatic install not supported for your distro.${NC}"
                        return 2 ;;
                esac
                if command -v enscript >/dev/null 2>&1 && command -v ps2pdf >/dev/null 2>&1; then
                    echo -e "${GREEN}[+] PDF tools installed successfully!${NC}"; return 0
                else
                    echo -e "${RED}[-] Installation failed.${NC}"; return 2
                fi ;;
            2)
                echo -e "\n${CYAN}=== Installation Instructions ===${NC}"
                case $distro in
                    debian)      echo "Run: sudo apt update && sudo apt install enscript ghostscript cups-client vim" ;;
                    redhat|fedora) echo "Run: sudo yum install enscript ghostscript cups-client vim" ;;
                    arch)        echo "Run: sudo pacman -S enscript ghostscript cups vim" ;;
                    suse)        echo "Run: sudo zypper install enscript ghostscript cups-client vim" ;;
                    *)           echo "Please install: enscript ghostscript cups-client vim" ;;
                esac
                echo "" ;;
            3) echo -e "${YELLOW}[!] Continuing with TXT format only...${NC}"; return 2 ;;
            4) echo -e "${RED}[-] Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice. Please enter 1-4.${NC}" ;;
        esac
    done
}

# ──────────────────────────────────────────────────────────────────
# AUTO-INSTALL AUDIT TOOLS
# ──────────────────────────────────────────────────────────────────
auto_install_audit_tools() {
    local distro=$(detect_distro)
    local missing_tools=()

    # Reduced to core tools to prevent endless install loops for OS-specific binaries
    local tool_pkg_map=(
        "nmap:nmap"
        "lsof:lsof"
        "ss:iproute2"
        "netstat:net-tools"
        "auditctl:auditd"
    )

    echo -e "\n${CYAN}[*] Checking for required audit tools...${NC}"

    for entry in "${tool_pkg_map[@]}"; do
        local bin="${entry%%:*}"
        local pkg="${entry##*:}"
        if ! command -v "$bin" >/dev/null 2>&1; then
            missing_tools+=("$bin ($pkg)")
        fi
    done

    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo -e "${GREEN}[+] All core audit tools are present.${NC}"
        return 0
    fi

    echo -e "${YELLOW}[!] Missing tools detected:${NC}"
    for t in "${missing_tools[@]}"; do
        echo -e "    ${RED}✗${NC} $t"
    done

    echo ""
    echo "1) Install missing tools automatically (recommended)"
    echo "2) Continue without them (some checks may be incomplete)"
    echo "3) Exit"

    while true; do
        read -p "Enter your choice [1-3]: " tool_choice
        case $tool_choice in
            1)
                echo -e "${YELLOW}[*] Installing missing tools...${NC}"
                # Build unique package list
                local pkgs_to_install=()
                for entry in "${tool_pkg_map[@]}"; do
                    local bin="${entry%%:*}"
                    local pkg="${entry##*:}"
                    if ! command -v "$bin" >/dev/null 2>&1; then
                        pkgs_to_install+=("$pkg")
                    fi
                done
                # Deduplicate
                local unique_pkgs=($(printf '%s\n' "${pkgs_to_install[@]}" | sort -u))

                case $distro in
                    debian)
                        $SUDO apt-get update -qq && $SUDO apt-get install -y "${unique_pkgs[@]}" 2>/dev/null
                        ;;
                    redhat|fedora)
                        $SUDO yum install -y "${unique_pkgs[@]}" 2>/dev/null || \
                        $SUDO dnf install -y "${unique_pkgs[@]}" 2>/dev/null
                        ;;
                    arch)
                        $SUDO pacman -S --noconfirm "${unique_pkgs[@]}" 2>/dev/null
                        ;;
                    suse)
                        $SUDO zypper install -y "${unique_pkgs[@]}" 2>/dev/null
                        ;;
                    *)
                        echo -e "${RED}[-] Auto-install not supported for your distro. Install manually.${NC}"
                        return 1
                        ;;
                esac

                echo -e "${GREEN}[+] Tool installation complete.${NC}"
                return 0
                ;;
            2)
                echo -e "${YELLOW}[!] Continuing — some audit checks may show errors.${NC}"
                return 0
                ;;
            3)
                echo -e "${RED}[-] Exiting.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                ;;
        esac
    done
}

check_pdf_tools() {
    if command -v enscript >/dev/null 2>&1 && command -v ps2pdf >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Found enscript and ps2pdf${NC}"; return 0
    elif command -v cupsfilter >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Found cupsfilter${NC}"; return 0
    elif command -v vim >/dev/null 2>&1 && command -v ps2pdf >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Found vim and ps2pdf${NC}"; return 0
    fi
    echo -e "\n${YELLOW}[!] PDF generation tools not found.${NC}"
    echo "1) Yes, install PDF tools"
    echo "2) No, use TXT only"
    echo "3) Exit"
    while true; do
        read -p "Enter your choice [1-3]: " pdf_choice
        case $pdf_choice in
            1) if install_pdf_tools; then return 0; else return 1; fi ;;
            2) echo -e "${YELLOW}[!] Using TXT format only...${NC}"; return 1 ;;
            3) echo -e "${RED}[-] Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice.${NC}" ;;
        esac
    done
}

choose_output_format() {
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                 CHOOSE OUTPUT FORMAT                               ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}\n"
    echo -e "${YELLOW}[1]${NC} Text File (TXT) - Default"
    echo -e "${YELLOW}[2]${NC} PDF Document"
    echo -e "${YELLOW}[3]${NC} Both (TXT + PDF)"
    echo ""
    while true; do
        read -p "Select output format [1/2/3] (default: 1): " format_choice
        case "${format_choice:-1}" in
            1) OUTPUT_FORMAT="txt";  echo -e "${GREEN}[+] TXT selected${NC}"; break ;;
            2)
                if check_pdf_tools; then OUTPUT_FORMAT="pdf"; echo -e "${GREEN}[+] PDF selected${NC}"
                else OUTPUT_FORMAT="txt"; echo -e "${YELLOW}[!] Falling back to TXT${NC}"; fi
                break ;;
            3)
                if check_pdf_tools; then OUTPUT_FORMAT="both"; echo -e "${GREEN}[+] Both selected${NC}"
                else OUTPUT_FORMAT="txt"; echo -e "${YELLOW}[!] PDF unavailable, using TXT${NC}"; fi
                break ;;
            *) echo -e "${RED}Invalid choice. Enter 1, 2, or 3.${NC}" ;;
        esac
    done
    local timestamp=$(date +%Y%m%d_%H%M%S)
    OUTPUT_FILE_TXT="Linux_security_audit_${timestamp}.txt"
    OUTPUT_FILE_PDF="Linux_security_audit_${timestamp}.pdf"
}

convert_to_pdf() {
    local txt_file=$1
    local pdf_file=$2
    echo -e "${YELLOW}[*] Converting to PDF...${NC}"

    if command -v python3 >/dev/null 2>&1 && python3 -c "import reportlab" 2>/dev/null; then
        python3 - "$txt_file" "$pdf_file" << 'PYEOF'
import sys, os
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, HRFlowable, Table, TableStyle, PageBreak
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER

txt_file, pdf_file = sys.argv[1], sys.argv[2]

with open(txt_file, 'r', errors='replace') as f:
    raw_lines = f.readlines()

doc = SimpleDocTemplate(
    pdf_file, pagesize=A4,
    leftMargin=15*mm, rightMargin=15*mm,
    topMargin=20*mm, bottomMargin=20*mm,
    title="Linux Security Audit Report"
)

styles = getSampleStyleSheet()
style_title   = ParagraphStyle('T', fontName='Helvetica-Bold',   fontSize=16, textColor=colors.HexColor('#1a237e'), spaceAfter=4, alignment=TA_CENTER)
style_section = ParagraphStyle('S', fontName='Helvetica-Bold',   fontSize=11, textColor=colors.HexColor('#0d47a1'), spaceBefore=10, spaceAfter=4, leading=14)
style_subhdr  = ParagraphStyle('H', fontName='Helvetica-Bold',   fontSize=9,  textColor=colors.HexColor('#37474f'), spaceBefore=6, spaceAfter=2, leading=11)
style_meta    = ParagraphStyle('M', fontName='Helvetica',        fontSize=8,  textColor=colors.HexColor('#546e7a'), spaceAfter=2, leading=10)
style_code    = ParagraphStyle('C', fontName='Courier',          fontSize=7,  textColor=colors.HexColor('#212121'), spaceAfter=1, leading=9, leftIndent=6)
style_ok      = ParagraphStyle('OK',fontName='Helvetica-Bold',   fontSize=7.5,textColor=colors.HexColor('#1b5e20'), spaceAfter=3, leading=9)
style_fail    = ParagraphStyle('FL',fontName='Helvetica-Bold',   fontSize=7.5,textColor=colors.HexColor('#b71c1c'), spaceAfter=3, leading=9)
style_warn    = ParagraphStyle('WN',fontName='Helvetica-Bold',   fontSize=7.5,textColor=colors.HexColor('#e65100'), spaceAfter=3, leading=9)
style_normal  = ParagraphStyle('N', fontName='Helvetica',        fontSize=8,  textColor=colors.HexColor('#212121'), spaceAfter=2, leading=10)

def esc(t):
    return t.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')

story = []

# --- Cover page ---
story.append(Spacer(1, 18*mm))
story.append(HRFlowable(width="100%", thickness=3, color=colors.HexColor('#1a237e')))
story.append(Spacer(1, 4*mm))
story.append(Paragraph("LINUX SECURITY AUDIT REPORT", style_title))
story.append(Paragraph("Comprehensive Security Assessment", ParagraphStyle('sub', fontName='Helvetica', fontSize=10, textColor=colors.HexColor('#455a64'), alignment=TA_CENTER, spaceAfter=4)))
story.append(Spacer(1, 3*mm))
story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#90a4ae')))
story.append(Spacer(1, 8*mm))

# Extract metadata from file header
meta = {}
for line in raw_lines[:20]:
    for k in ['Generated on', 'Hostname', 'Kernel Version', 'Distribution', 'IP Address', 'User', 'Working Dir']:
        if line.strip().startswith(k):
            val = line.split(':', 1)[-1].strip()
            meta[k] = val

meta_data = [
    ['Field', 'Value'],
    ['Generated On',  meta.get('Generated on', 'N/A')],
    ['Hostname',      meta.get('Hostname', 'N/A')],
    ['Kernel',        meta.get('Kernel Version', 'N/A')],
    ['Distribution',  meta.get('Distribution', 'N/A')],
    ['IP Address',    meta.get('IP Address', 'N/A')],
    ['Audited User',  meta.get('User', 'N/A')],
]
t = Table(meta_data, colWidths=[45*mm, 120*mm])
t.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#1a237e')),
    ('TEXTCOLOR',  (0,0), (-1,0), colors.white),
    ('FONTNAME',   (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE',   (0,0), (-1,-1), 8),
    ('BACKGROUND', (0,1), (-1,-1), colors.HexColor('#f5f5f5')),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#fafafa'), colors.HexColor('#e8eaf6')]),
    ('GRID',       (0,0), (-1,-1), 0.5, colors.HexColor('#90a4ae')),
    ('FONTNAME',   (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR',  (0,1), (0,-1), colors.HexColor('#37474f')),
    ('ALIGN',      (0,0), (-1,-1), 'LEFT'),
    ('PADDING',    (0,0), (-1,-1), 5),
    ('VALIGN',     (0,0), (-1,-1), 'MIDDLE'),
]))
story.append(t)
story.append(Spacer(1, 6*mm))

# TOC
story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#90a4ae')))
story.append(Spacer(1, 3*mm))
story.append(Paragraph("TABLE OF CONTENTS", style_section))
toc_items = [
    "1. System Security Audit  (checks 1.1 - 1.50)",
    "2. Network Security Audit  (checks 2.1 - 2.22)",
    "3. Port Scanning Analysis  (checks 3.1 - 3.8)",
    "4. Security Summary &amp; Recommendations",
]
for item in toc_items:
    story.append(Paragraph(item, ParagraphStyle('toc', fontName='Helvetica', fontSize=9, textColor=colors.HexColor('#37474f'), leftIndent=10, spaceAfter=3, leading=11)))
story.append(Spacer(1, 4*mm))
story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#1a237e')))
story.append(PageBreak())

# --- Body ---
BOX_CHARS = set('╔╗╚╝║═╠╣╦╩╬┌┐└┘│─├┤┬┴┼')

def is_separator(line):
    stripped = line.strip()
    if not stripped:
        return False
    unique = set(stripped)
    return unique <= BOX_CHARS or unique <= {'=', '-', '─'} or '═══' in stripped or '╔══' in stripped or '╚══' in stripped

def is_section_header(line):
    stripped = line.strip()
    for mark in ['1. SYSTEM', '2. NETWORK', '3. PORT SCAN', '4. SECURITY SUMMARY']:
        if mark in stripped.upper():
            return True
    return False

def is_check_header(line):
    import re
    return bool(re.match(r'.*\d+\.\d+\s*[-\u2013]\s*\S', line.strip()))

def classify_status(line):
    u = line.upper()
    if 'STATUS: SUCCESS' in u:
        return 'ok'
    if 'STATUS: FAILED' in u or 'STATUS: FAIL' in u:
        return 'fail'
    if 'CRITICAL' in u or 'WARNING' in u or 'WARN' in u:
        return 'warn'
    return None

in_section = False
for raw in raw_lines:
    line = raw.rstrip('\n')
    clean = ''.join(c for c in line if c not in BOX_CHARS)

    if is_separator(line):
        story.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor('#b0bec5'), spaceAfter=2, spaceBefore=2))
        continue

    if is_section_header(line):
        story.append(Spacer(1, 4*mm))
        story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#0d47a1')))
        story.append(Paragraph(esc(clean.strip()), style_section))
        story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#90a4ae')))
        continue

    if is_check_header(line):
        story.append(Spacer(1, 3*mm))
        story.append(Paragraph(esc(clean.strip()), style_subhdr))
        continue

    st = classify_status(line)
    if st == 'ok':
        story.append(Paragraph('&#10003; ' + esc(clean.strip()), style_ok))
        continue
    if st == 'fail':
        story.append(Paragraph('&#10007; ' + esc(clean.strip()), style_fail))
        continue
    if st == 'warn':
        story.append(Paragraph('&#9888; ' + esc(clean.strip()), style_warn))
        continue

    stripped = clean.strip()
    if not stripped:
        story.append(Spacer(1, 1.5*mm))
        continue

    if line.startswith('Description:') or line.startswith('Timestamp:'):
        story.append(Paragraph(esc(stripped), style_meta))
    else:
        story.append(Paragraph(esc(stripped), style_code))

def add_page_number(canvas, doc):
    canvas.saveState()
    canvas.setFont('Helvetica', 7)
    canvas.setFillColor(colors.HexColor('#90a4ae'))
    canvas.drawString(15*mm, 10*mm, "Linux Security Audit Report  |  Confidential")
    canvas.drawRightString(A4[0] - 15*mm, 10*mm, f"Page {doc.page}")
    canvas.setStrokeColor(colors.HexColor('#e0e0e0'))
    canvas.line(15*mm, 13*mm, A4[0]-15*mm, 13*mm)
    canvas.restoreState()

doc.build(story, onFirstPage=add_page_number, onLaterPages=add_page_number)
print("PDF created via Python/reportlab")
PYEOF
        if [ -s "$pdf_file" ]; then
            echo -e "${GREEN}[+] PDF via Python/reportlab (clean formatting)${NC}"
            return 0
        fi
    fi

    if command -v cupsfilter >/dev/null 2>&1; then
        local tmp="/tmp/tmp_utf8_$$.txt"
        iconv -f UTF-8 -t UTF-8 "$txt_file" > "$tmp" 2>/dev/null || cp "$txt_file" "$tmp"
        cupsfilter "$tmp" > "$pdf_file" 2>/dev/null
        rm -f "$tmp"
        [ -s "$pdf_file" ] && { echo -e "${GREEN}[+] PDF via cupsfilter${NC}"; return 0; }
    fi

    if command -v vim >/dev/null 2>&1 && command -v ps2pdf >/dev/null 2>&1; then
        local tmp_ps="/tmp/tmp_audit_$$.ps"
        cat > /tmp/vim2ps_$$.vim << EOF
:set enc=utf-8
:set fenc=utf-8
:set printencoding=utf-8
:hardcopy > ${tmp_ps}
:q
EOF
        vim -u NONE -U NONE -N -e -s "$txt_file" -S /tmp/vim2ps_$$.vim 2>/dev/null
        rm -f /tmp/vim2ps_$$.vim
        if [ -f "$tmp_ps" ]; then
            ps2pdf "$tmp_ps" "$pdf_file" 2>/dev/null; rm -f "$tmp_ps"
            [ -f "$pdf_file" ] && { echo -e "${GREEN}[+] PDF via vim+ps2pdf${NC}"; return 0; }
        fi
    fi

    if command -v enscript >/dev/null 2>&1 && command -v ps2pdf >/dev/null 2>&1; then
        local tmp_ps="/tmp/tmp_audit_$$.ps"
        enscript --encoding=utf-8 --font=Courier10 --landscape --word-wrap \
                 --margins=30:30:30:30 --output="$tmp_ps" "$txt_file" 2>/dev/null
        if [ -f "$tmp_ps" ]; then
            ps2pdf "$tmp_ps" "$pdf_file" 2>/dev/null; rm -f "$tmp_ps"
            [ -f "$pdf_file" ] && { echo -e "${GREEN}[+] PDF via enscript+ps2pdf${NC}"; return 0; }
        fi
    fi

    if command -v wkhtmltopdf >/dev/null 2>&1; then
        local html="/tmp/tmp_audit_$$.html"
        printf '<!DOCTYPE html><html><head><meta charset="UTF-8"><style>body{font-family:monospace;font-size:11pt;margin:40px}pre{white-space:pre-wrap;word-wrap:break-word}</style></head><body><pre>' > "$html"
        cat "$txt_file" >> "$html"
        printf '</pre></body></html>' >> "$html"
        wkhtmltopdf --encoding utf-8 "$html" "$pdf_file" 2>/dev/null
        rm -f "$html"
        [ -f "$pdf_file" ] && { echo -e "${GREEN}[+] PDF via wkhtmltopdf${NC}"; return 0; }
    fi

    local asc="/tmp/tmp_ascii_$$.txt"
    sed 's/╔/+/g;s/╗/+/g;s/╚/+/g;s/╝/+/g;s/║/|/g;s/═/-/g;s/─/-/g;s/│/|/g;s/┌/+/g;s/┐/+/g;s/└/+/g;s/┘/+/g' "$txt_file" > "$asc"
    if command -v enscript >/dev/null 2>&1 && command -v ps2pdf >/dev/null 2>&1; then
        local tmp_ps="/tmp/tmp_audit_$$.ps"
        enscript --output="$tmp_ps" "$asc" 2>/dev/null
        ps2pdf "$tmp_ps" "$pdf_file" 2>/dev/null
        rm -f "$tmp_ps" "$asc"
        [ -f "$pdf_file" ] && { echo -e "${GREEN}[+] PDF via ASCII fallback${NC}"; return 0; }
    fi
    rm -f "$asc"
    echo -e "${RED}[-] All PDF methods failed.${NC}"; return 1
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo -e "${RED}[-] $1 is not installed${NC}"; return 1
    fi
    return 0
}

check_append() {
    local section_num=$1
    local title=$2
    local command=$3
    local description=$4

    echo -e "${YELLOW}[*] $section_num - Checking: $title${NC}"

    cat >> "$TEMP_FILE" << EOF

┌─────────────────────────────────────────────────────────────────────────────┐
│ $section_num - $title
└─────────────────────────────────────────────────────────────────────────────┘
Description: $description
Timestamp: $(date)

EOF

    if eval "$command" >> "$TEMP_FILE" 2>&1; then
        echo "Status: SUCCESS" >> "$TEMP_FILE"
    else
        local exit_code=$?
        if [ $exit_code -eq 1 ]; then
            echo "Status: SUCCESS (no matches found)" >> "$TEMP_FILE"
        else
            echo "Status: FAILED or INCOMPLETE (exit code: $exit_code)" >> "$TEMP_FILE"
        fi
    fi

    printf '\n────────────────────────────────────────────────────────────────────────────\n\n' >> "$TEMP_FILE"
}

initialize_output() {
    cat > "$TEMP_FILE" << EOF
╔══════════════════════════════════════════════════════════════════════════════╗
║                          LINUX SECURITY AUDIT REPORT                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

Generated on   : $(date)
Hostname       : $(hostname)
Kernel Version : $(uname -r)
Distribution   : $(lsb_release -d 2>/dev/null | cut -f2- || grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Unknown")
IP Address     : $(hostname -I 2>/dev/null | awk '{print $1}' || echo "Unknown")
User           : $(whoami)
Working Dir    : $(pwd)

╔══════════════════════════════════════════════════════════════════════════════╗
║                                TABLE OF CONTENTS                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

1. SYSTEM SECURITY AUDIT      (checks 1.1 – 1.50)
2. NETWORK SECURITY AUDIT     (checks 2.1 – 2.22)
3. PORT SCANNING ANALYSIS     (checks 3.1 – 3.8)
4. SECURITY SUMMARY & RECOMMENDATIONS

══════════════════════════════════════════════════════════════════════════════

EOF
}

system_security_audit() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                           1. SYSTEM SECURITY AUDIT                          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"

    printf '\n╔══════════════════════════════════════════════════════════════════════════════╗\n' >> "$TEMP_FILE"
    printf '║                           1. SYSTEM SECURITY AUDIT                           ║\n' >> "$TEMP_FILE"
    printf '╚══════════════════════════════════════════════════════════════════════════════╝\n' >> "$TEMP_FILE"

    check_append "1.1"  "User Accounts"              "cat /etc/passwd" "All user accounts on the system"
    check_append "1.2"  "Password Hashes"            "$SUDO cat /etc/shadow 2>/dev/null || echo 'Access denied'" "Password hashes and account expiry info"
    check_append "1.3"  "Empty Password Accounts"    "$SUDO awk -F: '(\$2==\"\"){print \$1\" - CRITICAL: Empty Password!\"}' /etc/shadow 2>/dev/null || echo 'Requires root'" "Accounts with no password set (critical risk)"
    check_append "1.4"  "UID 0 Accounts"             "awk -F: '(\$3==0){print \$1\" - UID 0 (root equivalent)\"}' /etc/passwd" "Any account with root-level UID"
    check_append "1.5"  "Last Logins"                "lastlog 2>/dev/null || grep -v 'Never logged in' /var/log/wtmp 2>/dev/null | strings | head -50 || echo 'lastlog not available'" "Last login time for every account"
    check_append "1.6"  "Currently Logged In Users"  "w && echo && who -a" "Users active right now"
    check_append "1.7"  "Failed Login Attempts"      "$SUDO lastb 2>/dev/null || echo 'No records or access denied'" "All recent failed login attempts"
    check_append "1.8"  "Full Login History"         "last -F 2>/dev/null || last 2>/dev/null || echo 'last not available'" "Complete login/logout history"
    check_append "1.9"  "Password Aging Policy"      "$SUDO chage -l root 2>/dev/null; echo; grep -E '^PASS_MAX_DAYS|^PASS_MIN_DAYS|^PASS_WARN_AGE' /etc/login.defs 2>/dev/null" "Password expiry configuration"
    check_append "1.10" "Sudo Configuration"         "$SUDO cat /etc/sudoers 2>/dev/null; $SUDO ls -la /etc/sudoers.d/ 2>/dev/null; for f in \$($SUDO ls /etc/sudoers.d/ 2>/dev/null); do echo \"=== /etc/sudoers.d/\$f ===\"; $SUDO cat \"/etc/sudoers.d/\$f\" 2>/dev/null; done" "Full sudoers config including drop-in files"
    check_append "1.11" "Groups and Memberships"     "cat /etc/group; echo; getent group sudo 2>/dev/null; getent group wheel 2>/dev/null; getent group adm 2>/dev/null" "All groups and privileged group memberships"
    check_append "1.12" "SSH Server Configuration"   "$SUDO cat /etc/ssh/sshd_config 2>/dev/null | grep -v '^#' | grep -v '^\$' || echo 'SSH config not accessible'" "Active SSH daemon settings"
    check_append "1.13" "SSH Root Login Status"      "$SUDO grep -i 'PermitRootLogin' /etc/ssh/sshd_config 2>/dev/null || echo 'Not explicitly set (defaults to prohibit-password)'" "Whether root can log in over SSH"
    check_append "1.14" "SSH Authorized Keys"        "find /root /home -name 'authorized_keys' 2>/dev/null -exec echo '=== {} ===' \\; -exec cat {} \\;" "All SSH public keys authorized on this system"
    check_append "1.15" "SSH Host Keys"              "ls -la /etc/ssh/ssh_host_* 2>/dev/null" "SSH host key files and permissions"
    check_append "1.16" "World-Writable Files"       "$SUDO find / -xdev -type f -perm -0002 -exec ls -l {} + 2>/dev/null || echo 'None found or access denied'" "All world-writable files (security risk)"
    check_append "1.17" "World-Writable Directories" "$SUDO find / -xdev -type d -perm -0002 -exec ls -ld {} + 2>/dev/null || echo 'None found'" "All world-writable directories"
    check_append "1.18" "SUID Files"                 "$SUDO find / -xdev -perm -4000 -type f -exec ls -l {} + 2>/dev/null" "Files that run with the owner's privileges"
    check_append "1.19" "SGID Files"                 "$SUDO find / -xdev -perm -2000 -type f -exec ls -l {} + 2>/dev/null" "Files that run with the group's privileges"
    check_append "1.20" "Unowned Files"              "$SUDO find / -xdev \\( -nouser -o -nogroup \\) -exec ls -l {} + 2>/dev/null || echo 'None found'" "Files with no valid owner or group"
    check_append "1.21" "Hidden Files in Home Dirs"  "$SUDO find /home /root -maxdepth 3 -name '.*' -exec ls -la {} + 2>/dev/null" "Dotfiles in user home directories"
    check_append "1.22" "Critical Directory Perms"   "ls -ld /tmp /var /etc /root /boot /usr /bin /sbin /home 2>/dev/null" "Permissions on key system directories"
    check_append "1.23" "Critical File Permissions"  "ls -l /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/sudoers /etc/ssh/sshd_config /etc/hosts /etc/crontab 2>/dev/null" "Permissions on sensitive system files"
    check_append "1.24" "Sticky Bit on Temp Dirs"    "ls -ld /tmp /var/tmp 2>/dev/null" "Verify sticky bit is set to prevent file hijacking"
    check_append "1.25" "Core Dump Configuration"    "$SUDO sysctl fs.suid_dumpable kernel.core_pattern 2>/dev/null || echo 'Access denied'" "Core dump security settings"
    check_append "1.26" "ASLR Status"                "cat /proc/sys/kernel/randomize_va_space 2>/dev/null || echo 'Not accessible'" "Address Space Layout Randomization (0=off,1=partial,2=full)"
    check_append "1.27" "All Kernel Security Params" "$SUDO sysctl -a 2>/dev/null | grep -E 'kernel\\.(randomize|dmesg|kptr|perf|yama|unprivileged)|net\\.ipv4\\.(ip_forward|conf|tcp_syncookies)|fs\\.(suid|protected)'" "Security-relevant kernel parameters"
    check_append "1.28" "Loaded Kernel Modules"      "lsmod | sort" "All currently loaded kernel modules"
    check_append "1.29" "Recent Kernel Messages"     "$SUDO dmesg 2>/dev/null | tail -100 || echo 'Access denied'" "Last 100 kernel ring buffer messages"
    check_append "1.30" "OS and Kernel Details"      "uname -a; echo; cat /proc/version; echo; lsb_release -a 2>/dev/null || cat /etc/os-release" "Full OS and kernel version information"
    check_append "1.31" "Audit Daemon Status"        "$SUDO systemctl status auditd 2>/dev/null || echo 'auditd not available'" "Linux audit daemon status"
    check_append "1.32" "Audit Rules"                "$SUDO auditctl -l 2>/dev/null || echo 'No rules or access denied'" "Active auditd rules"
    check_append "1.33" "System Log Directory"       "$SUDO ls -la /var/log/ 2>/dev/null" "All log files and their permissions"
    check_append "1.34" "Logging Daemon Status"      "$SUDO systemctl status rsyslog syslog systemd-journald 2>/dev/null" "Status of syslog / journald services"
    check_append "1.35" "Authentication Log"         "$SUDO cat /var/log/auth.log 2>/dev/null || $SUDO cat /var/log/secure 2>/dev/null || echo 'Auth log not accessible'" "Full authentication log"
    check_append "1.36" "Recent Syslog Entries"      "$SUDO tail -200 /var/log/syslog 2>/dev/null || $SUDO journalctl -n 200 --no-pager 2>/dev/null || echo 'Syslog not accessible'" "Last 200 syslog entries"
    check_append "1.37" "Installed Packages"         "dpkg -l 2>/dev/null || rpm -qa 2>/dev/null || pacman -Q 2>/dev/null || echo 'Package manager not detected'" "All installed packages"
    check_append "1.38" "Pending Security Updates"   "$SUDO apt list --upgradable 2>/dev/null | grep -i security || $SUDO yum list updates 2>/dev/null | grep -i security || echo 'None detected or unsupported package manager'" "Available security patches"
    check_append "1.39" "Recent Package Changes"     "grep -iE 'install|upgrade' /var/log/dpkg.log 2>/dev/null | tail -100 || rpm -qa --last 2>/dev/null | head -100 || echo 'Not available'" "Recently installed or upgraded packages"
    check_append "1.40" "System Cron Directories"    "$SUDO ls -laR /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly /etc/cron.weekly 2>/dev/null; $SUDO cat /etc/crontab 2>/dev/null" "All system-wide cron job directories"
    check_append "1.41" "All User Crontabs"          "for user in \$(cut -f1 -d: /etc/passwd); do ct=\$($SUDO crontab -u \"\$user\" -l 2>/dev/null); if [ -n \"\$ct\" ]; then echo \"=== Crontab for \$user ===\"; echo \"\$ct\"; fi; done; $SUDO ls -la /var/spool/cron/crontabs/ 2>/dev/null || true" "Every user's crontab entries"
    check_append "1.42" "Systemd Timers"             "$SUDO systemctl list-timers --all 2>/dev/null || echo 'Not available'" "All systemd timer units"
    check_append "1.43" "At Jobs"                    "$SUDO atq 2>/dev/null; $SUDO ls -la /var/spool/at/ 2>/dev/null || echo 'at not installed or no jobs'" "Scheduled at-jobs"
    check_append "1.44" "SELinux Status"             "$SUDO sestatus 2>/dev/null || echo 'SELinux not installed'" "SELinux enforcement status and policy"
    check_append "1.45" "AppArmor Status"            "$SUDO aa-status 2>/dev/null || echo 'AppArmor not installed'" "AppArmor profiles and enforcement status"
    check_append "1.46" "Open Files (lsof)"          "$SUDO lsof 2>/dev/null || echo 'lsof not available'" "All open file handles and sockets"
    check_append "1.47" "Running Processes"          "ps auxf 2>/dev/null || ps aux 2>/dev/null" "All running processes with tree view"
    check_append "1.48" "Systemd Services"           "$SUDO systemctl list-units --type=service --all 2>/dev/null || echo 'systemd not available'" "All systemd service units and their status"
    check_append "1.49" "Environment Variables"      "env | sort" "Current shell environment"
    check_append "1.50" "Mounted Filesystems"        "mount | sort; echo; cat /etc/fstab 2>/dev/null" "Mounted filesystems and fstab configuration"
}

network_security_audit() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                          2. NETWORK SECURITY AUDIT                          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"

    printf '\n╔══════════════════════════════════════════════════════════════════════════════╗\n' >> "$TEMP_FILE"
    printf '║                          2. NETWORK SECURITY AUDIT                           ║\n' >> "$TEMP_FILE"
    printf '╚══════════════════════════════════════════════════════════════════════════════╝\n' >> "$TEMP_FILE"

    check_append "2.1"  "Network Interfaces"         "ip -br addr show; echo; ip link show" "Interface list and link status"
    check_append "2.2"  "Full IP Address Config"     "ip addr show" "All IP addresses on all interfaces"
    check_append "2.3"  "Active Interfaces"          "ip -br addr show | grep -v DOWN" "Interfaces currently up"
    check_append "2.4"  "Listening TCP Services"     "$SUDO ss -tulnp 2>/dev/null | grep LISTEN || $SUDO netstat -tulnp 2>/dev/null | grep LISTEN || echo 'Tools not available'" "TCP ports currently accepting connections"
    check_append "2.5"  "Listening UDP Services"     "$SUDO ss -ulnp 2>/dev/null || $SUDO netstat -ulnp 2>/dev/null || echo 'Not available'" "UDP ports currently open"
    check_append "2.6"  "All Network Connections"    "$SUDO ss -atnp 2>/dev/null || $SUDO netstat -atnp 2>/dev/null || echo 'Not available'" "All established and listening connections"
    check_append "2.7"  "IPTables Filter Rules"      "$SUDO iptables -L -n -v --line-numbers 2>/dev/null || echo 'Not accessible'" "iptables FILTER chain"
    check_append "2.8"  "IPTables NAT Rules"         "$SUDO iptables -t nat -L -n -v --line-numbers 2>/dev/null || echo 'Not accessible'" "iptables NAT chain"
    check_append "2.9"  "IPTables Mangle Rules"      "$SUDO iptables -t mangle -L -n -v --line-numbers 2>/dev/null || echo 'Not accessible'" "iptables mangle chain"
    check_append "2.10" "IP6Tables Rules"            "$SUDO ip6tables -L -n -v --line-numbers 2>/dev/null || echo 'ip6tables not accessible'" "IPv6 firewall rules"
    check_append "2.11" "UFW Status"                 "$SUDO ufw status verbose 2>/dev/null || echo 'UFW not installed'" "Uncomplicated Firewall status"
    check_append "2.12" "Firewalld Status"           "$SUDO firewall-cmd --state 2>/dev/null && $SUDO firewall-cmd --get-active-zones 2>/dev/null && $SUDO firewall-cmd --list-all 2>/dev/null || echo 'Not available'" "Firewalld zones and rules"
    check_append "2.13" "nftables Ruleset"           "$SUDO nft list ruleset 2>/dev/null || echo 'nftables not available'" "Modern nftables firewall rules"
    check_append "2.14" "DNS and Hosts Config"       "cat /etc/resolv.conf 2>/dev/null; echo; cat /etc/hosts; echo; cat /etc/nsswitch.conf 2>/dev/null" "Resolver, hosts file, name service config"
    check_append "2.15" "Routing Table"              "ip route show; echo; $SUDO route -n 2>/dev/null" "IPv4 routing table"
    check_append "2.16" "IPv6 Routes"                "ip -6 route show 2>/dev/null || echo 'No IPv6 routes'" "IPv6 routing table"
    check_append "2.17" "ARP Table"                  "ip neigh show || arp -a 2>/dev/null || echo 'Not available'" "ARP neighbour table"
    check_append "2.18" "Interface Statistics"       "ip -s link" "TX/RX counters for all interfaces"
    check_append "2.19" "Protocol Statistics"        "$SUDO netstat -s 2>/dev/null || $SUDO ss -s 2>/dev/null || echo 'Not available'" "Per-protocol network statistics"
    check_append "2.20" "Wireless Interfaces"        "iwconfig 2>/dev/null || iw dev 2>/dev/null || echo 'No wireless interfaces'" "Wi-Fi interface configuration"
    check_append "2.21" "Hostname Config"            "hostname -f 2>/dev/null; hostname -I 2>/dev/null; cat /etc/hostname 2>/dev/null" "System hostname settings"
    check_append "2.22" "NetworkManager Status"      "$SUDO systemctl status NetworkManager 2>/dev/null || echo 'NetworkManager not running'" "NetworkManager service status"
}

port_scanning_audit() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                         3. PORT SCANNING ANALYSIS                           ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"

    printf '\n╔══════════════════════════════════════════════════════════════════════════════╗\n' >> "$TEMP_FILE"
    printf '║                         3. PORT SCANNING ANALYSIS                            ║\n' >> "$TEMP_FILE"
    printf '╚══════════════════════════════════════════════════════════════════════════════╝\n' >> "$TEMP_FILE"

    if check_command "nmap"; then
        check_append "3.1" "Quick Port Scan (top 1000)" "nmap -sS --top-ports 1000 -T4 localhost 2>/dev/null || nmap --top-ports 1000 localhost 2>/dev/null" "Fast scan of the 1000 most common TCP ports"
        check_append "3.2" "Service Version Detection" "nmap -sV -sC --top-ports 100 localhost 2>/dev/null || echo 'Requires elevated privileges'" "Version and default script scan (top 100)"
        check_append "3.3" "UDP Port Scan" "$SUDO nmap -sU --top-ports 100 localhost 2>/dev/null || echo 'UDP scan requires root'" "UDP scan of top 100 ports"
        check_append "3.4" "Full TCP Scan (all ports)" "$SUDO nmap -sS -p- -T4 localhost 2>/dev/null || echo 'Requires root'" "Scan all 65535 TCP ports"
        check_append "3.5" "OS Detection" "$SUDO nmap -O localhost 2>/dev/null || echo 'Requires root'" "Remote OS fingerprinting"
    else
        check_append "3.1" "Fallback Port Scan (bash)" "
            echo 'nmap not available - using bash /dev/tcp fallback'
            common_ports=(20 21 22 23 25 53 67 80 88 110 111 119 135 139 143 161 389 443 445 465 514 587 631 636 993 995 1080 1194 1433 1521 1723 2049 2181 3306 3389 4444 5432 5900 5901 6379 6443 7001 8080 8443 8888 9000 9090 9200 27017)
            for port in \"\${common_ports[@]}\"; do
                if timeout 1 bash -c \"echo >/dev/tcp/localhost/\$port\" 2>/dev/null; then
                    echo \"Port \$port: OPEN\"
                fi
            done
        " "TCP probe of common ports using bash built-ins"
    fi

    check_append "3.6" "Listening Services Detail" "$SUDO netstat -tlnp 2>/dev/null | grep LISTEN || $SUDO ss -tlnp 2>/dev/null | grep LISTEN || echo 'Not available'" "All services with listening sockets"
    check_append "3.7" "Process-to-Port Mapping" "$SUDO lsof -i -P -n 2>/dev/null || echo 'lsof not available'" "Which process owns each open port"
    check_append "3.8" "Unix Domain Sockets" "$SUDO ss -xnp 2>/dev/null || echo 'Not available'" "Local Unix socket connections"
}

generate_security_summary() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                      4. SECURITY SUMMARY & RECOMMENDATIONS                   ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"

    local SNAPSHOT="/tmp/security_audit_snapshot_$$.txt"
    cp "$TEMP_FILE" "$SNAPSHOT"

    cat >> "$TEMP_FILE" << EOF

╔══════════════════════════════════════════════════════════════════════════════╗
║                      4. SECURITY SUMMARY & RECOMMENDATIONS                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

CRITICAL SECURITY FINDINGS:
══════════════════════════

EOF

    echo -e "${YELLOW}[*] Analysing audit results...${NC}"
    echo "Potential findings extracted from audit data:" >> "$TEMP_FILE"

    grep -iE \
        'empty password|permitrootlogin yes|world.writable|suid.*root|uid 0|password.*none|audit.*inactive|CRITICAL|FAILED' \
        "$SNAPSHOT" | grep -v "Description:" >> "$TEMP_FILE" 2>/dev/null

    rm -f "$SNAPSHOT"

    cat >> "$TEMP_FILE" << EOF

SECURITY RECOMMENDATIONS:
═════════════════════════

1. USER ACCOUNT SECURITY
   - Enforce strong passwords on all accounts; consider PAM password quality
   - Lock or remove unused accounts (usermod -L / userdel)
   - Implement lockout policy with faillock or pam_tally2
   - Audit sudo access: principle of least privilege
   - Enable MFA for privileged accounts where possible

2. SSH HARDENING
   - Set PermitRootLogin no  in /etc/ssh/sshd_config
   - Set PasswordAuthentication no  (key-based auth only)
   - Change SSH port away from 22 (AllowedPorts or Port directive)
   - Restrict access: AllowUsers / AllowGroups
   - Deploy fail2ban with an SSH jail

3. FILE SYSTEM SECURITY
   - Remove unnecessary world-writable files
   - Audit all SUID/SGID binaries; remove unneeded ones (chmod -s)
   - Confirm /tmp and /var/tmp have sticky bit (chmod +t)
   - Deploy a file-integrity monitor: AIDE or Tripwire
   - Review unowned files and assign or remove them

4. NETWORK SECURITY
   - Close all non-essential listening ports
   - Configure a stateful firewall (ufw enable / firewall-cmd)
   - Disable IP forwarding unless this host routes traffic
   - Block ICMP redirects: net.ipv4.conf.all.accept_redirects=0
   - Enable SYN cookies: net.ipv4.tcp_syncookies=1

5. KERNEL HARDENING
   - Full ASLR: kernel.randomize_va_space=2
   - Restrict dmesg: kernel.dmesg_restrict=1
   - Hide kernel pointers: kernel.kptr_restrict=2
   - Disable SUID core dumps: fs.suid_dumpable=0
   - Consider linux-hardened or grsecurity kernel

6. LOGGING AND MONITORING
   - Run auditd with comprehensive rules
   - Forward logs to a remote syslog server
   - Deploy OSSEC or Wazuh for HIDS
   - Alert on authentication failures and privilege escalation

7. SERVICE HARDENING
   - Disable and mask unused systemd units
   - Run services as dedicated low-privilege users
   - Use systemd sandboxing: ProtectSystem=strict, NoNewPrivileges=yes
   - Enable MAC profiles (AppArmor/SELinux) for internet-facing services

8. PATCH MANAGEMENT
   - Apply all pending security updates immediately
   - Enable unattended-upgrades for automatic security patches
   - Subscribe to your distro's security advisory mailing list
   - Target SLA: critical patches within 24 h, high within 7 days

AUDIT COMPLETION SUMMARY:
═════════════════════════
Completed on    : $(date)
Duration        : $(($(date +%s) - SCRIPT_START_TIME)) seconds
System examined : $(hostname) running $(uname -r)

NOTE: This is a point-in-time assessment. Schedule recurring audits
      and remediate findings according to your risk acceptance policy.

╔══════════════════════════════════════════════════════════════════════════════╗
║                              END OF REPORT                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

show_progress() {
    local current=$1 total=$2 description=$3
    local percent=$((current * 100 / total))
    if [ $USE_COLORS -eq 1 ]; then
        echo -e "${CYAN}Progress: ${GREEN}${percent}%${NC} — ${description}"
    else
        echo "Progress: ${percent}% — ${description}"
    fi
}

main() {
    local total_sections=4 current_section=0

    banner

    if [[ $EUID -eq 0 ]]; then
        echo -e "${GREEN}[+] Running as root — full audit available${NC}"
    else
        echo -e "${YELLOW}[!] Not root — some checks will be limited${NC}"
        echo -e "${YELLOW}[!] For a complete audit run: sudo $0${NC}"
    fi

    auto_install_audit_tools

    choose_output_format
    echo -e "${BLUE}[*] Initialising audit...${NC}"
    initialize_output

    current_section=$((current_section + 1))
    show_progress $current_section $total_sections "System Security Audit"
    system_security_audit

    current_section=$((current_section + 1))
    show_progress $current_section $total_sections "Network Security Audit"
    network_security_audit

    current_section=$((current_section + 1))
    show_progress $current_section $total_sections "Port Scanning Analysis"
    port_scanning_audit

    current_section=$((current_section + 1))
    show_progress $current_section $total_sections "Generating Security Summary"
    generate_security_summary

    echo -e "\n${BLUE}[*] Saving report(s)...${NC}"
    case $OUTPUT_FORMAT in
        txt)
            cp "$TEMP_FILE" "$OUTPUT_FILE_TXT"
            echo -e "${GREEN}[+] Report saved: ${YELLOW}$OUTPUT_FILE_TXT${NC}"
            FINAL_FILE="$OUTPUT_FILE_TXT" ;;
        pdf)
            cp "$TEMP_FILE" "$OUTPUT_FILE_TXT"
            if convert_to_pdf "$OUTPUT_FILE_TXT" "$OUTPUT_FILE_PDF"; then
                rm -f "$OUTPUT_FILE_TXT"
                echo -e "${GREEN}[+] Report saved: ${YELLOW}$OUTPUT_FILE_PDF${NC}"
                FINAL_FILE="$OUTPUT_FILE_PDF"
            else
                echo -e "${YELLOW}[!] PDF failed, keeping TXT: $OUTPUT_FILE_TXT${NC}"
                FINAL_FILE="$OUTPUT_FILE_TXT"
            fi ;;
        both)
            cp "$TEMP_FILE" "$OUTPUT_FILE_TXT"
            echo -e "${GREEN}[+] TXT saved: ${YELLOW}$OUTPUT_FILE_TXT${NC}"
            if convert_to_pdf "$OUTPUT_FILE_TXT" "$OUTPUT_FILE_PDF"; then
                echo -e "${GREEN}[+] PDF saved: ${YELLOW}$OUTPUT_FILE_PDF${NC}"
                FINAL_FILE="$OUTPUT_FILE_TXT and $OUTPUT_FILE_PDF"
            else
                echo -e "${YELLOW}[!] PDF failed, keeping TXT only${NC}"
                FINAL_FILE="$OUTPUT_FILE_TXT"
            fi ;;
    esac

    rm -f "$TEMP_FILE"

    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    AUDIT COMPLETED SUCCESSFULLY                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}[+] Results: ${YELLOW}$FINAL_FILE${NC}"
    echo -e "${GREEN}[+] Time   : ${YELLOW}$(($(date +%s) - SCRIPT_START_TIME))s${NC}"
    for f in "$OUTPUT_FILE_TXT" "$OUTPUT_FILE_PDF"; do
        [ -f "$f" ] && echo -e "${GREEN}[+] Size   : ${YELLOW}$(du -h "$f" | cut -f1) — $f${NC}"
    done
    echo -e "${CYAN}[*] Review the report carefully and remediate findings.${NC}"
}

show_help() {
    echo -e "${CYAN}Linux Security Audit Tool v3.1${NC}"
    echo ""
    echo -e "${YELLOW}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help"
    echo "  -v, --verbose   Verbose output"
    echo "  -q, --quiet     Minimal console output"
    echo "  -f, --format    Output format: txt | pdf | both"
    echo ""
    echo "Recommended: sudo $0"
}

# Argument parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)   show_help; exit 0 ;;
        -v|--verbose) VERBOSE=1; shift ;;
        -q|--quiet)  QUIET=1; shift ;;
        -f|--format)
            if [[ $2 =~ ^(txt|pdf|both)$ ]]; then
                OUTPUT_FORMAT=$2
            else
                echo -e "${RED}[-] Invalid format. Use txt, pdf, or both.${NC}"; exit 1
            fi
            shift 2 ;;
        *) echo -e "${RED}Unknown option: $1${NC}"; show_help; exit 1 ;;
    esac
done

if [ -z "$OUTPUT_FILE_TXT" ]; then
    timestamp=$(date +%Y%m%d_%H%M%S)
    OUTPUT_FILE_TXT="Linux_security_audit_${timestamp}.txt"
    OUTPUT_FILE_PDF="Linux_security_audit_${timestamp}.pdf"
fi

main
exit 0
