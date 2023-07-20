classdef VariableUsageProxy<SimulinkFixedPoint.SimulinkVariableUsageParser.VariableUsageProxy






    methods
        function sourceTypeEnum=getSourceTypeEnum(this)

            sourceType=getSourceType(this);
            sourceTypeEnum=SimulinkFixedPoint.AutoscalerVarSourceTypes.convertToEnumSourceType(sourceType);
        end
    end
end