function [z,p,k,kDen] = fitRational(w,y,u,Ts,Weight,sysOrder,optObject)
%

% [z,p,k,kDen] = fitRational(w,y,u,Ts,Weight,sysOrder,options)
%
% Fit a rational polynomial to complex data.
%
% w: [Nf 1] real frequency vector. Nf: # of freq points
% y: [Nf Ny] complex output data. Ny: # of outputs
% u: [Nf Nu] complex input data. Nu: # of inputs
% Ts: Sample time of the desired model (-1 is not permitted)
% Weight: Complex weight. Must be one of the following
%            -Empty (assumed to be 1)
%            -Scalar (assumed to be 1)
%            -[Nf 1] (expanded to [Nf Ny] automatically)
%            -[Nf Ny]
% sysOrder: Must be one of the following:
%             -Scalar: System order. Relative degree is assumed to be 0
%             -Cell: 1-3 elements. The 1st is the denominator order, the
%                    2nd is the relative degree, the 3rd is the initial
%                    pole location guess. Denominator order must be a
%                    scalar. Relative degree can be empty, a scalar, or a
%                    [Ny Nu] matrix. Initial poles can be empty, or must
%                    have as many elements as the denominator order.
%             -Struct: Must have 2 fields. Denominator is a [1 1]
%                      param.Continuous object. Numerator is a [Ny Nu]
%                      param.Continuous object.
%             -pmodel.tf: Denominator must be a scalar param.Continuous.
%                         Numerator must be a [Ny Nu] param.Continuous.
% options: An controllib.internal.fitRational.fitRationalOptions object

%   Copyright 2015-2018 The MathWorks, Inc.

%% Default options
if nargin<7 || isempty(optObject)
    optObject = controllib.internal.fitRational.fitRationalOptions;
end

options = struct(...
    'EnforceStability',optObject.EnforceStability,...
    'FittingMethod',optObject.FittingMethod,...
    'InitializationMethod',optObject.InitializationMethod,...
    'SolutionMethod',optObject.SolutionMethod,...
    'MaxIterSK', optObject.MaxIterSK,...
    'MaxIterIV', optObject.MaxIterIV,...
    'AutoIterations',optObject.AutoIterations,...
    'MagnitudeScaling',optObject.MagnitudeScaling,...
    'KeepAsymptotes',optObject.KeepAsymptotes,...
    'GuaranteeRelativeDegree',optObject.GuaranteeRelativeDegree,...
    'UseCtrlToolboxFcns',optObject.UseCtrlToolboxFcns,...
    'Debug',optObject.Debug,...
    'DisplayConditionNumber',optObject.DisplayConditionNumber);
% Unused options:
%     'UseNonlinearSolver',1,... 
%     'LSScalingR',0,...
%     'LSScalingL',0,...

% -MappingMethod: 'squad', 'fitfrd'
% -FittingMethod: 'OVF', 'VF', 'SP'
% -InitializationMethod: 'Levy', 'Lin', 'Log', 'URand'
% -SolutionMethod: 'qr', 'qrro', 'idilslnsh'
% -MaxIterSK: Max # of SK iterations
% -MaxIterIV: Max # of IV iterations
% -AutoIterations: If 1, end iterations early if there is no progress
% -MagnitudeScaling: Scale data around 0dB
% -KeepAsymptotes: If 1, discard poles/zeros beyond data's frequency range
% -GuaranteeRelativeDegree: If 1, and the engine doesn't return a model 
%                           with the exact desired relative degree, throw 
%                           away some poles. A warning is shown if this has
%                           a large impact on fit quality.
% -UseCtrlToolboxFcns: If 1, use zero, zpk, d2c, d2d, ltipack.ssdata,
%                            ltipack.zpkdata, ltipack.tfdata
%                      If 0, use simpler base MATLAB fcns instead for the
%                            same calculations, which may be less accurate
% -UseNonlinearSolver: If 1, call fmincon at the end of iterations.
% -DisplayConditionNumber: Display the condition number of the
%                                    LSQ matrices in each iteration

