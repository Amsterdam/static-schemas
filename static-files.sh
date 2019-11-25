#!/usr/bin/env bash

set -e
set -x

TARGET=$1

mkdir -p $TARGET/core
mkdir -p $TARGET/dataset

git clone -q https://github.com/Amsterdam/amsterdam-schema.git
cd amsterdam-schema

git tag -l 'v*' | while read version; do
  git ls-files --with-tree=$version "*.json" ":!test/**" | while read path; do
    name=${path%.*}
    dir=$TARGET/$(dirname $path)
    mkdir -p $dir
    git show $version:$path > $TARGET/$name@$version
  done
done

git ls-files "*.json" ":!test/**" | while read path; do
  name=${path%.*}
  dir=$(dirname $path)
  mkdir -p $dir
  git show HEAD:$path > $TARGET/$name
done

cd ..
git clone -q https://github.com/Amsterdam/schemas.git
cd schemas

git ls-files "*.json" ":!test/**" | while read path; do
  name=${path%.*}
  dir=$TARGET/datasets/$(dirname $name)
  mkdir -p $dir
  git show HEAD:$path > $TARGET/datasets/$name
done
