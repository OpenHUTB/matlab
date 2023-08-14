function tf = isConjugatePair(v)
%

%   Copyright 2017 The MathWorks, Inc.

% Given vector v, if k-th element is a complex-number check if (k+1)-th
% element is its conjugate

tf = true();

if isempty(v)
    return;
end

numelV = numel(v);
kk = 1;
while kk<=numelV
    if imag(v(kk))
       % complex element. perform checks
       tf = real(v(kk))==real(v(kk+1)) & -1*imag(v(kk))==imag(v(kk+1));
       if ~tf
           % found an element without the conjugate neighbor
           return;
       end
       kk = kk+2;
    else
       % real element, no need to do anything
       kk = kk+1;
    end
end
end
