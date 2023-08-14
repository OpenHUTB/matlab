classdef VariableConfiguration<Simulink.variant.configurationstrategy.ConfigurationInterface




    properties
        mSysName;
    end
    methods

        function obj=VariableConfiguration(modelName)
            obj.mSysName=modelName;
        end

        function errors=validateConfiguration(obj,configName)







            errors=false;

            controller=getController(obj.mSysName);
            if~controller.hasAnyVSSBlockWithGPCOff



                return;
            end



            mfvcdo=getMFVCDOFromModel(obj.mSysName);
            cfgs=mfvcdo.varConfigs;
            for i=1:cfgs.Size
                if strcmp(cfgs(i).configName,configName)
                    cfg=cfgs(i);
                    break;
                end
            end

            for varId=1:cfg.ConfigVariables.Size
                ctrlVar=struct('Name',cfg.ConfigVariables(varId).name,...
                'Value',cfg.ConfigVariables(varId).value,...
                'Source',cfg.ConfigVariables(varId).source);
                Simulink.variant.utils.assignVariableInWorkspace(ctrlVar);
            end
        end

        function configNames=getConfigurationNames(obj)
            mfvcdo=getMFVCDOFromModel(obj.mSysName);
            cfgs=mfvcdo.varConfigs;
            cfgCells=cfgs(1:cfgs.Size);
            configNames={cfgCells.configName};
        end

        function defaultConfig=getDefaultConfiguration(~)
            defaultConfig='';
        end

        function varExprMap=getSimExprMap(~)
            varExprMap=containers.Map('keyType','char','valueType','any');
        end

        function resetSimVarExprMap(~)

        end
    end

end

function mfVCDO=getMFVCDOFromModel(modelName)
    modelHandle=get_param(modelName,'Handle');
    controller=sl_variants.analyzer.getModel(modelHandle).topLevelElements;
    mfVCDO=controller.vcdoData;
end

function controller=getController(modelName)
    modelHandle=get_param(modelName,'Handle');
    controller=sl_variants.analyzer.getModel(modelHandle).topLevelElements;
end


