function [Aeq,beq,Aineq,bineq] = constructConstraints(fittingMethod,basisPoles,mapParams,tfNum,tfDen)
%

%   Copyright 2015-2018 The MathWorks, Inc.

if nargin<5
    tfDen = struct('Value',[],'Free',[],'Minimum',[],'Maximum',[]);
end

% Skip constructing constraints if:
% * Numerator params are free, and have +-inf bounds
% * (no denominator specification) or (all denominator params are free, and have +-inf bounds)
if all(tfNum.Free(:)) && ...
        all(isinf(tfNum.Minimum(:))) && all(isinf(tfNum.Maximum(:))) && ...
        (isempty(tfDen.Value) || (all(tfDen.Free) && all(isinf(tfDen.Minimum))) && all(isinf(tfDen.Maximum)) )
    Aeq = [];
    beq = [];
    Aineq = [];
    bineq = [];
    return;
end

tfOrder = size(tfNum.Value,1) - 1;
if isfield(mapParams,'alpha')
    tfVariable = 's';
else
    tfVariable = 'z';
end

% Get the mapping between polynomial coefficients and estimated parameters:
%    xPoly = (diag(exp(lMScale)) * M) * xEstimated
[M, lMScale] = controllib.internal.fitRational.getMapPolynomialCoefficients(...
    tfOrder,tfVariable,fittingMethod,basisPoles,mapParams);

% Select the required linear constraints
[Aeq,beq,lSeq,Aineq,bineq,lSineq] = localConstructConstraints(M,lMScale,tfNum,tfDen);

% Scale the rows of Aeq, beq, Aineq, Aineq. Embed the scaling lSeq and
% lSineq in Aeq,beq,Aineq,bineq
[Aeq,beq,Aineq,bineq] = localScaleParameterConstraints(Aeq,beq,lSeq,Aineq,bineq,lSineq);
end

function [Aeq,beq,lSeq,Aineq,bineq,lSineq] = localConstructConstraints(M,logRowScaleM,tfNum,tfDen)
% [Aeq,beq,Aineq,bineq] = localConstructConstraints(M,logRowScaleM,tfNum,tfDen)
%
% Given the mapping between fitRational parametrization of rational
% functions and polynomial representation of numerator/denominator
% coefficients (xtf = (diag(exp(logRowScaleM)))*M) * xFitRational),
% construct the linear constraints to fix or bound the transfer function
% coefficients:
%
%   diag(exp([lSeqd; lSeqn]))     * [Aeqd   0; 0 Aeqn]   * xFitRational  = [beqd; beqn]
%   diag(exp([lSineqd; lSineqn])) * [Aineqd 0; 0 Aineqn] * xFitRational <= [bineqd; bineqn]
%
% The 0 terms above are matrices of appropriate size. The terms in diag()
% are row scaling to avoid overflows in constraint matrices
%
% Inputs:
%   M:       The map between estimated coefficients and the corresponding
%            final transfer function coefficients
%   lMScale: log of the row scaling of M
%   tfNum:   A structure containing the fields 'Value', 'Free',
%            'Minimum', 'Maximum'. Similar to the param.Continuous, but
%            the parameter scaling is ignored (as of now).
%            Each field is a [numeratorLength by numberOfIOChannels] matrix. 
%            The k-th column holds the data for the k-th IO channel.
%   tfDen:   Similar to the tfNum. Since the denominator is shared across
%            all channels, structure fields are just column vectors.
%
% Outputs:
%   Aeq:    [Aeqd 0; 0 Aeqn]
%   beq:    [beqd; beqn]
%   lSeq:   log of the row scaling we need to apply to Aeq
%   Aineq:  [Aineqd 0; 0 Aineqn]
%   bineq:  [bineqd; bineqn]
%   lSineq: log of the row scaling we need to apply to Aineq
% See above for details of all output arguments.

