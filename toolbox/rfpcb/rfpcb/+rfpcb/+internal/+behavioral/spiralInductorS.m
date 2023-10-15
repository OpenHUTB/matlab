function S = spiralInductorS( obj, freq, z0 )

arguments
    obj( 1, 1 )
    freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
    z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end
validateattributes( freq, { 'double' }, { 'increasing' }, 2 )
thickness = obj.Conductor.Thickness;

r0 = obj.InnerDiameter / 2;
nturn = obj.NumTurns;
width = obj.Width;
w1 = width / 2;
spacing = obj.Spacing;
height = obj.Height;
sigma = obj.Conductor.Conductivity;
rhosp = 1 / sigma;

mu0 = pi * 4e-7;
c0 = physconst( 'LightSpeed' );
eps0 = 1 / mu0 / c0 ^ 2;
twoPi = 2 * pi;

epsR = obj.Substrate.EpsilonR( 1 );

m = spacing / ( spacing + 2 * width );
Kmp = ellipke( sqrt( 1 - m * m ) );
Km = ellipke( m );

nseg = 16;
n = nseg * nturn;
L = zeros( 1, n );
R = zeros( 1, n );
Rs = zeros( 1, n );
M = zeros( n, n );
Mr = zeros( n, n );
Cshunt = zeros( 1, n );
Ccoupling = zeros( 1, n );

woh = width / height;
ms = microstripLine( 'Width', width, 'Substrate', obj.Substrate,  ...
    'Conductor', obj.Conductor, 'Height', height );
tx = txlineMicrostrip( ms );
[ Z0, epsReff ] = getZ0( tx );





cp = eps0 * epsR * woh;

cf = ( sqrt( epsReff ) / ( c0 * Z0 ) - cp ) / 2;

A = exp(  - 0.1 * exp( 2.33 - 1.5 * woh ) );
cfp = cf * ( epsR / epsReff ) ^ ( 1 / 4 ) / ( 1 + A * ( height / spacing ) * tanh( 10 * spacing / height ) );

cga = eps0 * Kmp / Km;

cgd = eps0 * epsR / pi * log( coth( pi * spacing / ( 4 * height ) ) ) +  ...
    0.65 * cf * ( 0.02 * sqrt( epsR ) / ( spacing / height ) + ( 1 - 1 / epsR ^ 2 ) );
cm = ( cga + cgd - cfp ) / 2;

k = ( 1:n );

rad = r0 + width / 2 + ( ( width + spacing ) / nseg ) * ( k - 1 / 2 );
len = twoPi * rad / nseg;
lenInner = twoPi * ( rad - width / 2 ) / nseg;
lenOuter = twoPi * ( rad + width / 2 ) / nseg;

for kturn = 1:nturn
    for kseg = 1:nseg
        k = ( kturn - 1 ) * nseg + kseg;
        a = rad( k );


        k2sq = 4 * ( a * ( a - w1 ) ) / ( 2 * a - w1 ) ^ 2;
        [ K2, E2 ] = ellipke( k2sq );
        L( k ) = ( mu0 * ( 2 * a - w1 ) * ( ( 1 - k2sq / 2 ) * K2 - E2 ) ) / nseg;

        for jturn = 1:nturn
            j = ( jturn - 1 ) * nseg + kseg;
            b = rad( j );


            if kturn ~= jturn
                k1 = 2 * sqrt( a * b ) / ( a + b );
                [ K1, E1 ] = ellipke( k1 * k1 );
                M( k, j ) = ( mu0 * sqrt( a * b ) * ( ( 2 / k1 - k1 ) * K1 - 2 * E1 / k1 ) ) / nseg;
            end


            k3sq = 4 * a * b / ( ( 2 * height ) ^ 2 + ( a + b ) ^ 2 );
            [ K3, E3 ] = ellipke( k3sq );
            k3 = sqrt( k3sq );


            Mr( k, j ) = ( mu0 * sqrt( a * b ) * ( ( 2 / k3 - k3 ) * K3 - 2 * E3 / k3 ) ) / nseg;
        end


        R( k ) = rhosp * len( k ) / ( width * thickness );


        Rs( k ) = sqrt( pi * mu0 / sigma ) * len( k ) / ( 2 * width );



        if kturn == 1
            Cshunt( k ) = len( k ) * cp + lenInner( k ) * cf + lenOuter( k ) * cfp;
            Ccoupling( k ) = ( lenOuter( k ) + lenInner( k + nseg ) ) / 2 * cm;
        elseif kturn < nturn - 1
            Cshunt( k ) = len( k ) * ( cp + 2 * cfp );
            Ccoupling( k ) = ( lenOuter( k ) + lenInner( k + nseg ) ) / 2 * cm;
        elseif kturn == nturn - 1
            Cshunt( k ) = len( k ) * ( cp + 2 * cfp );
            Ccoupling( k ) = ( lenOuter( k ) + lenInner( k + nseg ) ) / 2 * cm;
        else
            Cshunt( k ) = len( k ) * cp + lenInner( k ) * cfp + lenOuter( k ) * cf;
        end
    end
end








ckt = circuit;
s = reshape( 2i * pi * freq, 1, 1, [  ] );
LL = diag( L ) + M - Mr;
RRs = diag( Rs ) .* reshape( sqrt( freq ), 1, 1, [  ] );
ZZ = LL .* s + diag( R ) + RRs;
Z = zparameters( ZZ, freq );
np = nport( Z );
r = 1:n;
add( ckt, [ r, r + 1 ], np )
for kturn = 1:nturn
    for kseg = 1:nseg
        k = ( kturn - 1 ) * nseg + kseg;
        add( ckt, [ k, 0 ], capacitor( Cshunt( k ) / 2 ) )
        add( ckt, [ k + 1, 0 ], capacitor( Cshunt( k ) / 2 ) )
        if kturn < nturn

            add( ckt, [ k, k + nseg ], capacitor( ( Ccoupling( k ) / 2 ) ) )
            add( ckt, [ k + 1, k + nseg + 1 ], capacitor( ( Ccoupling( k ) / 2 ) ) )
        end
    end
end

brLen = norm( [ 0, obj.FeedLocation( 2, 2 ) ] - obj.FeedLocation( 2, 1:2 ) );

msBridge = microstripLine(  ...
    'Length', brLen,  ...
    'Width', width,  ...
    'Height', height / 2,  ...
    'Conductor', obj.Conductor,  ...
    'Substrate', obj.Substrate );

Rfeed = twoPi * height / 2 / ( sigma * width ^ 2 );
add( ckt, [ 1, k + 2 ], resistor( Rfeed ) )
add( ckt, [ k + 2, k + 3, 0, 0 ], msBridge )
setports( ckt, [ k + 3, 0 ], [ k + 1, 0 ] )

S = sparameters( ckt, freq, z0 );
end

