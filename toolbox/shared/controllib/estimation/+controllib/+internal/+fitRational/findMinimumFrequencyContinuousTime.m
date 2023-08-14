function [wMinVec,wMin] = findMinimumFrequencyContinuousTime(rVec,Tol)
%

% Given the roots of a numerator or denominator polynomial for a
% continuous-time system, find the slowest frequency before which the
% frequency response from each root in rVec does not change much.
%
% Inputs:
%    rVec - Roots of the polynomial
%    Tol  - (Approximate) relative tolerance, used for how much change in
%           response of (j*w-r) is acceptable for determining wMinVec
%
% Outputs:
%    wMinVec - Vector with equal number of elements with rVec
%              The frequency below which response of (j*w-r) can be
%              approximated with a constant gain
%    wMin    - min(wMinVec), but with special handling of roots at r=0

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

wMinVec = zeros(size(rVec));
kk = 1;
while kk<=numel(rVec)
    r = rVec(kk);
    if imag(r)
        % complex-conjugate pole-pair
        t = 8*Tol*abs(r)^4;
        b = 2*(imag(r)^2 - real(r)^2);
        y = [b+sqrt(b^2-t); ...
            b-sqrt(b^2-t); ...
            b+sqrt(b^2+t); ...
            b-sqrt(b^2+t)]/2;
        x = min(sqrt( y(y>0) ));
        if isempty(x)
            x = Inf;
        end
        wMinVec([kk kk+1]) = x;
        kk = kk+2; % skip the conjugate
    else
        % real pole
        wMinVec(kk) = sqrt(2*Tol*r^2);
        kk = kk+1;
    end
end

% Pick the slowest frequency across all roots, while paying attention to
% roots at 0 (integrators or derivatives)
if nargout>1
    % Tolerance to detect integrators/derivative terms: 1e4*eps for now
    idxRootsNotAt0 = wMinVec>1e4*eps;
    wMin = min( wMinVec(idxRootsNotAt0) );
    % Integrators/derivatives: If there were any, look at 1 decade back so
    % that their effect is clearly visible on the grid
    if any(~idxRootsNotAt0)
        wMin = wMin/10;
    end
    % wMin can be [] if all roots were at 0
    if isempty(wMin)
        wMin = 1e-1;
    end
end
end