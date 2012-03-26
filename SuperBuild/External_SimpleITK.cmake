
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

# Set CMake OSX variable to pass down the external project
set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
if(APPLE)
  list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
    -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
endif()

set(SimpleITK_CONFIGURE_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_configure_step.cmake)
set(SimpleITK_INSTALL_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_install_step.cmake)


ExternalProject_add(SimpleITK
  SOURCE_DIR SimpleITK
  BINARY_DIR SimpleITK-build
  GIT_REPOSITORY ${git_protocol}://itk.org/SimpleITK.git

  # Tag of release branch on 2012-03-31
  GIT_TAG f41a2a3a7cb87df08448c6ec25bccdd3842de561
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND ${SimpleITK_CONFIGURE_COMMAND}
  INSTALL_COMMAND ${SimpleITK_INSTALL_COMMAND}
  DEPENDS ${SimpleITK_DEPENDENCIES}
)

set(SimpleITK_DIR "${CMAKE_BINARY_DIR}/SimpleITK-build")


configure_file(SuperBuild/SimpleITK_install_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_install_step.cmake
  @ONLY)
configure_file(SuperBuild/SimpleITK_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/SimpleITK_configure_step.cmake
  @ONLY)