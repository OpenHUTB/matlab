function ClearTimer( h )





R36
h Aero.FlightGearAnimation
end 

arrayfun( @localClear, h );
end 

function localClear( h )
if ( ~isempty( h.FGTimer ) && isvalid( h.FGTimer ) && strcmpi( h.FGTimer.Running, 'On' ) )
try 
stop( h.FGTimer )
catch invalidFGTimer %#ok<NASGU>




end 
end 
if ( ~isempty( h.FGTimer ) && isvalid( h.FGTimer ) )
try 
delete( h.FGTimer )
catch invalidFGTimer %#ok<NASGU>




end 
end 
h.FGTimer = [  ];

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpXNwJtQ.p.
% Please follow local copyright laws when handling this file.

