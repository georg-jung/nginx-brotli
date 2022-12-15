#!/usr/bin/env bash

# taken from https://gist.githubusercontent.com/bric3/f8ebbe444704a3a7a05d3fd952c32129/raw/e57108275e86c1a9b3ba8b38dc61a94f454136a2/docker-tag-groups.sh

set -euo pipefail
#set -o xtrace

image=${1};
wanted_tag=${2:-""};

max_pages=10;
grouped_tags_tmp=$(mktemp);

function finish {
  rm -rf "{$grouped_tags_tmp}";
}
trap finish EXIT;

(
  url="https://registry.hub.docker.com/v2/repositories/${image}/tags/?page_size=100"
  counter=1
  while [ $counter -le $max_pages ] && [ -n "${url}" ]; do
    >&2 echo -n ".";
    content=$(curl -s "${url}");
    ((counter++));
    url=$(jq -r '.next // empty' <<< "${content}");
    echo "${content}";
  done;
  >&2 echo;
) | jq -s '[.[].results[]]' \
  | jq 'map({tag: .name, digest: .images[].digest}) | unique | group_by(.digest) | map(select(.[].digest) | {(.[0].digest): [.[].tag]}) | unique' \
  > "${grouped_tags_tmp}";

# jq -s '[.[].results[]]' will slurp -s the array of all pages in a single big array, somewhat like a flatmap
# jq 'map({tag: .name, digest: .images[].digest}) | unique | group_by(.digest) | map(select(.[].digest) | {(.[0].digest): [.[].tag]})'
# - map({tag: .name, digest: .images[].digest}) will keep only the tag name and the images digest
# - unique will keep unique objects, as it's possible to have to have images digest that are available with various architecture or os
# - group_by(.digest) group tags by their images digest, this creates an array of an array of objects
# - map(select(.[].digest) | {(.[0].digest): [.[].tag]}) change the structure to an array of objects shaped this way
#      {
#        "sha256:518f6c2137b7463272cb1f52488e914b913b92bfe0783acb821c216987959971": [
#          "11",
#          "11-buster",
#          "11-jdk",
#          "11-jdk-buster",
#          "11.0",
#          "11.0-buster",
#          "11.0-jdk",
#          "11.0-jdk-buster",
#          "11.0.8",
#          "11.0.8-buster",
#          "11.0.8-jdk",
#          "11.0.8-jdk-buster"
#        ]
#      }


if [ -n "${wanted_tag}" ]; then
  jq --arg wanted_tag "${wanted_tag}" 'map(to_entries | map(select(.value | index($wanted_tag))) | from_entries | select(length > 0)) | unique' "${grouped_tags_tmp}"
  # 'map(to_entries | map(select(.value | index($wanted_tag))) | from_entries | select(length > 0)) | unique'
  # - first map(...) enable to work on each entries of the input array
  # - to_entries | map(select(.value | index($wanted_tag))) | from_entries | select(length > 0)
  #   - to_entries for each object extract as a dictionary with key : (the digest), value: (the tags array)
  #   - map(select(.value | index($wanted_tag))) will select the entry whose value has the wanted tag in its array
  #   - from_entries will reassemble the dictionary as a object { digest: tags array}
  #   - select(length > 0) will remove empty objects
  # - unique remove possible duplicates
else
  jq '.' "${grouped_tags_tmp}"
fi
