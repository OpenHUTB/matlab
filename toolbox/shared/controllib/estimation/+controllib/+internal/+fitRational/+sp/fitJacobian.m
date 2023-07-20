function [B,D,N,solutionHistory] = ...
    fitJacobian(tfNum,tfDen,y,u,Weight,scaleStruct,...
    lastB,lastD,lastN,mapParams,options,solutionHistory)
%

% Perform one IV iteration using fixed monomial bases.
%
% Inputs:
%   tfNum: Structured estimation data for numerator
%   tfDen: Structured estimation data for denominator
%   y: y data (see fitRational help)
%   u: u data (see fitRational help)
%   Weight: Weight (see fitRational help)
%   scaleStruct: I/O channel scaling data, from MagnitudeScaling option
%   basisPoles: Poles used for constructing lastB 
%   lastB: Basis functions from last iteration (fixed)
%   lastD: [Nf 1] vector, last estimated D(q)'s frequency response
%   lastN: Last estimated N(q)'s frequency response
%   mapParams: Domain mapping parameters
%   options: fitRationalOptions object
%   solutionHistory: Struct to store the best solution so far, and the
%                    evolution of cost function
%
% Outputs:
%   B: Basis functions utilized for the fit
%   D: Newly estimated D(q)'s frequency response
%   N: Newly estimated N(q)'s frequency response
%   solutionHistory: See the inputs list

%   Copyright 2015-2018 The MathWorks, Inc.

method = 'SP';
Ny = size(y,2);
Nu = size(u,2);
d = size(lastB,2)-1;
B = lastB; % Use the last basis functions

% Construct IV-iteration matrices
[A,b] = controllib.internal.fitRational.constructMatricesJacobian(y,u,B,Weight,lastN,lastD,lastB);
% Linear constraints on parameters
[Aeq,beq,Aineq,bineq] = controllib.internal.fitRational.constructConstraints(method,[],mapParams,tfNum,tfDen);
% Add a non-triviality constraint
[Aeq,beq] = controllib.internal.fitRational.addNonTrivialityConstraint(size(A,2),b,beq,bineq,Aeq);
% Expand LSQ matrices for Lagrange multipliers
Neqc = size(Aeq,1); % # of equality constraints
Nineqc = size(Aineq,1); % # of inequality constraints
A = [A Aeq.' Aineq.'];
Aeq = [Aeq zeros(Neqc,Nineqc+Neqc)];
Aineq = [Aineq zeros(Nineqc,Nineqc+Neqc)];
% Solve, with protection against bad matrices
if all(all(isfinite(A))) && all(isfinite(b)) && ...
        all(all(isfinite(Aeq))) && all(isfinite(beq)) && ...
        all(all(isfinite(Aineq))) && all(isfinite(bineq))
    % Scale, solve, revert scaling
    logScale = controllib.internal.fitRational.getMatrixColumnScaling(A);
    A = controllib.internal.fitRational.applyMatrixColumnScaling(A, logScale);
    Aeq = controllib.internal.fitRational.applyMatrixColumnScaling(Aeq, logScale);
    Aineq = controllib.internal.fitRational.applyMatrixColumnScaling(Aineq, logScale);
    [x,isSolutionSuccessful] = controllib.internal.fitRational.solve(A,b,Aeq,beq,Aineq,bineq,options);
    x = controllib.internal.fitRational.applyVectorElementScaling(x, logScale);
    % Remove the calculated Lagrange multipliers
    x = x(1:end-Neqc-Nineqc);
    % Unpack num, den parameters
    [dp,np] = controllib.internal.fitRational.unpack(x,d,Ny,Nu);   
    % Calculate the num, den responses for the next step
    [D,N] = controllib.internal.fitRational.getResponse(B,dp,np);
else
    D = ones(size(lastD));
    dp = [1 zeros(1,d)];
    N = cell(Ny,Nu);
    np = cell(Ny,Nu);
    for kkY=1:Ny
        for kkU=1:Nu
            N{kkY,kkU} = ones(size(lastN{kkY,kkU}));
            np{kkY,kkU} = [1 zeros(1,d)];
        end
    end
    isSolutionSuccessful = false();
end

% Calculate the nonlinear cost, store the best solution so far
if isSolutionSuccessful
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

% LocalWords: LSQ
