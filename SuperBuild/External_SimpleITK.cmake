
# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Sanity checks
if(DEFINED SimpleITK_DIR AND NOT EXISTS ${SimpleITK_DIR})
  message(FATAL_ERROR "SimpleITK_DIR variable is defined but corresponds to non-existing directory")
endif()

# Set dependency list
set(SimpleITK_DEPENDENCIES ITKv4 Swig python)

# Include dependent projects if any
SlicerMacroCheckExternalProjectDependency(SimpleITK)

#
#  SimpleITK externalBuild
#
include(ExternalProject)

if(APPLE)
  set(SIMPLEITK_PYTHON_ARGS
    -DPYTHON_EXECUTABLE:PATH=${slicer_PYTHON_EXECUTABLE}
    -DPYTHON_FRAMEWORKS:PATH=${slicer_PYTHON_FRAMEWORK}
    -DPYTHON_LIBRARY:FILEPATH=${slicer_PYTHON_LIBRARY}
    -DPYTHON_INCLUDE_DIR:PATH=${slicer_PYTHON_INCLUDE}
    )
else()
  set(SIMPLEITK_PYTHON_ARGS
    -DPYTHON_EXECUTABLE:PATH=${slicer_PYTHON_EXECUTABLE}
    -DPYTHON_LIBRARY:FILEPATH=${slicer_PYTHON_LIBRARY}
    -DPYTHON_INCLUDE_DIR:PATH=${slicer_PYTHON_INCLUDE}
    )
endif()

configure_file(SuperBuild/SimpleITK_install_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_install_step.cmake
  @ONLY)

set(SimpleITK_INSTALL_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_install_step.cmake)


if(NOT DEFINED git_protocol)
  set(git_protocol "git")
endif()

#set(SimpleITK_REPOSITORY "${git_protocol}://itk.org/SimpleITK.git")
set(SimpleITK_REPOSITORY "${git_protocol}://github.com:blowekamp/SimpleITK.git")
set(SimpleITK_GIT_TAG SIMPLEITK-348_PythonThreading)

if ( SimpleITK_REPOSITORY MATCHES "itk\\.org/SimpleITK\\.git$")
  set(SimpleITK_OFFICIAL 1)
endif()

ExternalProject_add(SimpleITK
  SOURCE_DIR SimpleITK
  BINARY_DIR SimpleITK-build
  GIT_REPOSITORY git@github.com:blowekamp/SimpleITK.git
  GIT_TAG SIMPLEITK-348_PythonThreading
  "${slicer_external_update}"
  CMAKE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  # The SimpleITK libraries are 10x bigger
  -DBUILD_SHARED_LIBS:BOOL=OFF
  -DSimpleITK_PYTHON_THREADS:BOOL=ON
  # if from official repo remove GIT hash from version
  -DSimpleITK_BUILD_DISTRIBUTE:BOOL=${SimpleITK_OFFICIAL}
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}
  -DITK_DIR:PATH=${ITK_DIR}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  -DBUILD_DOXYGEN:BOOL=OFF
  -DWRAP_PYTHON:BOOL=ON
  -DWRAP_TCL:BOOL=OFF
  -DWRAP_JAVA:BOOL=OFF
  -DWRAP_RUBY:BOOL=OFF
  -DWRAP_LUA:BOOL=OFF
  -DWRAP_CSHARP:BOOL=OFF
  -DWRAP_R:BOOL=OFF
  ${SIMPLEITK_PYTHON_ARGS}
  -DSWIG_EXECUTABLE:PATH=${SWIG_EXECUTABLE}
  #
  INSTALL_COMMAND ${SimpleITK_INSTALL_COMMAND}
  #
  DEPENDS ${SimpleITK_DEPENDENCIES}
  )
