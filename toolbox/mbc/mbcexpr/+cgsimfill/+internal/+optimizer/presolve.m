function [ lb, ub, Aineq, Cineq, Aeq, Ceq, exitFlag, msg ] = presolve( LB, UB, Aineq, Cineq, Aeq, Ceq )






R36
LB
UB
Aineq
Cineq
Aeq = [  ];
Ceq = [  ];
end 

options = optimset( optimset( 'fmincon' ) );
options.Display = 'none';
computeLambda = false;
makeExitMsg = true;

requestedTransforms = 2:6;


H = [  ];
f = ones( 1, size( Aineq, 2 ) )';
[ ~, ~, Aineq, Cineq, Aeq, Ceq, lb, ub, transforms, restoreData, exitFlag, msg ] =  ...
presolve( H, f, Aineq, Cineq, Aeq, Ceq, LB( : ), UB( : ), options, computeLambda, requestedTransforms, makeExitMsg );
if size( Aineq, 2 ) < restoreData.nVarOrig




A = spalloc( size( Aineq, 1 ), restoreData.nVarOrig, nnz( Aineq ) );
A( :, restoreData.varsInProblem ) = Aineq;
Aineq = A;


fullLB = zeros( 1, restoreData.nVarOrig );
fullUB = fullLB;

fixedVars = cat( 1, transforms.varIdx );
values = cat( 1, transforms.primalVals );
fullLB( fixedVars ) = values;
fullUB( fixedVars ) = values;


fullLB( restoreData.varsInProblem ) = lb;
fullUB( restoreData.varsInProblem ) = ub;

lb = fullLB;
ub = fullUB;
end 

if ~isempty( Aeq ) && size( Aeq, 2 ) < restoreData.nVarOrig

A = spalloc( size( Aeq, 1 ), restoreData.nVarOrig, nnz( Aeq ) );
A( :, restoreData.varsInProblem ) = Aeq;
Aeq = A;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpA_3Jyy.p.
% Please follow local copyright laws when handling this file.

