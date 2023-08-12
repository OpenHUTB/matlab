function loadedFiles = getLoadedFiles( properties, provider )



R36
properties( 1, : )matlab.internal.project.unsavedchanges.Property = matlab.internal.project.unsavedchanges.Property.empty( 1, 0 )
provider matlab.internal.project.unsavedchanges.LoadedFileProvider = matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider(  )
end 

loadedFiles = provider.getLoadedFiles(  );
if ~isempty( properties )
matches = arrayfun( @( file )any( ismember( properties, file.Properties ) ), loadedFiles );
loadedFiles = loadedFiles( matches );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNC2Y6R.p.
% Please follow local copyright laws when handling this file.

