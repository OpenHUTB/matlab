function r = loglrnd(mu,sigma,varargin)
%MATLAB Code Generation Private Function

%   LOGLRND Random arrays from the log-logistic distribution.

%   Copyright 1993-2014 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
eml_invariant(nargin >= 2,'MATLAB:minrhs');
if nargin < 1
    mu = 0;
end
if nargin < 2
    sigma = ones(class(mu));
end
coder.internal.prefer_const(varargin);
validateattributes(mu,{'single','double'},{'real'},'loglrnd','mu',1); %#ok<EMCA>
validateattributes(sigma,{'single','double'},{'real'},'loglrnd','sigma',2); %#ok<EMCA>
r = coder.internal.sxalloc([true,true],mu,sigma,varargin{:});
r(:) = rand(size(r),class(r));
for k = 1:numel(r)
    muk = eml_scalexp_subsref(mu,k);
    sigmak = eml_scalexp_subsref(sigma,k);
    if sigmak > 0
        p = r(k);
        r(k) = exp(log(p/(1 - p))*sigmak + muk);
    else
        r(k) = coder.internal.nan(class(r));
    end
end
