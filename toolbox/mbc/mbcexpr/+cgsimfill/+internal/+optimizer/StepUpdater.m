classdef StepUpdater < cgsimfill.internal.optimizer.OptimizerInterface




properties 

Gradient = 0;

LearningRate = 0.001;
end 

properties ( Dependent, SetAccess = private )

NormGradient
end 

methods 
function n = get.NormGradient( obj )

n = norm( obj.Gradient );
end 


function dx = projectBox( obj, x, dx )
















lb = obj.Bounds( :, 1 );
ub = obj.Bounds( :, 2 );

if ~isreal( x )
return 
end 











trialX = x( : ) + dx( : );
activeLB = isfinite( lb ) & trialX < lb;
activeUB = isfinite( ub ) & trialX > ub;
dx( activeLB ) = lb( activeLB ) - x( activeLB );
dx( activeUB ) = ub( activeUB ) - x( activeUB );

end 

function initialize( obj, LS )
[ obj.LearningRate ] = deal( LS.StepSize );
end 
end 

methods ( Static )
function obj = create( type )



R36
type( 1, 1 )string{ mustBeMember( type, [ "SecondOrder", "ADAM", "EigenSolver", "TrustRegionReflective" ] ) } = "SecondOrder"
end 

switch type
case 'SecondOrder'
obj = cgsimfill.internal.optimizer.SecondOrderUpdater;
case 'ADAM'
obj = cgsimfill.internal.optimizer.AdamStepUpdater;
case 'EigenSolver'
obj = cgsimfill.internal.optimizer.EigenSolverUpdater;
case 'TrustRegionReflective'
obj = cgsimfill.internal.optimizer.TrustRegionReflective;
end 

end 

function [ list, names ] = stepUpdaterList

list = { 'ADAM', 'SecondOrder', 'EigenSolver', 'TrustRegionReflective' };
names = { 'ADAM', 'Nonlinear least squares', 'Eigenvalue analysis-based optimization scheme', 'Analytic Hessian (slow)' };
end 

function [ J, g ] = reduce( J, e )
start = 1;
[ n, m ] = size( J );
step = ceil( max( max( 100 * m, 10 * n / m ), 1e6 ) );
if step < n && 2 * step > n
step = ceil( n / 2 );
end 
finish = 0;
Jred = [  ];
g = zeros( m, 1 );
while finish < n

finish = min( start + step, n );
Ji = J( start:finish, : );
g = g - Ji' * e( start:finish );
R = cgsimfill.internal.optimizer.StepUpdater.squareRDecomposition( Ji );
Jred = [ Jred;R ];%#ok<AGROW>
start = finish + 1;
end 

J = sparse( Jred );
end 

function ok = needsReduction( J )




[ n, m ] = size( J );

ok = n >= 1000 * m || ( m > 3000 && n >= 100 * m );
if ok && issparse( J )

ok = nnz( J ) / numel( J ) > 0.3 || nnz( J ) > 10 * m;
end 
end 

function [ R, OK ] = squareRDecomposition( J )


if issparse( J ) && ( nnz( J ) / numel( J ) < 0.1 || numel( J ) >= 5e5 )

R = qr( J, 0 );
else 

R = qr( full( J ), 0 );
end 


rd = abs( diag( R ) );
tol = length( J ) * eps * max( rd );
if tol == 0
tol = eps;
end 
OK = ~( size( R, 2 ) > size( J, 1 ) || any( rd < tol ) ) && allfinite( R );
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWOquFV.p.
% Please follow local copyright laws when handling this file.

