function S = traceTeeS( robj, freq, Z0 )





R36
robj( 1, 1 )pcbComponent
freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
Z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end 
validateattributes( freq, { 'double' }, { 'increasing' }, 2 )

validateattributes( robj.Layers, { 'cell' }, { 'size', [ 1, 3 ] }, 'sparameters', 'Layers' )
validateattributes( robj.Layers{ 1 }, { 'traceTee' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{1}' )
validateattributes( robj.Layers{ 2 }, { 'dielectric' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{2}' )
validateattributes( robj.Layers{ 3 }, { 'antenna.Rectangle' }, { 'size', [ 1, 1 ] }, 'sparameters', 'Layer{3}' )
validateattributes( robj.FeedLocations, { 'numeric' }, { 'size', [ 3, 4 ] }, 'sparameters', 'FeedLocations' )

Er = robj.Layers{ 2 }.EpsilonR;
validateattributes( unique( Er ), { 'numeric' }, { 'scalar' }, 'sparameters', 'EpsilonR' )

obj = robj.Layers{ 1 };
w1 = obj.Width( 1 );
w2 = obj.Width( 2 );
if obj.Offset
error( message( 'rfpcb:rfpcberrors:BehavioralUnsupported', 'Asymmetric T junction' ) )
end 
h = robj.BoardThickness;
w1overh = w1 / h;
validateattributes( w1overh, { 'numeric' }, { '>=', 1, '<=', 2 }, 'sparameters',  ...
'(conductor width/substrate height)' )
w2overh = w2 / h;
validateattributes( w2overh, { 'numeric' }, { '>=', 0.5, '<=', 2 }, 'sparameters',  ...
'(conductor width/substrate height)' )

obj = robj.Layers{ 1 };

tx1 = microstripLine(  ...
'Length', obj.Length( 1 ) / 2,  ...
'Height', robj.BoardThickness,  ...
'Width', w1,  ...
'Conductor', robj.Conductor,  ...
'Substrate', robj.Layers{ 2 } );


tx2 = txlineMicrostrip( microstripLine(  ...
'Length', obj.Length( 2 ),  ...
'Height', robj.BoardThickness,  ...
'Width', w2,  ...
'Conductor', robj.Conductor,  ...
'Substrate', robj.Layers{ 2 } ) );

[ Zc, Er_eff ] = getZ0( tx2 );




txmain = clone( tx1 );
txmain.Length = 2 * txmain.Length;
txmainZ0 = getZ0( txmain );

if ( ~( abs( txmainZ0 - 50 ) <= eps( max( abs( txmainZ0 ), 50 ) ) ) ) ||  ...
( ~( abs( Er - 9.9 ) <= eps( max( abs( Er ), 9.9 ) ) ) )
warning( message( 'rfpcb:rfpcberrors:TeeJunction' ) )
end 

if ( Zc >= 25 ) && ( Zc <= 100 )
C = ( ( 100 / tanh( 0.0072 * Zc ) ) + ( 0.64 * Zc ) - 261 ) * w1 * 1e-12;
else 
validateattributes( Zc, { 'numeric' }, { '>=', 25, '<=', 100 }, 'sparameters',  ...
'characterstic impedance of stub' )
end 

c = rf.physconst( 'LightSpeed' );
Lw = Zc * sqrt( Er_eff ) / c;
L1 =  - w2 * ( ( w2overh * (  - 0.016 * w1overh + 0.064 ) ) + ( 0.016 / w1overh ) ) * Lw * ( 10 ^  - 9 );
L2 = ( ( ( 0.12 * w1overh - 0.47 ) * w2overh ) + ( 0.195 * w1overh ) - 0.357 +  ...
( 0.0283 * sin( pi * w1overh - 0.75 * pi ) ) ) * Lw * h * ( 10 ^  - 9 );

ckt = circuit( robj.Name );
add( ckt, [ 1, 2, 0, 0 ], tx1 )
add( ckt, [ 2, 3 ], nport( zparameters( 1i * 2 * pi * freq * L1, freq ) ) )
add( ckt, [ 3, 0 ], nport( zparameters( 1 ./ ( 1i * 2 * pi * freq * C ), freq ) ) )
add( ckt, [ 3, 4 ], nport( zparameters( 1i * 2 * pi * freq * L1, freq ) ) )
add( ckt, [ 4, 5, 0, 0 ], clone( tx1 ) )
add( ckt, [ 3, 6 ], nport( zparameters( 1i * 2 * pi * freq * L2, freq ) ) )
add( ckt, [ 6, 7, 0, 0 ], tx2 )
setports( ckt, [ 1, 0 ], [ 5, 0 ], [ 7, 0 ] )
S = sparameters( ckt, freq, Z0 );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUK_uou.p.
% Please follow local copyright laws when handling this file.

