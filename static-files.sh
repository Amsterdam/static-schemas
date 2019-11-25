#!/usr/bin/env bash

set -e
set -x

TARGET=$1

if [[ -z "${TARGET}" ]]; then
  echo "Please supply target directory!"
  exit 1
fi

mkdir -p $TARGET/datasets

git clone -q https://github.com/Amsterdam/amsterdam-schema.git
cd amsterdam-schema

git tag -l 'v*' | while read version; do
  git ls-tree -r --name-only $version | grep "\.json\$" | grep -v "^test" | grep -v "^package" | while read path; do
    name=${path%.*}
    dir=$TARGET/$(dirname $path)
    mkdir -p $dir
    git show $version:$path > $TARGET/$name@$version
  done
done

git ls-tree -r --name-only HEAD | grep "\.json\$" | grep -v "^test" | grep -v "^package" | while read path; do
  name=${path%.*}
  dir=$(dirname $path)
  mkdir -p $dir
  git show HEAD:$path > $TARGET/$name
done

cd ..
git clone -q https://github.com/Amsterdam/schemas.git
cd schemas

git ls-tree -r --name-only HEAD | grep "\.json\$" | grep -v "^test" | grep -v "^package" | while read path; do
  name=${path%.*}
  dir=$TARGET/datasets/$(dirname $name)
  mkdir -p $dir
  git show HEAD:$path > $TARGET/datasets/$name
done
