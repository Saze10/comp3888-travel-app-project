#!/bin/bash

cd /workspace
git clone https://bitbucket.org/zelu2930/comp3888_t15_06_group3.git
cd comp3888_t15_06_group3
num=$(($(git log  --oneline | wc -l)))
echo $num
name=$(echo $num | cut -c 1).$(echo $num | cut -c 2).$(echo $num | cut -c 3)


# shellcheck disable=SC2164
cd /workspace/flutter_app
flutter test

#old=$(grep -w version: pubspec.yaml | cut -c 10-16)
#num=$(($(grep -w version: pubspec.yaml | cut -c 16)+1))
#shellcheck disable=SC2004
#new=$(grep -w version: pubspec.yaml | cut -c 10-15)$num
#
#path=$(find . -name pubspec.yaml)
#for way in $path
#do
#  echo $way
#  # shellcheck disable=SC1073
#  vi -e "$way"<<-!
#  :18,19s/$old/$new/g
#  :wq
#!
#done
#echo $name
#echo $num
flutter build appbundle --build-name=$name --build-number=$num
