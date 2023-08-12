function schedule = createFromStruct( s )







R36
s( 1, 1 )struct
end 

schedule = simulink.schedule.OrderedSchedule( 0 );

schedule.Description = s.Description;
schedule.IsExportFunction = s.IsExportFunction;








types = simulink.schedule.internal.getPartitionTypeFromInternalType(  ...
s.PartitionProperties.InternalType );
invalidTypes = types == simulink.schedule.PartitionType.Unknown;
if any( invalidTypes )
invalidNames = unique( string( s.PartitionProperties.Partition{ invalidTypes } ) );

warning( message( 'SimulinkPartitioning:CLI:DroppedInternalType',  ...
newline + strjoin( invalidNames, newline ) ) );

s.PartitionProperties = s.PartitionProperties( ~invalidTypes, : );
end 

schedule.PartitionProperties =  ...
simulink.schedule.internal.createPartitionPropertiesTable(  ...
height( s.PartitionProperties ) );


if height( s.PartitionProperties ) > 0


schedule.PartitionProperties.Event = repmat( "", height( schedule.PartitionProperties ), 1 );

variableNames = schedule.PartitionProperties.Properties.VariableNames;



existingVariables = intersect( variableNames, s.PartitionProperties.Properties.VariableNames );

schedule.PartitionProperties( :, existingVariables ) = s.PartitionProperties( :, existingVariables );
schedule.PartitionProperties.Partition = s.PartitionProperties.Partition;
end 

if isfield( s, 'Events' )
schedule.EventsInternal = s.Events;
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpEX3TOL.p.
% Please follow local copyright laws when handling this file.

