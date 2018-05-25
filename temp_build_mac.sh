#!/usr/bin/env bash
set -e
set -o pipefail
set -x

# Install dependencies
mozroots --import --sync --quiet
mono ./.nuget/NuGet.exe restore ./iCSharp.sln

# Build scriptcs
cd ./Engine

# install
mozroots --import --sync --quiet
mkdir -p packages
cp -r ../packages/* ./packages/
mono ./.nuget/NuGet.exe restore ./ScriptCs.sln

# script
mkdir -p artifacts/Release/bin
xbuild ./ScriptCs.sln /property:Configuration=Release /nologo /verbosity:normal
cp src/ScriptCs/bin/Release/* artifacts/Release/bin/

# Disable testing for now!
#mono ./packages/xunit.runners.1.9.2/tools/xunit.console.clr4.exe test/ScriptCs.Tests.Acceptance/bin/Release/ScriptCs.Tests.Acceptance.dll /xml artifacts/ScriptCs.Tests.Acceptance.dll.TestResult.xml /html artifacts/ScriptCs.Tests.Acceptance.dll.TestResult.html

cd ../

# Build iCSharp
mkdir -p build/Release/bin
xbuild ./iCSharp.sln /property:Configuration=Release /nologo /verbosity:normal

# Copy files safely
for line in $(find ./*/bin/Release/*); do 
	 cp $line ./build/Release/bin
done

jupyter kernelspec install kernel-spec --name=csharp --user
