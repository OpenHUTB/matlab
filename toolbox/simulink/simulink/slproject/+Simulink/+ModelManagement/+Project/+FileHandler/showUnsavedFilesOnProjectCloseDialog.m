function showUnsavedFilesOnProjectCloseDialog(latch)




    project=currentProject();

    provider=matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider();
    filter=@(files)matlab.internal.project.unsavedchanges.filter.unsavedProjectFiles(files,project);

    viewer=matlab.internal.project.unsavedchanges.ui.LoadedFileViewer(...
    provider,filter,...
    "DirtySaveButtonText","MATLAB:project:view_unsaved_changes:SaveAndClose",...
    "DirtyDiscardButtonText","MATLAB:project:view_unsaved_changes:CloseProject",...
    "CancelButtonText","MATLAB:project:view_unsaved_changes:Cancel",...
    "InfoText","MATLAB:project:view_unsaved_changes:ProjectCloseQuery",...
    "AutoCloseUI",true,...
    "WindowStyle","modal");

    addlistener(viewer,"Close",@(~,~)delete(viewer));

    showDialog(viewer,latch);
end

