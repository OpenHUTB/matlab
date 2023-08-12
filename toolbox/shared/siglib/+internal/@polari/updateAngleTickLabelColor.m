function updateAngleTickLabelColor( p )


switch p.AngleTickLabelColorMode
case { 'grid', 'auto' }
p.pAngleTickLabelColor =  ...
internal.ColorConversion.getRGBFromColor( p.GridForegroundColor );
case 'contrast'


bgcolor = getBackgroundColorOfAxes( p );
if ~isempty( bgcolor )
p.pAngleTickLabelColor =  ...
internal.ColorConversion.getBWContrast( bgcolor );
end 





end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmloEYh.p.
% Please follow local copyright laws when handling this file.

