#!/bin/bash
#author=Carson Brownlee
#generates md5 checksums for generated regression test image
# and uploads checksum and image to sdvis server
#
# argument 1: name of test
# argument 2: directory of test result images
# argument 2: path of ospray source
#
md5=`md5sum $2/$1.png | awk '{print $1 }'`
echo $md5
echo $md5 > $3/tests/baseline/$1.png.md5
rsync --rsync-path="sudo rsync" --chown=web:web $2/$1.png sdvis.org:/var/www/html/ospray/download/baseline/benchmark-data/MD5/$md5

