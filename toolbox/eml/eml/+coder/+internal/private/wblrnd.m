function r = wblrnd(A,B,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 2,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(A,{'single','double'},{'real'},'wblrnd','A',1); %#ok<EMCA>
validateattributes(B,{'single','double'},{'real'},'wblrnd','B',2); %#ok<EMCA>
r = coder.internal.sxalloc([true,true],A,B,varargin{:});
r(:) = rand(size(r),class(r));
for k = 1:numel(r)
    Ak = eml_scalexp_subsref(A,k);
    Bk = eml_scalexp_subsref(B,k);
    if Ak >= 0 && Bk >= 0
        r(k) = Ak*(-log(r(k)))^(1/Bk);
    else
        r(k) = coder.internal.nan(class(r));
    end
end
