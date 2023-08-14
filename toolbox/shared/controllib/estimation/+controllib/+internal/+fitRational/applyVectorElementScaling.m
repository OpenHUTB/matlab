function v = applyVectorElementScaling(v,log2S)
%

% Scale of elements of vector v, per log2 scaling in log2S
% * v(k) = pow2(v(k), -log2S(k))
% * log2S is most likely calculated by getMatrixColumnScaling()
% * log2S and v must be vectors with the same number of elements

%   Copyright 2018 The MathWorks, Inc.

% Validate assumptions
assert(isvector(v));
assert(isvector(log2S));
numberOfElements = numel(v);
assert(numberOfElements == numel(log2S));

% Apply the scaling
for kk = 1:numberOfElements
    v(kk) = pow2(v(kk), -log2S(kk));
end
end