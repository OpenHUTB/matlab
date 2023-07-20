function [identifiedPoles,solutionHistory] = ...
   fit(tfNum,tfDen,y,u,Weight,scaleStruct,identifiedPoles,mapParams,options,solutionHistory)
%

% Perform one SK iteration using barycentric bases (VF)
%
% Inputs:
%   tfNum: Structured estimation data for numerator
%   tfDen: Structured estimation data for denominator
%   y: y data (see fitRational help)
%   u: u data (see fitRational help)
%   Weight: Weight (see fitRational help)
%   scaleStruct: I/O channel scaling data, from MagnitudeScaling option
%   identifiedPoles: Identified poles in the last VF iteration
%   mapParams: Domain mapping parameters
%   options: fitRationalOptions object
%   solutionHistory: Struct to store the best solution so far, and the
%                    evolution of cost function
%
% Outputs:
%   identifiedPoles: Identified poles at the end of this step
%   solutionHistory: See inputs list.

%   Copyright 2015-2018 The MathWorks, Inc.
method = 'VF';
[d,Ny,Nu] = size(tfNum.Value);
d = d-1; % d is system order

basisPoles = controllib.internal.fitRational.pushPolesAwayFromUD(identifiedPoles);
basisPoles = controllib.internal.fitRational.b.separatePoles(basisPoles);
% Construct the basis matrix
[B,basisPolesIsReal] = controllib.internal.fitRational.b.constructBasisMatrix(basisPoles,mapParams.q);
% Get |D| for 1/|D| scaling (only needed when basis poles are perturbed in
% stabilizePoles)
lastD = controllib.internal.fitRational.getDenominatorScaling(mapParams.q,identifiedPoles,basisPoles);
% Construct SK iteration matrices
estimateD = true();
estimateN = true();
isRelaxed = false();
[A,b] = controllib.internal.fitRational.constructMatrices(y,u,B,Weight,lastD,estimateD,estimateN,isRelaxed);
% Linear constraints on parameters
[Aeq,beq,Aineq,bineq] = controllib.internal.fitRational.constructConstraints(method,basisPoles,mapParams,tfNum,tfDen);
[Aeq,beq] = controllib.internal.fitRational.addNonTrivialityConstraint((d+1)*(Ny*Nu+1),b,beq,bineq,Aeq);
% Solve
[x,successfulSolution] = controllib.internal.fitRational.solve(A,b,Aeq,beq,Aineq,bineq,options);
[dp,np] = controllib.internal.fitRational.unpack(x,d,Ny,Nu);
% Calculate zeros of the denominator polynomial
[Ap,Bp,Cp,Dp] = controllib.internal.fitRational.b.ssRealization(basisPoles,basisPolesIsReal,dp(2:end),dp(1));
identifiedPoles = ltipack.sszeroCG(Ap,Bp,Cp,Dp,[]);
% Calculate the nonlinear cost, store the best solution so far
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
solutionHistory = controllib.internal.fitRational.store(solutionHistory,nonlinearCost,nonlinearJacobian,method,B,dp,np,basisPoles,basisPolesIsReal);
end

% LocalWords:  LSQ
