function B = constructBasisMatrix(q,d)
%

% Given system order d and points on the unit disk q, construct:
% B = [q^d q^d-1 ... q^2 q 1]
%
% Inputs:
% q: [numFreqPoints 1] points on the unit disk, basis of fitting
% d: [1 1] system order

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');

assert(iscolumn(q));
B = bsxfun(@power,q,d:-1:0);
end