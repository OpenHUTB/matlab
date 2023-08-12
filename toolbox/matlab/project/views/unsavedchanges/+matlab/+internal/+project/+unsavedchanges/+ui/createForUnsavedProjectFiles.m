function viewer = createForUnsavedProjectFiles( project )




R36
project( 1, 1 ) = currentProject(  );
end 

provider = matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider(  );
filter = @( files )matlab.internal.project.unsavedchanges.filter.unsavedProjectFiles( files, project );

viewer = matlab.internal.project.unsavedchanges.ui.LoadedFileViewer( provider, filter );

addlistener( viewer, "Close", @( ~, ~ )delete( viewer ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplb_CMR.p.
% Please follow local copyright laws when handling this file.

