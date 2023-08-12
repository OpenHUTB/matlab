function updateMagnitudeTickLabelColor( p )


switch p.MagnitudeTickLabelColorMode
case { 'grid', 'auto' }
p.pMagnitudeTickLabelColor =  ...
internal.ColorConversion.getRGBFromColor( p.GridForegroundColor );
case 'contrast'
p.pMagnitudeTickLabelColor =  ...
internal.ColorConversion.getBWContrast( p.GridBackgroundColor );




end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9rvSHq.p.
% Please follow local copyright laws when handling this file.

