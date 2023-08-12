



function startingLocation = startingLocationForModelBrowseButton( currentModel )
[ ~, fullModelName ] = slInternal( 'getReferencedModelFileInformation', currentModel );

startingLocation = which( fullModelName );

if isempty( startingLocation )
startingLocation = pwd;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpN95PyQ.p.
% Please follow local copyright laws when handling this file.

