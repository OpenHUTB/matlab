function setToolForBoard( obj, boardName )




currentToolName = obj.get( 'Tool' );
isIn = isToolInBoardRequiredToolList( obj, currentToolName, boardName );
if ~isIn


availableToolList = getAvailableToolForBoard( obj, boardName );

toolName = availableToolList{ 1 };

oldCmdDisplay = obj.cmdDisplay;
obj.cmdDisplay = false;
obj.set( 'Tool', toolName );
obj.cmdDisplay = oldCmdDisplay;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTSHNii.p.
% Please follow local copyright laws when handling this file.

