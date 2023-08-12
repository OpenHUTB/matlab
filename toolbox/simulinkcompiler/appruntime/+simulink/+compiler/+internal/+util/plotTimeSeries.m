function lineHndls = plotTimeSeries( timeSeries, uiAxes )




R36
timeSeries timeseries
uiAxes( 1, 1 )matlab.ui.control.UIAxes
end 

if isempty( timeSeries.Time ) || isempty( timeSeries.Data )
return 
end 

lineHndls = plot( timeSeries, 'Parent', uiAxes );

if length( timeSeries.Time ) < 5
set( lineHndls, 'Marker', 'o', 'LineStyle', ':' );
end 
nLines = length( lineHndls );

tsDispName = timeSeries.Name;
tsDispNames = repmat( { tsDispName }, nLines, 1 );

if nLines > 1
for idx = 1:nLines
tsDispNames{ idx } = sprintf( "%s(%d)", tsDispNames{ idx }, idx );
end 
end 
set( lineHndls, { 'DisplayName' }, tsDispNames );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppw9VNq.p.
% Please follow local copyright laws when handling this file.

