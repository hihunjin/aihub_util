#!/usr/bin/env bash
# set -euo pipefail


DATASET=""                  # 다운로드할 datasetkey (required)

usage(){
  cat <<EOF
Usage: bash $0 -d DATASET [-f FILE_IDS]

This script downloads files from AIHub for a dataset.

Required:
  -d, --dataset DATASET   dataset key to download (required)

Optional:
  -f, --file-ids IDS      Comma or space-separated list of file IDs to download.
                          If omitted the script will list all files in the dataset
                          using `aihubshell -mode l` and download every numeric file ID
                          it finds.
  --list-only             Print the `aihubshell -mode l` listing (tree) and exit
  -h, --help              Show this help message

Notes:
  • The script expects an APIKEY available in a `.env` file in the same directory
    (the script loads variables from `.env` at startup). If you prefer you can
    export APIKEY in your environment before running.
  • Example downloads:
      bash $0 -d 71811                # download all files in dataset 71811
      bash $0 -d 71811 -f "397241,397242"  # download only two file IDs

EOF
}

if [[ $# -eq 0 ]]; then
  echo "Error: datasetkey required."
  usage
  exit 1
fi


FILE_IDS_ARG=""    # optional: comma or space-separated file ids passed by user
LIST_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dataset)
      DATASET="$2"; shift 2;;
    -f|--file-ids)
      FILE_IDS_ARG="$2"; shift 2;;
    --list-only|-L)
      LIST_ONLY=1; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if [[ -z "$DATASET" ]]; then
  echo "Error: datasetkey cannot be empty."; usage; exit 1
fi

# handle keyboard interrupt (Ctrl+C) / termination gracefully
STOPPED=0
trap 'STOPPED=1; echo; echo "[INFO] Interrupted by user — stopping..."; ' INT TERM

aihubshell -mode l -datasetkey "${DATASET}"
if [[ "$LIST_ONLY" -eq 1 ]]; then
  exit 0
fi


# If file IDs were passed with -f/--file-ids, use them. Accept comma or space separated lists.
if [[ -n "$FILE_IDS_ARG" ]]; then
  # normalize commas to spaces then split into array
  FILE_IDS_ARG=${FILE_IDS_ARG//,/ }
  read -r -a FILE_IDS <<< "$FILE_IDS_ARG"
else
  ############################################
  # 1) 파일 ID 목록 가져오기 (default / existing behavior)
  ############################################
  mapfile -t FILE_IDS < <(
    aihubshell -mode l -datasetkey "${DATASET}" \
    | awk -F'|' '{gsub(/ /,"",$3); if($3 ~ /^[0-9]+$/) print $3}' )
  # ↑ 세 번째 컬럼( | 552811 )에서 숫자만 뽑아 배열 FILE_IDS[] 로 저장
fi

# echo file ids
echo "[INFO] 다운로드할 파일 ID 목록: ${FILE_IDS[*]}"

# Load APIKEY from .env file
if [[ -f .env ]]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "[ERROR] .env file not found"
  exit 1
fi

############################################
# 2) 각 fileSn 별 개별 다운로드
############################################
mkdir ${DATASET}
cd ${DATASET} || exit 1
echo "[INFO] 총 ${#FILE_IDS[@]} 개 파일을 받습니다"
for id in "${FILE_IDS[@]}"; do
  if [[ "$STOPPED" -eq 1 ]]; then
    echo "[INFO] Stopped before processing fileSn=${id}"; break
  fi

  echo -e "\n[+] fileSn=${id}"
  aihubshell -mode d -datasetkey "${DATASET}" -filekey "${id}" -aihubapikey "${APIKEY}"
done

echo "✅  모든 파일 다운로드 · 추출 완료"
