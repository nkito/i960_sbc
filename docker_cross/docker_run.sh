#!/bin/sh

docker run -it --rm -v /path_to_src_folder_in_host:/src -u (host uid):(host gid) i960sdk
