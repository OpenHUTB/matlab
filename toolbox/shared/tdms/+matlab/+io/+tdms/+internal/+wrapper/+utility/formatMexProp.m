function T = formatMexProp( T )



R36
T table
end 
import matlab.io.tdms.internal.wrapper.utility.*
fnGetDateTime = @( x )( getDateTime( x ) );
T = convertvars( T, @iscellstr, "string" );
T = convertvars( T, @isstruct, fnGetDateTime );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJ7NPFv.p.
% Please follow local copyright laws when handling this file.

