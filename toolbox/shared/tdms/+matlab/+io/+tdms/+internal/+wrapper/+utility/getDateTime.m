function dateTime = getDateTime( absTime )

arguments
    absTime( 1, 1 )struct
end
import matlab.io.tdms.internal.wrapper.utility.AbsoluteTimeInterpreter
dateTime = AbsoluteTimeInterpreter.absTimeToDateTime( absTime.msb', absTime.lsb' );
end

