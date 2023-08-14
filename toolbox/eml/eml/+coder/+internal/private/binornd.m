function r = binornd(n,p,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 2,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(n,{'numeric'},{'real'},'binornd','n',1); %#ok<EMCA>
validateattributes(p,{'single','double'},{'real'},'binornd','p',2); %#ok<EMCA>
r = coder.internal.sxalloc([isfloat(n),true],n,p,varargin{:});
for k = 1:numel(r)
    nk = eml_scalexp_subsref(n,k);
    pk = eml_scalexp_subsref(p,k);
    if (0 <= pk && pk <= 1) && (0 <= nk && floor(nk) == nk)
        r(k) = 0;
        for j = 1:nk
            if rand(class(p)) < pk
                r(k) = r(k) + 1;
            end
        end
    else
        r(k) = coder.internal.nan(class(r));
    end
end
