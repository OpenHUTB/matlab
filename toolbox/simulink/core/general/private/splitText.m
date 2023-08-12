function retCellArray = splitText( strToSplit, splittingStr )







retCellArray = {  };
retStrToSplit = strtrim( strToSplit );

[ splitStartIdx, splitEndIdx ] = regexp( retStrToSplit, splittingStr );

if isempty( splitStartIdx )
retCellArray = { retStrToSplit };
return ;
end 

if splitStartIdx( 1 ) ~= 1
startIdx = [ 1, ( splitEndIdx + 1 ) ];
endIdx = [ ( splitStartIdx - 1 ), length( retStrToSplit ) ];
else 
startIdx = [ splitEndIdx + 1 ];
endIdx = [ ( splitStartIdx( 2:end  ) - 1 ), length( retStrToSplit ) ];
retCellArray{ 1 } = '';
end 

for idx = 1:length( startIdx )
retCellArray = { retCellArray{ : } ...
, retStrToSplit( startIdx( idx ):endIdx( idx ) ) };
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJlIIOP.p.
% Please follow local copyright laws when handling this file.

