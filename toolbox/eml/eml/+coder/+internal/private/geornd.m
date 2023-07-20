function r = geornd(p,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 1,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(p,{'single','double'},{'real'},'geornd','p',1); %#ok<EMCA>
r = coder.internal.sxalloc(true,p,varargin{:});
r(:) = rand(size(r),class(r));
for k = 1:numel(r)
    pk = eml_scalexp_subsref(p,k);
    if pk > 0 && pk <= 1
        r(k) = ceil(log(r(k))/log(1 - pk) - 1);
        if r(k) < 0
            r(k) = 0;
        end
    else
        r(k) = coder.internal.nan(class(r));
    end
end