%% Sanity checks and input validation
%
% 1) Validate/process inputs
% 2) Map the frequency points on the imaginary axis, or on the unit disk to
% a separate unit disk

% Validate the input data
[w,y,u,Weight,Ts,Ny,Nu] = controllib.internal.fitRational.validateData(w,y,u,Weight,Ts);

% Based on sysOrder, calculate:
%   numPoles:      Number of required basis functions. Scalar
%   relDeg:   Relative degree for each I/O channel. [Ny Nu] matrix
%   TFNum:    Structure with fields 'Value','Free','Minimum','Maximum'. Each
%             field is a [d+1 Ny Nu] matrix.
%   TFDen:    Similar to TFNum. There is a shared denominator, hence all
%             fields have the dimensions [d+1 1]
%   initialPoles: Initial pole location guess from the user. Can be [].
[numPoles,relDeg,tfNum,tfDen,initialPoles] = ...
    controllib.internal.fitRational.processSystemDescription(sysOrder,Ny,Nu);

% Validate input data against parameter constraints
[w,y,u,Weight] = controllib.internal.fitRational.validateDataAgainstConstraints(tfDen,Ts,w,y,u,Weight);

% For Ts=0, map points on the imaginary axis onto the unit circle
% For Ts>0, map points on the unit circle onto another unit circle
mapParams = controllib.internal.fitRational.map(w,Ts);

%% Pre-Processing of data: y, u, Weight
%
% Scaling of (y, u) improves the condition of LSQ matrices. 
% * For SISO, SIMO, MISO systems, in absence of numerical issues, this does
% not change the estimated model (after scaling is reverted
% post-estimation).
% * For MIMO systems this impacts the estimated model even in the absence
% of numerical issues. It's helpful to not to ignore channels with small
% magnitude.
scaleStruct = struct('Y',ones(Ny,1),'U',ones(1,Nu),'YoverU',ones(Ny,Nu),'Weight',1);
if options.MagnitudeScaling
    % Center the magnitude of u, y and Weight around 0dB
    [y,u,Weight,scaleStruct] = ...
        controllib.internal.fitRational.scaleMagnitude(y,u,Weight,scaleStruct);
    % Apply the scaling to numerator/denominator constraints
    tfNum = localApplyMagnitudeScaling(tfNum, scaleStruct);
end

% Store the best solution observed during iterations 
%
% Cost field stores the nonlinear cost observed at each step. +3 for:
%    1) Initialization
%    2) Potentially enforcing stability, or fitting with fixed poles
%    3) Potentially using an nonlinear solver
solutionHistory = struct('NumberOfFits',0,...
    'Cost', zeros(options.MaxIterSK+options.MaxIterIV+3,1), ...
    'Jacobian', zeros(options.MaxIterSK+options.MaxIterIV+3,1), ...
    'BestCost',Inf,...
    'FittingMethod',[],...
    'B',[],'n',[],'d',[],'basisPoles',[]);

% Take the norm of the y data. It is used for checking convergence: If
% the fit error is too small compared to this norm, we exit early.
if options.AutoIterations
    yNorm = norm(y(:));
    if yNorm == 0 % yNorm is used in divisions in hasConverged. Protect against div by 0
        yNorm = eps;
    end
else
    yNorm = 1;
end

% Disable the rank deficient matrix warnings
if ~options.Debug
    warningSuspension = ctrlMsgUtils.SuspendWarnings(...
        'MATLAB:illConditionedMatrix',...
        'MATLAB:rankDeficientMatrix',...
        'MATLAB:nearlySingularMatrix',...
        'MATLAB:singularMatrix');
end

