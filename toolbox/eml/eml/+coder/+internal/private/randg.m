function y = randg(a,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1984-2015 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
if nargin == 0
    a = 1;
end
coder.internal.prefer_const(varargin);
validateattributes(a,{'single','double'},{'real','nonsparse'},'randg','a',1);
y = coder.internal.sxalloc(true,a,varargin{:});
for k = 1:numel(y)
    y(k) = scalar_randg(double(eml_scalexp_subsref(a,k)));
end

%--------------------------------------------------------------------------

function y = scalar_randg(a)
% Scalar RANDG.
ONE = ones('like',a);
ZERO = zeros('like',a);
ONETHIRD = cast(1/3,'like',a);
THRESH = coder.const( ...
    0.5*log(1-eps(class(a))/2)/log(eps(realmin(class(a)))));
% Note that if 0 < a < THRESH, y = 0 is a foregone conclusion, but we have
% to go through the motions or else we will not leave the global stream in
% the same state as MATLAB would have.
if a <= 0
    if a == 0
        % Zero shape returns zero.
        y = ZERO; % Note: randg(-0) --> 0.
    else
        % Negative shape returns NaN.
        y = coder.internal.nan(class(a));
    end
elseif isfinite(a) % 0 < a < Inf.
    if a >= 1
        d = a - ONETHIRD;
        u = rand(class(a)); % for rejection
        p = ONE;
    else
        % When 0 < a < 1 use gamrnd(a) = gamrnd(a+1)*unifrnd^(1/a).
        d = (a + 1) - ONETHIRD;
        ur = rand(2,1,class(a));
        u = ur(1); % for rejection
        if a < THRESH
            % Avoid overflow with small inputs so that the algorithm will
            % not rely on non-finites support.
            p = ZERO;
        else
            p = ur(2)^coder.internal.recip(a);
        end
    end
    c = coder.internal.recip(sqrt(9*d));
    iter = coder.internal.indexInt(0);
    % The following two initializations are only needed because the
    % compiler may not be convinced that these variables are assigned to on
    % all execution paths. This is because their assignments are behind
    % conditionals that cannot be constant folded unless the first
    % iteration of the loops are unrolled.
    v = ZERO;
    x = ZERO;
    reject = true;
    while reject
        v = -ONE;
        while v <= 0
            x = randn(class(a));
            v = 1 + c*x;
        end
        v = v*v*v;
        x = x*x;
        if u < (1.0 - .0331*x*x)
            reject = false;
        elseif log(u) < (0.5*x + d*(1 - v + log(v)))
            reject = false;
        else
            iter = iter + 1;
            if iter > 1000000
                coder.internal.warning('Coder:toolbox:randgIterLimitExceeded');
                reject = false;
            else
                u = rand(class(a));
            end
        end
    end
    y = d*v*p;
else % isnan(a) || a == +Inf
    % randg(Inf) --> Inf and randg(NaN) --> NaN.
    y = a;
end

%--------------------------------------------------------------------------
