function [ testPositions, fileLevelPositions ] = getLocationDataForTest( fileName, procedureName )


















R36
fileName string{ mustBeNonempty };
procedureName string{ mustBeNonempty } = '';
end 

[ testPositions( 1 ), testPositions( 2 ) ] = deal(  - 1 );
[ fileLevelPositions( 1 ), fileLevelPositions( 2 ) ] = deal(  - 1 );

parseTree = rmiml.RmiMUnitData.getParsedMTree( fileName );
if isempty( parseTree )
return ;
end 


if parseTree.root.FileType == mtree.Type.ClassDefinitionFile ||  ...
parseTree.root.FileType == mtree.Type.FunctionFile
if ~isempty( procedureName )
[ testNames, allStartPos, allEndPos ] = rmiml.RmiMUnitData.getTestNamesAndPositions( parseTree, rmiml.RmiMUnitData.FETCH_FUNCTION_NAME_POS_ONLY );
matchingFunction = ismember( string( testNames ), string( procedureName ) );
if any( matchingFunction )
testPositions( 1 ) = allStartPos( matchingFunction );
testPositions( 2 ) = allEndPos( matchingFunction );
end 
end 

[ ~, fileLevelPositions( 1 ), fileLevelPositions( 2 ) ] = rmiml.RmiMUnitData.getTestFileNameAndPosition( parseTree );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpOfukXk.p.
% Please follow local copyright laws when handling this file.

