function viewer = createForUnsavedProjectFiles( project )

arguments
    project( 1, 1 ) = currentProject(  );
end

provider = matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider(  );
filter = @( files )matlab.internal.project.unsavedchanges.filter.unsavedProjectFiles( files, project );

viewer = matlab.internal.project.unsavedchanges.ui.LoadedFileViewer( provider, filter );

addlistener( viewer, "Close", @( ~, ~ )delete( viewer ) );
end

