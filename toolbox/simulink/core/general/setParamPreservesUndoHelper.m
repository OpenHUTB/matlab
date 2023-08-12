function returnValue = setParamPreservesUndoHelper( requestedAction )

persistent blackListParamsCell;

if isempty( blackListParamsCell ) && ~iscell( blackListParamsCell )
blackListParamsCell = {  };
end 

if strcmp( requestedAction, 'GetList' )
returnValue = blackListParamsCell;
else 
returnValue = [  ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQi06l_.p.
% Please follow local copyright laws when handling this file.

