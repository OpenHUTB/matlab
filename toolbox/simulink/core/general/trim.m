function [ x, u, y, dx, options ] = trim( fcn, varargin )
















































supportMsg = linmodsupported( fcn );
if ~isempty( supportMsg )
error( supportMsg );
end 

load_system( fcn );




if ~isempty( find_system( fcn, 'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', 'on', 'BlockType', 'ModelReference' ) )
DAStudio.error( 'Simulink:tools:trimNotSupportedModelReference' )
end 


if ~checkSingleTaskingSolver( { fcn } )
DAStudio.error( 'Simulink:tools:dlinmodMultiTaskingSolver' );
end 


pnames = { 'Dirty', 'SimulationMode', 'InitInArrayFormatMsg' };
pnewval = { '', 'normal', 'None' };
for i = length( pnames ): - 1:1, 
poldval{ i } = get_param( fcn, pnames{ i } );
if ~isempty( pnewval{ i } ), 
set_param( fcn, pnames{ i }, pnewval{ i } );
end 
end 

try 

feval( fcn, [  ], [  ], [  ], 'lincompile' );


[ x, u, y, dx, options ] = trim_alg( fcn, varargin{ : } );
catch Ex

LocalCleanUp( fcn, pnames, poldval )
rethrow( Ex )
end 


LocalCleanUp( fcn, pnames, poldval )




function LocalCleanUp( fcn, pnames, poldval )

if strcmp( get_param( fcn, 'SimulationStatus' ), 'paused' )

feval( fcn, [  ], [  ], [  ], 'term' );
end 


for i = length( pnames ): - 1:1
set_param( fcn, pnames{ i }, poldval{ i } );
end 



function [ x, u, y, dx, options ] = trim_alg( fcn, x0, u0, y0, ix, iu, iy, dx0, idx, para, t )

[ sizes, state0 ] = feval( fcn, [  ], [  ], [  ], 'sizes' );

sizes = [ sizes( : );zeros( 6 - length( sizes ), 1 ) ];
nxz = sizes( 1 ) + sizes( 2 );nu = sizes( 4 );ny = sizes( 3 );nx = sizes( 1 );

if nxz == 0
DAStudio.error( 'Simulink:tools:trimModelMustHaveOneState' )
end 


if nargin < 2, x0 = [  ];end 
if nargin < 3, u0 = [  ];end 
if nargin < 4, y0 = [  ];end 
if nargin < 5, ix = [  ];end 
if nargin < 6, iu = [  ];end 
if nargin < 7, iy = [  ];end 
if nargin < 8, dx0 = [  ];end 
if nargin < 9, idx = [  ];end 
if nargin < 10, para = [  ];end 
if nargin < 11, t = 0;end 


if isempty( x0 ), x0 = state0;end 


if isempty( u0 ), u0 = zeros( nu, 1 );end 
if isempty( y0 ), y0 = zeros( ny, 1 );end 
if isempty( dx0 ), dx0 = zeros( sizes( 1 ), 1 );end 
if isempty( para ), para = 0;end 

if numel( dx0 ) ~= sizes( 1 )

DAStudio.error( 'Simulink:tools:trimSupportContinuousDerivatives' )
end 



if isempty( [ ix( : );iy( : );iu( : ) ] ), ix = 1:nxz;iy = 1:ny;iu = 1:nu;end 
if isempty( idx );idx = 1:nx;end 


para( 13 ) = length( idx );
para( 7 ) = 1;


x = x0;
u = u0;


feval( fcn, [  ], [  ], [  ], 'all' );
y = feval( fcn, t, x, u, 'outputs' );
gg = [ x( ix ) - x0( ix );y( iy ) - y0( iy );u( iu ) - u0( iu ) ];

lambda = max( abs( gg ) );
caller = 'trim';
[ xu, options ] = simcnstr( caller, 'trimfcn',  ...
[ x;u;lambda ], para, [  ], [  ], [  ], fcn, t, x0, u0, y0,  ...
ix, iu, iy, dx0, idx );

x = xu( 1:nxz );u = xu( nxz + 1:nxz + nu );
y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmptst87q.p.
% Please follow local copyright laws when handling this file.

