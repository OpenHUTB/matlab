function solutionHistory = secondaryIterations(...
    tfNum,tfDen,y,u,Weight,scaleStruct,...
    mapParams,yNorm,options,solutionHistory)
%

% Perform IV-iterations utilizing fixed basis functions

%   Copyright 2015-2018 The MathWorks, Inc.

% Get the results form best fit so far
lastB = solutionHistory.B;
[lastD,lastN] = controllib.internal.fitRational.getResponse(solutionHistory.B,solutionHistory.d,solutionHistory.n);

switch solutionHistory.FittingMethod
    case 'OVF'
        basisPoles = solutionHistory.basisPoles;
        basisPolesIsReal = solutionHistory.basisPolesIsReal;
        for idn=1:options.MaxIterIV
            [lastB,lastD,lastN,solutionHistory] = ...
                controllib.internal.fitRational.o.fitJacobian(...
                tfNum,tfDen,y,u,Weight,scaleStruct,...
                basisPoles,basisPolesIsReal,lastB,lastD,lastN,...
                mapParams,options,solutionHistory);
            % Terminate iteration early if the nonlinear cost has converged.
            % Use a tighter tolerance than the SK iterations (1e-4 vs 1e-3)
            if options.AutoIterations && controllib.internal.fitRational.hasConverged(solutionHistory,yNorm,1e-4)
                break;
            end
        end        
    case 'SP'
        for idn=1:options.MaxIterIV
            [lastB,lastD,lastN,solutionHistory] = ...
                controllib.internal.fitRational.sp.fitJacobian(...
                tfNum,tfDen,y,u,Weight,scaleStruct,...
                lastB,lastD,lastN,...
                mapParams,options,solutionHistory);
            if options.AutoIterations && controllib.internal.fitRational.hasConverged(solutionHistory,yNorm,1e-4)
                break;
            end
        end
        
    case 'VF'
        basisPoles = solutionHistory.basisPoles;
        basisPolesIsReal = solutionHistory.basisPolesIsReal;        
        for idn=1:options.MaxIterIV
            [lastB,lastD,lastN,solutionHistory] = ...
                controllib.internal.fitRational.b.fitJacobian(...
                tfNum,tfDen,y,u,Weight,scaleStruct,...
                basisPoles,basisPolesIsReal,lastB,lastD,lastN,...
                mapParams,options,solutionHistory);
            if options.AutoIterations && controllib.internal.fitRational.hasConverged(solutionHistory,yNorm,1e-4)
                break;
            end
        end          
    otherwise
        assert(false);
end
end
