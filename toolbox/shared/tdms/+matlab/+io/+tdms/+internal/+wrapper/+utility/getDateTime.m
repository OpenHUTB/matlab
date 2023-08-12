function dateTime = getDateTime( absTime )



R36
absTime( 1, 1 )struct
end 
import matlab.io.tdms.internal.wrapper.utility.AbsoluteTimeInterpreter
dateTime = AbsoluteTimeInterpreter.absTimeToDateTime( absTime.msb', absTime.lsb' );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7tGPq5.p.
% Please follow local copyright laws when handling this file.

