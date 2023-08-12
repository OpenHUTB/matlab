function [ A, B, C, D ] = linmodv5( model, varargin )






































model = convertStringsToChars( model );

if ~is_simulink_loaded
load_simulink;
end 

fUDBusVal = sl( 'busUtils', 'handleunitdelaybus', 0 );
fUDBusValCleanup = onCleanup(  ...
@(  )sl( 'busUtils', 'handleunitdelaybus', fUDBusVal ) );


supportMsg = linmodsupported( model );
if ~isempty( supportMsg )
error( supportMsg );
end 


[ ~, normalrefs ] = getLinNormalModeBlocks( model );
models = [ model;normalrefs ];


want = struct( 'SimulationMode', 'normal', 'RTWInlineParameters', 'on', 'InitInArrayFormatMsg', 'None' );
[ have, preloaded ] = local_push_context( models, want );


feval( model, [  ], [  ], [  ], 'lincompile' );


errmsg = [  ];
try 
[ A, B, C, D ] = linmod_alg( model, varargin{ : } );
catch e
errmsg = e;
end 


feval( model, [  ], [  ], [  ], 'term' );
local_pop_context( models, have, preloaded );


if ~isempty( errmsg )
rethrow( errmsg );
end 



function [ A, B, C, D ] = linmod_alg( model, x, u, para, xpert, upert )


sizes = feval( model, [  ], [  ], [  ], 'sizes' );
sizes = [ sizes( : );zeros( 6 - length( sizes ), 1 ) ];
nxz = sizes( 1 ) + sizes( 2 );nu = sizes( 4 );
nx = sizes( 1 );

if nargin < 2, x = [  ];end 
if nargin < 3, u = [  ];end 
if nargin < 4, para = [  ];end 
if nargin < 5, xpert = [  ];end 
if nargin < 6, upert = [  ];end 


if isempty( u ), u = zeros( nu, 1 );end 




mdlrefflag = ~isempty( find_system( model, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'ModelReference' ) );


if isempty( x )
if mdlrefflag
x = sl( 'getInitialState', model );
else 
x = zeros( nxz, 1 );
end 
else 
if mdlrefflag && ~isstruct( x )
DAStudio.error( 'Simulink:tools:dlinmodv5RequireStateStruct' )
end 
end 

if isempty( para ), para = [ 0;0;0 ];end 
if para( 1 ) == 0, para( 1 ) = 1e-5;end 
if isempty( upert ), upert = para( 1 ) + 1e-3 * para( 1 ) * abs( u );end 
if isempty( xpert )
if isstruct( x )

xpert = x;

for ct = 1:length( x.signals )
xval = x.signals( ct ).values;
xpert.signals( ct ).values = para( 1 ) + 1e-3 * para( 1 ) * abs( xval );
end 
else 
xpert = para( 1 ) + 1e-3 * para( 1 ) * abs( x );
end 
end 
if length( para ) > 1
t = para( 2 );
else 
t = 0;
end 
if length( para ) < 3, para( 3 ) = 0;end 
if ~mdlrefflag && ~isstruct( x ) && length( x ) < nxz
MSLDiagnostic( 'Simulink:tools:dlinmodExtraStatesZero' ).reportAsWarning
x = [ x( : );zeros( nxz - length( x ), 1 ) ];
end 

if nxz > nx
MSLDiagnostic( 'Simulink:tools:dlinmodIgnoreDiscreteStates' ).reportAsWarning;
end 


oldx = x;oldu = u;

feval( model, [  ], [  ], [  ], 'all' );
y = struct2vect( feval( model, t, x, u, 'outputs' ) );
ny = numel( y );
dx = struct2vect( feval( model, t, x, u, 'derivs' ) );
oldy = y;olddx = dx;


A = zeros( nx, nx );B = zeros( nx, nu );C = zeros( ny, nx );D = zeros( ny, nu );

if isstruct( x )


model_struct = sl( 'getInitialState', model );
nsignals = numel( model_struct.signals );
blocknames = { model_struct.signals.blockName };
indsort = zeros( nsignals, 1 );
for ct = 1:nsignals
indsort( strcmp( x.signals( ct ).blockName, blocknames ) ) = ct;
end 
x.signals = x.signals( indsort );

