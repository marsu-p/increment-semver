#!/bin/bash

# Increment a version string using Semantic Versioning (SemVer) terminology.

# Parse command line options.

while getopts ":Mmp" Option
do
  case $Option in
    M ) major=true;;
    m ) minor=true;;
    p ) patch=true;;
  esac
done

shift $(($OPTIND - 1))

#version=$1
echo "cd to github workspace ${GITHUB_WORKSPACE}"
cd ${GITHUB_WORKSPACE}
find .
git for-each-ref refs/tags/
git for-each-ref refs/tags/ --count=1 --sort=-version:refname --format='%(refname:short)'

version=$(git for-each-ref refs/tags/ --count=1 --sort=-version:refname --format='%(refname:short)')
echo "Version: ${version}"

if [ -z ${version} ]
then
    echo "Couldn't determine version"
    exit 1
fi
# Build array from version string.

a=( ${version//./ } )
major_version=0
# If version string is missing or has the wrong number of members, show usage message.

if [ ${#a[@]} -ne 3 ]
then
  echo "usage: $(basename $0) [-Mmp] major.minor.patch"
  exit 1
fi

# Increment version numbers as requested.

if [ ! -z $major ]
then
# Check for v in version (e.g. v1.0 not just 1.0)
  if [[ ${a[0]} =~ ([vV]?)([0-9]+) ]]
  then 
    v="${BASH_REMATCH[1]}"
    major_version=${BASH_REMATCH[2]}
    ((major_version++))
    a[0]=${v}${major_version}
  else 
    ((a[0]++))
    major_version=a[0]
  fi
  
  a[1]=0
  a[2]=0
fi

if [ ! -z $minor ]
then
  ((a[1]++))
  a[2]=0
fi

if [ ! -z $patch ]
then
  ((a[2]++))
fi

echo "${a[0]}.${a[1]}.${a[2]}"
version=$(echo "${a[0]}.${a[1]}.${a[2]}")
just_numbers=$(echo "${major_version}.${a[1]}.${a[2]}")
echo "::set-output name=version::${version}"
echo "::set-output name=stripped-version::${just_numbers}"

