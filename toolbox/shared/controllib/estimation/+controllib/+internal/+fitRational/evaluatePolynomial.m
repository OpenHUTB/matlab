function f = evaluatePolynomial(r,qs)
%

% f = evaluatePolynomial(r,qs)
%
% Polynomial f(q)=(q-r(1))*(q-r(2))*... maps C^1 to C^1, where r are
% the roots. Evaluate f(q) at multiple points provided in qs \in C^N.
% The output is always a column vector.

%   Copyright 2016-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');

% Evaluate the polynomial. Compact form of the result is f=prod(qs-r,2)
%
% If there are no roots, the result is the constant leading coefficient of
% f(q). This is 1 by the definition above.
f = complex(ones(numel(qs),1,class(qs)));
for kkQ=1:numel(qs)   
    for kkR=1:numel(r)
        f(kkQ) = f(kkQ) * (qs(kkQ)-r(kkR));
    end
end
end