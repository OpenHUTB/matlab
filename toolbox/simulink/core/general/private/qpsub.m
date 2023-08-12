function [ X, lambda, how ] = qpsub( H, f, A, B, vlb, vub, X, neqcstr, verbosity, caller,  ...
ncstr, nvars, negdef, normalize )












if isempty( normalize ), normalize = 1;end 
if isempty( verbosity ), verbosity = 0;end 
if isempty( neqcstr ), neqcstr = 0;end 

maxiter = 10 * max( nvars, ncstr - neqcstr );
iterations = 0;

LLS = 0;
if isequal( caller, 'conls' )
LLS = 1;
[ rowH, colH ] = size( H );
nvars = colH;
end 

simplex_iter = 0;
if norm( H, 'inf' ) == 0 || ~length( H ), 
is_qp = 0;
else 
is_qp = ~negdef;
end 
how = 'ok';

if LLS == 1
is_qp = 0;
end 

normf = 1;
if normalize > 0

if ~is_qp && ~LLS
normf = norm( f );
f = f ./ normf;
end 
end 


lenvlb = length( vlb );
if lenvlb > 0
A = [ A; - eye( lenvlb, nvars ) ];
B = [ B; - vlb( : ) ];
end 
lenvub = length( vub );
if lenvub > 0
A = [ A;eye( lenvub, nvars ) ];
B = [ B;vub( : ) ];
end 
ncstr = ncstr + lenvlb + lenvub;



normA = ones( ncstr, 1 );
if normalize > 0
for i = 1:ncstr
n = norm( A( i, : ) );
if ( n ~= 0 )
A( i, : ) = A( i, : ) / n;
B( i ) = B( i ) / n;
normA( i, 1 ) = n;
end 
end 
else 
normA = ones( ncstr, 1 );
end 
errnorm = 0.01 * sqrt( eps );

lambda = zeros( ncstr, 1 );
aix = lambda;
ACTCNT = 0;
ACTSET = [  ];
ACTIND = 0;
CIND = 1;
eqix = 1:neqcstr;

