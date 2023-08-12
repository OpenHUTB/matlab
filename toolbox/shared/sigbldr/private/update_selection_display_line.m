function UD = update_selection_display_line( UD, x, y )



if ~isempty( UD.current.selectLine ) &&  ...
ishghandle( UD.current.selectLine, 'line' )



set( UD.current.selectLine, 'XData', x, 'YData', y );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpoMRyo3.p.
% Please follow local copyright laws when handling this file.

