function solutionHistory = ...
   fitNum(tfNum,y,u,Weight,scaleStruct,denPoles,mapParams,options,solutionHistory)
%

% Fit the numerator of a rational function with the given denominator poles
% (denPoles) using VF formulation. For a simple SISO fitting:
%       minimize || W * (N/D u - y) || by choosing N
% Express N and D in terms of the orthogonal polynomials formed by poles b.
% Then: 
%       minimize || W * ( (N/B)/(D/B) u - y) ||
% First calculate the response dOverb=D/B, then solve two LSQ problems to
% get the parameters for the numerator and the denominator

%   Copyright 2015-2018 The MathWorks, Inc.

method = 'VF';
[d,Ny,Nu] = size(tfNum.Value);
d = d-1; % d is system order

basisPoles = controllib.internal.fitRational.pushPolesAwayFromUD(denPoles);
basisPoles = controllib.internal.fitRational.b.separatePoles(basisPoles);
[B,basisPolesIsReal] = controllib.internal.fitRational.b.constructBasisMatrix(basisPoles,mapParams.q);
% Get |D| for 1/|D| scaling (only needed when poles are perturbed)
lastD = controllib.internal.fitRational.getDenominatorScaling(mapParams.q,denPoles,basisPoles);
% Get parameter constraints. Note that we don't need non-triviality constrains
[Aeq,beq,Aineq,bineq] = controllib.internal.fitRational.constructConstraints(method,basisPoles,mapParams,tfNum);
% Construct matrices for the SK iteration
estimateD = false();
estimateN = true();
isRelaxed = false();
[A,b] = controllib.internal.fitRational.constructMatrices(y,u,B,Weight,lastD,estimateD,estimateN,isRelaxed);
% Solve
[x,successfulSolution] = controllib.internal.fitRational.solve(A,b,Aeq,beq,Aineq,bineq,options);
np = controllib.internal.fitRational.unpackNum(x,d,Ny,Nu);
% Fit to the denominator polynomial
dp = controllib.internal.fitRational.solve(B,lastD,[],[],[],[],options).';
% Sanity check:
% controllib.internal.fitRational.o.getZeros(basisPoles,dp(2:end),dp(1),options.UseCtrlToolboxFcns)
% must yield denPoles

% Calculate the cost, and store the solution. We call fit with fixed poles
% under two conditions:
% 1) Initial fit
% 2) Enforcing stability
% Both cases require storing the solution for sure as the 'best'
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
solutionHistory = controllib.internal.fitRational.store(solutionHistory,nonlinearCost,nonlinearJacobian,method,B,dp,np,basisPoles,basisPolesIsReal,'force');
end

% LocalWords:  Overb LSQ controllib dp