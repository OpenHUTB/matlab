function M = applyMatrixColumnScaling(M,log2S)
%

% Scale columns of M per log2 scaling in log2S
% * M(:,k) = pow2(M(:,k), -log2S(k))
% * log2S is most likely calculated by getMatrixColumnScaling()
% * log2S must be a row vector, with as many elements as # of columns in M

%   Copyright 2018 The MathWorks, Inc.

% Quick return if matrix is empty
if isempty(M)
    return;
end

% Validate assumptions
assert(isrow(log2S));
numberOfColumns = size(M,2);
assert(numberOfColumns == size(log2S,2));

% Apply the scaling
for kk = 1:numberOfColumns
    M(:,kk) = pow2(M(:,kk), -log2S(kk));
end
end