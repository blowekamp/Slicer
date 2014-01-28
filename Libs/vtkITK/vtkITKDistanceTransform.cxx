/*=========================================================================

  Copyright Brigham and Women's Hospital (BWH) All Rights Reserved.

  See COPYRIGHT.txt
  or http://www.slicer.org/copyright/copyright.txt for details.

  Program:   vtkITK
  Module:    $HeadURL: http://svn.slicer.org/Slicer4/trunk/Libs/vtkITK/vtkITKDistanceTransform.cxx $
  Date:      $Date: 2006-12-21 07:21:52 -0500 (Thu, 21 Dec 2006) $
  Version:   $Revision: 1900 $

==========================================================================*/

#include "vtkITKDistanceTransform.h"
#include "vtkObjectFactory.h"

#include "vtkDataArray.h"
#include "vtkPointData.h"
#include "vtkImageData.h"

#include "sitkSignedMaurerDistanceMapImageFilter.h"
#include "sitkImportImageFilter.h"

//#include "FundamentalType.h"

#include <algorithm>
namespace sitk = itk::simple;

#define sitkSetBufferAsMacro(vtkType,sitkType,cintType) \
  case vtkType: { importer.SetBufferAs##sitkType(static_cast<cintType*>(input->GetScalarPointer()), inScalars->GetNumberOfComponents() ); }; break;
namespace util
{

sitk::Image GetSITKImageFromVTKImage( vtkImageData *input )
{
  int size[3];
  input->GetDimensions(&size[0]);

  std::vector<double> spacing(3);
  input->GetSpacing(&spacing[0]);

  sitk::ImportImageFilter importer;

  // direction?
  importer.SetSize( std::vector<unsigned int>(&size[0], &size[3]) );
  importer.SetSpacing( spacing );

  void* inPtr = input->GetScalarPointer();

  vtkPointData *pd = input->GetPointData();
  pd=input->GetPointData();
  if (pd ==NULL)
    {
    //vtkErrorMacro(<<"PointData is NULL");
    return sitk::Image();
    }
  vtkDataArray *inScalars=pd->GetScalars();
  if ( inScalars == NULL )
    {
    //vtkErrorMacro(<<"Scalars must be defined for distance tranform");
    return sitk::Image();
    }

  switch(inScalars->GetDataType())
    {
    sitkSetBufferAsMacro(VTK_DOUBLE, Double, double);
    sitkSetBufferAsMacro(VTK_FLOAT, Float, float);
    sitkSetBufferAsMacro(VTK_UNSIGNED_LONG_LONG, UInt64, uint64_t);
    sitkSetBufferAsMacro(VTK_LONG_LONG, Int64, int64_t);
#if __SIZE_OF_LONG__ == 8
    sitkSetBufferAsMacro(VTK_LONG, Int64, int64_t);
    sitkSetBufferAsMacro(VTK_UNSIGNED_LONG, UInt64, uint64_t);
#else
    sitkSetBufferAsMacro(VTK_LONG, Int32, int32_t);
    sitkSetBufferAsMacro(VTK_UNSIGNED_LONG, UInt32, uint32_t);
#endif
    sitkSetBufferAsMacro(VTK_INT, Int32, int);
    sitkSetBufferAsMacro(VTK_UNSIGNED_INT, UInt32, unsigned int);
    sitkSetBufferAsMacro(VTK_SHORT, Int16, short);
    sitkSetBufferAsMacro(VTK_UNSIGNED_SHORT, UInt16, unsigned short);
    sitkSetBufferAsMacro(VTK_CHAR, UInt8, uint8_t );
    sitkSetBufferAsMacro(VTK_UNSIGNED_CHAR, UInt8, unsigned char );
    sitkSetBufferAsMacro(VTK_SIGNED_CHAR, Int8, signed char );
    default:
      // error
      return sitk::Image();
    }

  return importer.Execute();
}

void SetVTKImageFromSITKImage( vtkImageData *out, sitk::Image &input )
{

  // Copy to the output
//  memcpy(outPtr, dist->GetOutput()->GetBufferPointer(),
//         dist->GetOutput()->GetBufferedRegion().GetNumberOfPixels() * sizeof(T));
}


}


vtkCxxRevisionMacro(vtkITKDistanceTransform, "$Revision: 1900 $");
vtkStandardNewMacro(vtkITKDistanceTransform);

vtkITKDistanceTransform::vtkITKDistanceTransform()
{
  this->SquaredDistance = 1;
  this->InsideIsPositive = 0;
  this->UseImageSpacing = 0;
  this->BackgroundValue = 0;
}

vtkITKDistanceTransform::~vtkITKDistanceTransform()
{
}

//
//
//
void vtkITKDistanceTransform::SimpleExecute(vtkImageData *input, vtkImageData *output)
{
  vtkDebugMacro(<< "Executing distance transform");

  sitk::Image in = util::GetSITKImageFromVTKImage(input);

  sitk::SignedMaurerDistanceMapImageFilter filter;

 // filter.SetBackgroundValue(BackgroundValue);
  filter.SetUseImageSpacing(UseImageSpacing);
  filter.SetSquaredDistance(SquaredDistance);

  sitk::Image out = filter.Execute(in);

  util::SetVTKImageFromSITKImage(output, out);

}

void vtkITKDistanceTransform::PrintSelf(ostream& os, vtkIndent indent)
{
  this->Superclass::PrintSelf(os,indent);

  os << indent << "BackgroundValue: " << BackgroundValue << std::endl;
  os << indent << "InsideIsPositive: " << InsideIsPositive << std::endl;
  os << indent << "UseImageSpacing: " << UseImageSpacing << std::endl;
  os << indent << "SquaredDistance: " << SquaredDistance << std::endl;
}


