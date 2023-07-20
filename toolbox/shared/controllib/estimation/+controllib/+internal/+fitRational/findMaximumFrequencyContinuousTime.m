function [wMaxVec,wMax] = findMaximumFrequencyContinuousTime(rVec,Tol)
%

% Given the roots of a denominator/numerator polynomial for a
% continuous-time system, find the frequency beyond which the response of
% each root (j*w-r) can be approximated well by an integrator/derivative,
% i.e. K*(j*w)
%
% Inputs:
%    rVec - Roots of the polynomial
%    Tol  - (Approximate) relative tolerance, used for how much change in
%           response of (j*w-r) is acceptable for determining wMaxVec
%
% Outputs:
%    wMaxVec - Vector with equal number of elements with rVec
%              The frequency beyond which response of (j*w-r) can be
%              approximated with K*(j*w)
%    wMax    - max(wMaxVec)

%   Copyright 2015-2017 The MathWorks, Inc.

if nargin<2
    % Default tolerance: A total 0.1% change in polynomial response is
    % acceptable. Divide this by the number of roots to get per-root Tol    
    Tol = 1e-3/numel(rVec);
end

% AAO: Assumption, estimating a model with real-valued coefficients
%
% Ensure complex-conjugate pairs are next to each other
assert(controllib.internal.fitRational.isConjugatePair(rVec));

wMaxVec = zeros(size(rVec));
kk = 1;
while kk<=numel(rVec)
    r = rVec(kk);
    if imag(r)
        % complex-conjugate pole-pair
        t = 2*Tol;
        tp = 2*t+t^2;
        tn = -2*t+t^2;
        b = 2*(imag(r)^2 - real(r)^2);
        deltaTP = sqrt(b^2+4*tp*abs(r)^4);
        deltaTN = sqrt(b^2+4*tn*abs(r)^4);
        y = [(-b+deltaTP)/tp; ...
             (-b-deltaTP)/tp; ...
             (-b+deltaTN)/tn; ...
             (-b-deltaTN)/tn] / 2;
        x = max(sqrt( y(y>0) ));
        if isempty(x)
            x = 0;
        end
        wMaxVec([kk kk+1]) = x;
        kk = kk+2; % skip the conjugate
    else
        % real pole
        wMaxVec(kk) = sqrt( r^2 / (2*Tol+Tol^2) );
        kk = kk+1;
    end
end

% Pick the fastest frequency across all roots, while paying attention to
% roots at 0 (integrators or derivatives)
if nargout>1
    % Tolerance to detect integrators/derivative terms: 1e4*eps for now
    idxRootsNotAt0 = wMaxVec>1e4*eps;
    wMax = max( wMaxVec(idxRootsNotAt0) );
    % Integrators/derivatives: If there were any, look at 1 decade forward
    % so that their effect is clearly visible on the grid
    if any(~idxRootsNotAt0)
        wMax = wMax*10;
    end
    % wMin can be [] if all roots were at 0
    if isempty(wMax)
        wMax = 1;
    end
end
end