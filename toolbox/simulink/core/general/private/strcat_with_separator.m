function oStr = strcat_with_seperator( iCell, iSep )










iCell = iCell( : );iCell = iCell';

n = length( iCell );
if n == 1, 
oStr = iCell{ 1 };
return ;
end 

tmpCell = [ iCell( 1:n - 1 );repmat( { iSep }, 1, n - 1 ) ];
oStr = [ [ tmpCell{ : } ], iCell{ n } ];



% Decoded using De-pcode utility v1.2 from file /tmp/tmpd8HS2V.p.
% Please follow local copyright laws when handling this file.

