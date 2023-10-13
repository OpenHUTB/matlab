function update( h, t )

arguments
    h Aero.FlightGearAnimation
    t( 1, 1 )double
end

mustHaveNonEmptyTimeSeriesData( h )

consistencyCheck( h );

h.initialize();

arrayfun( @( hh )localUpdate( hh, t ), h )

end


function localUpdate( h, t )
[ trans, rot ] = h.TimeSeriesReadFcn( t, h );

posData = [ trans( 2 ), trans( 1 ), trans( 3 ), rot( 1 ), rot( 2 ), rot( 3 ) ];

packetVersion = uint8( 0 );
packetData = packNetFDM( posData, packetVersion );

try

    write( h.FGSocket, packetData );
catch packetError %#ok<NASGU>
    warning( message( 'aero:FlightGearAnimation:packetError',  ...
        h.DestinationIpAddress, h.DestinationPort ) );
end
end


function mustHaveNonEmptyTimeSeriesData( h )
idxTimeseries = { h.TimeSeriesSourceType } == "Timeseries";
hTimeseries = [ h( idxTimeseries ).TimeSeriesSource ];
hNotTimeseries = { h( ~idxTimeseries ).TimeSeriesSource };

if ~isempty( hTimeseries ) && any( [ hTimeseries.Length ] == 0 )
    error( message( 'aero:FlightGearAnimation:NeedTimeData' ) );
elseif any( cellfun( @isempty, hNotTimeseries ) )
    error( message( 'aero:FlightGearAnimation:NeedTimeData' ) );
end
end



