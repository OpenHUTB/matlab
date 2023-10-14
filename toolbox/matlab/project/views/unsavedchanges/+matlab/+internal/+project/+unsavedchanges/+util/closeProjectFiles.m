function closeProjectFiles( project )

arguments
    project( 1, 1 ) = currentProject(  )
end

providers = matlab.internal.project.unsavedchanges.getDefaultFileProviders(  );
isAutoClose = false( size( providers ) );
for n = 1:numel( providers )
    isAutoClose( n ) = providers( n ).isAutoCloseEnabled(  );
end

tracking = matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider( providers( isAutoClose ) );
loadedFiles = tracking.getLoadedFiles(  );

isSaved = false( size( loadedFiles ) );
for n = 1:numel( loadedFiles )
    isSaved( n ) = isSavedProjectFile( project, loadedFiles( n ) );
end

if ~any( isSaved )
    return ;
end
savedProjectFiles = [ loadedFiles( isSaved ).Path ];


slmxFiles = endsWith( savedProjectFiles, ".slmx" );
savedProjectFiles( slmxFiles ) = [  ];

tracking.discard( savedProjectFiles );
end

function include = isSavedProjectFile( project, file )
include =  ...
    ~file.hasProperty( matlab.internal.project.unsavedchanges.Property.Unsaved ) ...
    && ~isempty( project.findFile( file.Path ) );
end

