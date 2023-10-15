function deselectAllTableRows( uiTable )

arguments
    uiTable( 1, 1 )matlab.ui.control.Table
end

nRows = length( uiTable.Data.selected );
uiTable.Data.selected = false( nRows, 1 );
end

