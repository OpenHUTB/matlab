function y = gradSpectralPenalty( x )



low = 0.25;
high = 4;
y =  - 1 ./ x .^ 2;
y( x < low ) =  - high ^ 2;
y( x > high ) =  - low ^ 2;
% Decoded using De-pcode utility v1.2 from file /tmp/tmpXxNDKa.p.
% Please follow local copyright laws when handling this file.

