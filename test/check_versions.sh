#!/bin/bash

# Checks that the artefacts produced by the JRuby build system have the correct
# names and versions.

jar_version=`cat VERSION`
gem_version=${jar_version/-/.}

rm -rf maven/*/target/*

mvn install -Pbootstrap
mvn -Pcomplete
mvn -Pdist
mvn -Pjruby-jars
mvn -Pjruby-tests
mvn -Pmain

declare -a failed
failed[0]=0

function check {
  archive=$1
  max=$2*1024*1024
  unpackaged=$3
  length=`cat $archive | wc -c`

  if [ ! -f $archive ]
  then
    echo $archive was not found - check your version numbers
    failed[0]=1
  fi

  if [[ $length -gt $max  ]]
  then
    echo size of $archive expected smaller then $max but got $length
    failed[0]=1
  fi

  if [[ $archive == *.tar.gz ]]
  then
    rm -rf $unpackaged
    tar -zxf $archive

    if [ ! -d $unpackaged ]
    then
      echo $archive did not untar to $unpackaged - check your version numbers
      failed[0]=1
    fi
  fi

  if [[ $archive == *.zip ]]
  then
    rm -rf $unpackaged
    unzip -q $archive

    if [ ! -d $unpackaged ]
    then
      echo $archive did not unzip to $unpackaged - check your version numbers
      failed[0]=1
    fi
  fi

}

check test/target/jruby-tests-$jar_version.jar 1
check maven/jruby-stdlib/target/jruby-stdlib-$jar_version.jar 8
check maven/jruby-jars/pkg/jruby-jars-$gem_version.gem 25
check maven/jruby-jars/lib/jruby-core-$jar_version-complete.jar 12
check maven/jruby-jars/lib/jruby-truffle-$jar_version-complete.jar 9
check maven/jruby-jars/lib/jruby-stdlib-$jar_version.jar 8
check maven/jruby-complete/target/jruby-complete-$jar_version.jar 27
check maven/jruby/target/jruby-$jar_version.jar 1
check maven/jruby-noasm/target/jruby-noasm-$jar_version.jar 9
check maven/jruby-dist/target/jruby-dist-$jar_version-bin.tar.gz 37 jruby-$jar_version
check maven/jruby-dist/target/jruby-dist-$jar_version-bin200.tar.gz 17 jruby-$jar_version
check maven/jruby-dist/target/jruby-dist-$jar_version-src.tar.gz 8 jruby-$jar_version
check maven/jruby-dist/target/jruby-dist-$jar_version-src.zip 13 jruby-$jar_version
check maven/jruby-dist/target/jruby-dist-$jar_version-bin.zip 38 jruby-$jar_version
check maven/jruby-dist/target/jruby-dist-$jar_version-bin200.zip 18 jruby-$jar_version
check core/target/jruby-core-$jar_version-noasm.jar 9
check core/target/jruby-core-$jar_version.jar 9
check core/target/jruby-core-$jar_version-complete.jar 12
check truffle/target/jruby-truffle-$jar_version.jar 8
check truffle/target/jruby-truffle-$jar_version-complete.jar 8

exit "${failed[0]}"
