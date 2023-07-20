function [Aeq,beq] = addNonTrivialityConstraint(numParams,b,beq,bineq,Aeq)
%

% Create a constraint to fix the first coefficient in the LSQ problem to 1
% to avoid trivial x=0 solution. If the trivial solution x=0 is not in the
% feasible set, this extra constraint is not added.
%
% numParams is the total number of parameters in the LSQ problem. These
% should be d+1 parameters in th denominator, and d+1 parameters for each
% numerator

%   Copyright 2015-2016 The MathWorks, Inc.

% Extra constraint is not required when any of the following is true:
%    1) If any of b is non-zero in ||A*x-b||
%    2) If any of beq is non-zero in Aeq*x=beq
%    3) If any of bineq is negative in Aineq*x<=bineq
% If all these conditions fail, then fix the leading denominator
% coefficient to 1

% Cond1) If any b is non-zero, then x=0 is not the LSQ solution
if any(b~=0)
    return;
end
if ~isempty(beq) && any(beq~=0)
    return;
end
if ~isempty(bineq) && any(bineq<0)
    return;
end

% All conditions failed. We need a constraint to get a non-trivial LSQ solution.
Aeq = [Aeq; 1 zeros(1,numParams-1)];
beq = [beq; 1];
end