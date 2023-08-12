function dateVecOut = createDateVec( dateTimeIn )



















R36
dateTimeIn( :, 1 )datetime
end 

[ yearOut, monthOut, dayOut ] = ymd( dateTimeIn );
[ hoursOut, minutesOut, secondsOut ] = hms( dateTimeIn );

dateVecOut = [ yearOut, monthOut, dayOut, hoursOut, minutesOut, secondsOut ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXLM4wq.p.
% Please follow local copyright laws when handling this file.

