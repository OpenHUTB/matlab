function bookmark = getBookmarkForTest( fileName, testName, createBookmark )

arguments
    fileName char{ mustBeNonempty };
    testName char = '';
    createBookmark double = true;
end

bookmark = [  ];
testName = stripTestParameters( testName );

[ testPositions, classdefPositions ] = rmiml.RmiMUnitData.getLocationDataForTest( fileName, testName );

if testPositions ~=  - 1
    bookmark = slreq.getRangeId( fileName, testPositions, createBookmark );
    return ;
elseif isempty( testName ) || strcmp( testName, rmiml.RmiMUnitData.getTestClassName( fileName ) )



    bookmark = slreq.getRangeId( fileName, classdefPositions, createBookmark );

end
end

function out = stripTestParameters( in )

out = regexprep( in, '\(.*\)', '' );
end



