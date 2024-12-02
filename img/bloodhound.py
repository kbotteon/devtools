#!/usr/bin/env python3
"""

Guesses the filetypes of a directory of files with either incorrect or
missing extensions, and then rename them with the assumed correct extension.

Tested on: macOS
--
Copyright 2023 Kyle Botteon

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

import os
import magic

OUTPUT_DIR = "./output"
MAX_DIRS = 500

MAGIC_EXT_PAIRS = {
    "image/png"       : "png",
    "image/heic"      : "heic",
    "image/jpeg"      : "jpeg",
    "video/quicktime" : "mov",
    "image/gif"       : "gif",
    "text/plain"      : "txt",
}

def decode(base, files):

    pairs = list()

    for file in files:

        old_path = os.path.join(base, file)
        guess_ext = magic.from_file(old_path, mime=True)

        # Map the guessed type to an extension to use in renaming
        ext = MAGIC_EXT_PAIRS.get(guess_ext)

        if ext != None:
            new_path = os.path.join(OUTPUT_DIR, f"{file}.{ext}")
            path_pair = (old_path, new_path)
            pairs.append(path_pair)
        else:
            print(guess_ext)

    return pairs

def main():

    dir_num = 0
    file_num = 0

    # Open a file to write commands into, so user can verify before executing
    cmd_log = open("../_cmd.sh", 'w')

    # Write the shebang line of the script file
    cmd_log.write("#!/usr/bin/env bash\n")

    for base, subdirs, files in os.walk(os.getcwd()):

        path_pairs = decode(base, files)

        for old_path, new_path in path_pairs:

            sys_cmd = "{} {} {}".format("cp", old_path, new_path)
            cmd_log.write(f"{sys_cmd}\n")
            file_num += 1

        dir_num += 1
        if dir_num >= MAX_DIRS:
            print(f"Reached maximum number of directories to recurse through: {MAX_DIRS}")
            break

    print(f"Made it through {file_num} files in {dir_num} directories")

if __name__ == "__main__":
    main()
