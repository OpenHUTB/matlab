function r = unifrnd(a,b,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 2,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(a,{'single','double'},{'real'},'unifrnd','a',1); %#ok<EMCA>
validateattributes(b,{'single','double'},{'real'},'unifrnd','b',2); %#ok<EMCA>
r = coder.internal.sxalloc([true,true],a,b,varargin{:});
r(:) = 2*rand(size(r),class(r)) - 1;
for k = 1:numel(r)
    ak = eml_scalexp_subsref(a,k)/2;
    bk = eml_scalexp_subsref(b,k)/2;
    if bk >= ak
        mu = ak + bk;
        sig = bk - ak;
        r(k) = mu + sig*r(k);
    else
        r(k) = coder.internal.nan(class(r));
    end
end
