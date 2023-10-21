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
