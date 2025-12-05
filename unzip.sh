# usage: bash unzip.sh --dir <directory has zip files recursively>
# unzip the files the next to the zip files with the name directory

# example: 
# 3.개방데이터/1.데이터/Validation
# ├── 01.원천데이터
# │   ├── 1.zip
# │   ├── 2.zip
# └── 02.라벨링데이터
#     ├── 6.zip
#     └── 7.zip
# result:
# 3.개방데이터/1.데이터/Validation_unzipped
# ├── 01.원천데이터
# │   ├── 1/
# │   ├── 2/
# └── 02.라벨링데이터
#     ├── 6/
#     └── 7/


while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dir) TARGET_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$TARGET_DIR" ]; then
    echo "Usage: sh unzip.sh --dir <directory has zip files recursively>"
    exit 1
fi

TARGET_DIR="${TARGET_DIR%/}"
OUTPUT_DIR="${TARGET_DIR}_unzipped"
mkdir -p "$OUTPUT_DIR"
find "$TARGET_DIR" -type f -name "*.zip" | while read -r zipfile; do
    # Get the relative path of the zip file with respect to TARGET_DIR
    rel_path="${zipfile#$TARGET_DIR/}"
    # Get the directory path without the zip file name
    dir_path="$(dirname "$rel_path")"
    # Create the corresponding output directory
    mkdir -p "$OUTPUT_DIR/$dir_path"
    # Unzip the file into the corresponding output directory
    unzip -q "$zipfile" -d "$OUTPUT_DIR/$dir_path/$(basename "${zipfile%.zip}")"
    echo "Unzipped $zipfile to $OUTPUT_DIR/$dir_path/$(basename "${zipfile%.zip}")"
done

echo "✅  모든 파일 압축 해제 완료"