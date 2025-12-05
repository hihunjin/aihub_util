# AIHub download helpers

Small collection of helper scripts for working with AIHub datasets in this workspace.

Requirements
- bash (the scripts use bash features such as `mapfile` and process substitution)
- `aihubshell` available on PATH (use `install_aihubshell.sh` to install it)
- `unzip` (used by `unzip.sh`)

API key (required)
Place a file named `.env` in the same directory with a single line like:

```
APIKEY="YOUR-AIHUB-API-KEY-HERE"
```

Where to get an API key
-----------------------
To obtain your AIHub API key visit:

https://www.aihub.or.kr/devsport/apishell/list.do

Sign in (or sign up) and request or create an API key for the Aihub API shells — paste that key into your local `.env` as shown above.

install_aihubshell.sh
---------------------
Convenience script included to fetch and install `aihubshell` into `/usr/bin` (requires sudo).

get_datasetkey.sh
------------------
Quick helper for searching the list command output. Example:

```bash
sh get_datasetkey.sh 오피스
```

Listing the dataset tree
------------------------
If you only want to inspect the raw listing (the tree of files and IDs) produced by
`aihubshell -mode l -datasetkey <DATASET>`, use:

```bash
# print the listing and exit
bash download_loop.sh -d 71811 --list-only
# (alias)
bash download_loop.sh -d 71811 -L

```

download_loop.sh usage
------------------
Main script to download dataset files from AIHub. The script expects a dataset key and will either
download the listed file IDs or the full dataset if no IDs are provided.

Basic examples:

- Download all files in dataset 71811 (the script uses `aihubshell -mode l` to list file IDs and downloads each numeric ID):

```bash
bash download_loop.sh -d 71811
```

- Download only specific file IDs (comma or space separated):

```bash
bash download_loop.sh -d 71811 -f "397241,397242"
# or
bash download_loop.sh -d 71811 -f "397241 397242"
```

Important notes about `download_loop.sh`
- The script reads APIKEY from `.env` and will exit with an error if `.env` is missing (place your APIKEY there).
- Use `-f` / `--file-ids` to limit downloads to specific file IDs. If omitted the script lists all file IDs.
- The script traps Ctrl+C (SIGINT/SIGTERM) and will stop cleanly between downloads.

unzip.sh usage
---------------
This helper recursively finds `*.zip` files inside the requested directory and extracts each
archive into a sibling directory structure under `<TARGET_DIR>_unzipped`.

Example (dry-run not required — when you run it will extract):

```bash
bash unzip.sh --dir "/path/to/Validation"
```

Output will be under `/path/to/Validation_unzipped` preserving nested directories. Each archive `foo.zip` is extracted into a folder named `foo/` under the corresponding place in the output tree.
