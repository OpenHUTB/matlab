function out = createPartitionPropertiesTable( numRows )

arguments
    numRows( 1, 1 )double
end

variableNames = {  ...
    'Index', 'Type', 'Trigger', 'Rate', 'HitTimes', 'Event', 'Priority', 'InternalType' };
variableTypes = {  ...
    'double', 'simulink.schedule.PartitionType', 'string', 'string', 'string', 'string', 'int32', 'string' };
out = table(  ...
    'Size', [ numRows, length( variableNames ) ],  ...
    'VariableNames', variableNames,  ...
    'VariableTypes', variableTypes );
out.Properties.DimensionNames{ 1 } = 'Partition';

end

