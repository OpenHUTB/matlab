function [Gd,w] = fitRationalC2D(Gc,Ts,FitOrder)
%

% Discretize an LTI via least-squares fitting
%
% Inputs:
%    Gc - Continuous-time plant
%         A tf/ss/zpk/ltipack.tfdata/ltipack.zpkdata/ltipack.ssdata object
%    Ts - Discretization sample time
%
% Outputs:
%    Gd - Discrete-time plant, a ZPK model
%    w  - The frequency grid algorithm utilized for fitting

%   Copyright 2016-2018 The MathWorks, Inc.

%% Error checking, input processing

% At least 2 inputs are required
assert(nargin>=2);

% Validate data, extract continuous-time model's ZPK
[zC,pC,kC] = localValidateAndGetZP(Gc);

% Quick return if static gain
if isempty(pC) && cellfun('isempty',zC)
    zD = zC;
    pD = pC;
    kD = kC;
    kDDen = 1;
    w = zeros(0,1);
    Gd = localConstructModel(Gc,Ts,zD,pD,kD,kDDen);
    return;
end

% Get the frequency grid from zeros/poles
w = localGetFrequencyPoints(zC,pC,Ts); % [Nf 1] column vector

% Extract the response
y = localGetContinuousTimeSystemResponse(Gc,w); % [Nf 1] column vector

% System order, relative degree, initial poles
%
% systemDescr is a [3 1] cell. 1st element is system order, 2nd element is
% relative degree, 3rd element is the initial pole guess
systemDescription = localGetSystemDescription(zC,pC,Ts,FitOrder);

% Pre-processing
% * Find and fix integrators s=0, which will be replaced with poles at z=+1
numIntegrators = localFindIntegrators(pC);
Weight = 1; % No frequency-based weighting (unless there are fixed integrators)
[y,Weight,systemDescription] = localPreprocessForFixedIntegrators(numIntegrators,Ts,w,y,Weight,systemDescription);

%% Fit
% * Use the default fitRational options
% * Do not enforce stability
u = []; % Fitting to frequency response, not (y(w),u(w))
[zD,pD,kD,kDDen] = controllib.internal.fitRational.fitRational(w,y,u,Ts,Weight,systemDescription);

%% Refit if there are pole/zero cancellations at z=1 or z=-1 (fairly common)
if ~(isempty(zD{1}) || isempty(pD))
   CANCEL = max(min(abs(zD{1}-[1 -1])),min(abs(pD-[1 -1]))) < 1e-3;
   while any(CANCEL)
      %fprintf('Refitting due to cancellation\n')
      if CANCEL(1)
         [~,imin] = min(abs(pD-1));   pD(imin,:)= [];
      end
      if CANCEL(2)
         [~,imin] = min(abs(pD+1));   pD(imin,:)= [];
      end
      systemDescription = {numel(pD);0;pD};
      [zD,pD,kD,kDDen] = controllib.internal.fitRational.fitRational(w,y,u,Ts,Weight,systemDescription);
      CANCEL = max(min(abs(zD{1}-[1 -1])),min(abs(pD-[1 -1]))) < 1e-3;
   end
end

%% Construct the model from identified zpk
Gd = localConstructModel(Gc,Ts,zD,pD,kD,kDDen);

%% Post-processing
% * Add back the integrators that were removed earlier
% * When there are integrators, make sure the gain of the systems match
% at low frequencies (w(1)/1e3 is 3 decades down from the slowest
% frequency point we chose for fitting)
Gd = localAddIntegratorsAndAdjustGain(Gd,Gc,numIntegrators,w(1)/1e3);
end


function [zCT,pCT,kCT] = localValidateAndGetZP(G)
% Inputs:
%    G - a tf/ss/zpk/ltipack.tfdata/ltipack.zpkdata/ltipack.ssdata
%
% Outputs:
%    zCT - Zeros of the model, a cell array of size [Ny Nu]
%    pCT - Poles of the model, a numeric vector

% System must be continuous-time
assert(G.Ts==0);

% Type conversion may be needed
if isa(G,'zpk') || isa(G,'tf') || isa(G,'ss')
    % Convert from user-facing objects to internal objects that are faster
    % to work with
    G = getPrivateData(G);
