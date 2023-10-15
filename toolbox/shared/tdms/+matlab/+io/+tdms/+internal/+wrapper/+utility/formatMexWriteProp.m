function T = formatMexWriteProp( T )

arguments
    T table
end
import matlab.io.tdms.internal.wrapper.utility.*
T = convertvars( T, @( x )isduration( x ) || isdatetime( x ), @getAbsoluteTime );
end

