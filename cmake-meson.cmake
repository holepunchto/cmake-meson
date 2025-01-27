include_guard()

set(meson_module_dir "${CMAKE_CURRENT_LIST_DIR}")

function(meson_system result)
  set(option_keywords
    BUILD
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "" ""
  )

  set(system ${CMAKE_SYSTEM_NAME})

  if(NOT system OR ARGV_BUILD)
    set(system ${CMAKE_HOST_SYSTEM_NAME})
  endif()

  string(TOLOWER "${system}" ${result})

  return(PROPAGATE ${result})
endfunction()

function(meson_cpu result)
  set(option_keywords
    BUILD
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "" ""
  )

  if(APPLE AND CMAKE_OSX_ARCHITECTURES)
    set(cpu ${CMAKE_OSX_ARCHITECTURES})
  elseif(MSVC AND CMAKE_GENERATOR_PLATFORM)
    set(cpu ${CMAKE_GENERATOR_PLATFORM})
  elseif(ANDROID AND CMAKE_ANDROID_ARCH_ABI)
    set(cpu ${CMAKE_ANDROID_ARCH_ABI})
  else()
    set(cpu ${CMAKE_SYSTEM_PROCESSOR})
  endif()

  if(NOT cpu OR ARGV_BUILD)
    set(cpu ${CMAKE_HOST_SYSTEM_PROCESSOR})
  endif()

  string(TOLOWER "${cpu}" ${result})

  return(PROPAGATE ${result})
endfunction()

function(meson_cpu_family result)
  set(option_keywords
    BUILD
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "" ""
  )

  if(ARGV_BUILD)
    set(BUILD BUILD)
  else()
    set(BUILD)
  endif()

  meson_cpu(cpu ${BUILD})

  if(cpu MATCHES "arm64|aarch64")
    set(${result} "aarch64")
  elseif(cpu MATCHES "armv7-a|armeabi-v7a")
    set(${result} "arm")
  elseif(cpu MATCHES "x64|x86_64|amd64")
    set(${result} "x86_64")
  elseif(cpu MATCHES "x86|i386|i486|i586|i686")
    set(${result} "x86")
  else()
    set(${result} "unknown")
  endif()

  return(PROPAGATE ${result})
endfunction()

function(meson_endian result)
  set(option_keywords
    BUILD
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "" ""
  )

  if(ARGV_BUILD)
    message(FATAL_ERROR "Unable to determine byte order of the build machine")
  endif()

  if(CMAKE_C_BYTE_ORDER MATCHES "BIG_ENDIAN")
    set(${result} "big")
  else()
    set(${result} "little")
  endif()

  return(PROPAGATE ${result})
endfunction()

function(meson_buildtype result)
  if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(${result} debug)
  elseif(CMAKE_BUILD_TYPE MATCHES "Release")
    set(${result} release)
  elseif(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
    set(${result} debugoptimized)
  elseif(CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
    set(${result} minsize)
  else()
    message(FATAL_ERROR "Unknown CMake build type '${CMAKE_BUILD_TYPE}'")
  endif()

  return(PROPAGATE ${result})
endfunction()

function(meson_cross_file result)
  meson_system(host_system)
  meson_cpu(host_cpu)
  meson_cpu_family(host_cpu_family)
  meson_endian(host_endian)

  meson_system(build_system BUILD)
  meson_cpu(build_cpu BUILD)
  meson_cpu_family(build_cpu_family BUILD)

  file(READ "${meson_module_dir}/cross-files/${host_system}.txt" template)

  string(CONFIGURE "${template}" ${result})

  return(PROPAGATE ${result})
endfunction()
