function modDefJson = getAppFrameworkModuleInfo( opts )




R36
opts.Assert( 1, 1 )logical = false
end 

file = fullfile( matlabroot(  ), 'toolbox/coder/coderapp/core/web/coderFrameworkProvider/coderModuleDef.json' );

if isfile( file )
modDef = coderapp.internal.util.parseCoderModuleDef( file );
modDefJson = jsonencode( modDef );
else 
modDefJson = '';
end 

if opts.Assert && isempty( modDefJson )
error( 'App Framework unavailable' );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqi5RxO.p.
% Please follow local copyright laws when handling this file.

