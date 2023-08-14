function solutionHistory = nonlinearRefinement(tfNum,tfDen,y,u,Weight,scaleStruct,mapParams,options,solutionHistory)
%

% solutionHistory = nonlinearRefinement(tfNum,tfDen,y,u,Weight,scaleStruct,mapParams,options,solutionHistory)
%
% -Use fmincon on the original nonlinear problem
%
% -Utilize the parameters, and the basis functions that gave the
% best-so-far results

%   Copyright 2015-2018 The MathWorks, Inc.

% Note: Currently this function is not utilized. It's for future testing
% and research.
%
% Call syntax from fitRational:
% %% Nonlinear refinement
% if options.UseNonlinearSolver
%     solutionHistory = controllib.internal.fitRational.nonlinearRefinement(tfNum,tfDen,y,u,Weight,scaleStruct,mapParams,options,solutionHistory);
% end


% Pick out the best fit so far
np = solutionHistory.n;
dp = solutionHistory.d;
B = solutionHistory.B;
basisPoles = solutionHistory.basisPoles;
basisPolesIsReal = solutionHistory.basisPolesIsReal;
d = numel(basisPoles); 

[Aeq,beq,Aineq,bineq] = controllib.internal.fitRational.constructConstraints(...
    solutionHistory.FittingMethod,basisPoles,mapParams,tfNum,tfDen);

% Initial parameter guess.
x0 = [dp reshape(cell2mat(np).',1,[])].';
% Fix the first den param to 1 through linear constraints to fixing the first parameter in the denominator
x0 = x0/dp(1);
Aeq = [Aeq; 1 zeros(1,numel(x0)-1)];
beq = [beq; 1];

nonlinearCostFcn = @(x)localFminconNonlinearCostFcnWrapper(x,y,u,B,Weight,scaleStruct);
nonlinearOptimOptions = optimoptions(@fmincon,...
    'GradObj', 'on',...
    'DerivativeCheck', 'off',...
    'MaxIterations', 250, ...
    'MaxFunctionEvaluations', 500*numel(x0),...
    'Display', 'none'); % 'iter' 'none'
% 'OptimalityTolerance', 1e-9,...
% 'Algorithm', 'sqp',...
% 'DerivativeCheck', 'on',...
% 'PlotFcns',{@optimplotresnorm, @optimplotfunccount},...
% Use nonlinear constraints if EnforceStability is on
if options.EnforceStability
    nonlinearConstraintFcn = @(x)localNonlinearStabilityConstraintFcn(x,solutionHistory.FittingMethod,d,basisPoles,basisPolesIsReal);
else
    nonlinearConstraintFcn = [];
end

% AAO: fmincon works worse than lsqnonlin, but it supports linear
% equality constraints. Should we write our own GN solver that
% incorporates linear equality constraints?
% [x,resnorm,residual,exitflag,output,lambda,jacobian] = ...
[x,~,~,exitflag] = ...
    fmincon(nonlinearCostFcn,x0,...
    Aineq,bineq,... % linear inequality constraints
    Aeq,beq,... % linear equality constraints
    [],[],... % lower and upper bounds
    nonlinearConstraintFcn, ... % nonlinear constraints
    nonlinearOptimOptions);
if options.Debug
    fprintf('%s\n',exitflag.message);
end
% Unpack estimated parameters
[dp,np] = controllib.internal.fitRational.unpack(x,d,size(y,2),size(u,2));

% Calculate the new nonlinear cost. This must be the best solution
% (ideally). Store it
nonlinearCost = controllib.internal.fitRational.costFcn(dp,np,y,u,B,Weight,scaleStruct);
if options.Debug
    % No need to calculate this when we are not debugging
    nonlinearJacobian = norm(controllib.internal.fitRational.costFcnJacobian(dp,np,y,u,B,Weight,scaleStruct));
else
    nonlinearJacobian = 0;
end
solutionHistory = controllib.internal.fitRational.store(solutionHistory,nonlinearCost,nonlinearJacobian,solutionHistory.FittingMethod,B,dp,np,basisPoles,basisPolesIsReal);
end

function [J,dJ] = localFminconNonlinearCostFcnWrapper(x,y,u,B,Weight,scaleStruct)
[dp,np] = controllib.internal.fitRational.unpack(x,size(B,2)-1,size(y,2));
J = controllib.internal.fitRational.costFcn(dp,np,y,u,B,Weight,scaleStruct);
if nargout>1
    dJ = controllib.internal.fitRational.costFcnJacobian(dp,np,y,u,B,Weight,scaleStruct);
end
end

function [c,ceq] = localNonlinearStabilityConstraintFcn(x,fittingMethod,d,basisPoles,basisPolesIsReal)
dp = x(1:d+1);
switch fittingMethod
   case 'OVF'
      [A,B,C,D] = controllib.internal.fitRational.o.ssRealization(basisPoles,basisPolesIsReal,dp(2:end),dp(1));
      p = ltipack.sszeroCG(A,B,C,D,[]);
   case 'VF'
      [A,B,C,D] = controllib.internal.fitRational.b.ssRealization(basisPoles,basisPolesIsReal,dp(2:end),dp(1));
      p = ltipack.sszeroCG(A,B,C,D,[]);
   case 'SP'
      p = roots(dp);
end
% c: The distance between the unit disk and the largest magnitude pole,
% times -1. If c<0 then the system is stable.
c = max(abs(p))-1;
% no equality constraints
ceq = 0;
end

% LocalWords:  controllib
