function outStr = cs_reserved_array_to_names( inCell )





outStr = '';
position = 0;
if ~isempty( inCell ) && iscell( inCell )
for i = 1:length( inCell )
cellItem = inCell{ i };
if ischar( cellItem )
if i == 1
outStr = cellItem;
position = position + length( cellItem );
else 
if position > 50
outStr = [ outStr, ',', sprintf( '\n' ), cellItem ];
position = 0;
else 
outStr = [ outStr, ', ', cellItem ];
position = position + length( cellItem ) + 2;
end 
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmph9wKck.p.
% Please follow local copyright laws when handling this file.

