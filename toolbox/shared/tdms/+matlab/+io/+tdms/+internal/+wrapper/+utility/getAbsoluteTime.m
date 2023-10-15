function absTime = getAbsoluteTime( time )

arguments
    time{ mustBeA( time, [ "datetime", "duration" ] ) }
end
import matlab.io.tdms.internal.wrapper.utility.AbsoluteTimeInterpreter
if isduration( time )
    time = time + AbsoluteTimeInterpreter.absTimeToDateTime( 0, 0 );
end
[ absTime.msb, absTime.lsb ] = AbsoluteTimeInterpreter.dateTimeToAbsTime( time );
end
