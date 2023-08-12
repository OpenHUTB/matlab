function names = validateNamesAgainst( names, existingNames, IgnoreExtraPartitions )





R36
names( :, 1 )string
existingNames( :, 1 )string
IgnoreExtraPartitions( 1, : )logical = false
end 


duplicates = simulink.schedule.internal.checkForDuplicateNames( names );
if ~isempty( duplicates )
msg = 'SimulinkPartitioning:CLI:SchedulePartitionMismatchDuplicate';
error( message( msg,  ...
newline + strjoin( duplicates, newline ) ) );
end 


if IgnoreExtraPartitions
names = dropNamesWhichDoNotExist( names, existingNames );
else 
extraNames = setdiff( names, existingNames );
if ~isempty( extraNames )
msg = 'SimulinkPartitioning:CLI:SchedulePartitionMismatchExtra';
error( message( msg,  ...
newline + strjoin( extraNames, newline ) ) );
end 
end 


missingNames = setdiff( existingNames, names );
if ~isempty( missingNames )
msg = 'SimulinkPartitioning:CLI:SchedulePartitionMismatchMissing';
error( message( msg,  ...
newline + strjoin( missingNames, newline ) ) );
end 
end 

function out = dropNamesWhichDoNotExist( names, existingNames )


[ ~, extraIdx ] = setdiff( names, existingNames );
mask = true( size( names ) );
mask( extraIdx ) = false;
out = names( mask );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpdC6aV2.p.
% Please follow local copyright laws when handling this file.

