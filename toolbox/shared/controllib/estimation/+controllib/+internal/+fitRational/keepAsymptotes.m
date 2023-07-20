function [z,p,k] = keepAsymptotes(z,p,k,canDiscardZ,canDiscardP,w,Ts)
%

% [z,p,k] =  keepAsymptotes(z,p,k,canDiscardZ,canDiscardP,w,Ts)
%
% Remove the fast and slow poles&zeros of the system outside the frequency
% grid of the data. These are likely to be spurious poles/zeros caused
% either by noisy data, or solver inaccuracies. Keep an eye on if user
% specified any constraints on the numerator or denominator.
%
% Implemented only for continuous-time models.
%
% Inputs:
%    z           - Zeros, [Ny Nu] cell, each with (1+d)-vectors
%    p           - Poles, (1+d)-vector
%    k           - Gain, [Ny Nu] matrix
%    canDiscardZ - Is it safe to discard zeros? [Ny Nu] logical
%    canDiscardP - Is it safe to discard poles? Scalar logical
%    w           - Frequency grid of the data
%    Ts          - Sample time

%   Copyright 2015-2017 The MathWorks, Inc.

zRemoveTol = 1e-4;
[Ny,Nu] = size(z);

if Ts==0
    % Continuous-time model
    %
    % 1) Find poles and zeros slower than wMin. Replace them with s=jw.
    % Adjust gain so that the magnitude at wMin is the same of before.
    % 2) Find poles and zeros faster than wMax. Remove them. Adjust
    % gain so that magnitude at wMax is the same of before.
    
    % Find&remove fast&slow zeros in each channel
    s = 1i*w;
    for kkY=1:Ny
        for kkU=1:Nu
            % Skip removing zeros if there are any constraints
            if ~canDiscardZ(kkY,kkU)
                continue;
            end                   
            % Find and replace the slow zeros with a derivative
            zRemove = localFindSlowRootsContinuous(z{kkY,kkU},s(1),zRemoveTol);
            [z{kkY,kkU},Kadjustment] = localRemoveSlowRootsContinuous(z{kkY,kkU},zRemove,s);
            k(kkY,kkU) = k(kkY,kkU) * Kadjustment; % Adjust K only for this channel when changing the numerator
            % Find and remove the fast zeros
            zRemove = controllib.internal.fitRational.findFastRootsContinuous(z{kkY,kkU},s(end),zRemoveTol);
            [z{kkY,kkU},Kadjustment] = controllib.internal.fitRational.removeFastRoots(z{kkY,kkU},zRemove,s);
            k(kkY,kkU) = k(kkY,kkU) * Kadjustment;
        end
    end
    if canDiscardP
        % Find and replace the slow poles with an integrator
        zRemove = localFindSlowRootsContinuous(p,s(1),zRemoveTol);
        [p,Kadjustment] = localRemoveSlowRootsContinuous(p,zRemove,s);
        k = k / Kadjustment;
        % Find and remove the fast poles
        zRemove = controllib.internal.fitRational.findFastRootsContinuous(p,s(end),zRemoveTol);
        [p,Kadjustment] = controllib.internal.fitRational.removeFastRoots(p,zRemove,s);
        k = k / Kadjustment;
    end
else
    % AAO: Implement this option for discrete time
    % warning('KeepAsymptotes is not implemented yet for discrete-time FRD');
end
end

function rRemove = localFindSlowRootsContinuous(rVec,sCutoff,Tol)
% zKeep = localFindSlowRootsContinuous(zVec,wCutoff,Tol)
%
% Inputs:
%    rVec:    Roots of a polynomial p(s), where s=jw
%    sCutoff: sCutoff=1i*wCutoff. Roots in rVec that can be well 
%             approximated by s beyond wCutoff (rad/s) will be indicated in
%             rRemove
%    Tol:     Maximum allowed relative deviation in magnitude at wCutoff
%             between s and s-rVec(...)
%
% Outputs:
%    rRemove: Indices of zeros in rVec that can be approximated well with
%             just s beyond wCutoff
wMaxVec = controllib.internal.fitRational.findMaximumFrequencyContinuousTime(rVec,Tol);
rRemove = wMaxVec<imag(sCutoff);
end

function [rVec,K] = localRemoveSlowRootsContinuous(rVec,rToBeRemoved,s)
% Replace the roots in rVec indexed by rToBeRemoved with 0. Adjust the gain
% to (roughly) minimize the impact on the 2-norm nonlinear cost fcn

K = 1;

if any(rToBeRemoved)
    rRemove = rVec(rToBeRemoved); % roots to be removed
    numRemove = numel(rRemove); % # of roots to be removed

    v1 = s.^numRemove;
    v2 = controllib.internal.fitRational.evaluatePolynomial(rRemove,s);
    % a few safeguards
    v1(~isfinite(v1)) = 0;
    v2(~isfinite(v2)) = 0;
    v1NormSq = max(norm(v1)^2, eps);
    % calculate the necessary adjustment
    K = real((v1'/ v1NormSq) * v2);
    % one last safeguard, K cannot be 0
    if K==0
        K = eps;
    end
    
    rVec(rToBeRemoved) = 0;
end
end