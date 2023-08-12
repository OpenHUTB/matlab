function [ testProcedureNames, isClassDefNode ] = getTestNamesFromEditorSelection( fileName )













R36
fileName string{ mustBeNonempty };
end 

editorObj = matlab.desktop.editor.findOpenDocument( fileName );
extendedSelection = editorObj.ExtendedSelection;

cursorRowStart = extendedSelection( :, 1 );
cursorColumnStart = extendedSelection( :, 2 );
cursorRowEnd = extendedSelection( :, 3 );
cursorColumnEnd = extendedSelection( :, 4 );

parseTree = rmiml.RmiMUnitData.getParsedMTree( fileName );
absPositions = rmiml.RmiMUnitData.convertToAbsolutePositions( parseTree, [ cursorRowStart, cursorColumnStart, cursorRowEnd, cursorColumnEnd ] );
[ testProcedureNames, isClassDefNode ] = rmiml.RmiMUnitData.getTestNamesUnderRange( fileName, absPositions );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpt_lqPn.p.
% Please follow local copyright laws when handling this file.

