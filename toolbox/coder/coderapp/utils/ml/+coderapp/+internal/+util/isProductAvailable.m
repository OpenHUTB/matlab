function avail = isProductAvailable( licName, testPath )
arguments
    licName{ mustBeTextScalar( licName ) }
    testPath{ mustBeTextScalar( testPath ) } = ''
end

avail = builtin( 'license', 'test', licName );
if avail && ~isempty( testPath )
    testPath = fullfile( matlabroot(  ), testPath );
    if isfolder( testPath )
        avail = isfile( fullfile( testPath, 'Contents.m' ) );
    elseif isfile( testPath )
        avail = true;
    else
        avail = false;
    end
end
end

