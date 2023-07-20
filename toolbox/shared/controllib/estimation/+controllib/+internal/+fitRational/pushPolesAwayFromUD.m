function p = pushPolesAwayFromUD(p)
%

% VF can run into trouble (0/0 expressions) when one of the poles p coincides
% with or gets too close to one of the unit-circle z values where we perform 
% the fit.

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
tol = sqrt(eps(class(p)));

for kkP=1:numel(p)
    absP = abs(p(kkP));
    if absP>1 && absP<1+tol
        % Push unstable poles close to the unit disk outwards
        p(kkP) = ((1+tol)/absP)*p(kkP);
    elseif absP<=1 && absP>1-tol
        % Push stable and marginally stable poles inwards
        p(kkP) = ((1-tol)/absP)*p(kkP);
    end    
end