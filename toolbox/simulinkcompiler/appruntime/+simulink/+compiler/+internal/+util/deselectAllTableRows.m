function deselectAllTableRows( uiTable )




R36
uiTable( 1, 1 )matlab.ui.control.Table
end 

nRows = length( uiTable.Data.selected );
uiTable.Data.selected = false( nRows, 1 );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpehV9oV.p.
% Please follow local copyright laws when handling this file.

