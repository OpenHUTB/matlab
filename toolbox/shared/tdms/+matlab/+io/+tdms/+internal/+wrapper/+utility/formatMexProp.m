function T = formatMexProp( T )

arguments
    T table
end
import matlab.io.tdms.internal.wrapper.utility.*
fnGetDateTime = @( x )( getDateTime( x ) );
T = convertvars( T, @iscellstr, "string" );
T = convertvars( T, @isstruct, fnGetDateTime );
end

