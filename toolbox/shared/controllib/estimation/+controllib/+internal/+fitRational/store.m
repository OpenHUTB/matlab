function bestSolution = store(bestSolution,nonlinearCost,nonlinearJacobian,method,B,dp,np,basisPoles,basisPolesIsReal,forceStore)
%

% Keep track of the best solution observed so far. We may 'force' storing
% a result regardless of the cost if we are enforcing stability, and the
% best solution from the fixed point iterations were unstable.

%   Copyright 2015-2018 The MathWorks, Inc.
if nargin<10
    forceStore = '';
end

bestSolution.NumberOfFits = bestSolution.NumberOfFits+1;
bestSolution.Cost(bestSolution.NumberOfFits) = nonlinearCost;
bestSolution.Jacobian(bestSolution.NumberOfFits) = nonlinearJacobian;

if strcmp(forceStore,'force') || nonlinearCost<bestSolution.BestCost
    bestSolution.BestCost = nonlinearCost;
    bestSolution.FittingMethod = method;
    bestSolution.basisPoles = basisPoles;
    bestSolution.basisPolesIsReal = basisPolesIsReal;
    bestSolution.B = B;
    bestSolution.n = np;
    bestSolution.d = dp;
end
end