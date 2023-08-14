function log2S = getMatrixColumnScaling(M)
%

% Find scaling for columns of the input matrix M
% * Scaling is done with integer powers of 2
% * Lower and upper bounds on the scaling is based on M's data type
% * Lower bound ensures that there is no division by 0
% * pow2(M(:,k),-log2S(k)) makes M's k-th column have a 2-norm closer to 1

%   Copyright 2018 The MathWorks, Inc.

% Maximum and minimum scaling. This ensures protection against div by 0
if isa(M,'double')
    log2SLowerBound = -52; % eps
elseif isa(M,'single')
    log2SLowerBound = single(-23); % eps('single')
else
    assert(false());
end
log2SUpperBound = -log2SLowerBound;

% Preallocate
log2S = zeros(1,size(M,2),class(M));

% Calculate the scaling column by column
for kk = 1:numel(log2S)
    % Calculate
    log2S(kk) = norm(M(:,kk), 2);
    log2S(kk) = nextpow2(log2S(kk));
    % Apply bounds
    if log2S(kk) < log2SLowerBound
        log2S(kk) = log2SLowerBound;
    elseif log2S(kk) > log2SUpperBound
        log2S(kk) = log2SUpperBound;
    elseif isnan(log2S(kk))
        log2S(kk) = cast(0,class(M));
    end
end
end