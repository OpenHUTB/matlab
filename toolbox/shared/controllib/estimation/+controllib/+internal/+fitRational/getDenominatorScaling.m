function denResp = getDenominatorScaling(q, identifiedPoles, basisPoles)
%

% Calculate D(w) (for 1/|D| scaling) required in VF and OVF iterations when
% basis poles are chosen differently from identified poles in previous
% iteration.
%
% Inputs:
%    q               - Frequency grid (points on the unit disk)
%    identifiedPoles - Poles identified in the previous (O)VF step
%    basisPoles      - Poles that will be used for constructing basis fcns
%
% Output:
%    denMag          - Denominator freq. response  magnitude, after (O)VF
%                      coordinate change

%   Copyright 2017-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');

denResp = controllib.internal.fitRational.evaluatePolynomial(identifiedPoles,q) ./ ...
       controllib.internal.fitRational.evaluatePolynomial(basisPoles,q);
% Loop equivalent
% denResp = zeros(numel(q), 1, class(q));    
% for kkQ = 1:numel(q)
%     r = cast(1, class(q));
%     for kkP = 1:numel(identifiedPoles)
%         s = abs(q(kkQ) - identifiedPoles(kkP));
%         r = r * s;
%         s = abs(q(kkQ) - basisPoles(kkP));
%         r = r / s;
%     end    
%     denResp(kkQ) = r;
% end

% Protection against numerical issues: scale down large entries
minTol = sqrt(eps(class(q)));
maxTol = 1 / minTol;
for kkQ = 1:numel(denResp)
    dAbs = abs(denResp(kkQ));
    if ~isfinite(dAbs)
        denResp(kkQ) = cast(1, class(q));
    elseif dAbs < minTol
        denResp(kkQ) = minTol;
    elseif dAbs > maxTol
        denResp(kkQ) = maxTol;
    end
end
end
