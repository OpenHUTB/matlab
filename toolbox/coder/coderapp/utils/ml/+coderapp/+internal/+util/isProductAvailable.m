function avail = isProductAvailable( licName, testPath )
R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpg7y7se.p.
% Please follow local copyright laws when handling this file.