end
if ~isa(G,'ltipack.zpkdata')
    G = zpk(G);
end
assert(isa(G,'ltipack.zpkdata'));

% Validation
[Ny, Nu] = size(G);
% Test:
% 1) Poles in each I/O channel are the same
% 2) Poles and zeros come in complex-conjugate pairs
assert(isconjugate(G.p{1,1}));
for kkY=1:Ny
    for kkU=1:Nu
        % 1) Single set of denominator poles
        assert(isequal(G.p{1,1},G.p{Ny,Nu}));
        % 2) Zeros come in complex-conjugate pairs
        assert(isconjugate(G.z{Ny,Nu}));
    end
end

% Extract data
zCT = G.z;
pCT = G.p{1};
kCT = G.k;
end

function w = localGetFrequencyPoints(zCT,pCT,Ts)
% Given zeros and poles of a continuous-time system, pick the frequency
% grid for fitting
%
% Inputs:
%    zCT - Zeros of the continuous-time plant
%    pCT - Poles of the continuous-time plant
%    Ts  - Discretization sample-time
%
% Outputs:
%    w   - Frequency grid. Guaranteed to contain unique points that do not
%          coincide with poles of the plant

% Determine the initial set of points
wMin = localFindInterestingFrequencyRangeCT(zCT,pCT);
wMinLog = log10(wMin);
wMaxLog = log10(0.999999*pi/Ts);  
numFreqPoints = round((wMaxLog-wMinLog)*50);

% Generate points
% PG: Do not include Nyquist frequency and make sure the gap between
% the last W frequency and the Nyquist frequency is larger than the tolerance 
% in pushPolesAwayFromUD, otherwise a pole at z=-1 results in a large scaling
% 1/lastD due to the mistmatch between identified and basis poles at z=-1.
% See g1671720 for an example.
w = logspace(wMinLog, wMaxLog, numFreqPoints).';

% Ensure w does not coincide with any poles of the system
w = localCheckPolynomialRootsAndEvaluationPointsCT(w,pCT);
end

function w = localCheckPolynomialRootsAndEvaluationPointsCT(w,r)
% Perturb points in freq. grid w so that no point 1i*w is close to any r
%
% Inputs:
%   w - Frequency grid
%   r - Roots of the denominator polynomial
%
% Outputs:
%   w - New frequency grid. Guaranteed to contain unique points that do not
%       coincide with poles of the plant

% Get a tolerance for each root
rRealAbs = abs(real(r));
Tol = 1e-3 + 1e-6*rRealAbs;

% Reduce the number of roots we need to look at
%
% r with abs(real(r))>Tol are guaranteed to have more than Tol distance to
% all points in w
idx = rRealAbs<Tol;
rRed = r(idx);
if isempty(rRed)
    return;
end
Tol = Tol(idx);
% Only look at the roots with non-negative imaginary values
idx = imag(rRed)>=0;
rRed = rRed(idx);
if isempty(rRed)
    return;
end
Tol = Tol(idx);
% Now rRed only contains the roots we need to consider, and Tol is the
% tolerance for each root

% Calculate exclusion zones for all roots
rRealAbs = abs(real(rRed));
wDelta = sqrt(Tol.^2 - rRealAbs.^2);
rRedImag = imag(rRed);
wExc = [rRedImag-wDelta rRedImag+wDelta];
% Merge the intersecting exclusion zones. Loop complexity O(numel(rRed)^2)
for kk=1:numel(rRed)
    % Roots indicated by idx have intersecting bounds
    idx = wExc(kk,2)>=wExc(:,1) & wExc(kk,2)<=wExc(:,2);
    % Merge the intersecting bounds
    wExc(kk,:) = [min(wExc(idx,1)) max(wExc(idx,2))];
end
% If there were any intersection of bounds, now multiple roots are sharing
% the same exclusion bounds. Make these unique
wExc = unique(wExc,'rows');

