function oMdlsLoaded = load_model( iMdl )







oMdlsLoaded = {  };
openMdls = find_system( 'SearchDepth', 0, 'type', 'block_diagram' );

if ~any( strcmp( openMdls, iMdl ) )
load_system( iMdl );
openMdlsAfterLoad = find_system( 'SearchDepth', 0, 'type', 'block_diagram' );
oMdlsLoaded = setdiff( openMdlsAfterLoad, openMdls );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyMWJbC.p.
% Please follow local copyright laws when handling this file.

