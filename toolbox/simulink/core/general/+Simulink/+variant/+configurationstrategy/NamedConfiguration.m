classdef NamedConfiguration<Simulink.variant.configurationstrategy.ConfigurationInterface




    properties
        validationLog;
        optArgs;
        varNameSimParamExpressionHierarchyMap containers.Map;
        mSysName char;
    end
    methods

        function obj=NamedConfiguration(modelName)
            obj.validationLog=[];
            obj.varNameSimParamExpressionHierarchyMap=containers.Map('keyType','char','valueType','any');
            obj.mSysName=modelName;
        end

        function errors=validateConfiguration(obj,configName)
            if slfeature('VMgrV2UI')>0
                [success,errors]=slvariants.internal.manager.core.activateModel(obj.mSysName,configName);
                if~success
                    err=MException(message('Simulink:Variants:InvalidConfigForModel',configName,obj.mSysName));
                    err=Simulink.variant.utils.addActivationCausesToDiagnostic(err,errors);
                    throw(err);
                end
            else
                obj.optArgs=struct('ConfigurationName',configName,'VarNameSimParamExpressionHierarchyMap',obj.varNameSimParamExpressionHierarchyMap);
                errors=Simulink.variant.manager.configutils.validateModelEntry(obj.mSysName,obj.validationLog,obj.optArgs);
                if~isempty(errors)
                    errid='Simulink:Variants:InvalidConfigForModel';
                    errmsg=message(errid,configName,obj.mSysName);
                    err=MException(errmsg);
                    err=Simulink.variant.utils.addValidationCausesToDiagnostic(err,errors);
                    throw(err);
                end
            end
        end

        function configNames=getConfigurationNames(obj)
            vcdo=Simulink.variant.utils.getConfigurationDataNoThrow(obj.mSysName);
            if~isempty(vcdo)
                configNames={vcdo.VariantConfigurations.Name};
            end
        end

        function defaultConfig=getDefaultConfiguration(obj)
            vcdo=Simulink.variant.utils.getConfigurationDataNoThrow(obj.mSysName);
            defaultConfig=vcdo.DefaultConfigurationName;
        end

        function varExprMap=getSimExprMap(obj)
            varExprMap=obj.varNameSimParamExpressionHierarchyMap;
        end

        function resetSimVarExprMap(obj)
            obj.varNameSimParamExpressionHierarchyMap=containers.Map('keyType','char','valueType','any');
        end
    end

end
