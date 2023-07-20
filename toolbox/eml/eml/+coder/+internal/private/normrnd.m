function r = normrnd(mu,sigma,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 2,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(mu,{'single','double'},{'real'},'normrnd','mu',1); %#ok<EMCA>
validateattributes(sigma,{'single','double'},{'real'},'normrnd','sigma',2); %#ok<EMCA>
r = coder.internal.sxalloc([true,true],mu,sigma,varargin{:});
r(:) = randn(size(r),class(r));
r = r.*sigma + mu;
if isscalar(sigma)
    if sigma(1) < 0
        r(:) = coder.internal.nan(class(r));
    end    
else
    for k = 1:numel(r)
        if sigma(k) < 0
            r(k) = coder.internal.nan(class(r));
        end
    end
end
