function bookmark = getBookmarkForTest( fileName, testName, createBookmark )











R36
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



% Decoded using De-pcode utility v1.2 from file /tmp/tmpvsRWzP.p.
% Please follow local copyright laws when handling this file.

