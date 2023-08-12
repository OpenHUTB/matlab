function updateAngleTickLabelFormat( p )


switch lower( p.AngleTickLabelFormat )
case 'compass'
p.AngleTickCompassPoints = true;
case '180'
p.AngleTickCompassPoints = false;

p.pAngleRange = [  - 180, 180 ];
p.AngleTickLabelMode = 'auto';
case '360'
p.AngleTickCompassPoints = false;

p.pAngleRange = [ 0, 360 ];
p.AngleTickLabelMode = 'auto';
otherwise 
p.AngleTickLabelMode = 'manual';
end 



cacheCoords_AngleTickLabels( p );
labelAngles( p );
adjustAngleLabelsPos( p.hAngleText );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8iqA2L.p.
% Please follow local copyright laws when handling this file.

