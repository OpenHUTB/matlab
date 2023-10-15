function S = traceCrossS( robj, freq, Z0 )

arguments
    robj( 1, 1 )pcbComponent
    freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
    Z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end
validateattributes( freq, { 'double' }, { 'increasing' }, 2 )

validateattributes( robj.Layers, { 'cell' }, { 'size', [ 1, 3 ] }, 'sparameters', 'Layers' )
validateattributes( robj.Layers{ 1 }, { 'traceCross' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{1}' )
validateattributes( robj.Layers{ 2 }, { 'dielectric' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{2}' )
validateattributes( robj.Layers{ 3 }, { 'antenna.Rectangle' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{3}' )
validateattributes( robj.FeedLocations, { 'numeric' }, { 'size', [ 4, 4 ] }, 'sparameters', 'FeedLocations' )

Er = robj.Layers{ 2 }.EpsilonR;
validateattributes( unique( Er ), { 'numeric' }, { 'scalar' }, 'sparameters', 'EpsilonR' )

obj = robj.Layers{ 1 };
w1 = obj.Width( 1 );
w2 = obj.Width( 2 );
if any( obj.Offset )
    error( message( 'rfpcb:rfpcberrors:BehavioralUnsupported', 'Asymmetric Cross junction' ) )
end
h = robj.BoardThickness;
w1overh = w1 / h;
validateattributes( w1overh, { 'numeric' }, { '>=', 0.5, '<=', 2 }, 'sparameters',  ...
    '(conductor width/substrate height)' )
w2overh = w2 / h;
validateattributes( w2overh, { 'numeric' }, { '>=', 0.5, '<=', 2 }, 'sparameters',  ...
    '(conductor width/substrate height)' )

obj = robj.Layers{ 1 };

tx1 = microstripLine(  ...
    "Length", ( obj.Length( 1 ) / 2 ) - ( obj.Width( 1 ) / 2 ),  ...
    'Height', robj.BoardThickness,  ...
    'Width', w1,  ...
    'Conductor', robj.Conductor,  ...
    'Substrate', robj.Layers{ 2 } );


tx2 = microstripLine(  ...
    "Length", ( obj.Length( 2 ) / 2 ) - ( obj.Width( 2 ) / 2 ),  ...
    'Height', robj.BoardThickness,  ...
    'Width', w2,  ...
    'Conductor', robj.Conductor,  ...
    'Substrate', robj.Layers{ 2 } );

if ( ~( abs( Er - 9.9 ) <= eps( max( abs( Er ), 9.9 ) ) ) )
    warning( message( 'rfpcb:rfpcberrors:CrossJunction' ) )
end

part1a = ( 86.6 .* w2overh - 30.9 .* sqrt( w2overh ) + 367 ) * log10( w1overh );
part1 = ( part1a + ( w2overh .^ 3 ) + ( 74 .* w2overh ) + 130 ) ./ ( w1overh ^ 3 );
Coverw1 = ( part1 - 240 + ( 2 ./ w2overh ) -  ...
    ( 1.5 .* w1overh ) .* ( 1 - w2overh ) ) .* 1e-12;
C = Coverw1 * w1;

Loverh = @( a, b )( ( 165.6 .* a + 31.2 .* sqrt( a ) - 11.8 .* ( a ) .^ 2 ) .* b - 32 .* a + 3 ) .* ( b ^ (  - 1.5 ) ) .* 1e-9;

L1overh = Loverh( w2overh, w1overh );
L2overh = Loverh( w1overh, w2overh );

L3overh = ( 337.5 + ( 1 + 7 ./ w1overh ) .* ( 1 ./ w2overh ) ...
    - 5 .* w2overh .* cos( ( pi / 2 ) * ( 1.5 - w1overh ) ) ) .* 1e-9;

L1 = L1overh * h;
L2 = L2overh * h;
L3 = L3overh * h;

ckt = circuit( robj.Name );
add( ckt, [ 1, 2, 0, 0 ], tx1 )
add( ckt, [ 2, 0 ], nport( zparameters( 1 ./ ( 1i * 2 * pi * freq * C ), freq ) ) )
add( ckt, [ 2, 3 ], nport( zparameters( 1i * 2 * pi * freq * L1, freq ) ) )
add( ckt, [ 3, 4 ], nport( zparameters( 1i * 2 * pi * freq * L3, freq ) ) )
add( ckt, [ 3, 5 ], nport( zparameters( 1i * 2 * pi * freq * L1, freq ) ) )
add( ckt, [ 5, 0 ], nport( zparameters( 1 ./ ( 1i * 2 * pi * freq * C ), freq ) ) )
add( ckt, [ 5, 6, 0, 0 ], clone( tx1 ) )

add( ckt, [ 7, 8, 0, 0 ], tx2 )
add( ckt, [ 8, 0 ], nport( zparameters( 1 ./ ( 1i * 2 * pi * freq * C ), freq ) ) )
add( ckt, [ 8, 4 ], nport( zparameters( 1i * 2 * pi * freq * L2, freq ) ) )
add( ckt, [ 4, 9 ], nport( zparameters( 1i * 2 * pi * freq * L2, freq ) ) )
add( ckt, [ 9, 0 ], nport( zparameters( 1 ./ ( 1i * 2 * pi * freq * C ), freq ) ) )
add( ckt, [ 9, 10, 0, 0 ], clone( tx2 ) )

setports( ckt, [ 1, 0 ], [ 6, 0 ], [ 7, 0 ], [ 10, 0 ] )
S = sparameters( ckt, freq, Z0 );
end
