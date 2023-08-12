function hex = rgb2hex( rgb )




R36
rgb{ comparisons.internal.colorutil.mustBeValidRGB }
end 

hex = arrayfun( @( x )dec2hex( x, 2 ), rgb, 'UniformOutput', false );
hex = [ '#', lower( [ hex{ : } ] ) ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFfkjQR.p.
% Please follow local copyright laws when handling this file.

