function showUnsavedFilesWarningDialog(latch)




    project=currentProject();
    viewer=matlab.internal.project.unsavedchanges.ui.createUnsavedFilesWarningDialog(project);
    showDialog(viewer,latch);
end
