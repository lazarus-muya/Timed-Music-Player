# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-src")
  file(MAKE_DIRECTORY "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-src")
endif()
file(MAKE_DIRECTORY
  "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-build"
  "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix"
  "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/tmp"
  "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
  "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src"
  "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "C:/Users/dev/Documents/projects/flutter/timed_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
