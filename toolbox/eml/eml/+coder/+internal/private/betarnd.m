function r = betarnd(a,b,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 2,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(a,{'single','double'},{'real'},'betarnd','a',1); %#ok<EMCA>
validateattributes(b,{'single','double'},{'real'},'betarnd','b',2); %#ok<EMCA>
r = coder.internal.sxalloc([true,true],a,b,varargin{:});
for k = 1:numel(r)
    ak = eml_scalexp_subsref(a,k);
    bk = eml_scalexp_subsref(b,k);
    g1k = randg(ak);
    r(k) = g1k + randg(bk);
    if r(k) > 0
        r(k) = g1k/r(k);
    elseif ~isnan(r(k))
        pk = ak/(ak + bk);
        % r(k) = binornd(1,pk)
        if rand(class(pk)) < pk
            r(k) = 1;
        end
    end
end
