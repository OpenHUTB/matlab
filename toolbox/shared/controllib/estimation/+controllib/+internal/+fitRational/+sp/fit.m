function [lastD,solutionHistory] = ...
    fit(tfNum,tfDen,y,u,Weight,scaleStruct,lastD,mapParams,options,solutionHistory)
%

% Perform one SK iteration using standard polynomial (SP) bases.
%
% Inputs:
%   d: highest numerator or denominator order, or the # of basis fcns
%   z: points on the unit disk
%   y: y data (see fitRational help)
%   u: u data (see fitRational help)
%   Weight: Weight (see fitRational help)
%   tfNum: Structured estimation data for numerator
%   tfDen: Structured estimation data for denominator
%   solutionHistory: Struct to store the best solution so far, and the
%                    evolution of cost function
%   lastD: [Nf 1] vector, frequency response of the last estimate of D(z)
%
% Outputs:
%   np: Numerator parameters. [Ny Nu] cell, each containing [d+1 1] vectors
%   dp: Denominator parameters. [d+1 vector]
%   solutionHistory: See inputs list.

%   Copyright 2015-2018 The MathWorks, Inc.
method = 'SP';
[d,Ny,Nu] = size(tfNum.Value);
d = d-1; % d is system order

B = controllib.internal.fitRational.sp.constructBasisMatrix(mapParams.q,d);
% Construct SK matrices
estimateD = true();
estimateN = true();
isRelaxed = false();
[A,b] = controllib.internal.fitRational.constructMatrices(y,u,B,Weight,lastD,estimateD,estimateN,isRelaxed);
% Construct parameter constraints
[Aeq,beq,Aineq,bineq] = controllib.internal.fitRational.constructConstraints(method,[],mapParams,tfNum,tfDen);
[Aeq,beq] = controllib.internal.fitRational.addNonTrivialityConstraint((d+1)*(Ny*Nu+1),b,beq,bineq,Aeq);
% Solve
[x,successfulSolution] = controllib.internal.fitRational.solve(A,b,Aeq,beq,Aineq,bineq,options);
[dp,np] = controllib.internal.fitRational.unpack(x,d,Ny,Nu);
% Get the frequency response of the identified denominator. This is
% necessary for the next step.
lastD = B*dp.';
% Store the solution
if successfulSolution
    nonlinearCost = controllib.internal.fitRational.costFcn(dp,np,y,u,B,Weight,scaleStruct);
    if options.Debug
        % No need to calculate this when we are not debugging
        nonlinearJacobian = norm(controllib.internal.fitRational.costFcnJacobian(dp,np,y,u,B,Weight,scaleStruct));
    else
        nonlinearJacobian = 0;
    end
else
    % LSQ solution doesn't satisfy parameter constraints
    nonlinearCost = Inf;
    nonlinearJacobian = NaN;
end
solutionHistory = controllib.internal.fitRational.store(solutionHistory,nonlinearCost,nonlinearJacobian,method,B,dp,np,[],[]);
end
