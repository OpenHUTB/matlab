function pVec = separatePoles(pVec)
%

% Ensure that poles in vector p are separated enough. VF basis construction
% does not yield linearly independent columns when there are repeated poles

%   Copyright 2015-2016 The MathWorks, Inc.

% Quick return base cases:
% * No poles
% * One real pole
% * Two complex-conjugate poles
if isempty(pVec) || ...
        numel(pVec)==1 || ...
        (numel(pVec)==2 && imag(pVec(1))~=0)
    return;
end

% Sort by real parts. 
[~,idx] = sort(real(pVec));
pVec = pVec(idx);

% Tolerance for comparing real and imag parts
tol = 1e-6;

% Approach:
% 1) Find sets of repeated poles
% 2) When we are certain we are done with the set, separate
%
% Initialization
pPrev = pVec(1);
if imag(pPrev) % if complex-pole
    startIdx=1; % idx of the first member of the set
    endIdx=2; % idx of the last member of the set
    kk=3; % idx of next pole
else % real pole    
    startIdx=1;
    endIdx=1;
    kk=2;
end
% Main loop
numP = numel(pVec);
while kk<=numP
    % Get the current pole. We'll compare it to the previous pole
    p = pVec(kk);
    if imag(p)
        jumpIdx=2;
    else
        jumpIdx=1;
    end
    % Two poles are equal if their:
    % * real parts match 
    % and
    % * abs(imag()) parts match
    if abs(real(p)-real(pPrev))<tol && abs(abs(imag(p))-abs(imag(pPrev)))<tol
        isUnique = false();
        endIdx = endIdx + jumpIdx;
    else
        isUnique = true();
    end

    % 2) Done with finding a set if (no more poles) or (this pole is unique)
    if kk+jumpIdx>numP || isUnique
        pVec(startIdx:endIdx) = localPerturbRepeatedPoles(pVec(startIdx:endIdx));
        startIdx = kk;
        endIdx = startIdx + jumpIdx - 1;
    end
    
    % Get ready for the next step
    kk = kk + jumpIdx;
    pPrev = p;       
end
end

function p = localPerturbRepeatedPoles(p)
% Perturb a set of nearby poles to achieve acceptable separation
% * Complex poles are just rotated
% * Real poles are pushed outwards from the origin

% Skip the first pole (or complex-conjugate pair)
if imag(p(1))
    % p may break the ordering of +- pairs. Here and below ensure the first
    % element is + imag
    p(1) = real(p(1))+1i*imag(p(1));
    p(2) = conj(p(1));
    kk = 3;
else
    kk = 2;
end
% Separate the following poles
sep = 1e-4;
while kk<=numel(p)
    pIm = imag(p(kk));
    if pIm
        % complex-conjugate pole pair
        %
        % Rotate the poles. Ensuring the rotation is always in the same
        % direction by making the first element in the pair with + imag
        p(kk) = (real(p(kk-2))+1i*abs(imag(p(kk-2))))*exp(1i*sep);
        p(kk+1) = conj(p(kk));
        kk = kk+2;
    else
        % real pole
        %
        % Move pole towards the origin. This is to avoid pushing poles
        % outside the unit disk by accident.
        p(kk) = (1-sep)*p(kk-1);
        kk = kk+1;
    end
    sep = 1.414213562373095*sep;
end
end