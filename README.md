<div align="center">
  <pre>

     _______. ___________    ____  __          ___      .______    __     .______      ___      .__   __.  _______  __      
    /       ||   ____\   \  /   / |  |        /   \     |   _  \  |  |    |   _  \    /   \     |  \ |  | |   ____||  |     
   |   (----`|  |__   \   \/   /  |  |       /  ^  \    |  |_)  | |  |    |  |_)  |  /  ^  \    |   \|  | |  |__   |  |     
    \   \    |   __|   \_    _/   |  |      /  /_\  \   |   _  <  |  |    |   ___/  /  /_\  \   |  . `  | |   __|  |  |     
.----)   |   |  |____    |  |     |  `----./  _____  \  |  |_)  | |  |    |  |     /  _____  \  |  |\   | |  |____ |  `----.
|_______/    |_______|   |__|     |_______/__/     \__\ |______/  |__|    | _|    /__/     \__\ |__| \__| |_______||_______|
                                                                                                                            

  </pre>
  <h1>SeylabiPanel 🚀</h1>
  <p><strong>Your All-in-One Linux RDP & GUI Setup Assistant!</strong></p>
  <p>
    <a href="https://www.gnu.org/software/bash/" target="_blank"><img src="https://img.shields.io/badge/Made%20with-Bash-blue?style=for-the-badge&logo=gnu-bash" alt="Made with Bash"></a>
    <a href="#" target="_blank"><img src="https://img.shields.io/badge/Platform-Linux-green?style=for-the-badge&logo=linux" alt="Platform: Linux (Debian-based)"></a>
    <a href="https://github.com/YOUR_USERNAME/SeylabiPanel/issues" target="_blank"><img src="https://img.shields.io/badge/Contributions-welcome-brightgreen.svg?style=for-the-badge" alt="Contributions Welcome"></a>
    </p>
</div>

Welcome to SeylabiPanel! This script simplifies setting up a Linux desktop environment (XFCE, MATE, LXQt) with RDP (xrdp) access on Debian-based systems. Manage installations, uninstallations, and check status with an easy-to-use interactive menu.

