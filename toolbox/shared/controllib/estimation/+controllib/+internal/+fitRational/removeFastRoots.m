function [rVec,K] = removeFastRoots(rVec,rToBeRemoved,z_or_s)
%

% Replace the roots of the polynomial in vector rVec that indexed by
% rToBeRemoved by a gain K. K is determined to (roughly) minimize the
% impact on the 2-norm nonlinear cost fcn on the range given by z_Or_s.
% z_or_s is z=exp(1i*w*Ts) or s=1i*w where w is the frequency range (a
% scalar or a vector)


%   Copyright 2015-2017 The MathWorks, Inc.

K = 1;
% Removal
if any(rToBeRemoved) 
    % Ensure that we are not removing a root at the origin
    rToBeRemoved(rVec==0) = false();
    % Adjust the gain to minimize the impact on the freq range w
    rRemove = rVec(rToBeRemoved);
    v = controllib.internal.fitRational.evaluatePolynomial(rRemove,z_or_s);
    vFinite = v(isfinite(v));
    numvFinite = numel(vFinite);
    assert(numvFinite~=0); % div by 0
    K = sum( real(vFinite)/numvFinite );
    if K==0
        K = eps;
    end
    % remove roots
    rVec(rToBeRemoved) = [];
end
end
