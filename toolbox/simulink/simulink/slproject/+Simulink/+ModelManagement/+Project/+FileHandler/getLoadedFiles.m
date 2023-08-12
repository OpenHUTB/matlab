function paths = getLoadedFiles( properties )




R36
properties( 1, : )string = string.empty;
end 

files = matlab.internal.project.unsavedchanges.getLoadedFiles( properties );
if isempty( files )
paths = {  };
else 
paths = cellstr( [ files.Path ] );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpVIDqgc.p.
% Please follow local copyright laws when handling this file.