%% Initialization
[solutionHistory,p,lastD] = ...
    controllib.internal.fitRational.initialize(...
    solutionHistory,initialPoles,tfNum,tfDen,Ts,...
    w,y,u,Weight,scaleStruct,mapParams,options);
% AAO: Check for 'perfect' fit here and skip the iterations?

%% SK iterations
solutionHistory = controllib.internal.fitRational.primaryIterations(...
    tfNum,tfDen,y,u,Weight,scaleStruct,...
    p,lastD,mapParams,yNorm,options,solutionHistory);

%% IV Refinement
% These are optional
if options.MaxIterIV
    solutionHistory = controllib.internal.fitRational.secondaryIterations(...
        tfNum,tfDen,y,u,Weight,scaleStruct,...
        mapParams,yNorm,options,solutionHistory);
end

%% Enforce stability, if requested
if options.EnforceStability    
    p = localGetPolesOfBestFit(solutionHistory);
    idx = abs(p)>1;
    if any(idx)
        % Reflect the poles w.r.t the unit disk
        p(idx) = 1./p(idx);
        solutionHistory = ...
            controllib.internal.fitRational.o.fitNum(tfNum,y,u,Weight,scaleStruct,p,mapParams,options,solutionHistory);
    end
end

%% Investigate results
if options.Debug
    figure(109);
    subplot(2,1,1);
    idx = 1:solutionHistory.NumberOfFits;
    plot(idx,solutionHistory.Cost(idx));
    [mmm,iii] = min(solutionHistory.Cost(idx));
    title(sprintf('Cost fcn (min=%.2e, iter=%d)',mmm,iii));
    subplot(2,1,2);
    plot(idx,solutionHistory.Jacobian(idx));
    [mmm,iii] = min(solutionHistory.Jacobian(idx));
    title(sprintf('Cost fcn jacobian (min=%.2e, iter=%d)',mmm,iii));
end

%% Construct the estimated zpk system from the best-so-far results

% Extract ZPK from the best fit so far
[z,p,k] = localExtractIdentifiedZPK(...
    solutionHistory.n,...
    solutionHistory.d,...
    solutionHistory.basisPoles,...
    solutionHistory.basisPolesIsReal,...
    solutionHistory.FittingMethod);

%% Revert the domain mapping
[z,p,k] = controllib.internal.fitRational.revertMapZPK(z,p,k,...
    Ts,...
    mapParams,...
    options.UseCtrlToolboxFcns);

%% Post-Processing
if ~options.Debug
    % Restore the rank deficient matrix warning that was disabled earlier
    delete(warningSuspension);
end

if options.MagnitudeScaling
    % Revert the magnitude scaling around 0dB
    %
    % We only revert the scaling for tfNum and identified system gain k.
    % The scaling on y, u, Weight is left untouched as those are not used
    % in the rest of the code.
    [tfNum,k] = localRevertMagnitudeScaling(tfNum,k,scaleStruct);
end

% Remove fast&slow poles and zeros beyond data's frequency range
if options.KeepAsymptotes
    [z,p,k] = controllib.internal.fitRational.keepAsymptotes(z,p,k,...
        tfNum.IsSafeToDisccardRoots,tfDen.IsSafeToDisccardRoots,w,Ts);
end

% Ensure that user's relative degree request is met. The accuracy of the
% LSQ solver is not sufficient to get the exact desired relative degree. In
% addition, for discrete-time systems, d2d sometimes doesn't map the
% zeros at 1/b to inf.
if options.GuaranteeRelativeDegree && any(relDeg(:))
    [z,p,k] = controllib.internal.fitRational.guaranteeRelativeDegree(z,p,k,numPoles,relDeg,w,Ts);
end

%% Extra outputs
if nargout>=4
    kDen = localCalculatekden(z,p,k,tfNum,tfDen);
end
end


