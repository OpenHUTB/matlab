function [numPoles,relDeg,TFNum,TFDen,initialPoles] = processSystemDescription(S,Ny,Nu)
%

% [numPoles,relDeg,TFNum,TFDen,initialPoles] = processSystemDescription(S,Ny,Nu)
%
% Desired model order and strucure can be set via 4 methods:
%
% 1) S is a scalar: the system order. relative degree is asusmed to be 0
% 2) S is a cell with 1-3 elements: the 1st is the system order, the 2nd
% is the relative degree, the 3rd is the initial poles
% 3) S is a pmodel.tf object
% 4) S is a struct with the 2 fields. Denominator is a [1 1]
% param.Continuous object. Numerator is a [Ny Nu] param.Continuous object.
%
% Options 3) and 4) allow fixing or bounding parameter values.
%
% Based on these, calculate:
%   numPoles:     Number of requested poles in the system. A scalar.
%   relDeg:       Relative degree for each I/O channel. [Ny Nu] matrix
%   TFNum:        Structure with fields 'Value','Free','Minimum','Maximum'.
%                 Each field is a matrix of dimensions [d+1 Ny Nu]. d is 
%                 the number of required basis functions.
%   TFDen:        Similar to TFNum. Since the denominator is shared, all 
%                 fields have the dimensions [d+1 1]
%   initialPoles: User provided initial poles for initialization. It is []
%                 if unprovided. Engine performs its own initialization  it 
%                 this case.

%   Copyright 2015-2017 The MathWorks, Inc.

if isnumeric(S) && isscalar(S)
    % S is the system order
    S = struct('DenominatorOrder',S,'RelativeDegree',zeros(Ny,Nu),'InitialPoles',[]);
    structuredTFEstimation = false();
elseif iscell(S)
    % S is a cell. The first element is the system order, the
    % second element is the relative degree, the 3rd one is the initial
    % poles
    nS = numel(S);
    if nS<3
        S{3} = []; % Unknown initial poles
    end
    if nS<2 || isempty(S{2})
        S{2} = zeros(Ny,Nu); % 0 reldeg
    end
    S = struct('DenominatorOrder',S{1},'RelativeDegree',S{2},'InitialPoles',S{3});
    structuredTFEstimation = false();
elseif isa(S,'pmodel.tf') || ...
        (isstruct(S) && isfield(S,'Denominator') && isfield(S,'Numerator'))
    structuredTFEstimation = true();
else
    error(message('Controllib:estimation:fitRationalInvalidSysDescription'));
end

