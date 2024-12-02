#!/usr/bin/env python3
"""

Get and set EXIF data on images.

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

import exif as libExif
from PIL import Image as libImage

import os as libOs
import sys as libSys

EXIF_DATETIME = 306
EXIF_DATETIME_ORIGINAL = 36867

################################################################################

def get_exif(file):

    with open(file, "rb") as my_file:
        image_handle = libExif.Image(my_file)

    all_exif = image_handle.list_all()

    if all_exif == None:
        print("No EXIF data found")

    else:
        print(all_exif)

################################################################################

def set_exif_datetime(filePathOrig, filePathNew, value):

    with open(filePathOrig, 'rb') as orig_file:
        image_handle = libExif.Image(orig_file)
        image_handle.datetime = value
        del image_handle._gps_ifd_pointer
        print("New EXIF: {}".format(image_handle.list_all()))
        with open(filePathNew, 'wb') as new_file:
            new_file.write(image_handle.get_file())

################################################################################

def set_exif_datetime_pillow(filePathOrig, filePathNew, value):

    with libImage.open(filePathOrig) as image_handle:
        exif = image_handle.getexif()
        exif[EXIF_DATETIME] = str(value)
        exif[EXIF_DATETIME_ORIGINAL] = str(value)
        image_handle.save(filePathNew, exif=exif)

################################################################################

def parse_args(args):

    arg_dict = {}

    arg_dict["Mode"] = args[0]
    arg_dict["File"] = args[1]

    if(arg_dict["Mode"] == "set"):
        arg_dict["Tag"] = args[2]
        arg_dict["Value"] = args[3]

    return arg_dict

################################################################################

def main(args):

    arg_dict = parse_args(args)

    if arg_dict["Mode"] == "set":
        if not libOs.path.exists("export"):
            libOs.makedirs("export")

        set_exif_datetime_pillow(
            arg_dict["File"],
            "export/"+arg_dict["File"],
            arg_dict["Value"]
        )

    elif arg_dict["Mode"] == "get":
        get_exif(arg_dict["File"])

################################################################################

if __name__ == "__main__":

    args = []
    for arg in libSys.argv[1:]:
        args.append(arg)

    main(args)