% Move the points in w that fall within the ranges described in wExc
% * First, get a reduced portion of freq grid that is relevant to the range
% spanned by the roots. This is just to speed up calculations
% * Ensure all frequency points are outside the exclusion zone
wRelevantIdx = w>min(wExc(:,1)) & w<max(wExc(:,2));
wReduced = w(wRelevantIdx);
for kk=1:size(wExc,1)
    idx = wReduced>wExc(kk,1) & wReduced<wExc(kk,2);
    if isempty(idx)
        % No frequency points in this exclusion zone
        continue;
    end
    % There are points in the exclusion zone. Find the middle point of the
    % exclusion zone. Move the points in the zone to either to the top or
    % the bottom of the zone based on if they are above or below the
    % midpoint
    wInExcZone = wReduced(idx);
    wExcZoneMidpoint = (wExc(kk,1)+wExc(kk,2))/2;
    wInExcZone(wInExcZone<=wExcZoneMidpoint) = wExc(kk,1);
    wInExcZone(wInExcZone>wExcZoneMidpoint) = wExc(kk,2);
    wReduced(idx) = wInExcZone;
end
% Insert the relevant portion we cut out earlier from the grid
w(wRelevantIdx) = wReduced;

% Ensure the repeated points are removed. The routine above maps all points
% in the exclusion zone on top of each other, at the boundary of the zone.
w = unique(w);
end

function C = localGetSystemDescription(zCT,pCT,Ts,FitOrder)
% Construct a cell array that describes the order and relative degree of
% the desired rational function fit, along with initial pole guess.
%
% fitRational accepts a [3 1] cell array, where 1st element is # of poles,
% 2nd element is relative degree, 3rd element is the initial pole
% guess.
%
% Inputs:
%    zCT            - Zeros of the continuous-time model
%    pCT            - Poles of the continuous-time model, without integrators
%    numIntegrators - Number of integrators removed from pCT

% SISO assumption
[Ny,Nu] = size(zCT);
assert(Ny*Nu==1);
C = cell(3,1);

% # of poles
% * Choice: maximum of # of poles or zeros in the system
% * This choice introduces extra poles for improper systems, and extra
% zeros for strictly proper systems
if strcmp(FitOrder,'auto')
   % Default order
   C{1} = max(numel(pCT),numel(zCT{1}));
else
   % User-specified order
   C{1} = FitOrder;
end

% Relative degree 0
%
% Note: If we have fixed integrators, this is modified at a later stage in
% the fitting code
C{2} = 0; % relative degree

% Initial set of poles
%
% Notes: 
% * If we have fixed integrators, this is modified at a later stage in
%   the fitting code
% * Add initial pole guesses near -1 when discretizing to improper models
%   Avoid exact -1 because orthonormal rational basis functions in
%   fitRational are linearly dependent when there are repeated poles at -1
[~,is] = sort(real(pCT));
pCT = pCT(is,:);
numExtraPoles = C{1}-numel(pCT); % Positive when discretizing improper systems
pIni = [exp(pCT(1:min(end,C{1}))*Ts) ; -0.995*ones(numExtraPoles,1)];
if ~all(isfinite(pIni))
   error(message('Control:transformation:c2d02'));
end
C{3} = pIni;
end

function numIntegrators = localFindIntegrators(pCT)
% Find integrators in the continuous-time system poles pCT
idxIntegrators = abs(pCT)<1e-12;
numIntegrators = nnz(idxIntegrators);
end

function [y,Weight,systemDescription] = localPreprocessForFixedIntegrators(numIntegrators,Ts,w,y,Weight,systemDescription)
% Perform necessary modifications on data structures for performing a fit
% with fixed integrators (if there are any)
%
% Inputs:
%    numIntegrators    - # of integrators in the CT system
%    Ts                - Sample time of the discrete system
%    w                 - Frequency grid for fitting
%    y                 - CT system response on the grid w
%    Weight            - Frequency-based weight
%    systemDescription - Structure of the model to be fit. See localGetSystemDescription
%
% Outputs:
%   y                  - (Potentially modified) response to be fitted
%   Weight             - (Potentially modified) frequency-based weight
%   systemDescription  - (Potentially modified) Structure of the model to
%                        be fit

