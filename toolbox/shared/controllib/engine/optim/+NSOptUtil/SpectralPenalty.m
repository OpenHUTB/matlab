function y = SpectralPenalty( x )






low = 0.25;
high = 4;
y = 1 ./ x;
y( x < low ) = 2 * high - high ^ 2 * x( x < low );
y( x > high ) = 2 * low - low ^ 2 * x( x > high );
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7m69Gb.p.
% Please follow local copyright laws when handling this file.

