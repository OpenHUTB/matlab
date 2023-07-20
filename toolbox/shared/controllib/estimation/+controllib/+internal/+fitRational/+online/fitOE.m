function [dp,np,dpnpCovSqrt,identifiedPoles,yHat,isSingular] = fitOE(nb,nf,nk,y,u,w,identifiedPoles)
%

% Perform one SK iteration using orthogonal rational basis functions, for
% estimating OE (transfer function) models online.
%
% Inputs:
%    nb, nf, nk      - OE model orders
%                      nb and nk are row vectors with the same dimensions
%                      nf is a scalar
%    y               - Outputs in frequency-domain, y(w)
%                      Must be a column vector
%    u               - Inputs in frequency domain, u(w)
%                      Must have the same # of rows as u
%                      Must have the same # of columns as nb and nk
%    w               - w in u(w) and y(w)
%                      Normalized: Its values are in [0, 2*pi)
%                      Column vector. Must have the same # of rows as u
%    identifiedPoles - Identified poles from the last iteration
%
% Outputs:
%    dp              - Identified Denominator polynomial coefficients
%                      A row vector with max(nf, nb+nk-1) elements. 
%                      Any trailing zeros are not trimmed
%    np              - Identified numerator polynomial coefficients
%                      A [numberOfOutputs numberOfInputs] cell array
%                      Each cell is a max(nf, nb+nk-1) element row vector.
%                      Any trailing zeros are not trimmed
%    dpnpCovSqrt     - Square-root of the covariance of dp and np
%                      The first row and column is 0s because the leading
%                      denominator coefficient is fixed. The ordering of
%                      the parameters in this matrix is [dp; np{1}; np{2};...]
%    identifiedPoles - Roots of the denominator polynomial
%                      Must be a complex-valued column vector
%    yHat            - Output predictions in frequency domain
%    isSingular      - Was the least-squares problem singular?
%
% Assumptions:
% * Estimated coefficients are real-valued
% * w is uniformly spaced. This is a mild assumption. Violation does not
% impact correctness, but it means numerics can likely be improved by
% utilizing the disk to disk bilinear mapping in fitRational engine (which
% has no impact when w is uniformly spaced, and is skipped here)

%   Copyright 2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.internal.prefer_const(nb, nf, nk);

% Quick validation
assert(isrow(nb));
assert(isrow(nf));
assert(isscalar(nf));
assert(size(nb,2)==size(nk,2));
assert(size(nb,2)==size(u,2));
assert(iscolumn(y));
assert(size(u,1)==size(y,1));
assert(iscolumn(w));
assert(size(u,1)==size(w,1));
assert(iscolumn(identifiedPoles));

% Helper variables
basisFcnType = 'OVF';
dataType = class(y);
rfOrder = cast(recursiveEstimation.internal.rpoly.roeFiniteHistory.getRationalFcnOrder(nb,nf,nk),dataType);
Ny = size(y,2);
Nu = size(u,2);

% No weighting (yet)
Weight = ones(size(y,1), 1, dataType);

% Scale data
scaleStruct = struct(...
    'Y', ones(Ny,1,dataType),...
    'U', ones(1,Nu,dataType),...
    'YoverU', ones(Ny,Nu,dataType),...
    'Weight', cast(1,dataType));
[y, u, Weight, scaleStruct] = ...
    controllib.internal.fitRational.scaleMagnitude(y,u,Weight,scaleStruct);

% Domain mapping
%
% (u,y,w) is from DFT. Frequency points on the unit disk are uniformly
% spaced. The usual bilinear mapping in fitRational is not needed
mapParams = struct(...
    'b', cast(0,dataType),...
    'q', exp(1i*w), ...
    'mappedTs', cast(-1, 'like', y));

% Ensure basis poles are within the unit disk
basisPoles = controllib.internal.fitRational.stabilizePoles(identifiedPoles, mapParams.q);
% Construct the basis matrix
[B,basisPolesIsReal] = controllib.internal.fitRational.o.constructBasisMatrix(basisPoles, mapParams.q);
% Get |D| for 1/|D| scaling (needed only when basis poles are perturbed in 
% stabilizePoles)
lastDMag = controllib.internal.fitRational.getDenominatorScaling(mapParams.q, identifiedPoles, basisPoles);
% Construct real-valued SK iteration matrices
estimateD = true();
estimateN = true();
isRelaxed = true();
[A,b] = controllib.internal.fitRational.constructMatrices(y,u,B,Weight,lastDMag,estimateD,estimateN,isRelaxed);