function tfNum = localApplyMagnitudeScaling(tfNum, scaleStruct)
% Scale the desired TF num/den constraints per fitRational's data scaling
[~,Ny,Nu] = size(tfNum.Value);
for kkY=1:Ny
    for kkU=1:Nu
        tfNum.Value(:,kkY,kkU) = tfNum.Value(:,kkY,kkU) / scaleStruct.YoverU(kkY,kkU);
        tfNum.Minimum(:,kkY,kkU) = tfNum.Minimum(:,kkY,kkU) / scaleStruct.YoverU(kkY,kkU);
        tfNum.Maximum(:,kkY,kkU) = tfNum.Maximum(:,kkY,kkU) / scaleStruct.YoverU(kkY,kkU);
    end
end
end

function [tfNum,k] = localRevertMagnitudeScaling(tfNum,k,scaleStruct)
% Revert the magnitude scaling 
k = k .* scaleStruct.YoverU;

[Ny,Nu] = size(k);
for kkY=1:Ny
    for kkU=1:Nu
        tfNum.Value(:,kkY,kkU) = tfNum.Value(:,kkY,kkU) * scaleStruct.YoverU(kkY,kkU);
        tfNum.Minimum(:,kkY,kkU) = tfNum.Minimum(:,kkY,kkU) * scaleStruct.YoverU(kkY,kkU);
        tfNum.Maximum(:,kkY,kkU) = tfNum.Maximum(:,kkY,kkU) * scaleStruct.YoverU(kkY,kkU);
    end
end
% The data (y,u,Weight) was also scaled, but skip reverting their scaling.
% Their non-scaled versions are not required.
%
% y(:,kkY) = y(:,kkY) * scaleStruct.Y(kkY);
% u(:,kkU) = u(:,kkU) * scaleStruct.U(kkU);
% Weight = Weight * scaleStruct.U(Weight)
end

function kDen = localCalculatekden(z,p,k,tfNum,tfDen)
%AAO: Clean-up kDen calculation. We should be able to get kDen from our
%scaling of linear equality constraints. This is hacky.

[~,Ny,Nu] = size(tfNum);

% Calculate kDen
kDen = [];
idx = ~tfDen.Free & tfDen.Value;
if any(idx)
    % There is a non-zero fixed denominator tf coefficient
    pPos = find(idx,1);
    den = poly(p);
    % The fixed leading zeros of the num/den are not stored in
    % tf objects. Ensure they have the same length by zero-padding.
    den = localPadWithLeadingZeros(den,tfDen.Value);
    kDen = tfDen.Value(pPos) / den(pPos);
end
% Any non-zero fixed parameters in any of the num?
for kkY=1:Ny
    if ~isempty(kDen)
        break;
    end
    for kkU=1:Nu
        idx = ~tfNum.Free(:,kkY,kkU) & tfNum.Value(:,kkY,kkU);
        if any(idx)
            % There is a non-zero fixed numerator tf coefficient in this I/O channel
            pPos = find(idx,1); % its position
            num = k(kkY,kkU)*poly(z{kkY,kkU});
            % The fixed leading zeros of the num/den are not stored in
            % tf objects. Ensure they have the same length by zero-padding.
            num = localPadWithLeadingZeros(num,tfNum.Value(:,kkY,kkU));
            kDen = tfNum.Value(pPos,kkY,kkU) / num(pPos);
        end
    end
end
% AAO: Our code can error out if there are no equality constraints.
% Then we need to get information from the inequality constraints. As
% of now tfest seems to enforce that the first denominator coefficient
% is fixed.
if isempty(kDen)
    kDen = 1;
end
end

function p1 = localPadWithLeadingZeros(p1,p2)
% p1 = localPadWithLeadingZeros(p1,p2)
%
% Add leading zeros p1 so that it has the same length as p2. p1, p2 must be
% vectors.
%
% When performing structured TF estimation, there are 2 pieces of
% information we have:
% 1) User specified TF num/den structure
% 2) Estimated TF stored in tf or ltipack.tfdata objects
% Here 1) contains leading fixed zeros, but 2) not. This comes into play
% when we are looking at 1) and 2) together for any kind of purpose.
lenP1 = numel(p1);
lenP2 = numel(p2);
if lenP1<lenP2
    p1 = [zeros(1,lenP2-lenP1) p1];
