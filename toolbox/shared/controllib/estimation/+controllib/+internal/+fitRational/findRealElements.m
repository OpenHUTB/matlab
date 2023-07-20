function ksiIsReal = findRealElements(ksi)
%

%   Copyright 2018 The MathWorks, Inc.

% Determine the real-valued elements in ksi, with the assumption that
% complex elements in ksi must come in conjugate pairs.
%
% * ksiVector is typically calculated via eig(M) on a real-valued matrix M
% * Codegen essentially does eig(complex(M),eye(size(M)),’qz’)
% * Codegen's complex cast means there is no guarantee that M's real
% eigenvalues will have exactly 0 imaginary part. In other words, checking
% imag(pVector(idx))==0 isn't sufficient.

%#codegen
coder.allowpcode('plain');

% Pick a tolerance
absTol = 100 * eps(class(ksi));
 
% Preallocate
numPoles = controllib.internal.util.indexInt(numel(ksi));
ksiIsReal = false(numPoles, 1);

% Iterate over each pole in ksi 
% * Get the angle via atan2
% * If the angle indicates that pole is almost on the real axis, flag as real
% * If pole has angle above the tolerance, perform extra checks
ONE = controllib.internal.util.indexInt(1);
TWO = controllib.internal.util.indexInt(2);
kk = ONE;
while kk <= numPoles
    p = ksi(kk);
    pAngleAbs = abs(atan2(imag(p), real(p)));
    if pAngleAbs < absTol || (pi - pAngleAbs) < absTol
        % Real pole. Flag as such
        ksiIsReal(kk) = true();
        kk = kk + ONE;
    else
        % Complex pole. Ensure next pole is (almost) a conjugate
        if kk + ONE <= numPoles && abs(p - conj(ksi(kk + ONE))) < absTol * abs(p)
            % All good, safe to flag this and next one as complex
            ksiIsReal(kk) = false();
            ksiIsReal(kk + ONE) = false();
            kk = kk + TWO;
        else
            % Failed one of the checks. Flag as real
            ksiIsReal(kk) = true();
            kk = kk + ONE;
        end        
    end
end
end