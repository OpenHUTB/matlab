function showUnsavedFilesInfoDialog(latch)




    project=currentProject();
    viewer=matlab.internal.project.unsavedchanges.ui.createForUnsavedProjectFiles(project);
    showDialog(viewer,latch);
end

