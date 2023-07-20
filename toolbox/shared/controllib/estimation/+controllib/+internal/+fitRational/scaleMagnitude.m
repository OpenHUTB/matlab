function [y,u,Weight,scaleStruct] = scaleMagnitude(y,u,Weight,scaleStruct)
%

% Center the magnitude of u, y, Weight around 0dB

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');

% Scale columns of y
for kkY=1:size(y,2)
    scaleStruct.Y(kkY) = localGetScaleFactor(y(:,kkY));
    y(:,kkY) = y(:,kkY) / scaleStruct.Y(kkY);
end
% Scale columns of u
for kkU=1:size(u,2)
    scaleStruct.U(kkU) = localGetScaleFactor(u(:,kkU));
    u(:,kkU) = u(:,kkU) / scaleStruct.U(kkU);
end
scaleStruct.YoverU = scaleStruct.Y ./ scaleStruct.U;
% Scale the weight
%
% Weight matrix must be scaled all at once (instead of column by column) so
% that weighting across different channels are not destroyed
scaleStruct.Weight = localGetScaleFactor(Weight);
Weight = Weight / scaleStruct.Weight;
end

function [maxAbs,minAbs] = localFindAbsoluteMinMaxIgnoreZero(X)
% Find maxAbs = max(abs(X),[],'all') and minAbs = min(abs(X),[],'all')
% 
% * X must have at least one element.
% * 0 elements in abs(X) are ignored. Unless all elements in X are 0,
% maxAbs and minAbs are not 0.

assert(numel(X) > 0);

% Initialize
maxAbs = -inf(class(X));
minAbs = inf(class(X));
% Single pass over X
for kkE = 1:numel(X)
    absElement = abs(X(kkE));
    % Ignore 0 elements
    if absElement == 0
        continue;
    end
    % Update min and max values, if necessary
    if absElement > maxAbs
        maxAbs = absElement;
    end
    if absElement < minAbs
        minAbs = absElement;
    end
end
% Handle edge case: All elements in X are 0
if maxAbs == -inf(class(X))
    maxAbs = cast(0,class(X));
end
if minAbs == inf(class(X))
    minAbs = cast(0,class(X));
end
end

function s = localGetScaleFactor(X)
% Get a scale factor s so that X/s has elements balanced around 1
%
% s is guaranteed to be nonzero

% Find the max and min magnitude elements in the matrix
[maxAbs, minAbs] = localFindAbsoluteMinMaxIgnoreZero(X);

% Calculate the scale factor
assert(maxAbs >= 0);
assert(minAbs >= 0);
s = sqrt(maxAbs*minAbs + realmin(class(X)));
end