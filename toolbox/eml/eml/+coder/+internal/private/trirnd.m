function r = trirnd(a,b,c,varargin)
%MATLAB Code Generation Private Function

%   TRIRND Random arrays from the triangular distribution.

%   Copyright 1993-2014 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
eml_invariant(nargin >= 3,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(a,{'single','double'},{'real'},'trirnd','a',1); %#ok<EMCA>
validateattributes(b,{'single','double'},{'real'},'trirnd','b',2); %#ok<EMCA>
validateattributes(c,{'single','double'},{'real'},'trirnd','c',3); %#ok<EMCA>
r = coder.internal.sxalloc([true,true,true],a,b,c,varargin{:});
r(:) = rand(size(r),class(r));
for k = 1:numel(r)
    ak = eml_scalexp_subsref(a,k);
    bk = eml_scalexp_subsref(b,k);
    ck = eml_scalexp_subsref(c,k);
    if ck >= ak && ck <= bk
        bma = bk - ak;
        if bma > 0
            cma = ck - ak;
            if r(k)*bma < cma
                r(k) = ak + sqrt(r(k)*bma*cma);
            else
                r(k) = bk - sqrt((1 - r(k))*bma*(bk - ck));
            end
        else
            r(k) = ck;
        end
    else
        r(k) = coder.internal.nan(class(r));
    end
end