if numIntegrators
    z = exp(1i*Ts*w);
    fixedIntegratorResp = (z-1).^numIntegrators;
    y = y .* fixedIntegratorResp;
    Weight = Weight ./ fixedIntegratorResp;
    % Modify system description
    % * # of poles: equal to non-integrator poles in continuous domain
    % * Relative degree: Negative relative degree, so that after adding the
    % fixed poles the system is proper
    % * Remove the integrators from initial pole guess
    systemDescription{1} = systemDescription{1} - numIntegrators;
    systemDescription{2} = systemDescription{2} - numIntegrators;
    systemDescription{3} = localRemoveIntegratorsDiscrete(systemDescription{3},numIntegrators);
end
end


function pD = localRemoveIntegratorsDiscrete(pD,n)
% Remove n elements in pD closest to z=+1
distanceFrom1 = abs(pD-1);
[~,idx] = sort(distanceFrom1,'ascend');
idx = idx(n+1:end); % ignore the first numIntegrators terms
pD = pD(idx);
end


function Gd  = localAddIntegratorsAndAdjustGain(Gd,Gc,numIntegrators,w)
% Add poles at z=+1 for each removed integrator during pre-processing
if numIntegrators
    % Add poles at z=+1
    pD = [Gd.p{1}; ones(numIntegrators,1)];
	Gd.p = repmat({pD},size(Gd.p));
    % Ensure gain at low frequencies match between Gc and Gd
    % * The gain can be slightly off (on the order of 1e-5) because of our
    % grid choice not covering the slow end of the frequency grid enough.
    % * We cannot use w=0 because of the integrators
    % * First see the ratio of responses at w [rad/s]
    % * Compare this ratio to the ratio at w/2 [rad/s]. These two ratios
    % should be close if what we are looking at is the response of the
    % integrators.
    Ts = Gd.Ts;
    cRespSlow = evalfr(Gc,1i*w);
    dRespSlow = evalfr(Gd,exp(1i*Ts*w));
    maxIter = 20;
    isSuccessful = false();
    for kk=1:maxIter
        cResp = cRespSlow;
        dResp = dRespSlow;
        cRespSlow = evalfr(Gc,1i*w/2);
        dRespSlow = evalfr(Gd,exp(1i*Ts*w/2));
        
        respRatioReal = real(cResp/dResp);
        if isfinite(respRatioReal) && abs(1-cResp*dRespSlow/cRespSlow/dResp)<1e-8
            isSuccessful = true();
            break;
        else
            w = w/2; % try a slower frequency
        end
    end
    if isSuccessful
        Gd.k = Gd.k * respRatioReal;
    end
end
end

function y = localGetContinuousTimeSystemResponse(Gc,w)
% Extract FRD for continuous-time system on frequency grid w
y = frd(Gc,w);
y = squeeze(y.Response);
end

function Gd = localConstructModel(Gc,Ts,zD,pD,kD,kDDen)
% If the original model was a user-facing LTI-object, construct a similar
% object. Otherwise, construct an internal object.

[Ny,Nu] = size(zD);
if isa(Gc,'ss') || isa(Gc,'tf') || isa(Gc,'zpk')
    % user facing LTI model objects
    Gd = zpk(zD,repmat({pD},Ny,Nu),kD/kDDen,Ts);
else
    % Internal objects
    Gd = ltipack.zpkdata(zD,repmat({pD},Ny,Nu),kD/kDDen,Ts);
end
end

function [minW,maxW] = localFindInterestingFrequencyRangeCT(zCT,pCT)
% Given zeros zCT, poles pCT of a continuous-time system, pick the minimum
% and maximum frequency beyond which there are no interesting dynamics.
% Specifically, below minW (rad/s) and above maxW (rad/s) system dynamics
% are (approximately) either constant or have constant magnitude slope.

% Check the denominator
[~,minW] = controllib.internal.fitRational.findMinimumFrequencyContinuousTime(pCT);
[~,maxW] = controllib.internal.fitRational.findMaximumFrequencyContinuousTime(pCT);
% Check the numerator
[Ny,Nu] = size(zCT);
for kkY=1:Ny
    for kkU=1:Nu
        [~,cMinW] = controllib.internal.fitRational.findMinimumFrequencyContinuousTime(zCT{kkY,kkU});
        [~,cMaxW] = controllib.internal.fitRational.findMaximumFrequencyContinuousTime(zCT{kkY,kkU});
        minW = min(minW, cMinW);
        maxW = max(maxW, cMaxW);
    end
end
end
