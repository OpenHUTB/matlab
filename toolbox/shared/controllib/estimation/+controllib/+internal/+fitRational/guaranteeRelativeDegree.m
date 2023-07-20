function [z,p,k] = guaranteeRelativeDegree(z,p,k,numRequestedPoles,relDeg,w,Ts)
%

% [z,p,k] = guaranteeRelativeDegree(z,p,k,relDeg,w,Ts)
%
% Ensure that user's relative degree request is satisfied.
% * Remove extra poles and zeros from the system. 
% * Ensure that we only remove the minimum necessary amount of poles/zeros.
% 
% * The fastest poles/zeros are removed from the system, with a tolerance
% looser than the one in keepAsymptotes.
% * We throw a warning if the removal is causing a larger deterioration in
% fit than this looser tolerance.
%
% Inputs:
%    z        - zeros, [Ny Nu] cell
%    p        - poles, a vector
%    k        - gain, [Ny Nu] matrix
%    numPoles - Number of requested poles, a scalar
%    relDeg   - relative degree request from user, [Ny Nu] matrix
%    w        - Frequency grid, a vector
%    Ts       - Sample time, scalar

%   Copyright 2015-2017 The MathWorks, Inc.

% Get requested number of zeros
numRequestedZeros = numRequestedPoles - relDeg;
% If requested relDeg>than model order, number of requested zeros is 0
numRequestedZeros(numRequestedZeros<0) = 0;
% Only throw 1 warning from this fcn regarding throwing out zeros/poles
didNotThrowWarning = true();

% Throw extra zeros
[Ny,Nu] = size(z);
for kkY=1:Ny
    for kkU=1:Nu
        [z{kkY,kkU},Kadjustment,didNotThrowWarning] = ...
            localRemoveExtraRoots(z{kkY,kkU},numRequestedZeros(kkY,kkU),w,Ts,didNotThrowWarning);
        k(kkY,kkU) = k(kkY,kkU) * Kadjustment;
    end % kkU:1:Nu
end % kkY:1:Ny

% Throw extra poles
[p,Kadjustment,didNotThrowWarning] = ...
    localRemoveExtraRoots(p,numRequestedPoles,w,Ts,didNotThrowWarning); %#ok<ASGLU>
k = k / Kadjustment;
end

function [r,Kadj,didNotThrowWarning] = localRemoveExtraRoots(r,n,w,Ts,didNotThrowWarning)
% Remove the fast roots in r to ensure it has maximum n elements. Calculate
% the adjustment in system gain necessary to roughly keep the 2-norm error
%
% Inputs:
%    r:  Current set of roots
%    n:  Maximum allowed number of roots
%    w:  The frequency grid
%    Ts: Sample time of the model
%    didNotThrowWarning: Variable to keep track of if we threw a warning.
%                        We want to throw only one, maximum.
%
% Outputs:
%    r:    Reduced roots, which has a maximum of n elements
%    KAdj: Adjustment
%    didNotThrowWarning: Variable to keep track of if we threw a warning.
%                        We want to throw only one, maximum.
numRootsToRemove = numel(r)-n;
if numRootsToRemove<=0
    % Nothing to do, return
    Kadj = 1;
    return;
end

% Determine the roots to be removed
if Ts==0 % Continuous-time
    % Remove fast roots that whose removal will impact the fit at the fast
    % end of freq grid less than 1e-3 (relative)
    [rRemove,wMinVec] = controllib.internal.fitRational.findFastRootsContinuous(r,1i*w(end),1e-3);
    [~,idx] = sort(wMinVec);
else % Discrete-time
    % Find large zeros (>1e3) and remove them.
    % Example: solitude_x_frd, RelDeg=1, Order=16, artificially set Ts=1e-8
    rRemove = abs(r)>1e3;
    [~,idx] = sort(r);
end

% Was it possible to remove sufficient zeros? If no, need to throw out more zeros
if nnz(rRemove)<numRootsToRemove
    % Need to throw out more
    % if didNotThrowWarning
    %    warning(message('Controllib:estimation:fitRationalRelDegFitDeterioration'));
    %    didNotThrowWarning = false();
    % end
    rRemove(:) = false();
    if any(idx)
        rRemove(idx(end+1-numRootsToRemove:end)) = true();
        if imag(r(idx(end+1-numRootsToRemove)))
            % The slowest of the 'fast root to be removed' is a complex
            % root. Check that the next element is its conjugate.
            if numRootsToRemove==1 || ...
                    imag(r(idx(end+1-numRootsToRemove)))~=-imag(r(idx(end+2-numRootsToRemove)))
                % The conjugate pair is not in the list of zeros to be
                % removed. add it.
                rRemove(idx(end-numRootsToRemove)) = true();
            end
        end
    end
end
% Remove the roots
%
% Match the gain at w(1) (as opposed to w(end) or the whole frequency range
% w). We see problems when we need to remove a zero that has a decent
% impact on the fit in the data's frequency range, and we try maintaining
% the gain at the high end of the frequency range (which is near Inf if
% relative degree is high)
if Ts==0
    polyEvalPts = 1i*w(1);
else
    polyEvalPts = exp(1i*Ts*w(1));
end
[r,Kadj] = controllib.internal.fitRational.removeFastRoots(r,rRemove,polyEvalPts);
end
