function ClearTimer( h )

arguments
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


