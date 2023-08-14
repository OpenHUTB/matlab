classdef VCDOImpl<Simulink.variant.variablegroups.VariableGroupsInterface




    properties
        newVCDO Simulink.VariantConfigurationData;
    end

    methods
        function obj=VCDOImpl(modelName,origModelName,variableGroups)
            obj.modelName=modelName;
            obj.origModelName=origModelName;
            obj.variableGroups=variableGroups;
            obj.newVCDO=Simulink.VariantConfigurationData;
        end

        function createConfig(obj,configName,ctrlVars,slVarCtrlNameValueMap)
            obj.newVCDO.addConfiguration(configName);
            ctrlVars=obj.updateCtrlVarsForslVarCtrl(ctrlVars,slVarCtrlNameValueMap);



            obj.newVCDO.addControlVariables(configName,ctrlVars);
        end

        function cvv=getControlVariableValue(obj,cvv,cvvSpecified,skipGlobalWksCheck)
            val=obj.getUpdatedValueForParamsAndSLVarCtrl(cvv,cvvSpecified,skipGlobalWksCheck);
            if~isempty(val)
                cvv=val;
            elseif Simulink.data.isSupportedEnumObject(cvv)



                cvv=[class(cvv),'.',char(cvv)];
            elseif isa(cvv,'double')
                cvv=Simulink.variant.reducer.utils.i_num2str(cvv);
            else




                cvv=[class(cvv),'(',Simulink.variant.reducer.utils.i_num2str(cvv),')'];
            end
        end
    end
end


