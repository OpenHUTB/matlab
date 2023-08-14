classdef MFModelImpl<Simulink.variant.variablegroups.VariableGroupsInterface




    properties
        updatedConfigGroups cell;
    end

    methods

        function obj=MFModelImpl(modelName,variableGroups)
            obj.modelName=modelName;
            obj.origModelName=modelName;
            obj.variableGroups=variableGroups;
        end

        function createConfig(obj,configName,ctrlVars,slVarCtrlNameValueMap)


            ctrlVars=obj.updateCtrlVarsForslVarCtrl(ctrlVars,slVarCtrlNameValueMap);
            obj.updatedConfigGroups{end+1}={configName,ctrlVars};
        end

        function val=getControlVariableValue(obj,cvv,cvvSpecified,skipGlobalWksCheck)


            val=obj.getUpdatedValueForParamsAndSLVarCtrl(cvv,cvvSpecified,skipGlobalWksCheck);
            if isempty(val)
                val=cvv;
            end
        end
    end

end


