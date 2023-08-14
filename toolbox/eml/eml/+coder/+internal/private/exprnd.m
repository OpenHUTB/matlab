function r = exprnd(mu,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 1,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(mu,{'single','double'},{'real'},'exprnd','mu',1); %#ok<EMCA>
r = coder.internal.sxalloc(true,mu,varargin{:});
r(:) = -mu.*log(rand(size(r),class(r)));
if isscalar(mu)
    if mu(1) < 0
        r(:) = coder.internal.nan(class(r));
    end
else
    for k = 1:numel(r)
        if mu(k) < 0
            r(k) = coder.internal.nan(class(r));
        end
    end
end
