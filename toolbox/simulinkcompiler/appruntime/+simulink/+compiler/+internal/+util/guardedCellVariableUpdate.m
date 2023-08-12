function [ variable, error ] = guardedCellVariableUpdate( updateEvent )




R36
updateEvent( 1, 1 )matlab.ui.eventdata.CellEditData
end 

rowIdx = updateEvent.Indices( 1 );

nameCell = updateEvent.Source.Data{ rowIdx, 1 };
variable.Name = nameCell{ 1 };

previousData = updateEvent.PreviousData;
newData = updateEvent.NewData;

try 
variable.Value = eval( newData );
error = [  ];
catch error
updateEvent.Source.Data{ rowIdx, 2 } = { previousData };
variable.Value = previousData;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDm7wrn.p.
% Please follow local copyright laws when handling this file.

