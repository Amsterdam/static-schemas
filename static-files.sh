#!/usr/bin/env bash

set -e
set -x

TARGET=$1

if [[ -z "${TARGET}" ]]; then
  echo "Please supply target directory!"
  exit 1
fi

TARGET=$PWD/$TARGET

mkdir -p $TARGET/datasets

git clone -q https://github.com/Amsterdam/amsterdam-schema.git
cd amsterdam-schema

# Fetch all tags, filter out unwanted path names, write out content with @version postfix in filename
git tag -l 'v*' | while read version; do
  git ls-tree -r --name-only $version | grep "\.json\$" | grep -v "^test" | grep -v "^package" | while read path; do
    name=${path%.*}
    dir=$TARGET/$(dirname $path)
    mkdir -p $dir
    git show $version:$path > $TARGET/$name@$version
  done
done

# Same for HEAD, does not get @version postfix
git ls-tree -r --name-only HEAD | grep "\.json\$" | grep -v "^test" | grep -v "^package" | grep -v "^datasets" | grep -v "^schema" | while read path; do
  name=${path%.*}
  dir=$(dirname $path)
  mkdir -p $dir
  git show HEAD:$path > $TARGET/$name
done

cd ..
git clone -q https://github.com/Amsterdam/schemas.git
cd schemas

# Finally write out the published dataset from the schemas repo.
git ls-tree -r --name-only HEAD | grep "\.json\$" | grep -v "^test" | grep -v "^package" | while read path; do
  name=${path%.*}
  dir=$TARGET/datasets/$(dirname $name)
  mkdir -p $dir
  git show HEAD:$path > $TARGET/datasets/$name
done