end
end

function p = localGetPolesOfBestFit(solutionHistory)
dp = solutionHistory.d;
switch solutionHistory.FittingMethod
   case 'OVF'
      [A,B,C,D] = controllib.internal.fitRational.o.ssRealization(solutionHistory.basisPoles,solutionHistory.basisPolesIsReal,dp(2:end),dp(1));
      p = ltipack.sszeroCG(A,B,C,D,[]);
   case 'VF'
      [A,B,C,D] = controllib.internal.fitRational.b.ssRealization(solutionHistory.basisPoles,solutionHistory.basisPolesIsReal,dp(2:end),dp(1));
      p = ltipack.sszeroCG(A,B,C,D,[]);
   case 'SP'
      p = roots(dp);
end
end


function [z,p,k] = localExtractIdentifiedZPK(np,dp,basisPoles,basisPolesIsReal,fittingMethod)
[Ny,Nu] = size(np);
z = cell(Ny,Nu);
k = zeros(Ny,Nu);

switch fittingMethod
   case 'OVF'
      [Ap,Bp,Cp,Dp] = controllib.internal.fitRational.o.ssRealization(basisPoles,basisPolesIsReal,dp(2:end),dp(1));
      [p,identifiedDenK] = ltipack.sszeroCG(Ap,Bp,Cp,Dp,[]);
      for kk=1:Ny*Nu
         [Az,Bz,Cz,Dz] = controllib.internal.fitRational.o.ssRealization(basisPoles,basisPolesIsReal,np{kk}(2:end),np{kk}(1));
         [z{kk},k(kk)] = ltipack.sszeroCG(Az,Bz,Cz,Dz,[]);
      end
      k = k/identifiedDenK;
   case 'VF'
      [Ap,Bp,Cp,Dp] = controllib.internal.fitRational.b.ssRealization(basisPoles,basisPolesIsReal,dp(2:end),dp(1));
      [p,identifiedDenK] = ltipack.sszeroCG(Ap,Bp,Cp,Dp,[]);
      for kk=1:Ny*Nu
         [Az,Bz,Cz,Dz] = controllib.internal.fitRational.b.ssRealization(basisPoles,basisPolesIsReal,np{kk}(2:end),np{kk}(1));
         [z{kk},k(kk)] = ltipack.sszeroCG(Az,Bz,Cz,Dz,[]);
      end
      k = k/identifiedDenK;
   case 'SP'
      % Get poles, and the first nonzero denominator coefficient
      [p,identifiedDenK] = localGetPolyRootsAndLeadingCoeff(dp);
      % Get zeros and the first nonzero numerator coefficient
      for kk=1:Ny*Nu
         [z{kk},k(kk)] = localGetPolyRootsAndLeadingCoeff(np{kk});
      end
      k = k/identifiedDenK;
end
end

function [r,k] = localGetPolyRootsAndLeadingCoeff(c)
% Given coefficients c of polynomial
%    p(x)=c(1)*x^n + c(2)*x^(n-1) + ... + c(n-1)*x + c(n)
% extract the roots and the leading coefficient:
%    p(x)=k*(x-r(1))*(x-r(2))*...
%
% If c contains leading zeros, then numel(r) can be less than n
r = roots(c);
% find the first nonzero coefficient
idx = find(c,1);
if isempty(idx) % all coefficients can be 0
    k = 0;
else
    k = c(idx);
end
end

% LocalWords:  Ny nd OVF URand qrro idilslnsh ltipack LSQ Yover AAO kk hacky
% LocalWords:  tfest halfplane zo po ko Prewarp ro controllib SIMO MISO
