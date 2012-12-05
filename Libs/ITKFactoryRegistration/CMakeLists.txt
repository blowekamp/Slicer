project(ITKFactoryRegistration)

find_package(ITK REQUIRED)

# This should be the one slicer libray which registers the default ITK libraieso
set ( ITK_NO_IO_FACTORY_REGISTER_MANAGER 0 )
include(${ITK_USE_FILE})

set( ITKFactoryRegistration_SRCS itkFactoryRegistration.cxx )
add_library( ITKFactoryRegistration ${ITKFactoryRegistration_SRCS} )
target_link_libraries( ITKFactoryRegistration ${ITK_LIBRARIES} )