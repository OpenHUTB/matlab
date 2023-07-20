function [solutionHistory,initialPoles,lastD] = ...
    initialize(solutionHistory,initialPoles,tfNum,tfDen,Ts,...
    w,y,u,Weight,scaleStruct,mapParams,options)
%

% Perform the initial fit. 
% 
% If the user provided initial poles, utilize those. Otherwise, initialize
% utilizing the method specified via options.InitializationMethod.
%
% The resulting fit is stored in solutionHistory.
%
% initialPoles: Needed if we'll perform SK iterations with VF or OVF bases
% lastD: Needed if we'll perform SK iterations with SP bases

%   Copyright 2015-2018 The MathWorks, Inc.

%% Initial poles
d = numel(tfDen.Value)-1; % number of required initial poles (=basis functions)
hasInitialPoles = ~isempty(initialPoles);

%% Initial fit
% -All initialization methods must output identifiedPoles
% -If the fitting method is SP, then the last identified denominator
% response is needed (lastD)
if hasInitialPoles
    % Initialize utilizing user provided initial pole guess
        
    % Map the specified poles to the q domain.
    %
    % If the model has negative relative degree, we need more initial poles
    % than what user specified. fitNum code will separate these repeated
    % poles as necessary. These will later be removed in
    % guaranteeRelativeDeg when fitting is done.
    if Ts
        initialPoles = (initialPoles+mapParams.b)./(initialPoles*mapParams.b+1);
        % The poles at inf are mapped to 1/b with q=(z+b)/(b*z+1)
        initialPoles = [initialPoles; ones(d-numel(initialPoles),1)/mapParams.b];
    else
        initialPoles = (mapParams.alpha+initialPoles)./(mapParams.alpha-initialPoles);
        % The poles at inf are mapped to -1 with q=(alpha+s)/(alpha-s)
        initialPoles = [initialPoles; -ones(d-numel(initialPoles),1)];
    end

    % Fit with fixed poles since the initial pole guess is likely decent. 
    % This is guaranteed to improve the numerator guess.
    solutionHistory = ...
        controllib.internal.fitRational.o.fitNum(tfNum,y,u,Weight,...
        scaleStruct,initialPoles,mapParams,options,solutionHistory);
    % Calculate denominator freq response
    lastD = localCalculateLastD(solutionHistory,options);
else
    switch options.InitializationMethod
        case 'Levy'
            % Assume den frequency response is just constant 1
            [lastD,solutionHistory] = ...
                controllib.internal.fitRational.sp.fit(tfNum,tfDen,y,u,Weight,scaleStruct,1,...
                mapParams,options,solutionHistory);
            initialPoles = roots(solutionHistory.d); % starting poles
        case {'Lin','Log','UniformRandom'}
            % Generate poles in s domain to cover the frequency range, then
            % map them to the discrete domain
            basisPoles = zeros(d,1);
            vv = 0.1;
            switch options.InitializationMethod
                case 'Lin'
                    Bp = linspace(w(1),w(end),floor(d/2));
                case 'Log'
                    Bp = logspace(log10(w(1)),log10(w(end)),floor(d/2));
                case 'UniformRandom'
                    Bp = (min(w) + (max(w)-min(w))*rand(floor(d/2),1));
            end
            Bp = Bp /sqrt(1+vv^2);
            basisPoles(1:2:floor(d/2)*2) = -vv*Bp + 1i*Bp;
            basisPoles(2:2:floor(d/2)*2) = -vv*Bp - 1i*Bp;
            if bitand(d,1)
                % odd number of poles. Pick a real pole
                basisPoles(end) = -(w(1)+w(end))/2;
            end
            % map to the discrete domain
            if Ts
                basisPoles = exp(Ts*basisPoles);
                basisPoles = (basisPoles+mapParams.b)./(basisPoles*mapParams.b+1);
            else
                basisPoles = (mapParams.alpha+basisPoles)./(mapParams.alpha-basisPoles);
            end
            [initialPoles,solutionHistory] = ...
                controllib.internal.fitRational.o.fit(tfNum,tfDen,y,u,Weight,scaleStruct,basisPoles,mapParams,options,solutionHistory);
            % Calculate denominator freq response
            lastD = localCalculateLastD(solutionHistory,options);
        otherwise
            assert(false);
    end    
end
end

function lastD = localCalculateLastD(solutionHistory,options)
% lastD is needed if the fitting method is standard polynomials
if strcmp(options.FittingMethod,'SP')
    lastD = solutionHistory.B * solutionHistory.d.';
else 
    lastD = 0;
end
end
