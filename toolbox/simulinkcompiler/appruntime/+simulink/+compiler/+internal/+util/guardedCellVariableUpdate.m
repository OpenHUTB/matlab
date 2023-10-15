function [ variable, error ] = guardedCellVariableUpdate( updateEvent )

arguments
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

