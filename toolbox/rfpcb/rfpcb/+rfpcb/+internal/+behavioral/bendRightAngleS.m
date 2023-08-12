function S = bendRightAngleS( robj, freq, Z0 )















R36
robj( 1, 1 )pcbComponent
freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
Z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end 
validateattributes( freq, { 'double' }, { 'increasing' }, 2 )

validateattributes( robj.Layers, { 'cell' }, { 'size', [ 1, 3 ] }, 'sparameters', 'Layers' )
validateattributes( robj.Layers{ 1 }, { 'bendRightAngle' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{1}' )
validateattributes( robj.Layers{ 2 }, { 'dielectric' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{2}' )
validateattributes( robj.Layers{ 3 }, { 'antenna.Rectangle' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{3}' )

Er = robj.Layers{ 2 }.EpsilonR;
validateattributes( unique( Er ), { 'numeric' }, { 'scalar' }, 'sparameters', 'EpsilonR' )
validateattributes( Er, { 'numeric' }, { '>=', 2, '<=', 15 }, 'sparameters', 'EpsilonR' )

obj = robj.Layers{ 1 };
w1 = obj.Width( 1 );
w2 = obj.Width( 2 );
if ~( abs( w1 - w2 ) <= eps( max( abs( w1 ), abs( w2 ) ) ) )
error( message( 'rfpcb:rfpcberrors:BehavioralUnsupported', 'Unequal width right-angle bend' ) )
end 
w = w1;
woverh = w / robj.BoardThickness;
validateattributes( woverh, { 'numeric' }, { '>=', 0.1, '<=', 6 }, 'sparameters',  ...
'(conductor width/substrate height)' )













ckt = [  ];
if ( Er >= 2 && Er <= 13 ) && ( woverh >= 0.2 && woverh <= 6 )

h = robj.BoardThickness * 1e3;
C = 0.001 * h * ( ( 10.35 * Er + 2.5 ) * ( woverh ^ 2 ) + ( 2.6 * Er + 5.64 ) * ( woverh ) ) * ( 10 ^  - 12 );
L = 0.22 * h * ( 1 - 1.35 * exp(  - 0.18 * ( woverh ^ 1.39 ) ) ) * ( 10 ^  - 9 );
ckt = buildCircuit( L, C, robj, freq, Z0 );
elseif ( Er >= 2.5 && Er <= 15 ) && ( woverh >= 0.1 && woverh <= 5 )


h = robj.BoardThickness;
L = 100 * h * ( 4 * sqrt( woverh ) - 4.21 ) * ( 10 ^  - 9 ) / 2;
if woverh < 1
fraction1 = ( ( 14 * Er + 12.5 ) * woverh - ( 1.83 * Er - 2.25 ) ) / sqrt( woverh );
fraction2 = 0.02 * Er / woverh;
C = w * ( fraction1 + fraction2 ) * ( 10 ^  - 12 );
else 
C = w * ( ( 9.5 * Er + 1.25 ) * woverh + 5.2 * Er + 7 ) * ( 10 ^  - 12 );
end 
ckt = buildCircuit( L, C, robj, freq, Z0 );
end 

if ~isempty( ckt )
S = sparameters( ckt, freq, Z0 );
else 
inputvar = "epsilonR of " + num2str( Er ) + " and (conductor width/substrate height) of " + num2str( woverh );
error( message( 'rfpcb:rfpcberrors:BehavioralUnavailable', inputvar ) )
end 
end 

function ckt = buildCircuit( L, C, robj, freq, Z0 )
R36
L
C
robj( 1, 1 )pcbComponent
freq
Z0
end 

obj = robj.Layers{ 1 };
tx1 = microstripLine(  ...
'Length', obj.Length( 1 ) - obj.Width( 2 ) / 2,  ...
'Height', robj.BoardThickness,  ...
'Width', obj.Width( 1 ),  ...
"Conductor", robj.Conductor,  ...
"Substrate", robj.Layers{ 2 } );
tx2 = microstripLine(  ...
'Length', obj.Length( 2 ) - obj.Width( 1 ) / 2,  ...
'Height', robj.BoardThickness,  ...
'Width', obj.Width( 2 ),  ...
"Conductor", robj.Conductor,  ...
"Substrate", robj.Layers{ 2 } );

ckt = circuit( robj.Name );
add( ckt, [ 1, 2, 0, 0 ], tx1 )
add( ckt, [ 2, 4, 0, 0 ], nport( lumpedTeeS( C, L, Z0, freq ) ) )
add( ckt, [ 4, 5, 0, 0 ], tx2 )
setports( ckt, [ 1, 0 ], [ 5, 0 ] )
end 

function S = lumpedTeeS( C, L, Z0, freq )
s = 1i * 2 * pi * freq;
s11( 1, 1, : ) = ( s .* ( C * L ^ 2 * s .^ 2 + 2 * L - C * Z0 ^ 2 ) ) ./ ( ( Z0 + L * s ) .* ( C * L * s .^ 2 + C * Z0 * s + 2 ) );
s12( 1, 1, : ) = ( 2 * Z0 ) ./ ( ( Z0 + L .* s ) .* ( C * L * s .^ 2 + C * Z0 * s + 2 ) );
s21 = s12;
s22 = s11;
S = sparameters( [ s11, s12;s21, s22 ], freq, Z0 );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3qkXso.p.
% Please follow local copyright laws when handling this file.

