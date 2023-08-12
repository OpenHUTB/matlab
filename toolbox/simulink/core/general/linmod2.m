function [ A, B, C, D, apert, bpert, cpert, dpert ] = linmod2( fcn, varargin )






































if ~is_simulink_loaded
load_simulink;
end 

fUDBusVal = sl( 'busUtils', 'handleunitdelaybus', 0 );
fUDBusValCleanup = onCleanup(  ...
@(  )sl( 'busUtils', 'handleunitdelaybus', fUDBusVal ) );


supportMsg = linmodsupported( fcn );
if ~isempty( supportMsg )
error( supportMsg );
end 


want = struct( 'SimulationMode', 'normal', 'InitInArrayFormatMsg', 'None',  ...
'LoadInitialState', 'off', 'LoadExternalInput', 'off' );
[ have, preloaded ] = local_push_context( fcn, want );

warning_state = warning;
warning( 'on' );


feval( fcn, [  ], [  ], [  ], 'lincompile' );


errmsg = [  ];
try 
[ A, B, C, D, apert, bpert, cpert, dpert ] = linmod2_alg( fcn, varargin{ : } );
catch e
errmsg = e;
end 


feval( fcn, [  ], [  ], [  ], 'term' );

warning( warning_state );


if ~isempty( errmsg ), 
rethrow( errmsg );
end 


local_pop_context( fcn, have, preloaded );




function [ A, B, C, D, apert, bpert, cpert, dpert ] =  ...
linmod2_alg( fcn, x, u, para, apert, bpert, cpert, dpert )



sizes = feval( fcn, [  ], [  ], [  ], 'sizes' );
sizes = [ sizes( : );zeros( 6 - length( sizes ), 1 ) ];
nxz = sizes( 1 ) + sizes( 2 );nu = sizes( 4 );ny = sizes( 3 );
nx = sizes( 1 );

if nargin < 2, x = [  ];end 
if nargin < 3, u = [  ];end 
if nargin < 4, para = [  ];end 
if nargin < 5, apert = [  ];end 
if nargin < 6, bpert = [  ];end 
if nargin < 7, cpert = [  ];end 
if nargin < 8, dpert = [  ];end 

if isempty( u ), u = zeros( nu, 1 );end 
if isempty( x ), x = zeros( nxz, 1 );end 
if isempty( para ), para = [ 0;0 ];end 
if para( 1 ) == 0, para( 1 ) = 1e-8;else para( 1 ) = abs( para( 1 ) );end 
if isempty( apert ), apert = 1e-2 * ones( nx, nx );end 
if isempty( bpert ), bpert = 1e-2 * ones( nx, nu );end 
if isempty( cpert ), cpert = 1e-2 * ones( ny, nx );end 
if isempty( dpert ), dpert = 1e-2 * ones( ny, nu );end 
if length( para ) > 1, t = para( 2 );else t = 0;end 



A = zeros( nxz, nxz );B = zeros( nxz, nu );C = zeros( ny, nxz );D = zeros( ny, nu );


oldx = x;oldu = u;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
oldy = y;olddx = dx;


for i = 1:nx
for j = 1:nx

pert = apert( j, i );
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Aterm = ( dx( j ) - olddx( j ) ) ./ pert;
x = oldx;


pert = max( abs( 1e-2 * Aterm ), para( 1 ) );
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Aterm = ( dx( j ) - olddx( j ) ) ./ pert;
x = oldx;
diff = 1e20;


while abs( diff ) > sqrt( eps ) * abs( Aterm ) + eps & pert > para( 1 )
pert = pert / 2;
aold = Aterm;
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Aterm = ( dx( j ) - olddx( j ) ) ./ pert;
x = oldx;
diff = Aterm - aold;
end 

apert( j, i ) = pert;
if pert <= para( 1 ), diff = para( 1 );end 

pert =  - pert;
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Ao = ( dx( j ) - olddx( j ) ) ./ pert;
x = oldx;
if abs( Ao - Aterm ) > 100 * abs( diff ) + sqrt( eps ) + eps * abs( Aterm )
disp( [ 'Warning: Discontinuity detected at A(',  ...
num2str( j ), ',', num2str( i ), ')' ] );
A( j, i ) = sign( Aterm ) * Inf;
else 
A( j, i ) = Aterm;
end 
end 
end 


for i = 1:nx
for j = 1:ny

pert = cpert( j, i );
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
Cterm = ( y( j ) - oldy( j ) ) ./ pert;
x = oldx;


pert = max( abs( 1e-2 * Cterm ), para( 1 ) );
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
Cterm = ( y( j ) - oldy( j ) ) ./ pert;
x = oldx;
diff = 1e20;


