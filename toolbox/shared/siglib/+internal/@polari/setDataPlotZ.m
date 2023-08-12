function setDataPlotZ( p, z )


h = getDataWidgetHandles( p );
N = getNumDatasets( p );
for i = 1:N
setappdata( h( i ), 'polariZPlane', z( i ) );
h( i ).ZData( : ) = z( i );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnrCGSH.p.
% Please follow local copyright laws when handling this file.

