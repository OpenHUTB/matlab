function prob = addIntVarToOptimProb( obj, prob )




























R36
obj( 1, 1 ){ mustBeA( obj, "Portfolio" ) }
prob( 1, 1 ){ mustBeA( prob, "optim.problemdef.OptimizationProblem" ) }
end 


x = prob.Variables.x;
nAssets = size( x, 1 );


lowerBound = x.LowerBound;
upperBound = x.UpperBound;

cond = false( nAssets, 1 );
if ~isempty( obj.BoundType )
cond = obj.BoundType == obj.BoundTypeCategory( 2 );
end 

if isempty( lowerBound ) || ~all( isfinite( lowerBound ) ) ||  ...
isempty( upperBound ) || ~all( isfinite( upperBound ) )
try 
[ lowerBound, upperBound, isBounded ] = obj.estimateBounds( false );
catch 


error( message( 'finance:Portfolio:addIntVarToOptimProb:IllDefinedSet' ) )
end 

if ~isBounded
error( message( 'finance:Portfolio:addIntVarToOptimProb:UnboundedProblem' ) )
elseif isempty( isBounded )
error( message( 'finance:Portfolio:addIntVarToOptimProb:InfeasibleProblem' ) )
end 
end 
lowerBound( cond ) = 0;

x.LowerBound = lowerBound;
x.UpperBound = upperBound;



v = optimvar( 'v', nAssets, 1, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1 );


cond = false( nAssets, 1 );
if ~isempty( obj.BoundType )
cond = obj.BoundType == obj.BoundTypeCategory( 2 );
end 




if ~isempty( obj.MinNumAssets )

if ~isfinite( obj.MinNumAssets )
error( message( 'finance:Portfolio:addIntVarToOptimProb:InvalidMinNumAssets' ) );
end 
if obj.MinNumAssets > 0
prob.Constraints.CardinalityLowerBound = sum( v ) >= obj.MinNumAssets;
end 
end 



if ~isempty( obj.MaxNumAssets )

if ~isfinite( obj.MaxNumAssets )
error( message( 'finance:Portfolio:addIntVarToOptimProb:InvalidMaxNumAssets' ) );
end 
if obj.MaxNumAssets < nAssets
prob.Constraints.CardinalityUpperBound = sum( v ) <= obj.MaxNumAssets;
end 
end 




if any( ~cond )
prob.Constraints.ConditionalLowerBound_SB =  ...
lowerBound( ~cond ) .* v( ~cond ) <= x( ~cond );
end 

if ~isempty( obj.LowerBound )

if any( cond & ~isfinite( obj.LowerBound ) )
error( message( 'finance:Portfolio:addIntVarToOptimProb:InvalidCondLowerBounds' ) );
end 
idx = cond & isfinite( obj.LowerBound );
if any( idx )
prob.Constraints.ConditionalLowerBound_CB =  ...
obj.LowerBound( idx ) .* v( idx ) <= x( idx );
end 
end 



prob.Constraints.ConditionalUpperBound = x <= upperBound .* v;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpkghamK.p.
% Please follow local copyright laws when handling this file.

