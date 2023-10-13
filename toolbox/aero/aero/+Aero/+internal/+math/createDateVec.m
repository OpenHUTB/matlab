function dateVecOut = createDateVec( dateTimeIn )

arguments
    dateTimeIn( :, 1 )datetime
end

[ yearOut, monthOut, dayOut ] = ymd( dateTimeIn );
[ hoursOut, minutesOut, secondsOut ] = hms( dateTimeIn );

dateVecOut = [ yearOut, monthOut, dayOut, hoursOut, minutesOut, secondsOut ];
end



