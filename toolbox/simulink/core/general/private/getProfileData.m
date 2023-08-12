function getProfileData( fileName, modelName )



varName = [ modelName, 'ProfileData' ];
d = load( fileName, 'iProfileHandle' );
assignin( 'base', varName, d.iProfileHandle );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5iCLE9.p.
% Please follow local copyright laws when handling this file.

