classdef StorageTypesChecker<FunctionApproximation.internal.autosar.AUTOSARLUTComplianceChecker





    methods(Access=public)
        function diagnostic=check(~,context)
            diagnostic=MException.empty();

            nTypes=numel(context.StorageTypes);
            for iType=1:nTypes
                if context.StorageTypes(iType).isdouble()
                    diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarComplianceDoubleNotAllowed'));%#ok<AGROW>                    
                    break;
                end
            end

            if~isequal(context.StorageTypes(end),context.OutputType)
                diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarComplianceTableTypeMustBeSameAsOutputType'));
            end
        end
    end
end


