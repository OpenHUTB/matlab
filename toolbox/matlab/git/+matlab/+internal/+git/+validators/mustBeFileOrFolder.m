function mustBeFileOrFolder( Path )




if ~isNontrivialText( Path )
throwAsCaller( MException( "MATLAB:validators:mustBeNonzeroLengthText",  ...
message( "MATLAB:validators:nonzeroLengthText" ) ) );
end 

tf = isfolder( Path ) | isfile( Path );

if ~all( tf, 'all' )
files = string( Path );
throwAsCaller( createExceptionForMissingItems( files( ~tf ),  ...
'shared_cmlink:git:mustBeFileOrFolder' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpF7VxJr.p.
% Please follow local copyright laws when handling this file.