oldx = x;


if ~isstruct( xpert )
DAStudio.error( 'Simulink:tools:dlinmodv5StateStructXPert' )
end 



indsort = zeros( nsignals, 1 );
for ct = 1:nsignals
indsort( strcmp( xpert.signals( ct ).blockName, blocknames ) ) = ct;
end 
xpert.signals = xpert.signals( indsort );


for ct = length( x.signals ): - 1:1
if ~isa( x.signals( ct ).values, 'double' )
x.signals( ct ) = [  ];
xpert.signals( ct ) = [  ];
end 
end 


ctr = 1;
for ct1 = 1:length( x.signals )
for ct2 = 1:length( x.signals( ct1 ).values )
xpertval = xpert.signals( ct1 ).values( ct2 );
xval = x.signals( ct1 ).values( ct2 );
x.signals( ct1 ).values( ct2 ) = xval + xpertval;

y = struct2vect( feval( model, t, x, u, 'outputs' ) );
dx = struct2vect( feval( model, t, x, u, 'derivs' ) );
A( :, ctr ) = ( dx - olddx ) ./ xpertval;
if ny > 0
C( :, ctr ) = ( y - oldy ) ./ xpertval;
end 
x = oldx;
ctr = ctr + 1;
end 
end 
else 

for i = 1:nx
x( i ) = x( i ) + xpert( i );
y = feval( model, t, x, u, 'outputs' );
dx = feval( model, t, x, u, 'derivs' );
A( :, i ) = ( dx - olddx ) ./ xpert( i );
if ny > 0
C( :, i ) = ( y - oldy ) ./ xpert( i );
end 
x = oldx;
end 
end 


for ct1 = 1:nu
u( ct1 ) = u( ct1 ) + upert( ct1 );

y = struct2vect( feval( model, t, x, u, 'outputs' ) );
dx = struct2vect( feval( model, t, x, u, 'derivs' ) );
if ~isempty( B )
B( :, ct1 ) = ( dx - olddx ) ./ upert( ct1 );
end 
if ny > 0
D( :, ct1 ) = ( y - oldy ) ./ upert( ct1 );
end 
u = oldu;
end 




if para( 3 ) == 1
[ A, B, C, ~ ] = minlin( A, B, C );
end 


if nargout == 2
disp( DAStudio.message( 'Simulink:tools:dlinmodReturningTransferFunction' ) )

[ A, B ] = feval( 'ss2tf', A, B, C, D, 1 );
end 





function x = struct2vect( xstr )

if isstruct( xstr )

for ct = length( xstr.signals ): - 1:1
if ~isa( xstr.signals( ct ).values, 'double' )
xstr.signals( ct ) = [  ];
end 
end 


nels = sum( [ xstr.signals.dimensions ] );


x = zeros( nels, 1 );


ind = 1;


for ct = 1:length( xstr.signals )
x( ind:ind + xstr.signals( ct ).dimensions - 1 ) = xstr.signals( ct ).values;
ind = ind + xstr.signals( ct ).dimensions;
end 
else 
x = xstr;
end 


function [ old_values, preloaded ] = local_push_context( models, new )


preloaded = false( numel( models ), 1 );

for ct = numel( models ): - 1:1

if isempty( find_system( 'SearchDepth', 0, 'CaseSensitive', 'off', 'Name', models{ ct } ) )
load_system( models{ ct } );
else 
preloaded( ct ) = true;
end 


old = struct( 'Dirty', get_param( models{ ct }, 'Dirty' ) );

f = fieldnames( new );
for k = 1:length( f )
prop = f{ k };
have_val = get_param( models{ ct }, prop );
want_val = new.( prop );
set_param( models{ ct }, prop, want_val );
old.( prop ) = have_val;
end 
old_values( ct ) = old;
end 


function local_pop_context( models, old, ~ )


for ct = numel( models ): - 1:1
f = fieldnames( old );
for k = 1:length( f )
prop = f{ k };
if ~isequal( prop, 'Dirty' )
set_param( models{ ct }, prop, old( ct ).( prop ) );
end 
end 

set_param( models{ ct }, 'Dirty', old( ct ).Dirty );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQmdSFb.p.
% Please follow local copyright laws when handling this file.

