function paddedVector = padVector( vector, newlength )



R36
vector( 1, : )
newlength( 1, 1 )uint64
end 
import matlab.io.tdms.internal.wrapper.utility.*

if newlength > length( vector )
paddedVector = createPadding( class( vector ), [ 1, newlength ] );
paddedVector( 1:length( vector ) ) = vector;
else 
paddedVector = vector;
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmprPUbYQ.p.
% Please follow local copyright laws when handling this file.

