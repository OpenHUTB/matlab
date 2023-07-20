function r = poissrnd(lambda,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1993-2012 The MathWorks, Inc.
%#codegen

coder.allowpcode('plain');
coder.internal.errorIf(nargin < 1,'MATLAB:minrhs');
coder.internal.prefer_const(varargin);
validateattributes(lambda,{'single','double'},{'real'},'poissrnd','lambda',1); %#ok<EMCA>
r = coder.internal.sxalloc(true,lambda,varargin{:});
for k = 1:numel(r);
    lk = eml_scalexp_subsref(lambda,k);
    if lk >= 0
        if isinf(lk)
            r(k) = coder.internal.inf(class(r));
        elseif lk >= 15
            % For large lambda, use the method of Ahrens and Dieter as
            % described in Knuth, Volume 2, 1998 edition.
            r(k) = 0;
            alpha = 7/8;
            while true
                m = floor(alpha*lk);
                x = randg(m);
                if lk < x
                    if m > 1
                        r(k) = r(k) + binornd(m-1,lk/x);
                    end
                    break
                end
                lk = lk - x;
                r(k) = r(k) + m;
                if lk < 15
                    r(k) = r(k) + poissrnd_small_lambda(lk);
                    break
                end
            end
        else
            r(k) = poissrnd_small_lambda(lk);
        end
    else
        r(k) = coder.internal.nan(class(r));
    end
end

%--------------------------------------------------------------------------

function r = poissrnd_small_lambda(lambda)
% For small lambda, generate and count waiting times.
r = zeros(class(lambda));
p = -log(rand(class(lambda)));
while p < lambda
    r = r + 1;
    p = p - log(rand(class(lambda)));
end

%--------------------------------------------------------------------------
