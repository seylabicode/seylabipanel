#!/bin/bash

# --- ANSI Color Codes ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_MAGENTA='\033[0;35m'
C_CYAN='\033[0;36m'
C_WHITE='\033[0;37m'
C_GRAY='\033[0;90m'
C_WHITE_BRIGHT='\033[1;37m'

ADD_USER_TO_SUDO=true 
APT_LOG_FILE="/tmp/seylabipanel_apt.log" 

display_main_banner() {
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local title="S E Y L A B I P A N E L" 
    local border_line_char="═"
    local vertical_border_char="║"
    local border_line=$(printf '%*s' "$term_width" '' | tr ' ' "$border_line_char")
    local title_padding=$(( (term_width - ${#title} - 2) / 2 ))

    clear
    echo -e "${C_BOLD}${C_BLUE}${border_line}${C_RESET}"
    echo -e "${C_BLUE}${vertical_border_char}$(printf '%*s' $((term_width - 2)) '')${C_BLUE}${vertical_border_char}${C_RESET}"
    printf "${C_BLUE}${vertical_border_char}%*s${C_BOLD}${C_WHITE_BRIGHT}%s${C_RESET}${C_BLUE}%*s${vertical_border_char}${C_RESET}\n" \
        "$title_padding" "" "$title" "$((term_width - title_padding - ${#title} - 2))" ""
    echo -e "${C_BLUE}${vertical_border_char}$(printf '%*s' $((term_width - 2)) '')${C_BLUE}${vertical_border_char}${C_RESET}"
    echo -e "${C_BOLD}${C_BLUE}${border_line}${C_RESET}"
    echo
}

section_header() {
    local text_to_display_prefix="SeylabiPanel: "
    local text_to_display_suffix="$1"
    local full_text_len=$(( ${#text_to_display_prefix} + ${#text_to_display_suffix} ))
    local content_min_width=30 
    local content_width=$((full_text_len > content_min_width ? full_text_len : content_min_width))
    local box_padding=4 
    local box_width=$((content_width + box_padding))
    local line_char_top_bottom="═"
    local vertical_border_char="║"
    local corner_tl="╔"
    local corner_tr="╗"
    local corner_bl="╚"
    local corner_br="╝"
    local line_top="${corner_tl}$(printf '%*s' "$box_width" '' | tr ' ' "$line_char_top_bottom")${corner_tr}"
    local line_bottom="${corner_bl}$(printf '%*s' "$box_width" '' | tr ' ' "$line_char_top_bottom")${corner_br}"
    local text_padding_total=$((box_width - full_text_len))
    local text_padding_left=$((text_padding_total / 2))
    local text_padding_right=$((text_padding_total - text_padding_left))

    echo
    echo -e "${C_BOLD}${C_MAGENTA}${line_top}${C_RESET}"
    printf "${C_BOLD}${C_MAGENTA}${vertical_border_char}%*s${C_CYAN}%s${C_WHITE_BRIGHT}%s%*s${C_MAGENTA}${vertical_border_char}${C_RESET}\n" \
        "$text_padding_left" "" "$text_to_display_prefix" "$text_to_display_suffix" "$text_padding_right" ""
    echo -e "${C_BOLD}${C_MAGENTA}${line_bottom}${C_RESET}"
    echo
}

error_exit() { echo -e "${C_BOLD}${C_RED}[ERROR]${C_RESET}${C_RED} $1${C_RESET}" >&2; exit 1; }
warning_msg() { echo -e "${C_BOLD}${C_YELLOW}[WARN]${C_RESET}${C_YELLOW} $1${C_RESET}" >&2; }
info_msg() { echo -e "${C_BOLD}${C_GREEN}[INFO]${C_RESET} $1"; }

spinner() {
    local pid=$1; local message=${2:-"Processing..."}; local delay=0.1; local spinstr='|/-\'
    echo -n -e "${C_YELLOW}${message} ${C_RESET}"
    while ps -p $pid > /dev/null; do
        local temp_spinstr=${spinstr#?}; printf "${C_BOLD}${C_CYAN} [%c]  ${C_RESET}" "$spinstr"
        spinstr=$temp_spinstr${spinstr%"$temp_spinstr"}; sleep $delay; printf "\b\b\b\b\b\b";
    done
    printf " ${C_BOLD}${C_GREEN}[DONE]${C_RESET} \n";
}

press_enter_to_continue() {
    echo
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Press Enter to return to the main menu... "${C_RESET})"
}

install_panel() {
    section_header "Install Panel"
    info_msg "Starting SeylabiPanel installation process..."
    echo -e "${C_YELLOW}Log file for this session: ${C_GRAY}$APT_LOG_FILE${C_RESET}"
    echo "SeylabiPanel Installation Log - $(date)" > "$APT_LOG_FILE"


    section_header "User Setup" 
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Enter the username for RDP login: "${C_RESET})" TARGET_USERNAME
    if [ -z "$TARGET_USERNAME" ]; then error_exit "Username cannot be empty."; fi 

    USER_EXISTS=false
    if id "$TARGET_USERNAME" &>/dev/null; then
        USER_EXISTS=true
        info_msg "User '${C_CYAN}$TARGET_USERNAME${C_GREEN}' already exists."
        read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Update password for this user and continue? (yes/no): "${C_RESET})" choice
        if [[ "$choice" != "yes" && "$choice" != "y" ]]; then 
            info_msg "Installation aborted by user."
            return 1 
        fi
    else
        info_msg "User '${C_CYAN}$TARGET_USERNAME${C_GREEN}' does not exist. This script will create this user."
    fi

    while true; do
        read -s -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Enter password for '${C_CYAN}$TARGET_USERNAME${C_YELLOW}': "${C_RESET})" PASSWORD; echo
        read -s -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Confirm password: "${C_RESET})" PASSWORD_CONFIRM; echo
        if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
            if [ -z "$PASSWORD" ]; then warning_msg "Password cannot be empty."; else break; fi
        else warning_msg "Passwords do not match."; fi
    done

    if [ "$USER_EXISTS" = false ]; then
        info_msg "Creating user '${C_CYAN}$TARGET_USERNAME${C_GREEN}'..."
        useradd -m -s /bin/bash "$TARGET_USERNAME" &>> "$APT_LOG_FILE"
        if [ $? -ne 0 ]; then warning_msg "Failed to create user. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; return 1; fi
        info_msg "User '${C_CYAN}$TARGET_USERNAME${C_GREEN}' created."
        if [ "$ADD_USER_TO_SUDO" = true ]; then
            info_msg "Adding user '${C_CYAN}$TARGET_USERNAME${C_GREEN}' to sudo group..."
            usermod -aG sudo "$TARGET_USERNAME" &>> "$APT_LOG_FILE"
            if [ $? -ne 0 ]; then warning_msg "Failed to add user to sudo. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}";
            else info_msg "User added to sudo group. ${C_YELLOW}(Logout/login may be needed)${C_RESET}"; fi
        fi
    fi
    info_msg "Setting password for '${C_CYAN}$TARGET_USERNAME${C_GREEN}'..."
    echo "$TARGET_USERNAME:$PASSWORD" | chpasswd &>> "$APT_LOG_FILE"
    if [ $? -ne 0 ]; then warning_msg "Failed to set password. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; return 1; fi
    info_msg "Password has been set."

    TARGET_USER_HOME="/home/$TARGET_USERNAME"
    if [ ! -d "$TARGET_USER_HOME" ];then
        info_msg "Creating home directory: ${C_CYAN}$TARGET_USER_HOME${C_GREEN}"
        mkdir -p "$TARGET_USER_HOME" &>> "$APT_LOG_FILE"
        if [ $? -ne 0 ]; then warning_msg "Failed to create home dir. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; return 1; fi
        chown "$TARGET_USERNAME:$TARGET_USERNAME" "$TARGET_USER_HOME" &>> "$APT_LOG_FILE"
        chmod 700 "$TARGET_USER_HOME" &>> "$APT_LOG_FILE"
        info_msg "Home directory created and permissions set."
    fi


    section_header "Desktop Environment Setup"
    echo -e "${C_YELLOW}Please choose a Desktop Environment to install:${C_RESET}"
    echo -e "${C_CYAN}┌──────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_CYAN}│  ${C_GREEN}1)${C_RESET} XFCE4 (Recommended, lightweight)         ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}│  ${C_GREEN}2)${C_RESET} MATE (Traditional, based on GNOME 2)     ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}│  ${C_GREEN}3)${C_RESET} LXQt (Lightweight Qt desktop environment)${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}└──────────────────────────────────────────────────┘${C_RESET}"
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Enter your choice [1-3, default 1]: "${C_RESET})" DE_CHOICE
    DE_CHOICE=${DE_CHOICE:-1}
    DESKTOP_PACKAGES="" SESSION_COMMAND="" DESKTOP_NAME="" TEXT_EDITOR_PKG="" TERMINAL_PKG=""
    case "$DE_CHOICE" in
        1) DESKTOP_NAME="XFCE4"; DESKTOP_PACKAGES="xfce4 xfce4-goodies"; SESSION_COMMAND="xfce4-session"; TEXT_EDITOR_PKG="mousepad"; TERMINAL_PKG="xfce4-terminal";;
        2) DESKTOP_NAME="MATE"; DESKTOP_PACKAGES="mate-desktop-environment mate-desktop-environment-extras"; SESSION_COMMAND="mate-session"; TEXT_EDITOR_PKG="pluma"; TERMINAL_PKG="mate-terminal";;
        3) DESKTOP_NAME="LXQt"; DESKTOP_PACKAGES="lxqt-core lxqt-config qterminal openbox"; SESSION_COMMAND="startlxqt"; TEXT_EDITOR_PKG="featherpad"; TERMINAL_PKG="qterminal";;
        *) warning_msg "Invalid DE choice. Aborting installation."; return 1;;
    esac

    section_header "Package Management: Updating List"
    info_msg "Updating package list... (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
    apt update -y >> "$APT_LOG_FILE" 2>&1 &
    spinner $! "Updating apt lists..."
    wait $!
    if [ $? -ne 0 ]; then warning_msg "apt update failed. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; else info_msg "Package list update complete."; fi

    section_header "Installation: $DESKTOP_NAME"
    info_msg "Installing $DESKTOP_NAME... (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
    DEBIAN_FRONTEND=noninteractive apt install -y $DESKTOP_PACKAGES >> "$APT_LOG_FILE" 2>&1 &
    spinner $! "Installing $DESKTOP_NAME..."
    wait $!
    if [ $? -ne 0 ]; then warning_msg "Failed to install $DESKTOP_NAME. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; return 1; else info_msg "$DESKTOP_NAME installed."; fi

    section_header "Installation: xrdp Server"
    info_msg "Installing xrdp server... (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
    DEBIAN_FRONTEND=noninteractive apt install -y xrdp >> "$APT_LOG_FILE" 2>&1 &
    spinner $! "Installing xrdp..."
    wait $!
    if [ $? -ne 0 ]; then warning_msg "Failed to install xrdp. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; return 1; else info_msg "xrdp installed."; fi

    section_header "Configuration: xrdp for $DESKTOP_NAME"
    echo "$SESSION_COMMAND" > "$TARGET_USER_HOME/.xsession"
    chown "$TARGET_USERNAME:$TARGET_USERNAME" "$TARGET_USER_HOME/.xsession"
    chmod 644 "$TARGET_USER_HOME/.xsession"
    info_msg "Created .xsession for '${C_CYAN}$TARGET_USERNAME${C_GREEN}' to start ${C_CYAN}$DESKTOP_NAME${C_GREEN}."
    if command -v update-alternatives &> /dev/null; then
        SESSION_MANAGER_PATH=$(command -v "$SESSION_COMMAND")
        if [ -n "$SESSION_MANAGER_PATH" ]; then
            info_msg "Setting $DESKTOP_NAME as system default session manager..."
            update-alternatives --install /usr/bin/x-session-manager x-session-manager "$SESSION_MANAGER_PATH" 50 >> "$APT_LOG_FILE" 2>&1
            update-alternatives --set x-session-manager "$SESSION_MANAGER_PATH" >> "$APT_LOG_FILE" 2>&1
        else warning_msg "Could not find path for $SESSION_COMMAND. Skipping update-alternatives."; fi
    else warning_msg "'update-alternatives' not found. Skipping system-wide setting."; fi
    info_msg "xrdp configuration for $DESKTOP_NAME complete."

    if [ "$DESKTOP_NAME" = "XFCE4" ]; then
        section_header "XFCE Specific RDP Optimizations"
        XFCE_XFWM4_CONFIG_DIR="$TARGET_USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
        XFCE_XFWM4_CONFIG_FILE="$XFCE_XFWM4_CONFIG_DIR/xfwm4.xml"
        info_msg "Disabling XFCE compositor for '${C_CYAN}$TARGET_USERNAME${C_GREEN}'..."
        mkdir -p "$XFCE_XFWM4_CONFIG_DIR"; chown "$TARGET_USERNAME:$TARGET_USERNAME" "$TARGET_USER_HOME/.config"
        if [ -d "$TARGET_USER_HOME/.config/xfce4" ]; then chown -R "$TARGET_USERNAME:$TARGET_USERNAME" "$TARGET_USER_HOME/.config/xfce4"; fi
        cat << EOF > "$XFCE_XFWM4_CONFIG_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0"><property name="general" type="empty"><property name="use_compositing" type="bool" value="false"/></property></channel>
EOF
        chown "$TARGET_USERNAME:$TARGET_USERNAME" "$XFCE_XFWM4_CONFIG_FILE"; chmod 644 "$XFCE_XFWM4_CONFIG_FILE"
        info_msg "XFCE compositor disabled. ${C_YELLOW}(Relogin may be needed)${C_RESET}"
    fi

    section_header "Sound Redirection Setup (Optional)"
    # ... (Sound setup code from previous version, adapted with return on critical failure) ...
    echo -e "${C_CYAN}┌──────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_CYAN}│ ${C_YELLOW}Attempt to install and configure sound         ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}│ ${C_YELLOW}redirection for RDP?                         ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}└──────────────────────────────────────────────────┘${C_RESET}"
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Your choice (yes/no, default: no): "${C_RESET})" SOUND_CHOICE
    SOUND_CHOICE=${SOUND_CHOICE:-no}
    if [[ "$SOUND_CHOICE" == "yes" || "$SOUND_CHOICE" == "y" ]]; then
        info_msg "Installing PulseAudio and xrdp module... (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
        DEBIAN_FRONTEND=noninteractive apt install -y pulseaudio pulseaudio-utils pulseaudio-module-xrdp >> "$APT_LOG_FILE" 2>&1 &
        spinner $! "Installing sound packages..."
        wait $!
        if [ $? -ne 0 ]; then warning_msg "Failed to install PulseAudio packages. Sound might not work. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; 
        else
            info_msg "PulseAudio packages installed."
            info_msg "Adding user '${C_CYAN}$TARGET_USERNAME${C_GREEN}' to 'audio' & 'pulse-access' groups..."
            usermod -aG audio "$TARGET_USERNAME" &>> "$APT_LOG_FILE"
            usermod -aG pulse-access "$TARGET_USERNAME" &>> "$APT_LOG_FILE"
            info_msg "Sound packages installed and user groups configured."
        fi
    fi


    section_header "Common Applications Setup (Optional)"
    echo -e "${C_CYAN}┌──────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_CYAN}│ ${C_YELLOW}Install common applications?                   ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}│ ${C_GRAY}(Firefox, Editor, Terminal, htop, net-tools)${C_CYAN} │${C_RESET}"
    echo -e "${C_CYAN}└──────────────────────────────────────────────────┘${C_RESET}"
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Your choice (yes/no, default: no): "${C_RESET})" APPS_CHOICE
    APPS_CHOICE=${APPS_CHOICE:-no}
    if [[ "$APPS_CHOICE" == "yes" || "$APPS_CHOICE" == "y" ]]; then
        COMMON_APPS_LIST="firefox-esr $TEXT_EDITOR_PKG $TERMINAL_PKG htop net-tools curl wget"
        info_msg "Installing common applications... (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
        info_msg "Apps: ${C_CYAN}$COMMON_APPS_LIST${C_RESET}"
        DEBIAN_FRONTEND=noninteractive apt install -y $COMMON_APPS_LIST >> "$APT_LOG_FILE" 2>&1 &
        spinner $! "Installing common apps..."
        wait $!
        if [ $? -ne 0 ]; then warning_msg "Failed to install some common apps. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW}"; else info_msg "Common applications installed."; fi
    fi

    section_header "Configuration: xrdp System User Groups"
    if getent group ssl-cert &>/dev/null; then
        if ! groups xrdp 2>/dev/null | grep -q '\bssl-cert\b'; then 
            info_msg "Adding xrdp user to 'ssl-cert' group..."
            adduser xrdp ssl-cert &>> "$APT_LOG_FILE"; info_msg "xrdp user added to 'ssl-cert' group."
        else info_msg "xrdp user already member of 'ssl-cert'."; fi
    else info_msg "'ssl-cert' group does not exist. Skipping."; fi

    section_header "Service Management: xrdp"
    info_msg "Restarting xrdp service..."
    systemctl restart xrdp &>> "$APT_LOG_FILE"
    if [ $? -ne 0 ]; then warning_msg "xrdp failed to restart. See: ${C_GRAY}$APT_LOG_FILE${C_YELLOW} & 'systemctl status xrdp'"; else info_msg "xrdp restarted."; fi
    info_msg "Enabling xrdp service on boot..."
    systemctl enable xrdp &>> "$APT_LOG_FILE"
    if [ $? -ne 0 ]; then warning_msg "Failed to enable xrdp."; else info_msg "xrdp enabled on boot."; fi

    section_header "Firewall Configuration (UFW)"
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "Status: active"; then
            info_msg "UFW is active. Configuring firewall..."
            ufw allow 3389/tcp >> "$APT_LOG_FILE" 2>&1
            ufw reload >> "$APT_LOG_FILE" 2>&1 &
            spinner $! "Reloading UFW rules..."
            wait $!
            info_msg "Port 3389 (RDP) rule added/updated in UFW."
        else info_msg "UFW not active. Skipping config."; fi
    else info_msg "UFW not found. Skipping config."; fi
    info_msg "If using another firewall, open port 3389/tcp manually."
    
    info_msg "${C_BOLD}${C_GREEN}SeylabiPanel installation process completed successfully!${C_RESET}"
    echo -e "${C_WHITE_BRIGHT}Username:          ${C_BOLD}${C_CYAN}$TARGET_USERNAME${C_RESET}"
    echo -e "${C_WHITE_BRIGHT}Password:          ${C_BOLD}${C_YELLOW}(the password you set)${C_RESET}"
    echo -e "${C_WHITE_BRIGHT}Desktop Environ.:  ${C_BOLD}${C_CYAN}$DESKTOP_NAME${C_RESET}"
}

uninstall_panel() {
    section_header "Uninstall Panel"
    info_msg "Starting SeylabiPanel uninstallation process..."
    echo -e "${C_YELLOW}Log file for this session: ${C_GRAY}$APT_LOG_FILE${C_RESET}"
    echo "SeylabiPanel Uninstallation Log - $(date)" > "$APT_LOG_FILE"

    read -r -p "$(echo -e ${C_BOLD}${C_RED}"This will attempt to remove components installed by SeylabiPanel. Are you sure you want to continue? (yes/NO): "${C_RESET})" confirm_uninstall
    if [[ "$confirm_uninstall" != "yes" ]]; then
        info_msg "Uninstallation cancelled by user."
        return
    fi

    info_msg "Stopping and disabling xrdp service..."
    systemctl stop xrdp &>> "$APT_LOG_FILE"
    systemctl disable xrdp &>> "$APT_LOG_FILE"
    info_msg "xrdp service stopped and disabled."

    # Remove xrdp packages
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Remove xrdp packages (xrdp, pulseaudio-module-xrdp)? (yes/NO): "${C_RESET})" remove_xrdp_pkgs
    if [[ "$remove_xrdp_pkgs" == "yes" ]]; then
        info_msg "Removing xrdp packages... (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
        DEBIAN_FRONTEND=noninteractive apt-get purge -y xrdp pulseaudio-module-xrdp >> "$APT_LOG_FILE" 2>&1 &
        spinner $! "Removing xrdp packages..."
        wait $!
        DEBIAN_FRONTEND=noninteractive apt-get autoremove -y >> "$APT_LOG_FILE" 2>&1 # Clean dependencies
        info_msg "xrdp packages removed."
    else
        info_msg "Skipping xrdp package removal."
    fi

    # Remove Desktop Environment
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Do you want to remove a Desktop Environment? (yes/no): "${C_RESET})" remove_de_choice
    if [[ "$remove_de_choice" == "yes" ]]; then
        read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Enter DE to remove (e.g., xfce4, mate-desktop-environment, lxqt-core) or 'skip': "${C_RESET})" de_to_remove
        if [[ "$de_to_remove" != "skip" && ! -z "$de_to_remove" ]]; then
            local de_pkgs_guess=""
            if [[ "$de_to_remove" == "xfce4" ]]; then de_pkgs_guess="xfce4 xfce4-goodies"; fi
            if [[ "$de_to_remove" == "mate-desktop-environment" ]]; then de_pkgs_guess="mate-desktop-environment mate-desktop-environment-extras"; fi
            if [[ "$de_to_remove" == "lxqt-core" ]]; then de_pkgs_guess="lxqt-core lxqt-config"; fi
            
            if [[ ! -z "$de_pkgs_guess" ]]; then
                 read -r -p "$(echo -e ${C_BOLD}${C_RED}"This will attempt to remove: $de_pkgs_guess. Are you sure? (yes/NO): "${C_RESET})" confirm_de_remove
                 if [[ "$confirm_de_remove" == "yes" ]]; then
                    info_msg "Removing $de_to_remove packages... (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
                    DEBIAN_FRONTEND=noninteractive apt-get purge -y $de_pkgs_guess >> "$APT_LOG_FILE" 2>&1 &
                    spinner $! "Removing $de_to_remove..."
                    wait $!
                    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y >> "$APT_LOG_FILE" 2>&1
                    info_msg "$de_to_remove packages removed."
                 else
                    info_msg "Skipping $de_to_remove removal."
                 fi
            else
                 warning_msg "Could not determine packages for '$de_to_remove'. Please remove manually if needed."
            fi
        else
            info_msg "Skipping Desktop Environment removal."
        fi
    fi
    
    # Remove Common Applications (simplified: remove a predefined list if user agrees)
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Remove common applications (firefox-esr, text editors, etc.) installed by the panel? (yes/NO): "${C_RESET})" remove_common_apps
    if [[ "$remove_common_apps" == "yes" ]]; then
        # Generic list, as we don't store exactly what was installed
        # User should be aware this might remove apps they want to keep if installed separately
        local common_apps_to_remove="firefox-esr mousepad pluma featherpad xfce4-terminal mate-terminal qterminal htop net-tools curl wget"
        info_msg "Attempting to remove common applications: $common_apps_to_remove (Log: ${C_GRAY}$APT_LOG_FILE${C_RESET})"
        read -r -p "$(echo -e ${C_BOLD}${C_RED}"This may remove apps you wish to keep. Are you sure? (yes/NO): "${C_RESET})" confirm_common_remove
        if [[ "$confirm_common_remove" == "yes" ]]; then
            DEBIAN_FRONTEND=noninteractive apt-get purge -y $common_apps_to_remove >> "$APT_LOG_FILE" 2>&1 &
            spinner $! "Removing common applications..."
            wait $!
            DEBIAN_FRONTEND=noninteractive apt-get autoremove -y >> "$APT_LOG_FILE" 2>&1
            info_msg "Attempted removal of common applications."
        else
            info_msg "Skipping common application removal."
        fi
    fi

    # Remove UFW rule
    if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Remove RDP firewall rule (port 3389) from UFW? (yes/NO): "${C_RESET})" remove_ufw_rule
        if [[ "$remove_ufw_rule" == "yes" ]]; then
            info_msg "Deleting UFW rule for port 3389..."
            ufw delete allow 3389/tcp >> "$APT_LOG_FILE" 2>&1
            ufw reload >> "$APT_LOG_FILE" 2>&1 &
            spinner $! "Reloading UFW..."
            wait $!
            info_msg "UFW rule removed."
        else
            info_msg "Skipping UFW rule removal."
        fi
    fi

    # Remove user
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Do you want to remove the user configured by SeylabiPanel? (yes/no): "${C_RESET})" remove_user_choice
    if [[ "$remove_user_choice" == "yes" ]]; then
        read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Enter the username to remove: "${C_RESET})" user_to_remove
        if id "$user_to_remove" &>/dev/null; then
            read -r -p "$(echo -e "${C_BOLD}${C_RED}ARE YOU ABSOLUTELY SURE you want to remove user '$user_to_remove' AND THEIR HOME DIRECTORY (/home/$user_to_remove)? This is IRREVERSIBLE. (Type 'YESIDO' to confirm): "${C_RESET})" confirm_user_deletion
            if [[ "$confirm_user_deletion" == "YESIDO" ]]; then
                info_msg "Removing user '$user_to_remove' and their home directory..."
                deluser --remove-home "$user_to_remove" &>> "$APT_LOG_FILE"
                if [ $? -eq 0 ]; then info_msg "User '$user_to_remove' removed."; else warning_msg "Failed to remove user '$user_to_remove'."; fi
            else
                info_msg "User removal cancelled."
            fi
        else
            warning_msg "User '$user_to_remove' not found."
        fi
    fi
    
    # Clean .xsession for a given user (even if user not removed)
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Enter username whose .xsession file should be cleaned (if any, or skip): "${C_RESET})" xsession_user
    if [[ ! -z "$xsession_user" && "$xsession_user" != "skip" ]]; then
        local user_home_for_xsession="/home/$xsession_user"
        if [ -f "$user_home_for_xsession/.xsession" ]; then
            info_msg "Removing .xsession file for user '$xsession_user'..."
            rm -f "$user_home_for_xsession/.xsession"
            info_msg ".xsession file removed for '$xsession_user'."
        else
            info_msg ".xsession file not found for '$xsession_user'."
        fi
    fi

    info_msg "Cleaning up package cache..."
    apt-get autoremove -y >> "$APT_LOG_FILE" 2>&1
    apt-get clean >> "$APT_LOG_FILE" 2>&1
    info_msg "Package cache cleaned."

    info_msg "${C_BOLD}${C_GREEN}SeylabiPanel uninstallation process completed.${C_RESET}"
    info_msg "Please review ${C_GRAY}$APT_LOG_FILE${C_RESET} for details."
    info_msg "${C_YELLOW}A system reboot might be recommended.${C_RESET}"
}

# --- Status Check Logic ---
check_status() {
    section_header "Panel Status"
    info_msg "Checking SeylabiPanel components status..."

    # Check xrdp service
    echo -e "${C_WHITE_BRIGHT}Checking xrdp service...${C_RESET}"
    if systemctl is-active --quiet xrdp; then
        info_msg "xrdp service is ${C_GREEN}active (running)${C_RESET}."
    else
        warning_msg "xrdp service is ${C_RED}inactive (stopped)${C_RESET}."
    fi
    if systemctl is-enabled --quiet xrdp; then
        info_msg "xrdp service is ${C_GREEN}enabled${C_RESET} on boot."
    else
        warning_msg "xrdp service is ${C_RED}disabled${C_RESET} on boot."
    fi

    # Check xrdp package
    echo -e "\n${C_WHITE_BRIGHT}Checking xrdp package...${C_RESET}"
    if dpkg -s xrdp >/dev/null 2>&1; then
        info_msg "xrdp package is ${C_GREEN}installed${C_RESET}."
        info_msg "Version: $(dpkg -s xrdp | grep Version: | awk '{print $2}')"
    else
        warning_msg "xrdp package is ${C_RED}not installed${C_RESET}."
    fi

    # Check pulseaudio-module-xrdp package
    echo -e "\n${C_WHITE_BRIGHT}Checking xrdp PulseAudio module...${C_RESET}"
    if dpkg -s pulseaudio-module-xrdp >/dev/null 2>&1; then
        info_msg "pulseaudio-module-xrdp is ${C_GREEN}installed${C_RESET}."
    else
        warning_msg "pulseaudio-module-xrdp is ${C_RED}not installed${C_RESET} (Sound redirection might not work)."
    fi
    
    # Check Desktop Environments
    echo -e "\n${C_WHITE_BRIGHT}Checking Desktop Environments...${C_RESET}"
    local de_found=false
    if dpkg -s xfce4 >/dev/null 2>&1; then info_msg "XFCE4 base package seems ${C_GREEN}installed${C_RESET}."; de_found=true; fi
    if dpkg -s mate-desktop-environment >/dev/null 2>&1; then info_msg "MATE base package seems ${C_GREEN}installed${C_RESET}."; de_found=true; fi
    if dpkg -s lxqt-core >/dev/null 2>&1; then info_msg "LXQt core package seems ${C_GREEN}installed${C_RESET}."; de_found=true; fi
    if ! $de_found; then warning_msg "No common Desktop Environments (XFCE, MATE, LXQt) detected by this check."; fi

    # Check Firewall (UFW)
    echo -e "\n${C_WHITE_BRIGHT}Checking UFW Firewall for RDP port (3389)...${C_RESET}"
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "Status: active"; then
            info_msg "UFW firewall is ${C_GREEN}active${C_RESET}."
            if ufw status verbose | grep -q "3389/tcp.*ALLOW IN"; then
                info_msg "Port 3389/tcp is ${C_GREEN}allowed${C_RESET} in UFW."
            else
                warning_msg "Port 3389/tcp is ${C_RED}not explicitly allowed${C_RESET} in UFW (or rule not found by this check)."
            fi
        else
            warning_msg "UFW firewall is ${C_RED}inactive${C_RESET}."
        fi
    else
        info_msg "UFW command not found. Firewall status not checked by this script."
    fi
    
    # Check for a user's .xsession file
    read -r -p "$(echo -e "\n${C_BOLD}${C_YELLOW}Enter username to check for .xsession file (or press Enter to skip): "${C_RESET})" check_user_xsession
    if [[ ! -z "$check_user_xsession" ]]; then
        local user_home_to_check="/home/$check_user_xsession"
        if [ -f "$user_home_to_check/.xsession" ]; then
            info_msg ".xsession file found for user '${C_CYAN}$check_user_xsession${C_GREEN}': $(cat "$user_home_to_check/.xsession")"
        else
            warning_msg ".xsession file ${C_RED}not found${C_RESET} for user '${C_CYAN}$check_user_xsession${C_YELLOW}' in their home directory."
        fi
    fi

    info_msg "Status check complete."
}


# --- Main Menu ---
main_menu() {
    display_main_banner
    echo -e "      ${C_WHITE_BRIGHT}Welcome to the SeylabiPanel Management Script${C_RESET}"
    echo

    echo -e "${C_YELLOW}Please choose an action:${C_RESET}"
    echo -e "${C_CYAN}┌──────────────────────────────────┐${C_RESET}"
    echo -e "${C_CYAN}│  ${C_GREEN}1)${C_RESET} Install SeylabiPanel        ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}│  ${C_GREEN}2)${C_RESET} Uninstall SeylabiPanel      ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}│  ${C_GREEN}3)${C_RESET} Check Panel Status          ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}│  ${C_GREEN}4)${C_RESET} Exit                        ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}└──────────────────────────────────┘${C_RESET}"
    read -r -p "$(echo -e ${C_BOLD}${C_YELLOW}"Enter your choice [1-4]: "${C_RESET})" choice

    case "$choice" in
        1) install_panel ;;
        2) uninstall_panel ;;
        3) check_status ;;
        4) info_msg "Exiting SeylabiPanel. Goodbye!"; exit 0 ;;
        *) warning_msg "Invalid choice. Please try again." ;;
    esac
    press_enter_to_continue
    main_menu # Loop back to main menu
}

# --- Script Entry Point ---
if [ "$(id -u)" -ne 0 ]; then error_exit "This script must be run as root. Please use sudo."; fi

# Ensure log directory/file is writable (though /tmp should be fine)
touch "$APT_LOG_FILE" &>/dev/null || warning_msg "Cannot write to log file $APT_LOG_FILE"

main_menu
