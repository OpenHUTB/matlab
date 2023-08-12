function out = convertToStruct( schedule )















R36
schedule( 1, 1 )simulink.schedule.OrderedSchedule
end 

out = struct(  ...
'Description', { schedule.Description },  ...
'PartitionProperties', { schedule.PartitionProperties },  ...
'IsExportFunction', { schedule.IsExportFunction },  ...
'Version', { schedule.Version },  ...
'Events', { schedule.Events } );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUKpxkg.p.
% Please follow local copyright laws when handling this file.

