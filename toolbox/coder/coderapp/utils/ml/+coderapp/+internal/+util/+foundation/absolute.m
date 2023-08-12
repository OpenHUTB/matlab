function result = absolute( aFile )











R36
aFile( 1, 1 )string
end 

if isAbsolute( aFile )
result = aFile;
else 
result = fullfile( pwd, aFile );
end 

if exist( result, 'file' )
try 
result = builtin( "_canonicalizepath", result );
catch 
end 
end 
end 

function result = isAbsolute( aFile )
R36
aFile( 1, 1 )string
end 

result = aFile == matlab.io.internal.filesystem.absolutePath( aFile );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsKEL2_.p.
% Please follow local copyright laws when handling this file.

