function solutionHistory = primaryIterations(...
    tfNum,tfDen,y,u,Weight,scaleStruct,...
    identifiedPoles,lastD,mapParams,yNorm,options,solutionHistory)
%

% solutionHistory = primaryIterations(tfNum,tfDen,y,u,Weight,scaleStruct,identifiedPoles,mapParams,options,solutionHistory)
%
% Perform SK-iterations utilizing desired basis functions

%   Copyright 2015-2016 The MathWorks, Inc.

switch options.FittingMethod
    case 'OVF'
        for idn=1:options.MaxIterSK
            [identifiedPoles,solutionHistory] = ...
                controllib.internal.fitRational.o.fit(tfNum,tfDen,y,u,Weight,scaleStruct,identifiedPoles,mapParams,options,solutionHistory);
            % Terminate iteration early if the nonlinear cost has converged
            if options.AutoIterations && controllib.internal.fitRational.hasConverged(solutionHistory,yNorm)
                break;
            end
        end
        
    case 'VF'
        for idn=1:options.MaxIterSK
            [identifiedPoles,solutionHistory] = ...
                controllib.internal.fitRational.b.fit(tfNum,tfDen,y,u,Weight,scaleStruct,identifiedPoles,mapParams,options,solutionHistory);
            if options.AutoIterations && controllib.internal.fitRational.hasConverged(solutionHistory,yNorm)
                break;
            end
        end
        
    case 'SP'
        for idn=1:options.MaxIterSK
            [lastD,solutionHistory] = ...
                controllib.internal.fitRational.sp.fit(tfNum,tfDen,y,u,Weight,scaleStruct,lastD,...
                mapParams,options,solutionHistory);
            if options.AutoIterations && controllib.internal.fitRational.hasConverged(solutionHistory,yNorm)
                break;
            end
        end
        
end
end