Q = zeros( nvars, nvars );
R = [  ];
if neqcstr > 0
aix( eqix ) = ones( neqcstr, 1 );
ACTSET = A( eqix, : );
ACTIND = eqix;
ACTCNT = neqcstr;
if ACTCNT >= nvars - 1, simplex_iter = 1;end 
CIND = neqcstr + 1;
[ Q, R ] = qr( ACTSET' );
if max( abs( A( eqix, : ) * X - B( eqix ) ) ) > 1e-10
X = ACTSET\B( eqix );

end 

[ m, n ] = size( ACTSET );
Z = Q( :, m + 1:n );
err = 0;
if neqcstr > nvars
err = max( abs( A( eqix, : ) * X - B( eqix ) ) );
if ( err > 1e-8 )
how = 'infeasible';
if verbosity >  - 1
warning( message( 'Simulink:util:EqualityConstraintsOverlyStringent' ) )
end 
end 
if ~LLS
actlambda =  - R\( Q' * ( H * X + f ) );
else 
actlambda =  - R\( Q' * ( H' * ( H * X - f ) ) );
end 
lambda( eqix ) = normf * ( actlambda ./ normA( eqix ) );
return 
end 
if ~length( Z )
if ~LLS
actlambda =  - R\( Q' * ( H * X + f ) );
else 
actlambda =  - R\( Q' * ( H' * ( H * X - f ) ) );
end 
lambda( eqix ) = normf * ( actlambda ./ normA( eqix ) );
if ( max( A * X - B ) > 1e-8 )
how = 'infeasible';
warning( message( 'Simulink:util:EqualityConstraintsOverlyStringentMet' ) )
end 
return 
end 

if ( verbosity ==  - 2 )
cstr = A * X - B;
mc = max( cstr( neqcstr + 1:ncstr ) );
if ( mc > 0 )
X( nvars ) = mc + 1;
end 
end 
else 
Z = 1;
end 


cstr = A * X - B;
mc = max( cstr( neqcstr + 1:ncstr ) );
if mc > eps
A2 = [ [ A;zeros( 1, nvars ) ], [ zeros( neqcstr, 1 ); - ones( ncstr + 1 - neqcstr, 1 ) ] ];
[ XS, lambdas ] = qpsub( [  ], [ zeros( nvars, 1 );1 ], A2, [ B;1e-5 ],  ...
[  ], [  ], [ X;mc + 1 ], neqcstr,  - 2, 'qpsub', size( A2, 1 ), nvars + 1, 0,  - 1 );

X = XS( 1:nvars );
cstr = A * X - B;
if XS( nvars + 1 ) > eps
if XS( nvars + 1 ) > 1e-8
how = 'infeasible';
if verbosity >  - 1
warning( message( 'Simulink:util:ConstraintsOverlyStringent' ) )
end 
else 
how = 'overly constrained';
end 
lambda = normf * ( lambdas( ( 1:ncstr )' ) ./ normA );
return 
end 
end 

if ( is_qp )
gf = H * X + f;
SD =  - Z * ( ( Z' * H * Z )\( Z' * gf ) );


elseif ( LLS )
HXf = H * X - f;
gf = H' * ( HXf );
HZ = H * Z;
[ mm, nn ] = size( HZ );

[ QHZ, RHZ ] = qr( HZ );
Pd = QHZ' * HXf;

SD =  - Z * ( RHZ( 1:nn, 1:nn )\Pd( 1:nn, : ) );

else 
gf = f;
SD =  - Z * Z' * gf;
if norm( SD ) < 1e-10 && neqcstr


if ~LLS
actlambda =  - R\( Q' * ( H * X + f ) );
else 
actlambda =  - R\( Q' * ( H' * ( H * X - f ) ) );
end 
lambda( eqix ) = normf * ( actlambda ./ normA( eqix ) );
return ;
end 
end 






if negdef
if norm( SD ) < sqrt( eps )
SD =  - Z * Z' * ( rand( nvars, 1 ) - 0.5 );
end 
end 
oldind = 0;

t = zeros( 10, 2 );
tt = zeros( 10, 1 );





while iterations < maxiter
iterations = iterations + 1;



GSD = A * SD;






indf = find( ( GSD > errnorm * norm( SD ) ) & ~aix );

if ~length( indf )
STEPMIN = 1e16;
else 
dist = abs( cstr( indf ) ./ GSD( indf ) );
[ STEPMIN, ind2 ] = min( dist );
ind2 = find( dist == STEPMIN );


ind = indf( min( ind2 ) );


end 

if ( is_qp ) || LLS

if STEPMIN >= 1
X = X + SD;
if ACTCNT > 0
if ACTCNT >= nvars - 1, 

if CIND <= ACTCNT
ACTSET( CIND, : ) = [  ];
ACTIND( CIND ) = [  ];
end 
end 

if ~LLS
rlambda =  - R\( Q' * ( H * X + f ) );
else 
rlambda =  - R\( Q' * ( H' * ( H * X - f ) ) );
end 
actlambda = rlambda;
actlambda( eqix ) = abs( rlambda( eqix ) );
indlam = find( actlambda < 0 );
if ( ~length( indlam ) )
lambda( ACTIND ) = normf * ( rlambda ./ normA( ACTIND ) );
return 
end 

lind = find( ACTIND == min( ACTIND( indlam ) ) );
lind = lind( 1 );
ACTSET( lind, : ) = [  ];
aix( ACTIND( lind ) ) = 0;
[ Q, R ] = qrdelete( Q, R, lind );
ACTIND( lind ) = [  ];
ACTCNT = ACTCNT - 2;
simplex_iter = 0;
ind = 0;
else 
return 
end 
else 
X = X + STEPMIN * SD;
end 

if is_qp
gf = H * X + f;
else 
gf = H' * ( H * X - f );
end 

else 

if ~length( indf ) || ~isfinite( STEPMIN )
if norm( SD ) > errnorm
if normalize < 0
STEPMIN = abs( ( X( nvars ) + 1e-5 ) / ( SD( nvars ) + eps ) );
else 
STEPMIN = 1e16;
end 
X = X + STEPMIN * SD;
how = 'unbounded';
else 
how = 'ill posed';
end 
if verbosity >  - 1
if norm( SD ) > errnorm
warning( message( 'Simulink:util:ConstraintsNotRestrictive' ) )
else 
warning( message( 'Simulink:util:SearchDirCloseToZero' ) )
end 
end 
return 
else 
X = X + STEPMIN * SD;
end 
end 


cstr = A * X - B;
cstr( eqix ) = abs( cstr( eqix ) );

if normalize < 0
if X( nvars, 1 ) < eps
return ;
end 
end 

if max( cstr ) > 1e5 * errnorm
if max( cstr ) > norm( X ) * errnorm
if verbosity >  - 1
warning( message( 'Simulink:util:ProblemBadlyConditioned' ) )
verbosity =  - 1;
end 
how = 'unreliable';
if 0
X = X - STEPMIN * SD;
return 
end 
end 
end 







if negdef
if norm( gf ) < sqrt( eps )
gf = randn( nvars, 1 );
end 
end 
if ind
aix( ind ) = 1;
ACTSET( CIND, : ) = A( ind, : );
ACTIND( CIND ) = ind;
[ m, n ] = size( ACTSET );
[ Q, R ] = qrinsert( Q, R, CIND, A( ind, : )' );
end 
if oldind
aix( oldind ) = 0;
end 
if ~simplex_iter

[ m, n ] = size( ACTSET );
Z = Q( :, m + 1:n );
ACTCNT = ACTCNT + 1;
if ACTCNT == nvars - 1, simplex_iter = 1;end 
CIND = ACTCNT + 1;
oldind = 0;
else 
rlambda =  - R\( Q' * gf );

if isinf( rlambda( 1 ) ) && rlambda( 1 ) < 0
disp( [ '    ', getString( message( 'Simulink:util:WorkingSetSingular' ) ) ] );
[ m, n ] = size( ACTSET );
rlambda =  - ( ACTSET + sqrt( eps ) * randn( m, n ) )'\gf;
end 
actlambda = rlambda;
actlambda( eqix ) = abs( actlambda( eqix ) );
indlam = find( actlambda < 0 );
if length( indlam )
if STEPMIN > errnorm




[ minl, CIND ] = min( actlambda );
else 



CIND = find( ACTIND == min( ACTIND( indlam ) ) );
end 

[ Q, R ] = qrdelete( Q, R, CIND );
Z = Q( :, nvars );
oldind = ACTIND( CIND );
else 
lambda( ACTIND ) = normf * ( rlambda ./ normA( ACTIND ) );
return 
end 
end 
if ( is_qp )
Zgf = Z' * gf;
if ( norm( Zgf ) < 1e-15 )
SD = zeros( nvars, 1 );
elseif ~length( Zgf )

warning( message( 'Simulink:util:ProblemNegSemiDef' ) )
SD = zeros( nvars, 1 );
else 
SD =  - Z * ( ( Z' * H * Z )\( Zgf ) );
end 


elseif ( LLS )
Zgf = Z' * gf;
if ( norm( Zgf ) < 1e-15 )
SD = zeros( nvars, 1 );
elseif ~length( Zgf )

warning( message( 'Simulink:util:ProblemNegSemiDef' ) )
SD = zeros( nvars, 1 );
else 


HXf = H * X - f;
gf = H' * ( HXf );
HZ = H * Z;
[ mm, nn ] = size( HZ );

[ QHZ, RHZ ] = qr( HZ );
Pd = QHZ' * HXf;

SD =  - Z * ( RHZ( 1:nn, 1:nn )\Pd( 1:nn, : ) );

end 
else 
if ~simplex_iter
SD =  - Z * Z' * gf;
gradsd = norm( SD );
else 
gradsd = Z' * gf;
if gradsd > 0
SD =  - Z;
else 
SD = Z;
end 
end 
if abs( gradsd ) < 1e-10


if ~oldind
rlambda =  - R\( Q' * gf );
end 
actlambda = rlambda;
actlambda( 1:neqcstr ) = abs( actlambda( 1:neqcstr ) );
indlam = find( actlambda < errnorm );
lambda( ACTIND ) = normf * ( rlambda ./ normA( ACTIND ) );
if ~length( indlam )
return 
end 
cindmax = length( indlam );
cindcnt = 0;
newactcnt = 0;
while ( abs( gradsd ) < 1e-10 ) && ( cindcnt < cindmax )

cindcnt = cindcnt + 1;
if oldind

[ Q, R ] = qrinsert( Q, R, CIND, A( oldind, : )' );
else 
simplex_iter = 0;
if ~newactcnt
newactcnt = ACTCNT - 1;
end 
end 
CIND = indlam( cindcnt );
oldind = ACTIND( CIND );

[ Q, R ] = qrdelete( Q, R, CIND );
[ m, n ] = size( ACTSET );
Z = Q( :, m:n );

if m ~= nvars
SD =  - Z * Z' * gf;
gradsd = norm( SD );
else 
gradsd = Z' * gf;
if gradsd > 0
SD =  - Z;
else 
SD = Z;
end 
end 
end 
if abs( gradsd ) < 1e-10
return ;
end 
lambda = zeros( ncstr, 1 );
if newactcnt
ACTCNT = newactcnt;
end 
end 
end 

if simplex_iter && oldind

if CIND <= ACTCNT
ACTIND( CIND ) = [  ];
ACTSET( CIND, : ) = [  ];
CIND = nvars;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphOfasK.p.
% Please follow local copyright laws when handling this file.

