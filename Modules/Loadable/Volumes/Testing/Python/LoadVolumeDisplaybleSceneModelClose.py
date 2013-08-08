import unittest
from  __main__ import vtk, qt, ctk, slicer


HAVE_SIMPLEITK=True
try:
  import SimpleITK as sitk
  import sitkUtils
except ImportError:
  HAVE_SIMPLEITK=False


class VolumesLoadSceneCloseTesting(unittest.TestCase):
  def setUp(self):

    # start with clean scene
    slicer.mrmlScene.Clear(0)

  def test_LoadVolumeCloseScene(self):
    """
    Load a volume, go to a module that has a displayable scene model set for the tree view, then close the scene.
    Tests the case of closing a scene with a displayable node in it while a GUI is up that is showing a tree view with a displayable scene model (display nodes are set to null during scene closing and can trigger events).
    """

    #
    # first, get some sample data
    #
    import SampleData
    sampleDataLogic = SampleData.SampleDataLogic()
    head = sampleDataLogic.downloadMRHead()

    #
    # enter the models module
    #
    mainWindow = slicer.util.mainWindow()
    mainWindow.moduleSelector().selectModule('Models')

    #
    # close the scene
    #
    slicer.mrmlScene.Clear(0)

  if HAVE_SIMPLEITK:
    def test_VolumeOriginPrecision(self):
      """
      Verify that viewing a volume with large image origin does not change the values.
      """

      origin = [547339, 218860, 20904.4]
      print "Initial Origin:", origin

      # create a small image with a large origin which was reported to be a problem
      img = sitk.Image([10,10,10], sitk.sitkInt16)
      img.SetOrigin(origin)
      sitkUtils.PushToSlicer(img, "test_VolumeOriginPrecision")


      #
      # enter the Volumes module
      #
      mainWindow = slicer.util.mainWindow()
      mainWindow.moduleSelector().selectModule('Volumes')

      viewed_img = sitkUtils.PullFromSlicer("test_VolumeOriginPrecision")
      print "Viewed Origin:", viewed_img.GetOrigin()
      self.assertEqual(viewed_img.GetOrigin(), origin, "Origin changed after viewing")
