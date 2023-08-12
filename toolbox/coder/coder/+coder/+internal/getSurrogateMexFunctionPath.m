function result = getSurrogateMexFunctionPath( aOptions )








R36
aOptions.Debug( 1, 1 )logical
end 
coderapp.internal.util.mustHaveNVPair( aOptions, 'Debug' );
result = getSurrogateMexFunctionPathImpl( aOptions.Debug );
end 

function result = getSurrogateMexFunctionPathImpl( aDebug )
mexFunctionDir = fullfile( matlabroot, 'toolbox', 'coder', 'coder', '+coder', '+internal' );
surrogateMexFunctionPath = constructMexFunctionPath( mexFunctionDir, 'surrogateMexFunction' );
surrogateMexFunctionDebugPath = constructMexFunctionPath( mexFunctionDir, 'surrogateMexFunctionDebug' );

if aDebug && isfile( surrogateMexFunctionDebugPath )
result = surrogateMexFunctionDebugPath;
else 
result = surrogateMexFunctionPath;
end 
end 

function mexFunctionPath = constructMexFunctionPath( mexFunctionDir, mexFunctionName )
mexFunctionPath = fullfile( mexFunctionDir, [ mexFunctionName, '.', mexext ] );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpkUwmr6.p.
% Please follow local copyright laws when handling this file.

