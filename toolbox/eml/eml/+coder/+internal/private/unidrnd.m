function r = unidrnd(n,varargin)
%MATLAB Code Generation Private Function


%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 1,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(n,{'numeric'},{'real'},'unidrnd','n',1); %#ok<EMCA>
r = coder.internal.sxalloc(isfloat(n),n,varargin{:});
r(:) = rand(size(r),class(r));
for k = 1:numel(r)
    nk = eml_scalexp_subsref(n,k);
    if nk > 0 && floor(nk) == nk
        r(k) = ceil(cast(nk,class(r))*r(k));
    else
        r(k) = coder.internal.nan(class(r));
    end
end
