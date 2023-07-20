function r = gamrnd(a,b,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 2,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(a,{'single','double'},{'real'},'gamrnd','a',1); %#ok<EMCA>
validateattributes(b,{'single','double'},{'real'},'gamrnd','b',2); %#ok<EMCA>
r = coder.internal.sxalloc([true,true],a,b,varargin{:});
r(:) = b.*randg(a,size(r));
if isscalar(b)
    if b(1) < 0
        r(:) = coder.internal.nan(class(r));
    end
else
    for k = 1:numel(b)
        if b(k) < 0
            r(k) = coder.internal.nan(class(r));
        end
    end
end
