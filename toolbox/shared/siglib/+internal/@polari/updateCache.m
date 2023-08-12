function update = updateCache( p )






update = p.pPublicPropertiesDirty;
if update || ~strcmpi( p.NextPlot, 'replacechildren' )
updateDataLabels( p, 'update' );
updateAxesMagLimits( p );
cacheCoords_AngleTickLabels( p );
cacheCoords_MagTickLabels( p );

p.pPublicPropertiesDirty = false;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpoYbIIH.p.
% Please follow local copyright laws when handling this file.

