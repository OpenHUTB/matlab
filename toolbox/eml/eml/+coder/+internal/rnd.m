function r = rnd(name,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2016 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 1,'MATLAB:minrhs');
coder.internal.prefer_const(name);
coder.internal.prefer_const(varargin);
eml_invariant(coder.internal.isConst(name),'Coder:toolbox:InputMustBeConstant','NAME');
eml_invariant(~isempty(coder.target),'Coder:toolbox:CodegenOnly');
switch coder.const(name)
    case 'betarnd'
        %betarnd - Beta random numbers.
        r = betarnd(varargin{:});
    case 'binornd'
        %binornd - Binomial random numbers.
        %Bernoulli random numbers with varargin{1} == 1.
        r = binornd(varargin{:});
    case 'exprnd'
        %exprnd - Exponential random numbers.
        r = exprnd(varargin{:});
    case 'gamrnd'
        %gamrnd - Gamma random numbers.
        r = gamrnd(varargin{:});
    case 'geornd'
        %geornd - Geometric random numbers.
        r = geornd(varargin{:});
    case 'loglrnd'
        %loglrnd -- Log-logistic random numbers.
        r = lognrnd(varargin{:});
    case 'lognrnd'
        %lognrnd - Lognormal random numbers.
        r = lognrnd(varargin{:});
    case 'normrnd'
        %normrnd - Normal (Gaussian) random numbers.
        r = normrnd(varargin{:});
    case 'poissrnd'
        %poissrnd - Poisson random numbers.
        r = poissrnd(varargin{:});
    case 'randg'
        %randg - Gamma random numbers (unit scale).
        r = randg(varargin{:});
    case 'trirnd'
        %trirnd - Triangular distribution random numbers.
        r = trirnd(varargin{:});
    case 'unidrnd'
        %unidrnd - Discrete uniform random numbers.
        r = unidrnd(varargin{:});
    case 'unifrnd'
        %unifrnd - Uniform random numbers.
        r = unifrnd(varargin{:});
    case 'wblrnd'
        %wblrnd - Weibull random numbers.
        r = wblrnd(varargin{:});
    otherwise
        r = coder.internal.nan;
end
