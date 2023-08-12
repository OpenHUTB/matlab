function SetTimer( h, timername )





R36
h Aero.FlightGearAnimation
timername string{ Aero.internal.validation.mustBeScalarOrSameSize( h, timername, "h", "timername" ) } = 'FGAnimTimer'
end 

if ~isempty( [ h.FGTimer ] ) && any( isvalid( [ h.FGTimer ] ) )
error( message( 'aero:FlightGearAnimation:TimerAlreadySet' ) );
end 




if isscalar( timername )
timername = repmat( timername, size( h ) );
end 

arrayfun( @( hh, t )localSet( hh, t ), h, timername );
end 

function localSet( h, timername )
h.FGTimer = timer(  ...
Name = timername,  ...
Tag = join( [ string( h.DestinationIpAddress ), string( h.DestinationPort ) ] ) ...
 );



timePace = ceil( 1000 / h.FramesPerSecond ) / 1000;

timeAdvance = h.TimeScaling * timePace;


if ( abs( ( h.TimeScaling / h.FramesPerSecond ) - timeAdvance ) / timeAdvance > 0.15 )
warning( message( 'aero:FlightGearAnimation:timeAdvance', sprintf( '%5.3f', timePace ),  ...
sprintf( '%d', 1 / timePace ) ) );
end 





h.FGTimer.BusyMode = 'drop';



h.FGTimer.ExecutionMode = 'fixedRate';
h.FGTimer.Period = timePace;
h.FGTimer.StartFcn = { @h.timerCallbackFcn, 0 };
h.FGTimer.TimerFcn = { @h.timerCallbackFcn, timeAdvance };
h.FGTimer.StopFcn = { @h.timerCallbackFcn, 0 };





tmp = floor( ( h.TFinal - h.TStart ) / ( h.TimeScaling * timePace ) );
if isfinite( tmp )
h.FGTimer.TasksToExecute = tmp;
else 
h.FGTimer.TasksToExecute = 1;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpYYPiFQ.p.
% Please follow local copyright laws when handling this file.

