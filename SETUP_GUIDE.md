# 🌾 SmartCrop Agri-DSS — Installation & Setup Guide

> **Nueva Ecija Offline Agricultural Decision Support System**  
> A C++ console application with MySQL persistence for rice crop management.  
> Authors: DELCASTILLO, MANALO, VIRAY, PATDO — Computer Programming 2, May 2026

---

## 📋 Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Clone the Repository](#2-clone-the-repository)
3. [Project Structure](#3-project-structure)
4. [Database Setup](#4-database-setup)
5. [Visual Studio Project Setup](#5-visual-studio-project-setup)
6. [MySQL Connector Configuration](#6-mysql-connector-configuration)
7. [Build the Project](#7-build-the-project)
8. [Copy Required DLLs](#8-copy-required-dlls)
9. [Run the Program](#9-run-the-program)
10. [Verify the Installation](#10-verify-the-installation)
11. [Common Errors & Fixes](#11-common-errors--fixes)
12. [Recommended Tools](#12-recommended-tools)

---

## 1. Prerequisites

Install all of the following before proceeding. **Do not skip any item.**

| Requirement | Version | Purpose | Download |
|---|---|---|---|
| Visual Studio | 2022 / Insiders | IDE + MSVC C++ Compiler | [visualstudio.microsoft.com](https://visualstudio.microsoft.com) |
| MySQL Server | 8.x or higher | Database engine | [dev.mysql.com](https://dev.mysql.com/downloads/mysql/) |
| MySQL Connector C++ | **9.7.0 winx64** | C++ MySQL driver (JDBC API) | [dev.mysql.com/downloads](https://dev.mysql.com/downloads/connector/cpp/) |
| MySQL Workbench *(optional)* | Any | GUI for running SQL scripts | [dev.mysql.com](https://dev.mysql.com/downloads/workbench/) |

> ⚠️ **Platform Warning:** The MySQL Connector provided is **64-bit (winx64)**. Your Visual Studio build configuration **must be set to x64**. Building as x86/Win32 will cause fatal linker errors.

### Visual Studio Workload Required

When installing Visual Studio, make sure the following workload is checked:

```
✅ Desktop development with C++
```

This installs the MSVC compiler and Windows SDK needed to build this project.

---

## 2. Clone the Repository

```bash
git clone https://github.com/your-username/SmartCropAgroDSS.git
cd SmartCropAgroDSS
```

Or download the ZIP from GitHub → **Code → Download ZIP**, then extract it.

---

## 3. Project Structure

After cloning, your project folder should contain exactly these files:

```
SmartCropAgroDSS/
├── INPUT_DATA/
│   └── database.txt          ← offline backup (create this manually if missing)
├── main.cpp
├── agriManager.cpp
├── agriManager.h
├── dailyRecord.h
├── DatabaseManager.cpp
├── DatabaseManager.h
└── smartCropSQL.sql
```

### Create the INPUT_DATA folder manually

The program reads and writes to `INPUT_DATA/database.txt` for offline mode. Create it now:

1. Inside the project folder, create a new folder named exactly `INPUT_DATA`
2. Inside that folder, create an empty text file named `database.txt`

> The folder name is **case-sensitive** and must match exactly. If it is missing, the program will print `SYSTEM: No database.txt found. Starting with empty session.` on every launch.

---

## 4. Database Setup

The program connects to a local MySQL database named `agri_dss`. You must create this database and its table **before** running the program.

### Step 1 — Open MySQL Workbench or the MySQL CLI

**Option A — MySQL Workbench:**
- Launch Workbench and connect to `localhost` on port `3306`
- Open a new query tab

**Option B — Command Line:**
```bash
mysql -u root -p
# Enter your MySQL root password when prompted
```

### Step 2 — Create the Database and Table

Run the following SQL. This is safe to run multiple times — it will not overwrite existing data:

```sql
CREATE DATABASE IF NOT EXISTS agri_dss;

USE agri_dss;

CREATE TABLE IF NOT EXISTS daily_records (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    temperature   FLOAT NOT NULL,
    rainfall_mm   FLOAT NOT NULL,
    daily_gdd     FLOAT NOT NULL
);
```

### Step 3 — Load the Sample Data

Run the included `smartCropSQL.sql` file to populate the table with 22 days of sample weather data:

**In Workbench:** File → Open SQL Script → select `smartCropSQL.sql` → press `Ctrl+Shift+Enter`

**In CLI:**
```bash
source /path/to/smartCropSQL.sql
```

### Step 4 — Verify

```sql
SELECT * FROM agri_dss.daily_records;
```

You should see **22 rows** returned. If the table is empty or missing, the program will print:

```
ERROR: Could not read daily_records. Table 'agri_dss.daily_records' doesn't exist
CRITICAL: Validation failed. Switching to offline mode.
```

### Database Credentials

The credentials are hardcoded in `main.cpp`:

```cpp
db.connect("root", "Your Password");
```

If your MySQL root password is **different**, open `main.cpp` and update the second argument before building:

```cpp
db.connect("root", "YOUR_ACTUAL_PASSWORD");
```

---

## 5. Visual Studio Project Setup

### Step 1 — Create a New Project

1. Open Visual Studio
2. Click **Create a new project**
3. Search for **Empty Project** and select **Empty Project (C++)** — not Console App
4. Click **Next**
5. Set the project name (e.g., `SmartCropAgroDSS`) and choose your cloned folder as the location
6. Click **Create**

> ⚠️ Do **not** use "Console App". It auto-generates a `main.cpp` that will conflict with the existing one.

### Step 2 — Set Platform to x64

In the top toolbar, change the platform dropdown from **x86** or **Win32** to **x64**.

```
Debug ▾  |  x64 ▾       ← must look like this
```

If x64 is not listed, go to **Build → Configuration Manager → Active solution platform → New → x64**.

### Step 3 — Add Source Files

In **Solution Explorer** on the right panel:

1. Right-click **Source Files → Add → Existing Item...**
   - Add: `main.cpp`, `agriManager.cpp`, `DatabaseManager.cpp`

2. Right-click **Header Files → Add → Existing Item...**
   - Add: `agriManager.h`, `dailyRecord.h`, `DatabaseManager.h`

---

## 6. MySQL Connector Configuration

This is the most critical section. Open **Project Properties** by right-clicking the project name in Solution Explorer → **Properties**.

> ⚠️ Before making any changes, confirm the dropdowns at the top of the Properties window show **Debug** and **x64**.

---

### 6A — Additional Include Directories

**Path:** `C/C++ → General → Additional Include Directories`

Click the field → dropdown arrow → **Edit...** → add:

```
C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\include
```

---

### 6B — Additional Library Directories

**Path:** `Linker → General → Additional Library Directories`

Click the field → dropdown arrow → **Edit...** → add:

```
C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\lib64\vs14
```

> ⚠️ **Important:** The `.lib` files are inside the `vs14` subfolder — **not** directly in `lib64`. Setting the path to `lib64` alone will cause `LNK1104: cannot open file 'mysqlcppconn8.lib'`.

---

### 6C — Additional Dependencies (Linker Input)

**Path:** `Linker → Input → Additional Dependencies`

Click the field → dropdown arrow → **Edit...** → add these two lines at the top:

```
mysqlcppconnx.lib
mysqlcppconn.lib
```

> ⚠️ **Important:** There is **no** `mysqlcppconn8.lib` in Connector/C++ 9.7.0. The correct library names for this version are `mysqlcppconnx.lib` and `mysqlcppconn.lib`. Using the old name causes `LNK1104`.

---

### 6D — Save Settings

Click **Apply → OK** to close Project Properties.

---

## 7. Build the Project

Press `Ctrl+Shift+B` or go to **Build → Build Solution**.

A successful build ends with:

```
========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
```

If errors appear, check the **Error List** tab at the bottom and refer to [Section 11](#11-common-errors--fixes).

---

## 8. Copy Required DLLs

Even after a successful build, the program **will crash immediately at runtime** if the MySQL DLLs are not present next to the `.exe`. This is a required manual step.

### Source folder:
```
C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\lib64\
```

### Copy these 4 files:
```
mysqlcppconnx-2-vs14.dll
mysqlcppconn-10-vs14.dll
libssl-3-x64.dll
libcrypto-3-x64.dll
```

### Paste them into:
```
<YourProjectFolder>\x64\Debug\
```

> ⚠️ This step must be repeated after a full **Clean + Rebuild**, as the `Debug` folder is wiped and recreated.

---

## 9. Run the Program

Press `Ctrl+F5` (Run Without Debugging) to launch the console application.

> Use `Ctrl+F5` instead of `F5`. It keeps the console window open after the program exits so you can read the output.

---

## 10. Verify the Installation

### Successful startup output:

```
SUCCESS: Connected to the database.
Session GDD seeded from database: 484 GDD
Session arrays loaded: 22 day(s) restored.

SYSTEM: Press Enter to launch the dashboard...
```

Press **Enter**. The main menu will appear:

```
=== Nueva Ecija Offline Agri-DSS ===
Time: 10:30 AM
1. Input Farm Data (Rain/Temp)
2. Analyze Crop Stage
3. Fertilizer Recommendation
4. Irrigation Schedule
5. Harvest Prediction
6. Search Specific Record
7. Edit Past Record
8. Reset Season Data
9. Delete Specific Record
10. Exit
Select an option:
```

If the program starts in **Offline Mode** instead, refer to [Section 11](#11-common-errors--fixes).

---

## 11. Common Errors & Fixes

---

### ❌ Error: `LNK1104: cannot open file 'mysqlcppconn8.lib'`

**Cause:**  
The library name `mysqlcppconn8.lib` does not exist in MySQL Connector C++ 9.7.0. The file was renamed in this version. Additionally, the `.lib` files are inside `lib64\vs14\`, not `lib64\` directly.

**Fix:**  
1. Go to `Project Properties → Linker → General → Additional Library Directories`  
   Set path to: `C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\lib64\vs14`

2. Go to `Project Properties → Linker → Input → Additional Dependencies`  
   Replace `mysqlcppconn8.lib` with:
   ```
   mysqlcppconnx.lib
   mysqlcppconn.lib
   ```

---

### ❌ Error: `Cannot open include file: 'jdbc/mysql_connection.h'`

**Cause:**  
The include directory is missing or pointing to the wrong path.

**Fix:**  
Go to `Project Properties → C/C++ → General → Additional Include Directories`  
Set path to:
```
C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\include
```

---

### ❌ Error: `Unhandled exception: std::bad_alloc` (program crashes on launch)

**Cause:**  
The MySQL DLL files are missing from the output directory. The connector loaded but failed to initialize because it could not find its runtime dependencies (`libssl`, `libcrypto`).

**Fix:**  
Copy all 4 DLL files from `lib64\` into `x64\Debug\`:
```
mysqlcppconnx-2-vs14.dll
mysqlcppconn-10-vs14.dll
libssl-3-x64.dll
libcrypto-3-x64.dll
```

---

### ❌ Error: `0xC0000135 — The application was unable to start correctly`

**Cause:**  
One or more DLL files are missing from the output directory.

**Fix:**  
Same as above — copy all 4 DLLs into `x64\Debug\`.

---

### ❌ Error: `Table 'agri_dss.daily_records' doesn't exist` → Offline Mode

**Cause:**  
The SQL script was never run. The database or table does not exist yet.

**Fix:**  
Open MySQL Workbench or CLI and run:
```sql
CREATE DATABASE IF NOT EXISTS agri_dss;
USE agri_dss;
CREATE TABLE IF NOT EXISTS daily_records (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    temperature FLOAT NOT NULL,
    rainfall_mm FLOAT NOT NULL,
    daily_gdd   FLOAT NOT NULL
);
```
Then run `smartCropSQL.sql` to load the sample data.

---

### ❌ Program starts with: `WARNING: Database unavailable. Starting in Offline Mode.`

**Cause:**  
Either the MySQL Server is not running, or the password in `main.cpp` does not match your MySQL root password.

**Fix:**  
1. Open **Services** (Windows) and confirm `MySQL80` is running.  
2. Open `main.cpp` and update the credentials:
   ```cpp
   db.connect("root", "YOUR_ACTUAL_PASSWORD");
   ```
3. Rebuild and rerun.

---

### ❌ Build errors with no clear message / `0 succeeded`

**Cause:**  
Platform mismatch. Project is being built as x86 but the connector is 64-bit.

**Fix:**  
Check the top toolbar. The platform dropdown must show **x64**, not x86 or Win32.

---

### ❌ `SYSTEM: No database.txt found. Starting with empty session.`

**Cause:**  
The `INPUT_DATA` folder or `database.txt` file does not exist in the project directory.

**Fix:**  
1. Create a folder named `INPUT_DATA` inside your project folder
2. Create an empty file named `database.txt` inside it

---

## 12. Recommended Tools

| Tool | Purpose |
|---|---|
| Visual Studio 2022 / Insiders | Primary IDE — required |
| MySQL Workbench | GUI for running SQL scripts and inspecting data |
| MySQL Shell | CLI alternative for database management |
| Windows File Explorer | Manually verifying DLL placement in `x64\Debug\` |
| Git | Cloning and version control |

---

## 📁 MySQL Connector Path Reference

| Property | Path |
|---|---|
| Include Directory | `C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\include` |
| Library Directory | `C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\lib64\vs14` |
| DLL Source | `C:\Program Files\MySQL\mysql-connector-c++-9.7.0-winx64\lib64\` |
| Linker Libraries | `mysqlcppconnx.lib` and `mysqlcppconn.lib` |
| Build Platform | **x64 only** |
| Database Name | `agri_dss` |
| DB Host | `tcp://127.0.0.1:3306` |
| Default Credentials | `root` / `Your Password` *(change if different)* |

---

*SmartCrop Agri-DSS — Computer Programming 2 Project, May 2026*
