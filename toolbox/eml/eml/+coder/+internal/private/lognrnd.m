function r = lognrnd(mu,sigma,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 2,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(mu,{'single','double'},{'real'},'lognrnd','mu',1); %#ok<EMCA>
validateattributes(sigma,{'single','double'},{'real'},'lognrnd','sigma',2); %#ok<EMCA>
r = exp(normrnd(mu,sigma,varargin{:}));