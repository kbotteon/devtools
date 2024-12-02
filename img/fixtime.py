#!/usr/bin/env python3
"""

Pull EXIF DateTimeOriginal and adjust the file Create Date to match
Prints the suggested commands rather than executing them, so you can eyeball
for correctness. Works with JPEG only! Known to NOT work on MOV and HEIC.

Tested on: macOS
--
Copyright 2022 Kyle Botteon

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import sys
import os
import subprocess
from PIL import Image
from pillow_heif import register_heif_opener
from hachoir.parser import createParser
from hachoir.metadata import extractMetadata

register_heif_opener()

CMD_SCRIPT_PATH = "./_cmd.sh"
EXIF_LOG_PATH = "./_exif.txt"
ERROR_LOG_PATH = "./_problems.txt"

EXT_VIDEO = [
    ".mov",
]

EXT_PHOTO = [
    ".jpg",
    ".jpeg",
    ".heic",
]

# From EXIF specification
EXIF_DATE_TIME_ORIGINAL = 36867
EXIF_DATE_TIME_BACKUP = 306

def main(file_list):

    # Open the command script file we're generating, plus log files
    cmd_log = open(CMD_SCRIPT_PATH, 'w')
    exif_log = open(EXIF_LOG_PATH, 'w')
    bad_file_list = open(ERROR_LOG_PATH, 'w')

    # Write the shebang line of the script file
    cmd_log.write("#!/usr/bin/env bash\n")

    # Write a new line to the script or logs for every file being inspected
    for file in file_list:

        IS_VIDEO = False
        IS_PHOTO = False
        split = os.path.splitext(file)
        ext = split[1].lower()

        if ext in EXT_VIDEO:

            date = get_create_date(file)
            year = date.year
            month = date.month
            day = date.day
            hour = date.hour
            minute = date.minute
            second = date.second

            command = "SetFile"
            args = f" -d \"{month}/{day}/{year} {hour}:{minute}:{second}\""
            args += f" -m \"{month}/{day}/{year} {hour}:{minute}:{second}\""
            args += f" {file}"

            exif_log.write(f"{date}\n")
            cmd_log.write(f"{command}{args}\n")

        elif ext in EXT_PHOTO:

            # Extract EXIF DateTimeOriginal
            imageHandle = Image.open(file)
            exif = imageHandle.getexif() # .getexif() doesn't work?

            # If there is no EXIF data, can't do much here; try the next file
            if exif == None:
                bad_file_list.write(f"{file}\n")
                print(f"[ERR] _getexif failed in {file}")
                continue

            dateTimeOriginal = exif.get(EXIF_DATE_TIME_ORIGINAL)

            if dateTimeOriginal == None:
                # Try DateTime if missing DateTimeOriginal
                dateTimeOriginal = exif.get(EXIF_DATE_TIME_BACKUP)

            if dateTimeOriginal == None:
                bad_file_list.write(f"{file}\n")
                print(f"[ERR] No EXIF data found in {file}")
                continue

            # Extract date-time to reformat into a shell command
            # These offsets come from the EXIF spec
            exifYear = dateTimeOriginal[0:4]
            exifMonth = dateTimeOriginal[5:7]
            exifDay = dateTimeOriginal[8:10]
            exifHour = dateTimeOriginal[11:13]
            exifMin = dateTimeOriginal[14:16]
            exifSec = dateTimeOriginal[17:19]

            # Form and print the suggested commands
            command = "SetFile"
            args = f" -d \"{exifMonth}/{exifDay}/{exifYear} {exifHour}:{exifMin}:{exifSec}\""
            args += f" -m \"{exifMonth}/{exifDay}/{exifYear} {exifHour}:{exifMin}:{exifSec}\""
            args += f" {file}"

            exif_log.write(f"{exif}\n")
            cmd_log.write(f"{command}{args}\n")

        else:

            bad_file_list.write(f"{file}\n")
            continue

    # Print the script file and log names to terminal
    print(f"Generated command file written to {cmd_log.name}. Verify, make it executable, and run.")
    print(f"EXIF data dumped to {exif_log.name}.")
    print(f"Problem files logged to {bad_file_list.name}")

def get_create_date(filename):
    parser = createParser(filename)
    metadata = extractMetadata(parser)
    return metadata.get('creation_date')

# File to operate on are passed as arguments to script
if __name__ == "__main__":

    args = []
    for arg in sys.argv[1:]:
        # Skip directories
        if not os.path.isdir(arg):
            args.append(arg)

    main(args)
