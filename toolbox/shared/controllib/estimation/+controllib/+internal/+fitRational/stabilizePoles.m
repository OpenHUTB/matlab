function p = stabilizePoles(p,q)
%

%   Copyright 2015-2018 The MathWorks, Inc.

% Interpolation points, i.e. the poles used to construct the bases, must be
% strictly stable for the orthogonal rational basis functions.
%
% Inputs:
%    p - Interpolation points (basis poles)
%    q - Points on the unit disk (frequency grid)
%
% Outputs:
%    p - Interpolation points (basis poles), all inside the unit disk

%#codegen
coder.allowpcode('plain');

% Reflect the unstable poles w.r.t. the unit disk
numberOfPoles = numel(p);
for kkP=1:numberOfPoles
    if abs(p(kkP))>1
        p(kkP) = 1/p(kkP);
    end
end

% Move the poles on (or too close to) the unit disk toward inside
p = controllib.internal.fitRational.pushPolesAwayFromUD(p);

% Ensure that the basis poles are within the frequency grid
[qMaxReal,qMinReal] = localGetMinMaxFreqPoints(q);
p = localEnsureBeingWithinGrid(p,qMaxReal,qMinReal);

% Extra perturbation for poles near q=+1 or q=-1
p = localEnsureDistanceFromPM1(p,qMaxReal,qMinReal);

% Sort the poles by magnitude. Slightly helpful for:
% * zpk2tf, when it's ill-conditioned:
%     load long_attas_discretized.mat Gfrd
%     Gfrd = fselect(Gfrd(1,4), 1e-2, 1e2);
%     md = tfest(Gfrd, 4, 4, 'Ts', Gfrd.Ts, 'Feedthrough', true());
%     md.Report.Fit.FitPercent % 68% -> 88%
% * c2d, when there are (near) PZ cancellations around -1. See
% tNUM_C2DLeastSquares.m, Example2 from tNUM_C2DIZF.m
p = sort(p);
end


function [qMaxReal,qMinReal] = localGetMinMaxFreqPoints(q)
% Make a single over q pass to find max(real(q)) and min(real(q))
assert(~isempty(q)); % ensure q(1) is accessible
idxMaxReal = 1;
idxMinReal = 1;
for kk = 2:numel(q)
    if real(q(kk)) > real(q(idxMaxReal))
        idxMaxReal = kk;
    end
    if real(q(kk)) < real(q(idxMinReal))
        idxMinReal = kk;
    end 
end

qMaxReal = q(idxMaxReal);
qMinReal = q(idxMinReal);
end

function pArray = localEnsureDistanceFromPM1(pArray,qMaxReal,qMinReal)
% Push the poles near +1 or -1 toward the center of the unit disk
%
% It is assumed that the all poles in p are inside the unit disk

perturbationSize = 5e-1;

% Perturbation for poles near +1
kkP = 1;
while kkP<=numel(pArray)
    % Skip if distance to -1 is greater than or equal to 1e-4    
    if abs(1-pArray(kkP))>=1e-4
        kkP = kkP + 1;
        continue;
    end
    % Perturbation
    maxAbsDelta = perturbationSize * abs(qMaxReal-pArray(kkP));
    pArray(kkP) = pArray(kkP) - maxAbsDelta; 
    % If this was a complex pole, ensure the next pole is the conjugate and
    % move two steps. Otherwise, pole was real, move one step forward.    
    if imag(pArray(kkP))~=0
        pArray(kkP+1) = conj(pArray(kkP));
        kkP = kkP + 2;
    else
        kkP = kkP + 1;
    end
end

% Perturbation for poles near -1
kkP = 1;
while kkP<=numel(pArray)
    % Skip if distance to -1 is greater than or equal to 1e-4
    if abs(1+pArray(kkP))>=1e-4
        kkP = kkP + 1;
        continue;
    end
    % Perturbation
    maxAbsDelta = perturbationSize * abs(qMinReal-pArray(kkP));
    pArray(kkP) = pArray(kkP) + maxAbsDelta; 
    % If this was a complex pole, ensure the next pole is the conjugate and
    % move two steps. Otherwise, pole was real, move one step forward.    
    if imag(pArray(kkP))~=0
        pArray(kkP+1) = conj(pArray(kkP));
        kkP = kkP + 2;
    else
        kkP = kkP + 1;
    end
end
end

function p = localEnsureBeingWithinGrid(p,qMaxReal,qMinReal)
% Perturb poles whose real part is greater than the first point on the
% frequency grid (which has the largest real part among all points)
skipIdx = real(p) <= real(qMaxReal);
p = localPolePerturbationToEnsureBeingWithinGrid(p, skipIdx, qMaxReal);

% Perturb poles whose real part is smaller than the last point on the
% frequency grid (which has the smallest real part among all points)
skipIdx = real(p) >= real(qMinReal);
p = localPolePerturbationToEnsureBeingWithinGrid(p, skipIdx, qMinReal);
end

function pArray = localPolePerturbationToEnsureBeingWithinGrid(pArray, pSkipIdx, qEndPoint)
% Perturb poles in pArray(~pSkipIdx) so that their real part is within (or
% closer) to the real part of qEndPoint
%
% All poles in the input pArray must be in the unit disk. Then the elements
% in the output are guaranteed to be in the unit disk.

% Use Tol=1e3*eps for checking if poles are in the unit disk. This is in
% line with controllib.internal.fitRational.pushPolesAwayFromUD
maxMagnitude = 1 - 1e3*eps(class(pArray));

% Iterate over the array of poles
kkP = cast(1,class(pArray));
while kkP<=numel(pArray)
    % Does this pole need to be moved? If no, move on quickly
    if pSkipIdx(kkP)
        kkP = kkP + 1;
        continue;
    end
    
    % Get the single pole
    p = pArray(kkP);
    pPerturbed = p;
    % Calculate the real perturbation (imaginary part is kept as is)
    pDelta = - sign(real(p)) * 0.5 * abs(qEndPoint - p);
    % If necessary, backtrack on perturbation size to ensure perturbed pole
    % is in the unit disk
    currentIter = 1;
    while currentIter <= 100
        pPerturbed = p + pDelta;
        if abs(pPerturbed) < maxMagnitude
            % Perturbed pole was inside the unit disk. Exit the loop
            break;
        else
            % Perturbed pole was not inside the unit disk. Backtrack
            pDelta = pDelta * 0.9;
        end
        currentIter = currentIter + 1;
    end
    % Use the perturbed pole only if it is inside the unit disk.
    if abs(pPerturbed) < maxMagnitude
        pArray(kkP) = pPerturbed;
    end
    
    % If this was a complex pole, ensure the next pole is the conjugate and
    % move two steps. Otherwise, pole was real, move one step forward.
    if imag(p)~=0
        pArray(kkP+1) = conj(pArray(kkP));
        kkP = kkP + 2;
    else
        kkP = kkP + 1;
    end
end
end

% LocalWords:  controllib
