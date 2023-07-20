function hasConverged = hasConverged(solutionHistory,zNorm,Tol)
%

% localHasConverged Check if the SK iteration converged based on the
% history of the LSQ condition numbers.
%
% solutionHistory.Cost is a vector that holds the current&past
% nonlinear cost function values.
%
% zNorm is ||z||_2 where z is the measured frequency response
%
% n is the index for the current iteration step

%   Copyright 2015-2016 The MathWorks, Inc.

% Terminate if the nonlinear cost function is too small relative to the
% zNorm, or if the cost has not been changing over alst 2 iterations.

if nargin<3
    Tol = 1e-3;
end

c = solutionHistory.Cost;
n = solutionHistory.NumberOfFits;

hasConverged = (c(n)/zNorm<eps) || ... % 'perfect' fit
    (n>2 && all( abs(diff(c(n-2:n))) ./ abs(c(n-2:n-1)) < Tol )) || ...
    (n>2 && all(~isfinite(c(n-2:n))) ); % last 3 fits have non-finite cost
end