while abs( diff ) > sqrt( eps ) * abs( Cterm ) + eps & pert > para( 1 )
pert = pert / 2;
cold = Cterm;
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
Cterm = ( y( j ) - oldy( j ) ) ./ pert;
x = oldx;
diff = Cterm - cold;
end 

cpert( j, i ) = pert;
if pert <= para( 1 ), diff = para( 1 );end 


pert =  - pert;
x( i ) = x( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
Co = ( y( j ) - oldy( j ) ) ./ pert;
x = oldx;
if abs( Co - Cterm ) > 100 * abs( diff ) + sqrt( eps ) + eps * abs( Cterm )
disp( [ 'Warning: Discontinuity detected in evaluating C(',  ...
num2str( j ), ',', num2str( i ), ')' ] );
C( j, i ) = sign( Cterm ) * Inf;
else 
C( j, i ) = Cterm;
end 
end 
end 


for i = 1:nu
for j = 1:nx

pert = bpert( j, i );
u( i ) = u( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Bterm = ( dx( j ) - olddx( j ) ) ./ pert;
u = oldu;


pert = max( abs( 1e-2 * Bterm ), para( 1 ) );
u( i ) = u( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Bterm = ( dx( j ) - olddx( j ) ) ./ pert;
u = oldu;
diff = 1e20;


while abs( diff ) > sqrt( eps ) * abs( Bterm ) + eps & pert > para( 1 )
bold = Bterm;
pert = pert / 2;
u( i ) = u( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Bterm = ( dx( j ) - olddx( j ) ) ./ pert;
u = oldu;
diff = Bterm - bold;
end 

bpert( j, i ) = pert;
if pert <= para( 1 ), diff = para( 1 );end 


pert =  - pert;
u( i ) = u( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );
Bo = ( dx( j ) - olddx( j ) ) ./ pert;
u = oldu;
if abs( Bo - Bterm ) > 100 * abs( diff ) + sqrt( eps ) + eps * abs( Bterm )
disp( [ 'Warning: Discontinuity detected in evaluating B(',  ...
num2str( j ), ',', num2str( i ), ')' ] );
B( j, i ) = sign( Bterm ) * Inf;
else 
B( j, i ) = Bterm;
end 
end 
end 


for i = 1:nu
for j = 1:ny

pert = dpert( j, i );
u( i ) = u( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
Dterm = ( y( j ) - oldy( j ) ) ./ pert;
u = oldu;


pert = max( abs( 1e-2 * Dterm ), para( 1 ) );
diff = 1e20;


while abs( diff ) > sqrt( eps ) * abs( Dterm ) + eps & pert > para( 1 )
pert = pert / 2;
dold = Dterm;
u( i ) = u( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
Dterm = ( y( j ) - oldy( j ) ) ./ pert;
u = oldu;
diff = Dterm - dold;
end 

dpert( j, i ) = pert;
if pert <= para( 1 ), diff = para( 1 );end 


pert =  - pert;
u( i ) = u( i ) + pert;
y = feval( fcn, t, x, u, 'outputs' );
Do = ( y( j ) - oldy( j ) ) ./ pert;
u = oldu;
if abs( Do - Dterm ) > 100 * abs( diff ) + sqrt( eps ) + eps * abs( Dterm )
disp( [ 'Warning: Discontinuity detected in evaluating D(',  ...
num2str( j ), ',', num2str( i ), ')' ] );
D( j, i ) = sign( Dterm ) * Inf;
else 
D( j, i ) = Dterm;
end 
end 
end 

function [ old, preloaded ] = local_push_context( model, new )



if isempty( find_system( 'SearchDepth', 0, 'CaseSensitive', 'off', 'Name', model ) )
preloaded = 0;
load_system( model );
else 
preloaded = 1;
end 


old = struct( 'Dirty', get_param( model, 'Dirty' ) );

f = fieldnames( new );
for k = 1:length( f )
prop = f{ k };
have_val = get_param( model, prop );
want_val = getfield( new, prop );
if ~isequal( have_val, want_val )
set_param( model, prop, want_val );
old = setfield( old, prop, have_val );
end 
end 



function local_pop_context( model, old, preloaded )


f = fieldnames( old );
for k = 1:length( f )
prop = f{ k };
if ~isequal( prop, 'Dirty' )
set_param( model, prop, getfield( old, prop ) );
end 
end 

set_param( model, 'Dirty', old.Dirty );

if preloaded == 0
close_system( model, 0 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpL61ViI.p.
% Please follow local copyright laws when handling this file.

