function S = bendMiteredS( robj, freq, Z0 )

arguments
    robj( 1, 1 )pcbComponent
    freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
    Z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end
validateattributes( freq, { 'double' }, { 'increasing' }, 2 )

validateattributes( robj.Layers, { 'cell' }, { 'size', [ 1, 3 ] }, 'sparameters', 'Layers' )
validateattributes( robj.Layers{ 1 }, { 'bendMitered' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{1}' )
validateattributes( robj.Layers{ 2 }, { 'dielectric' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{2}' )
validateattributes( robj.Layers{ 3 }, { 'antenna.Rectangle' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{3}' )

Er = robj.Layers{ 2 }.EpsilonR;
validateattributes( unique( Er ), { 'numeric' }, { 'scalar' }, 'sparameters', 'EpsilonR' )
validateattributes( Er, { 'numeric' }, { '>=', 2, '<=', 13 }, 'sparameters', 'EpsilonR' )

obj = robj.Layers{ 1 };
w1 = obj.Width( 1 );
w2 = obj.Width( 2 );
if ~( abs( w1 - w2 ) <= eps( max( abs( w1 ), abs( w2 ) ) ) )
    error( message( 'rfpcb:rfpcberrors:BehavioralUnsupported', 'Unequal width mitered bend' ) )
end
w = w1;
woverh = w / robj.BoardThickness;
validateattributes( woverh, { 'numeric' }, { '>=', 0.2, '<=', 6 }, 'sparameters',  ...
    '(conductor width/substrate height)' )
ckt = [  ];
if robj.Layers{ 1 }.MiterDiagonal > 0.98 * w * sqrt( 2 ) &&  ...
        robj.Layers{ 1 }.MiterDiagonal < 1.02 * w * sqrt( 2 )


    h = robj.BoardThickness * 1e3;
    C = 0.001 * h * ( ( 3.93 * Er + 0.62 ) * ( woverh ^ 2 ) + ( 7.6 * Er + 3.80 ) * ( woverh ) ) * ( 10 ^  - 12 );
    L = 0.44 * h * ( 1 - 1.062 * exp(  - 0.177 * ( woverh ^ 0.947 ) ) ) * ( 10 ^  - 9 );
    ckt = buildCircuit( L, C, robj, freq, Z0 );







end
if ~isempty( ckt )
    S = sparameters( ckt, freq, Z0 );
else
    error( message( 'rfpcb:rfpcberrors:BehavioralUnavailable', 'mitered-bend with other than 50% miter.' ) )
end
end

function ckt = buildCircuit( L, C, robj, freq, Z0 )
arguments
    L
    C
    robj( 1, 1 )pcbComponent
    freq
    Z0
end

obj = robj.Layers{ 1 };

tx1 = microstripLine(  ...
    "Length", obj.Length( 1 ) - obj.Width( 2 ) / 2,  ...
    'Height', robj.BoardThickness,  ...
    'Width', obj.Width( 1 ),  ...
    "Conductor", robj.Conductor,  ...
    "Substrate", robj.Layers{ 2 } );

tx2 = microstripLine(  ...
    "Length", obj.Length( 2 ) - obj.Width( 1 ) / 2,  ...
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

