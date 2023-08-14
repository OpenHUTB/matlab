function [result, varargout] = multicoreFeatureOn()
%MULTICOREFEATUREON Returns true if multicore designer feature is enabled

% Copyright 2020 The MathWorks, Inc.

result = (slfeature('SLMulticore') > 0);

if nargout > 1
    varargout{1} = slfeature('SLMulticoreModelRef') > 0;
end

end