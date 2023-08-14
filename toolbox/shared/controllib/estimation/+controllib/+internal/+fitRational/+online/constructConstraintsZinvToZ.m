function [Aeq,beq] = constructConstraintsZinvToZ(M,nb,nf,nk)
%

%   Copyright 2018 The MathWorks, Inc.

% oe models in the sysid toolbox are expressed in z^-1. When performing
% estimation in terms of z, some leading and trailing coefficients of the
% numerator/denominator polynomials may need to be fixed to 0. 
%
% OE model expressed in terms of z^-1:
%    n_0*z^-(nk) + n_1*z^-(nk+1) + ... + n_(nb-1)*z^-(nb+nk-1)
%   ----------------------------------------------------
%       1        + d_1*z^-1      + ... + d_nf*z^-(nf)
%
% Let m=max(nf,nb+nk-1). The same model expressed in terms of z:
%    n_0*z^(m-nk) + n_1*z^(m-nk-1)  + ... + n_(nb-1)*z^(m-nb-nk+1)
%   ----------------------------------------------------
%       z^m       + d_1*z^(m-1)     + ... + d_nf*z^(m-nf)
%
% Summary:
% 1) nk leading coefficients in the numerator are 0
% 2) m-(nk+nb-1) trailing coefficients in the numerator are 0
% 3) m-nf trailing coefficients in the denominator are 0
%
% Inputs:
%    M - Linear mapping between the internal parametrization in fitRational
%        (xfr) and polynomials expressed in z (xz): xz = N * xfr
%    nb, nf, nk - oe model order specification
%
% Outputs:
%    Aeq, beq - Linear equality constraint matrices Aeq*xfr=beq
%
% This function must be kept in sync with the function
% localEnsureParameterConstraintsAreHonored() in fitOE

%#codegen
coder.allowpcode('plain');
coder.internal.prefer_const(nb, nf, nk);

% No multiple-output system support
assert(isrow(nb));
assert(isrow(nk));
numInputs = cast(numel(nb), 'like', nb);
assert(numel(nk)==numInputs);
assert(isscalar(nf));

% Count the number of constraints (see the description above)
nkbm1 = nk + nb - 1;
m = max(nkbm1,[],'all');
m = max(m, nf);
numberOfConstraints = sum(nk) + sum(m-nkbm1) + m - nf;

% Pre-allocation
%
% Each numerator and the denominator polynomial has size(M,2) coefficients
numPolynomials = numInputs+1;
numCoeff = cast(size(M,2), 'like', nb);
Aeq = zeros(numberOfConstraints,numCoeff*numPolynomials,'like',M);
beq = zeros(numberOfConstraints,1,'like',M);

% Start construction
rowShift = cast(0, 'like', nb);
colShift = cast(0, 'like', nb);

% Trailing coefficients in the denominator
if m~=nf
    Aeq(rowShift+(1:(m-nf)),colShift+(1:numCoeff)) = M(end-(m-nf-1):end,:);
    rowShift = rowShift + m - nf;
end
colShift = colShift + numCoeff;

for kkU=1:numInputs
    % Leading coefficients in the numerator
    if nk(kkU)>0
        for kkNK = 1:nk(kkU)
            rowShift = rowShift + 1;
            Aeq(rowShift,colShift+(1:numCoeff)) = M(kkNK,:);
        end
    end
    % Trailing coefficients in the numerator
    if m~=nkbm1(kkU)
        for kkNK = 1:m-nkbm1(kkU)
            rowShift = rowShift + 1;
            Aeq(rowShift,colShift+(1:numCoeff)) = M(end-(m-nkbm1(kkU))+kkNK,:);
        end
    end
    % Move on to the next numerator polynomial
    colShift = colShift + numCoeff;
end
end

% LocalWords:  nk nb
