function T = formatMexWriteProp( T )



R36
T table
end 
import matlab.io.tdms.internal.wrapper.utility.*
T = convertvars( T, @( x )isduration( x ) || isdatetime( x ), @getAbsoluteTime );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHXtSzS.p.
% Please follow local copyright laws when handling this file.