% Linear constraints on TF coefficients
M = controllib.internal.fitRational.getMapPolynomialCoefficients(...
    rfOrder, 'z', basisFcnType, basisPoles, mapParams);
[Aeq, beq] = controllib.internal.fitRational.online.constructConstraintsZinvToZ(M, nb, nf, nk);

% Solve
% * Enforce real solutions
% * Use all output args to indicate A, b, Aeq, beq can be modified in place
% * xCovSqrt: sqrt of the covariance matrix E[x*x']=xCovSqrt*xCovSqrt'
Areal = [real(A); imag(A)];
breal = [real(b); imag(b)];
calculateCovariance = true();
[x, isSingular, dpnpCovSqrt, Areal, breal, Aeq, beq] = controllib.internal.fitRational.solveLSQEQR(Areal,breal,Aeq,beq,calculateCovariance); %#ok<ASGLU>

% Unpack estimation results
% * Calculate zeros of the denominator polynomial (for the next iteration)
% * Ensure leading denominator coefficient is not 0. If it is, use a small
% perturbation
[dp,np] = controllib.internal.fitRational.unpack(x,rfOrder,Ny,Nu);
identifiedPoles = localGetZeros(basisPoles, basisPolesIsReal, dp);
dp = localProtectAgainstLeadingZeroDenominatorCoefficient(B,dp);

% Revert impact of data scaling on parameters
np = localRevertDataScaling(np,scaleStruct);

% Get the predicted frequency domain response
yHat = localGetEstimatedSystemResponse(B,np,dp,u,scaleStruct);

% Final tasks:
% * Convert dp, np to OE polynomial coefficients and fix the first
% denominator coefficient to 1
% * Convert covariance of dp, np to covariance of OE polynomial coeff. and
% eliminate the first denominator coefficient
% * Ensure parameter constraints imposed by (nb, nf, nk) are honored.
% Numerical inaccuracies cause slight violations
[dp, np] = localConvertToOEPolynomialCoefficients(dp, np, M);
dpnpCovSqrt = localConvertToOEPolynomialCoefficientsCovariance(dpnpCovSqrt, M);
[dp, np] = localEnsureParameterConstraintsAreHonored(dp, np, nb, nf, nk);
end

function xCovSqrt = localConvertToOEPolynomialCoefficientsCovariance(xCovSqrt, M)
% Convert square-root covariance of OVF parameters to square-root
% covariance of OE polynomial coefficients
%
% M is the mapping xOE = M * xOVF
% * Compute xOE = blkdiag(M,M,...) * xCovSqrt
% * Eliminate the first denominator parameter

% Ensure one-to-one mapping
mSize = controllib.internal.util.indexInt(size(M,1));
assert(mSize==size(M,2));
xSize = controllib.internal.util.indexInt(size(xCovSqrt,1));
numPolynomials = xSize / mSize;
assert(numPolynomials * mSize == xSize); 

% xOE = blkdiag(M,M,...) * xCovSqrt
for kk = 1:numPolynomials
    xCovSqrt((kk-1)*mSize+(1:mSize),:) = M * xCovSqrt((kk-1)*mSize+(1:mSize),:);
end

% Eliminate the entries associated with the first denominator parameter
% because it's fixed to 1 via Schur complement
%
% (AAO optimization) To be replaced with rank-1 update on the square-root
% directly, and in-place operations
xCovSqrt = xCovSqrt * xCovSqrt';
ZERO = cast(0,'like', xCovSqrt);
if xCovSqrt(1) == ZERO
    % Nothing to eliminate, but ensure that all corresponding entries are 0
    xCovSqrt(:,1) = ZERO;
    xCovSqrt(1,:) = ZERO;
    return;
end
v = xCovSqrt(2:end,1) / sqrt(xCovSqrt(1));
xCovSqrt(2:end,2:end) = xCovSqrt(2:end,2:end) - v*v';
xCovSqrt(:,1) = ZERO;
xCovSqrt(1,:) = ZERO;
xCovSqrt = controllib.internal.util.cholSD(xCovSqrt);
end

function dp = localProtectAgainstLeadingZeroDenominatorCoefficient(B, dp)
% * Relaxed fitting may return the leading denominator coefficient as 0,
% which is not supported by the higher level estimator objects
% * Perturb the 0 coefficient, hopefully with a minimal impact on the fit
%
% Inputs:
%    B  - Set of basis functions
%    dp - Row vector of estimated denominator parameters

% Quick return if there is nothing to do
if dp(1) ~= cast(0, class(dp))
    return;
end

% Get magnitude of the denominator response
v = B * dp.';
vSignDC = sign(real(v(1)));
v = abs(v);

% Get the minimum response across all frequencies
vMin = min(v, [], 1);

% Determine perturbation size
p = real(vMin);
if p == 0
    p = eps(class(B));
else
    p = 1e-3 * p;
end

% Determine perturbation sign so that no phase change is introduced at DC
if vSignDC == cast(-1, class(vSignDC))
    p = -p;
end

% Apply the perturbation
dp(1) = p;
end

function [dp,np] = localConvertToOEPolynomialCoefficients(dp,np,M)
% Map the denominator back to monomials of z^-1
dp = dp * M.';

% The first denominator coefficient is expected to be 1
dScale = dp(1);
if dScale == cast(0, 'like', dp)
    dScale = cast(1, 'like', dp);
end

dp = dp / dScale;
for kkY = 1:size(np,1)
    for kkU = 1:size(np,2)
        % Map back to monomials of z^-1
        np{kkY,kkU} = np{kkY,kkU} * M.';
        np{kkY,kkU} = np{kkY,kkU} / dScale;
    end
end
end

function np = localRevertDataScaling(np,scaleStruct)
% Revert the impact of data scaling on numerator parameters
for kkY = 1:size(np,1)
    for kkU = 1:size(np,2)
        np{kkY,kkU} = np{kkY,kkU} * scaleStruct.YoverU(kkY, kkU);
    end
end
end

function [dp,np] = localEnsureParameterConstraintsAreHonored(dp, np, nb, nf, nk)
% Fix small constraint violations arising from minor numerical inaccuracies
%
% This function must be kept in sync with
% controllib.internal.fitRational.online.constructConstraintsZinvToZ 
%
% Summary from constructConstraintsZinvToZ:
% 1) nk leading coefficients in the numerator are 0
% 2) m-(nk+nb-1) trailing coefficients in the numerator are 0
% 3) m-nf trailing coefficients in the denominator are 0

