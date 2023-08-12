function [ testProcedureNames, isFileLevel ] = getTestNamesUnderRangeRaw( ~, fileName, positions, parseTree )
























R36
~
fileName char{ mustBeNonempty }
positions( 1, 2 )double{ mustBeNonempty }
parseTree = [  ];
end 

testProcedureNames = cell( 1, 0 );
isFileLevel = false;

if isempty( parseTree )

[ parseTree, ~ ] = rmiml.RmiMUnitData.getParsedMTree( fileName );
end 
if isempty( parseTree )

return ;
end 

selectionStartPosition = positions( 1 );
selectionEndPosition = positions( 2 );

if selectionStartPosition ==  - 1 || selectionEndPosition ==  - 1
return ;
end 

testProcedureNames = getProcedureNamesBetweenPositions( parseTree, selectionStartPosition, selectionEndPosition );
isFileLevel = isSelectionInFileLevelNode( parseTree, selectionStartPosition, selectionEndPosition );
end 

function procedureNames = getProcedureNamesBetweenPositions( parseTree, selectionStartPosition, selectionEndPosition )
[ testNames, startPositions, endPositions ] = rmiml.RmiMUnitData.getTestNamesAndPositions( parseTree );
procedureNameAtStart = selectionStartPosition <= endPositions;
procedureNameAtEnd = selectionEndPosition >= startPositions;
procedureNames = testNames( any( ( procedureNameAtStart & procedureNameAtEnd ), 1 ) );
end 

function tf = isSelectionInFileLevelNode( parseTree, selectionStartPosition, selectionEndPosition )
[ ~, fileLevelStart, fileLevelEnd ] = rmiml.RmiMUnitData.getTestFileNameAndPosition( parseTree );

isSelectionBeforeStart = selectionStartPosition <= fileLevelEnd;
isSelectionAfterEnd = selectionEndPosition >= fileLevelStart;

tf = isSelectionBeforeStart & isSelectionAfterEnd;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpCa_nLd.p.
% Please follow local copyright laws when handling this file.

