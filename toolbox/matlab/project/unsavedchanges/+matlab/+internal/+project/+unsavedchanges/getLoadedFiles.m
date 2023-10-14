function loadedFiles = getLoadedFiles( properties, provider )

arguments
    properties( 1, : )matlab.internal.project.unsavedchanges.Property = matlab.internal.project.unsavedchanges.Property.empty( 1, 0 )
    provider matlab.internal.project.unsavedchanges.LoadedFileProvider = matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider(  )
end

loadedFiles = provider.getLoadedFiles(  );
if ~isempty( properties )
    matches = arrayfun( @( file )any( ismember( properties, file.Properties ) ), loadedFiles );
    loadedFiles = loadedFiles( matches );
end
end
