function absTime = getAbsoluteTime( time )



R36
time{ mustBeA( time, [ "datetime", "duration" ] ) }
end 
import matlab.io.tdms.internal.wrapper.utility.AbsoluteTimeInterpreter
if isduration( time )
time = time + AbsoluteTimeInterpreter.absTimeToDateTime( 0, 0 );
end 
[ absTime.msb, absTime.lsb ] = AbsoluteTimeInterpreter.dateTimeToAbsTime( time );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp60usti.p.
% Please follow local copyright laws when handling this file.

