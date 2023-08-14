function showShadowedFilesWarningDialog(latch)




    project=currentProject();
    viewer=matlab.internal.project.unsavedchanges.ui.createForShadowedProjectFiles(project);
    showDialog(viewer,latch);
end