ZERO = cast(0, class(dp));

% Numerator
for kkY = 1:size(np,1)
    for kkU = 1:size(np,2)
        % Enforce 1)
        for kk = 1:nk(kkY,kkU)
            np{kkY,kkU}(kk) = ZERO;
        end
        % Enforce 2)
        for kk = nk(kkY,kkU)+nb(kkY,kkU)+1:numel(np{kkY,kkU})
            np{kkY,kkU}(kk) = ZERO;
        end
    end
end

% Denominator. Enforce 3)
for kk = nf+2:numel(dp)
    dp(kk) = ZERO;
end
end

function z = localGetZeros(basisPoles,basisPolesIsReal,dp)
% Get a SS realization
[A,B,C,D] = controllib.internal.fitRational.o.ssRealization(basisPoles, basisPolesIsReal, dp(2:end), dp(1));

% Get zeros.
% Note: 
%   1) In codegen call, z has same length as A and is padded with Inf's
%   2) z=inf is reflected to z=0 for stability
z = ltipack.sszeroCG(A,B,C,D,[]);
for ct=1:numel(z)
   if ~isfinite(z(ct))
      z(ct) = 0;
   end
end

end

function yHat = localGetEstimatedSystemResponse(B,np,dp,u,scaleStruct)
% Calculate yHat(w) = (N1(w)*u1(w) + N2(w)*u2(w) + ...) / D(w)
%
% * k-th column of yhat holds the estimated response for k-th output
% * Inputs np, dp already has scaling reverted. Only the input signal u is
% scaled

% Allocate space
[Ny,Nu] = size(np);
yHat = complex(zeros(size(u,1),Ny,class(B)));

% Add numerator responses N(w)*u(w)
for kkY = 1:Ny
    for kkU = 1:Nu
        v = B * (np{kkY,kkU}.' * scaleStruct.U(kkY,kkU)); % N(w)
        v = v .* u(:,kkU); % N(w) * u(w)
        yHat(:,kkY) = yHat(:,kkY) + v;
    end
end

% Divide by denominator response D(w)
v = B * dp.' + realmin(class(B));
yHat = bsxfun(@rdivide, yHat, v);
end

% LocalWords:  OVF LSQ DFT controllib
