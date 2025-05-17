#!/usr/bin/env bash
################################################################################
# Generate some files using dd
#
# Usage
#
#   ./mkfiles.sh NUM_FILES FILE_SIZE > do.sh && chmod +x do.sh && ./do.sh
#
#   Where FILE_SIZE can be an integer or have suffix 'k' or 'M'
#
# Alternatively, you can specify the starting index for the files with:
#
#   ./mkfiles.sh NUM_FILES FILE_SIZE START_IDX
#
################################################################################

# set -x

SCRIPT_NAME=${0##*/}

si_to_byte_int()
{
  local string=$1

  # If there is no prefix
  if [[ ${string} =~ ^[0-9]+$ ]]; then
    val=${string}
    echo ${val}
    return 0;
  else
    # Trim the prefix
    unit=${string: -1}
    val=${string%?}
  fi

  # Convert the prefix
  case ${unit} in
    K|k) echo $((${val} * 1024)) ;;
    M|m) echo $((${val} * 1024 * 1024)) ;;
    *) printf "Invalid unit. Use k or M\r\n"; return 1 ;;
  esac
}

byte_int_to_si()
{
  local bytes=$1
  # Round to nearest kib
  local count_in_k=$(( (bytes+1023)/1024 ))
  echo "${count_in_k}k"
}

if [ "$#" -lt 2 ]; then
  printf "Usage: ${SCRIPT_NAME} FILE_SIZE NUM_FILES START_IDX\r\n"
  exit 1
fi

NUM_FILES=$1
FILE_SIZE=$(si_to_byte_int $2)
if [[ $? -ne 0 ]]; then
  exit 1
fi

# This is generally agreeable
BLOCK_SIZE=4096

COUNT=$((${FILE_SIZE}/${BLOCK_SIZE}))

if [[ ${NUM_FILES} -gt 100 ]]; then
  printf "WAY too many files! You requested ${NUM_FILES}\r\n"
  exit 1
fi

if [[ ${BLOCK_SIZE} -gt ${FILE_SIZE} ]]; then
  printf "BLOCK_SIZE of ${BLOCK_SIZE} exceeds FILE_SIZE of ${FILE_SIZE}\r\n"
  exit 1
fi

# Apparently dd won't allow a count of 65536, you must instead say 64k
COUNT=$(byte_int_to_si ${COUNT})

# FIXME: Validate argument 3
if [[ ! -z $3 ]]; then
  if [[ ! "$3" =~ ^[0-9]+$ ]]; then
    printf "If you use arg3, it must be an integer\r\n"
    exit 1
  else
    LOWER_IDX=$3
    UPPER_IDX=$(($3+${NUM_FILES}))
  fi
else
  LOWER_IDX=0
  UPPER_IDX=${NUM_FILES}
fi

printf "#!/usr/bin/env bash\n"
for ((file=$LOWER_IDX; file<${UPPER_IDX}; file++)); do
  printf "dd if=/dev/urandom of=block_${file}.bin bs=${BLOCK_SIZE} count=${COUNT}\n"
done
