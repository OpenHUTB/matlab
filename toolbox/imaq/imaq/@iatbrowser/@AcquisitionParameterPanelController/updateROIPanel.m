function updateROIPanel(this)%#ok<INUSD>








    b=iatbrowser.Browser();

    vidObj=iatbrowser.Browser().currentVideoinputObject;
    roi=vidObj.ROIPosition;
    resolution=vidObj.VideoResolution;
    b.roiGUIElementsController.setMaxROI(resolution(1),resolution(2));
    b.roiGUIElementsController.setSpinnerROI(roi);