✨ **See SeylabiPanel in Action!** ✨
*(Consider adding a GIF or a couple of screenshots here showing the script's menu and a successful RDP connection. This will greatly enhance the "dynamic" feel of your README!)*

---

<details open>
<summary><strong>🇬🇧 README in English</strong></summary>

### SeylabiPanel: GUI & RDP Setup Panel

SeylabiPanel is a Bash script designed to simplify the installation and configuration of a Linux desktop environment (XFCE, MATE, LXQt) with RDP access (via xrdp) on Debian-based systems (like Ubuntu). The script also includes options for uninstalling the installed components and checking their status.

#### 🌟 Key Features

| Feature                     | Description                                                                                                |
| :-------------------------- | :--------------------------------------------------------------------------------------------------------- |
| 🚀 **Interactive Menu** | Easy-to-use menu for Install, Uninstall, and Status Check operations.                                      |
| 👤 **User Management** | Creates a new user or configures an existing one for RDP login with password setup.                        |
| 💻 **Desktop Choice** | Allows selection between XFCE (recommended), MATE, and LXQt.                                               |
| 🌐 **Automated xrdp Setup** | Installs and configures xrdp for the chosen desktop environment.                                             |
| 🔊 **Sound (Optional)** | Attempts to set up basic sound redirection over RDP.                                                       |
| 📦 **Apps (Optional)** | Offers installation of common applications (web browser, text editor, etc.).                               |
| 🔥 **Firewall Config** | Automatically configures UFW to allow RDP connections (port 3389).                                         |
| 📝 **Logging** | Keeps a log of operations in `/tmp/seylabipanel_apt.log`.                                                  |
| ✨ **User-Friendly UI** | Colored output and clear prompts for a better experience.                                                  |

#### ✅ Prerequisites

* A Debian-based Linux distribution (e.g., Ubuntu 18.04+, Debian 10+).
* Root privileges (the script must be run with `sudo`).
* An active internet connection to download packages.

#### 🛠️ Installation and Usage

1.  **Clone or Download:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/SeylabiPanel.git](https://github.com/YOUR_USERNAME/SeylabiPanel.git)
    cd SeylabiPanel
    ```
    *(Replace `YOUR_USERNAME/SeylabiPanel.git` with your repository URL)*

    Or, download the `seylabipanel.sh` script file directly.

2.  **Make it Executable:**
    ```bash
    chmod +x seylabipanel.sh
    ```
    *(Ensure the filename matches your script's name)*

3.  **Run with Sudo:**
    ```bash
    sudo ./seylabipanel.sh
    ```

4.  **Navigate the Menu:**
    * **1. Install SeylabiPanel:** Guides you through setup (user, DE, RDP, optional features).
    * **2. Uninstall SeylabiPanel:** Carefully removes panel components. **Read prompts thoroughly!**
    * **3. Check Panel Status:** Shows status of xrdp, DE, firewall, etc.
    * **4. Exit:** Closes the script.

#### 🗒️ Logging
Operations are logged to `/tmp/seylabipanel_apt.log`. Check this file for troubleshooting.

</details>

---

<details>
<summary><strong>🇮🇷 README به زبان فارسی (Persian)</strong></summary>

### SeylabiPanel (فارسی) - پنل نصب محیط گرافیکی و RDP

SeylabiPanel یک اسکریپت Bash است که برای ساده‌سازی فرآیند نصب و پیکربندی محیط دسکتاپ لینوکس (XFCE، MATE، LXQt) به همراه دسترسی RDP (از طریق xrdp) بر روی سیستم‌های مبتنی بر دبیان (مانند اوبونتو) طراحی شده است. این اسکریپت همچنین شامل گزینه‌هایی برای حذف اجزای نصب‌شده و بررسی وضعیت آن‌ها می‌باشد.

#### 🌟 ویژگی‌های کلیدی

| ویژگی                     | توضیحات                                                                                                  |
| :-------------------------- | :------------------------------------------------------------------------------------------------------- |
| 🚀 **منوی تعاملی** | منوی کاربرپسند برای عملیات نصب، حذف و بررسی وضعیت.                                                        |
| 👤 **مدیریت کاربر** | ایجاد کاربر جدید یا پیکربندی کاربر موجود برای ورود با RDP و تنظیم رمز عبور.                              |
| 💻 **انتخاب محیط دسکتاپ** | امکان انتخاب بین XFCE (توصیه شده)، MATE و LXQt.                                                           |
| 🌐 **نصب خودکار xrdp** | نصب و پیکربندی xrdp برای محیط دسکتاپ انتخاب شده.                                                           |
| 🔊 **انتقال صدا (اختیاری)** | تلاش برای راه‌اندازی اولیه انتقال صدا از طریق RDP.                                                         |
| 📦 **برنامه‌های رایج (اختیاری)** | ارائه گزینه نصب برنامه‌های رایج (مرورگر وب، ویرایشگر متن و غیره).                                     |
| 🔥 **پیکربندی فایروال** | پیکربندی خودکار فایروال UFW برای اجازه دادن به اتصالات RDP (پورت 3389).                                   |
| 📝 **لاگ‌برداری** | ثبت گزارش عملیات در فایل `/tmp/seylabipanel_apt.log`.                                                      |
| ✨ **رابط کاربرپسند** | خروجی رنگی و راهنمایی‌های واضح برای تجربه کاربری بهتر.                                                      |

#### ✅ پیش‌نیازها

* یک توزیع لینوکس مبتنی بر دبیان (مثلاً اوبونتو 18.04 به بالا، دبیان 10 به بالا).
* دسترسی ریشه (root) (اسکریپت باید با `sudo` اجرا شود).
* اتصال اینترنت فعال برای دانلود بسته‌ها.

#### 🛠️ نصب و استفاده

1.  **کلون کردن یا دانلود:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/SeylabiPanel.git](https://github.com/YOUR_USERNAME/SeylabiPanel.git)
    cd SeylabiPanel
    ```
    *(آدرس `YOUR_USERNAME/SeylabiPanel.git` را با آدرس مخزن خود جایگزین کنید)*

    یا فایل اسکریپت `seylabipanel.sh` را مستقیماً دانلود کنید.

2.  **قابل اجرا کردن:**
    ```bash
    chmod +x seylabipanel.sh
    ```
    *(اطمینان حاصل کنید نام فایل صحیح است)*

3.  **اجرا با Sudo:**
    ```bash
    sudo ./seylabipanel.sh
    ```

4.  **استفاده از منو:**
    * **۱. نصب SeylabiPanel:** شما را در فرآیند راه‌اندازی (کاربر، محیط دسکتاپ، RDP، ویژگی‌های اختیاری) راهنمایی می‌کند.
    * **۲. حذف SeylabiPanel:** اجزای پنل را با احتیاط حذف می‌کند. **پیام‌ها را با دقت بخوانید!**
    * **۳. بررسی وضعیت پنل:** وضعیت xrdp، محیط دسکتاپ، فایروال و غیره را نشان می‌دهد.
    * **۴. خروج:** اسکریپت را می‌بندد.

#### 🗒️ لاگ‌برداری
عملیات در فایل `/tmp/seylabipanel_apt.log` ثبت می‌شوند. برای عیب‌یابی به این فایل مراجعه کنید.

</details>

---

<details>
<summary><strong>🇨🇳 README 中文版 (Chinese)</strong></summary>

### SeylabiPanel (简体中文) - GUI 与 RDP 安装面板

SeylabiPanel 是一个 Bash 脚本，旨在简化在基于 Debian 的系统（如 Ubuntu）上安装和配置 Linux 桌面环境（XFCE、MATE、LXQt）及 RDP 访问（通过 xrdp）的过程。该脚本还包括卸载已安装组件和检查其状态的选项。

#### 🌟 主要功能

| 功能              | 描述                                                                         |
| :---------------- | :--------------------------------------------------------------------------- |
| 🚀 **交互式菜单** | 易于使用的菜单，用于执行安装、卸载和状态检查操作。                                           |
| 👤 **用户管理** | 为 RDP 登录创建新用户或配置现有用户，并设置密码。                                            |
| 💻 **桌面选择** | 允许在 XFCE（推荐）、MATE 和 LXQt 之间进行选择。                                           |
| 🌐 **xrdp 自动设置** | 为所选桌面环境安装和配置 xrdp。                                                              |
| 🔊 **声音（可选）** | 尝试设置通过 RDP 的基本声音重定向。                                                          |
| 📦 **应用（可选）** | 提供安装常用应用程序（如 Web 浏览器、文本编辑器等）的选项。                                    |
| 🔥 **防火墙配置** | 自动配置 UFW 以允许 RDP 连接（端口 3389）。                                                |
| 📝 **日志记录** | 在 `/tmp/seylabipanel_apt.log` 文件中记录操作日志。                                        |
| ✨ **用户友好界面** | 彩色输出和清晰提示，提供更好的用户体验。                                                       |

#### ✅ 系统要求

* 基于 Debian 的 Linux 发行版（例如 Ubuntu 18.04+、Debian 10+）。
* Root 权限（脚本必须使用 `sudo` 运行）。
* 有效的互联网连接以下载软件包。

#### 🛠️ 安装和使用

1.  **克隆或下载：**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/SeylabiPanel.git](https://github.com/YOUR_USERNAME/SeylabiPanel.git)
    cd SeylabiPanel
    ```
    *(请将 `YOUR_USERNAME/SeylabiPanel.git` 替换为您的仓库 URL)*

    或者，直接下载 `seylabipanel.sh` 脚本文件。

2.  **赋予执行权限：**
    ```bash
    chmod +x seylabipanel.sh
    ```
    *(确保文件名正确)*

3.  **使用 Sudo 运行：**
    ```bash
    sudo ./seylabipanel.sh
    ```

4.  **使用菜单导航：**
    * **1. 安装 SeylabiPanel：** 指导您完成设置过程（用户、桌面环境、RDP、可选功能）。
    * **2. 卸载 SeylabiPanel：** 谨慎地移除面板组件。**请仔细阅读提示！**
    * **3. 检查面板状态：** 显示 xrdp、桌面环境、防火墙等的状态。
    * **4. 退出：** 关闭脚本。

#### 🗒️ 日志记录
操作记录在 `/tmp/seylabipanel_apt.log` 文件中。如需故障排除，请检查此文件。

</details>

---

### 📜 License (مجوز / 许可证)

*You should place your license information here. If you haven't chosen one, popular choices include MIT, Apache 2.0, or GPLv3.*
*(شما باید اطلاعات مجوز خود را در اینجا قرار دهید. اگر هنوز یکی را انتخاب نکرده‌اید، گزینه‌های محبوب شامل MIT، Apache 2.0 یا GPLv3 هستند.)*
*(您应在此处放置您的许可证信息。如果您尚未选择，流行的选择包括 MIT、Apache 2.0 或 GPLv3。)*

---
<div align="center">
  <p>Happy RDPing with SeylabiPanel! 💻</p>
</div>
