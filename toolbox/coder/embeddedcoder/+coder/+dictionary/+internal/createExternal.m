function createExternal( file, options )




R36
file
options.Force( 1, 1 )matlab.lang.OnOffSwitchState = "off"
options.PlatformName( 1, 1 )string
end 


[ pathname, name, ext ] = fileparts( file );
if options.Force == "on"
Simulink.data.dictionary.closeAll( [ name, ext ], '-discard' );
if isfile( file )
delete( file );
end 
end 


dictionaryObj = Simulink.data.dictionary.create( file );
cleanup1 = onCleanup( @dictionaryObj.close );
if ~isempty( pathname )

old = cd( pathname );
cleanup2 = onCleanup( @(  )cd( old ) );
end 

if isfield( options, 'PlatformName' )

opt = { 'PlatformName', options.PlatformName };
coder.internal.CoderDataStaticAPI.initializeSDP( [ name, ext ], opt{ : } );
elseif ~coder.dictionary.exist( [ name, ext ] )

coder.dictionary.create( [ name, ext ] );
end 
dictionaryObj.saveChanges;

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7XgtGT.p.
% Please follow local copyright laws when handling this file.