if structuredTFEstimation
    % The system descrpition is given as a struct with two fields,
    % Denominator and Numerator:
    %    Denominator is a [1 1] param.Continuous object.
    %    Numerator is a [Ny Nu] param.Continuous object.
    %
    % * The scaling info in the param.Continuous objects are ignored
    % * If both numerator and denominator have fixed leading zeros, these
    % are dumped. sIdx below camtures the number of dumped elements.
    % * TFNum and TFDen will have the length d+1, which is the length of
    % the longest numerator or denominator. These d+1 elements are: 
    % [PaddingFixedLeadingZeros User'sFixedLeadingZeros Parameters]
    
    if ~isa(S.Denominator,'param.Continuous') || ~isscalar(S.Denominator)
        error(message('Controllib:estimation:fitRationalInvalidSysDecriptionObj',1,1));
    end
    if ~isa(S.Numerator,'param.Continuous') || ~isequal(size(S.Numerator),[Ny Nu])
        error(message('Controllib:estimation:fitRationalInvalidSysDecriptionObj',Ny,Nu));
    end
    % All entries in param.Continuous objects must be row vectors
    if ~isrow(S.Denominator.Value)
        error(message('Controllib:estimation:fitRationalInvalidSysDescriptionNotRowVector'));
    end
    for kkY=1:Ny
        for kkU=1:Nu
            if ~isrow(S.Numerator(kkY,kkU).Value)
                error(message('Controllib:estimation:fitRationalInvalidSysDescriptionNotRowVector'));
            end
        end
    end
    
    % Ignore all fixed leading zeros  (later we may add some ourselves to
    % make the length of num and den the same).
    %
    % The fixed leading zeros in den
    numFLZDen = localFindNumberofFixedLeadingZeros(S.Denominator.Value,...
        S.Denominator.Free);
    % Fixed leading zeros in num
    numFLZNum = zeros(Ny,Nu);
    lengthNum = zeros(Ny,Nu);
    for kkY=1:Ny
        for kkU=1:Nu
            lengthNum(kkY,kkU) = numel(S.Numerator(kkY,kkU).Value);
            numFLZNum(kkY,kkU) = localFindNumberofFixedLeadingZeros(...
                S.Numerator(kkY,kkU).Value,...
                S.Numerator(kkY,kkU).Free);
        end
    end
    % The length of the num and den, before we apply zero-padding to make
    % them match in length.
    lengthNum = lengthNum-numFLZNum;
    lengthDen = numel(S.Denominator.Value)-numFLZDen;
    
    % Find the number of required basis functions, d. It is the longest
    % numerator or denominator, minus one.
    d = max([lengthDen; lengthNum(:)])-1;
    numPoles = lengthDen-1;
    
    % Start processing the denominator
    %
    % Pad denominator with fixed leading zeros if any numerator is longer
    numPaddingFLZDen = d+1-lengthDen;
    TFDen = struct('Value',[false(numPaddingFLZDen,1); S.Denominator.Value(numFLZDen+1:end).'],...
        'Minimum',[-inf(numPaddingFLZDen,1); S.Denominator.Minimum(numFLZDen+1:end).'],...
        'Maximum',[inf(numPaddingFLZDen,1); S.Denominator.Maximum(numFLZDen+1:end).'],...
        'Free',[false(numPaddingFLZDen,1); S.Denominator.Free(numFLZDen+1:end).'],...
        'IsSafeToDisccardRoots',true());
    % Each field in TFDen must be [d+1 1] vector
    
    % param.Continuous doesn't check Minimum&Maximum bounds for consistency
    isInconsistent = TFDen.Maximum<TFDen.Minimum;
    if any(isInconsistent)
        error(message('Controllib:general:ModelParInfeasibleBounds'))
    end
    % Move the initial parameter values into the min/max bounds
    TFDen.Value(~isfinite(TFDen.Value))=0;
    TFDen.Value = max(min(TFDen.Value,TFDen.Maximum),TFDen.Minimum);
    TFDen.Value(isinf(TFDen.Value)) = 0; % in case max=inf, min=-inf
    % If there are no denominator constraints except fixed leading zeros,
    % then it is safe to discard roots during post-processing in
    % KeepAsymptotes and GuaranteeRelativeDegree.
    TFDen.IsSafeToDisccardRoots = all(isinf(TFDen.Maximum)) && ...
        all(isinf(TFDen.Minimum)) && all(TFDen.Free(numPaddingFLZDen+1:end));
    
    % Start processing the numerator(s)
    TFNum = struct('Value',zeros(d+1,Ny,Nu),...
        'Minimum',-inf(d+1,Ny,Nu),...
        'Maximum',inf(d+1,Ny,Nu),...
        'Free',false(d+1,Ny,Nu),...
        'IsSafeToDisccardRoots',true(Ny,Nu));
    relDeg = zeros(Ny,Nu);
    for kkY=1:Ny
        for kkU=1:Nu
            % Relative degree for this channel is:
            % (#Poles)-(#Zeros) = (#Poles)-(numeratorLength-1)+(fixedLeadingZerosInNumerator)
            relDeg(kkY,kkU) = numPoles-(lengthNum(kkY,kkU)-1);
            % param.Continuous doesn't check Minimum&Maximum bounds for consistency
            isInconsistent = S.Numerator(kkY,kkU).Maximum<S.Numerator(kkY,kkU).Minimum;
            if any(isInconsistent)
                error(message('Controllib:general:ModelParInfeasibleBounds'))
            end
            % Move the initial parameter values into the min/max bounds
            Value = S.Numerator(kkY,kkU).Value;
            Value(~isfinite(Value)) = 0;
            Value = max( min(Value,S.Numerator(kkY,kkU).Maximum), ...
                S.Numerator(kkY,kkU).Minimum);
            Value(isinf(Value)) = 0; % in case max=inf, min=-inf
            S.Numerator(kkY,kkU).Value = Value;
            
            numPaddingFLZNum = d+1-lengthNum(kkY,kkU);
            TFNum.Value(numPaddingFLZNum+1:end,kkY,kkU) = S.Numerator(kkY,kkU).Value(numFLZNum(kkY,kkU)+1:end).';
            TFNum.Minimum(numPaddingFLZNum+1:end,kkY,kkU) = S.Numerator(kkY,kkU).Minimum(numFLZNum(kkY,kkU)+1:end).';
            TFNum.Maximum(numPaddingFLZNum+1:end,kkY,kkU) = S.Numerator(kkY,kkU).Maximum(numFLZNum(kkY,kkU)+1:end).';
            TFNum.Free(numPaddingFLZNum+1:end,kkY,kkU) = S.Numerator(kkY,kkU).Free(numFLZNum(kkY,kkU)+1:end).';
            % See TFDen.SafeToDisccardRoots
            TFNum.IsSafeToDisccardRoots(kkY,kkU) = ...
                all(isinf(TFNum.Maximum(:,kkY,kkU))) && ...
                all(isinf(TFNum.Minimum(:,kkY,kkU))) && ...
                all(TFNum.Free(numPaddingFLZNum+1:end,kkY,kkU));
        end 
    end
    
    % Validate the initial poles. If unprovided, it'll be left as [] and
    % the engine won't use this in intialize()
    if all(isfinite(S.Denominator.Value))
        initialPoles = localValidateInitialPoles(roots(S.Denominator.Value),numPoles);
    else
        initialPoles = [];
    end
else
    % The system descrpition is given via scalar DenominatorOrder (scalar) and
    % RelativeDegree ([Ny Nu] matrix)
    
    % Validate the number of poles
    %
    % numPoles and relDeg describe the number of poles and zeros in the system:
    %    numZeros=numPoles-relDeg
    % numPoles and numZeros must be positive. That is: numPoles>=0, numPoles>=relDeg
    validateattributes(S.DenominatorOrder,{'numeric'},{'integer','scalar','nonnegative'});
    
    % Validate the relative degree. It can be a scalar or a [Ny Nu] matrix.
    % Must be <=numPoles, integer, finite. 
    if isscalar(S.RelativeDegree)
        S.RelativeDegree = repmat(S.RelativeDegree,[Ny Nu]);
    end
    validateattributes(S.RelativeDegree,{'numeric'},...
        {'integer','finite','size',[Ny Nu]});
    % Relative degree must be less than the denominator order
    idx = S.RelativeDegree>S.DenominatorOrder;
    if any(idx)
        warning(message('Controllib:estimation:fitRationalRelativeDegreeTooLarge'));
        S.RelativeDegree(idx) = S.DenominatorOrder;
    end
    
    minRelDeg = min(S.RelativeDegree(:));
    
    % Calculate the number of required basis functions. Negative relative
    % degree requires more basis functions than the number of poles.
    minusMinRelDegOrZero = max(0,-minRelDeg);
    numPoles = S.DenominatorOrder;
    d = numPoles + max(0,minusMinRelDegOrZero);
    relDeg = S.RelativeDegree;

    TFDen = struct(...
        'Value',zeros(d+1,1),...
        'Free',[false(minusMinRelDegOrZero,1); true(S.DenominatorOrder+1,1)],...
        'Minimum',-inf(d+1,1),...
        'Maximum',inf(d+1,1),...
        'IsSafeToDisccardRoots',true());
    TFNum = struct(...
        'Value',zeros(d+1,Ny,Nu),...
        'Free',true(d+1,Ny,Nu),...
        'Minimum',-inf(d+1,Ny,Nu),...
        'Maximum',inf(d+1,Ny,Nu),...
        'IsSafeToDisccardRoots',true(Ny,Nu));
    for kkY=1:Ny
        for kkU=1:Nu
            TFNum.Free(1:minusMinRelDegOrZero+relDeg(kkY,kkU),kkY,kkU) = false();
        end
    end
    
    % Initial pole validation. If unprovided, it'll be left as [] and the
    % engine won't use this in intialize()
    initialPoles = localValidateInitialPoles(S.InitialPoles,S.DenominatorOrder);
end
end

function numFLZ = localFindNumberofFixedLeadingZeros(value,isFree)
% Given the vector 'value' and a boolean vector of same size isFree, count
% the number of leading, fixed zeros in 'value'.
%
fixedZeros = value==0 & ~isFree;
numFLZ = find(~fixedZeros,1)-1;
if isempty(numFLZ)
    numFLZ = 0;
end
end

function p = localValidateInitialPoles(p,denOrder)
% It's OK to leave it empty. Also ignore it if it's not finite
if isempty(p) || any(~isfinite(p))
    p = [];
    return;
end
% User specified initial poles, perform validation
validateattributes(p,{'numeric'},...
    {'vector','finite','numel',denOrder});
p = p(:);
% Note: We need extra poles for systems with negative reldeg, but user
% wouldn't and shouldn't know this. These are added to the user provided
% poles in initialize().
end