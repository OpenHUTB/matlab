function isMultiTasking = isSortedBlockMultiTasking( block )





sortedInfo = get_param( block, 'SortedOrder' );
nTasks = numel( sortedInfo );

isMultiTasking = false;

if nTasks > 1


nRunTimeTasks = 0;
for tIdx = nTasks: - 1:1
if sortedInfo( tIdx ).TaskIndex ~=  - 3
nRunTimeTasks = nRunTimeTasks + 1;
end 
if nRunTimeTasks > 1
isMultiTasking = true;
break ;
end 
end 
end 


end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp9NFEoZ.p.
% Please follow local copyright laws when handling this file.

