function play( h, timername )





R36
h Aero.FlightGearAnimation
timername string{ Aero.internal.validation.mustBeScalarOrSameSize( h, timername, "h", "timername" ) } = 'FGAnimTimer'
end 

arrayfun( @verifyTimeSeriesData, h );


consistencyCheck( h );


oldTimer = timerfind;

tags = { h.DestinationIpAddress } + " " + { h.DestinationPort };

if ~isempty( oldTimer )
try 
idxTags = ismember( { oldTimer.Tag }, tags );
while any( isvalid( oldTimer( idxTags ) ) )

end 
catch invalidFGAnimTimer %#ok<NASGU>




end 
end 

arrayfun( @setAndValidateTimeBounds, h )


h.SetTimer( timername );


start( [ h.FGTimer ] );
end 

function locStartStopTimeValidate( h )





validateStartTimeLessThanFinalTime( h )


[ minStart, maxFinal ] = h.TimeSeriesReadFcn( h );

validateTimeBounds( h, minStart, maxFinal )

end 

function setAndValidateTimeBounds( h )
if ~isfinite( h.TStart ) || ~isfinite( h.TFinal )
[ h.TStart, h.TFinal ] = h.TimeSeriesReadFcn( h );
else 
locStartStopTimeValidate( h );
end 
end 

function verifyTimeSeriesData( h )


if h.TimeSeriesSourceType == "Timeseries"
if h.TimeSeriesSource.Length == 0
error( message( 'aero:FlightGearAnimation:NeedTimeData' ) );
end 
else 
if isempty( h.TimeSeriesSource )
error( message( 'aero:FlightGearAnimation:NeedTimeData' ) );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp1W8XXS.p.
% Please follow local copyright laws when handling this file.