% Select the required linear constraints
[~,Ny,Nu] = size(tfNum.Value); % Number of I/O channels
lSeqn = cell(Nu,Ny);
Aeqn = cell(Nu,Ny);
beqn = cell(Nu,Ny);
lSineqn = cell(Nu,Ny);
Aineqn = cell(Nu,Ny);
bineqn = cell(Nu,Ny);
% Fixed numerator coefficients for each channel
for kkY=1:Ny
    for kkU=1:Nu
        % Fixed parameters
        idxF = ~tfNum.Free(:,kkY,kkU);
        lSeqn{kkU,kkY} = logRowScaleM(idxF);
        Aeqn{kkU,kkY} = M(idxF,:);
        beqn{kkU,kkY} = tfNum.Value(idxF,kkY,kkU);
        % Parameter upperbounds and lowerbounds
        idxU = tfNum.Free(:,kkY,kkU) & isfinite(tfNum.Maximum(:,kkY,kkU));
        idxL = tfNum.Free(:,kkY,kkU) & isfinite(tfNum.Minimum(:,kkY,kkU));
        lSineqn{kkU,kkY} = [logRowScaleM(idxU); ...
            logRowScaleM(idxL)];
        Aineqn{kkU,kkY} = [ M(idxU,:); ...
            -M(idxL,:)];
        bineqn{kkU,kkY} = [ tfNum.Maximum(idxU,kkY,kkU); ...
            -tfNum.Minimum(idxL,kkY,kkU)];
    end
end
% When we are fitting only for numerator parameters, tfDen can
% be passed as [] here.
if isempty(tfDen.Value)
    Aeqd = [];
    beqd = [];
    lSeqd = [];
    Aineqd = [];
    bineqd = [];
    lSineqd = [];
else
    % Fixed denominator coefficients: shared across all channels
    idxF = ~tfDen.Free;
    Aeqd = M(idxF,:);
    beqd = tfDen.Value(idxF);
    lSeqd = logRowScaleM(idxF);
    % Denominator upper and lowerbounds
    idxU = tfDen.Free & isfinite(tfDen.Maximum);
    idxL = tfDen.Free & isfinite(tfDen.Minimum);
    lSineqd = [logRowScaleM(idxU); ...
        logRowScaleM(idxL)];
    Aineqd = [ M(idxU,:); ...
        -M(idxL,:)];
    bineqd = [ tfDen.Maximum(idxU);
        -tfDen.Minimum(idxL)];
end
% Combine the constraints
Aeq = blkdiag(Aeqd,Aeqn{:});
beq = vertcat(beqd,beqn{:});
lSeq = vertcat(lSeqd,lSeqn{:});
Aineq = blkdiag(Aineqd,Aineqn{:});
bineq = vertcat(bineqd,bineqn{:});
lSineq = vertcat(lSineqd,lSineqn{:});
end

function [Aeq,beq,Aineq,bineq] = localScaleParameterConstraints(Aeq,beq,lSeq,Aineq,bineq,lSineq)
% Scale the rows of Aeq, beq, Aineq, Aineq by their inf norm
if ~isempty(Aeq)
    [Aeq,beq] = localScaleAb(Aeq,beq,lSeq);
end
if ~isempty(Aineq)
    [Aineq,bineq] = localScaleAb(Aineq,bineq,lSineq);
end
end

function [A,b] = localScaleAb(A,b,lS)
% A \in R^(Nc,Np) Nc: # of constraints, Np: # of parameters
% b \in R^(Nc) 
% lS \in R^Nc
%
% We have an equation of form:
%     diag(exp(lS))*A*x=b
% Get Abar*x=bbar by row scaling. Aim: inf-norm of each row of A is 1.
% Watch out for overflow.

lAinf = log( max(abs(A),[],2) ); % inf norm of the rows of A
% Find row scaling K which will be applied as:
%  diag(exp(lK))*diag(exp(lS))*A*x = diag(exp(lK))*b

lK = -lS-lAinf;
% prevent overflow and underflow
logRealMax = log(realmax(class(A)));
lK(lK>logRealMax) = logRealMax;
%lK(lK<log(realmin)) = log(realmin);

A = A .* exp(lS+lK);
b = b .* exp(lK);
end