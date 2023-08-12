function S = interdigitalCapacitorS( obj, freq, Z0 )











R36
obj( 1, 1 )
freq( 1, : ){ mustBeFinite, mustBeNonnegative }
Z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end 
validateattributes( freq, { 'double' }, { 'increasing' }, 2 )

N = obj.NumFingers;
fWidth = obj.FingerWidth;
fLength = obj.FingerLength;
spacing = obj.FingerSpacing;
height = obj.Height;
terminalLength = N * fWidth + ( N - 1 ) * spacing;

segLine = microstripLine( 'Length', terminalLength / ( N - 1 ),  ...
'Width', obj.TerminalStripWidth,  ...
'Height', height, 'Substrate', obj.Substrate, 'Conductor', obj.Conductor );
fingerLine = microstripLine( 'Length', fLength, 'Width', fWidth,  ...
'Height', height, 'Substrate', obj.Substrate, 'Conductor', obj.Conductor );
portLine = microstripLine( 'Length', obj.PortLineLength,  ...
'Width', obj.PortLineWidth,  ...
'Height', height, 'Substrate', obj.Substrate, 'Conductor', obj.Conductor );
gapLine = microstripLine( 'Length', obj.FingerEdgeGap,  ...
'Width', obj.FingerWidth,  ...
'Height', height, 'Substrate', obj.Substrate, 'Conductor', obj.Conductor );

cmGap = couplingCapacitance( segLine, obj.FingerEdgeGap );
Cgap = fWidth * cmGap;

cmFinger = couplingCapacitance( fingerLine, spacing );
halfCf = fLength * cmFinger / 2;


mu0 = pi * 4e-7;
eps0 = 8.854e-12;
m = zeros( N, 1 );
for i = 1:N - 1

[ ~, ce, co ] = couplingCapacitance( fingerLine, spacing * i + fWidth * ( i - 1 ), 1 );
m( i + 1 ) = mu0 * eps0 / 2 * ( 1 / ce - 1 / co );
end 
m = m * fLength;
M = toeplitz( m );
s = reshape( 2i * pi * freq, 1, 1, [  ] );
Lm = zparameters( M .* s, freq );









ckt = circuit;
for i = 1:N
add( ckt, [ 2 * N + i, 3 * N + i, 0, 0 ], fingerLine )
if mod( i, 2 ) == 1
add( ckt, [ i, N + i, 0, 0 ], gapLine )
add( ckt, [ 3 * N + i, 4 * N + i ], capacitor( Cgap ) )
else 
add( ckt, [ i, N + i ], capacitor( Cgap ) )
add( ckt, [ 3 * N + i, 4 * N + i, 0, 0 ], gapLine )
end 
if i < N
add( ckt, [ i, i + 1, 0, 0 ], segLine );
add( ckt, [ N + i, N + i + 1 ], capacitor( halfCf ) )
add( ckt, [ 3 * N + i, 3 * N + i + 1 ], capacitor( halfCf ) )
add( ckt, [ 4 * N + i, 4 * N + i + 1, 0, 0 ], segLine );
end 
end 

add( ckt, N + ( 1:2 * N ), nport( Lm ) )

add( ckt, [ 5 * N + 1, ceil( N / 2 ), 0, 0 ], portLine )
if mod( N, 2 ) == 1
add( ckt, [ 4 * N + ceil( N / 2 ), 5 * N + 2, 0, 0 ], portLine )
else 
add( ckt, [ 4 * N + ceil( N / 2 ) + 1, 5 * N + 2, 0, 0 ], portLine )
end 

setports( ckt, [ 5 * N + 1, 0 ], [ 5 * N + 2, 0 ] )
S = sparameters( ckt, freq, Z0 );
end 

function [ cm, ce, co ] = couplingCapacitance( txline, spacing, epsR )
if nargin < 3
txtemp = txlineMicrostrip( txline );
epsR = txtemp.EpsilonR;
end 
width = txline.Width;
height = txline.Height;

eps0 = 8.854e-12;
c0 = physconst( 'LightSpeed' );

[ Z0, epsReff ] = getZ0( txlineMicrostrip( txline ) );





woh = width / height;
cp = eps0 * epsR * woh;

cf = ( sqrt( epsReff ) / ( c0 * Z0 ) - cp ) / 2;

A = exp(  - 0.1 * exp( 2.33 - 1.5 * woh ) );
cfp = cf * ( epsR / epsReff ) ^ ( 1 / 4 ) / ( 1 + A * ( height / spacing ) * tanh( 10 * spacing / height ) );

m = spacing / ( spacing + 2 * width );
Kmp = ellipke( sqrt( 1 - m * m ) );
Km = ellipke( m );
cga = eps0 * Kmp / Km;

cgd = eps0 * epsR / pi * log( coth( pi * spacing / ( 4 * height ) ) ) +  ...
0.65 * cf * ( 0.02 * sqrt( epsR ) / ( spacing / height ) + ( 1 - 1 / epsR ^ 2 ) );
cm = ( cga + cgd - cfp ) / 2;
cm = max( cm, 0 );
co = cp + cf + cga + cgd;
ce = cp + cf + cfp;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppgQG0g.p.
% Please follow local copyright laws when handling this file.

