classdef(Sealed,Hidden)VariantConfigurationManager<handle






    properties(SetAccess=private)

        mMF0Model(1,1)mf.zero.Model;

        mController;

        mSysName char;

        mConfigs;

        mDefaultConfigurationName;

        configI;
    end

    methods
        function obj=VariantConfigurationManager(sysName,configName,configurationI,configInfoCell)


            obj.mSysName=sysName;
            mdlHandle=get_param(sysName,'Handle');

            obj.configI=configurationI;

            h=Simulink.PluginMgr();
            h.attach(mdlHandle,'sl_variants_analyzer_slplugin');


            obj.mMF0Model=sl_variants.analyzer.getModel(mdlHandle);
            vmgrcfgplugin.VariantConfigurationManager.getTopModelHandle(mdlHandle);


            obj.clearDataModelCache();


            controller=obj.mMF0Model.topLevelElements;


            Simulink.variant.utils.assert(isscalar(controller),'Returned more than one BlockDiagram Element for bd');
            Simulink.variant.utils.assert(isa(controller,'sl_variants.analyzer.datamodel.Controller'),'Incorrect datatype for controller element');


            obj.createMFVCDO(controller,configInfoCell);



            obj.mController.currentConfiguration=configName;



            set_param(sysName,'SimulationCommand','update');

            obj.mConfigs=configurationI.getConfigurationNames();
            obj.mDefaultConfigurationName=configurationI.getDefaultConfiguration();
        end

        function delete(obj)

            if bdIsLoaded(obj.mSysName)
                h=Simulink.PluginMgr();
                h.detachForAllModels('sl_variants_analyzer_slplugin');
            end
            obj.clearDataModelCache();
        end

        function determineActiveBlocks(obj,configName)

            cfgIdx=strcmp(obj.mConfigs,configName);
            if~any(cfgIdx)

                errmsg=message('Simulink:VariantManager:ConfigNotPresent',configName);
                err=MException(errmsg);
                throw(err);
            end



            hDefConfig=Simulink.variant.utils.DefaultConfigHandler(obj.mSysName);%#ok<NASGU>

            obj.configI.validateConfiguration(configName);



            if obj.mController.hasAnyVSSBlockWithGPCOff
                obj.mController.passedForReComputeVariantConds=true;
                obj.mController.currentConfiguration=configName;
                set_param(obj.mSysName,'SimulationCommand','update');

                obj.mController.passedForReComputeVariantConds=false;
            end


            modelHandle=get_param(obj.mSysName,'Handle');
            try
                sl_variants.analyzer.determineActiveChoices(modelHandle,configName);
            catch ME


                msgid='Simulink:VariantManager:IncompleteGroup';
                msg=message(msgid,configName);
                exp=MSLException(msg);
                exp=exp.addCause(ME);
                throwAsCaller(exp);
            end
        end

        function isActive=isBlockActive(obj,blkHandle,configName)

            try
                isActive=sl_variants.analyzer.isBlockActive(get_param(obj.mSysName,'Handle'),blkHandle,configName);
            catch


                isActive=false;
            end
        end

        function toggleModelEditFlag(obj)

            obj.mController.toggleOnModelEdit=~obj.mController.toggleOnModelEdit;
        end

        function varCond=getVariantCondition(obj,blockHandle,configName)


            try
                varCond=sl_variants.analyzer.getBlockVariantCondition(get_param(obj.mSysName,'Handle'),...
                blockHandle,configName);
            catch


                varCond='';
                warnid='Simulink:VariantManager:VariantCondOnInactiveModelRefBlock';
                blockPath=getfullname(blockHandle);
                blockRoot=bdroot(blockPath);
                warnmsg=message(warnid,blockPath,blockRoot);
                warning(warnid,warnmsg.getString);
            end
        end

        function metaModel=getMetaModel(obj)
            metaModel=obj.mMF0Model;
        end
    end

    methods(Static)
        function mdlHandle=getTopModelHandle(topmdlHandle)
            persistent mdl;
            if nargin
                mdl=topmdlHandle;
            end
            mdlHandle=mdl;
        end
    end

    methods(Access=private)

        function createMFVCDO(obj,controller,configInfoCell)

            if isempty(controller.vcdoData)
                controller.vcdoData=sl_variants.analyzer.datamodel.VCDOData(obj.mMF0Model);
            end
            vcdoData=controller.vcdoData;
            for i=1:length(configInfoCell)
                cfg=configInfoCell{i};
                vcdoData.varConfigs.add(sl_variants.analyzer.datamodel.VariantConfiguration(obj.mMF0Model));
                variantConfig=vcdoData.varConfigs(end);
                variantConfig.configName=cfg{1};
                for j=1:length(cfg{2})
                    cfgVars=cfg{2}(j);
                    variantConfig.ConfigVariables.add(sl_variants.analyzer.datamodel.ConfigurationVariables(obj.mMF0Model));
                    configVar=variantConfig.ConfigVariables(end);
                    configVar.name=cfgVars.Name;
                    configVar.value=cfgVars.Value;
                    configVar.source=cfgVars.Source;
                end

            end
            obj.mController=controller;
        end

        function clearDataModelCache(obj)

            if isempty(obj.mMF0Model.topLevelElements)
                return;
            end
            controller=obj.mMF0Model.topLevelElements;
            if~controller.isvalid
                return;
            end


            if~isa(controller,'sl_variants.analyzer.datamodel.Controller')
                return;
            end
            controller.bdElements.destroyAllContents;
            controller.vcConfigMap.destroyAllContents;
            controller.conditionToAnnotation.destroyAllContents;

            if~isempty(controller.vcdoData)
                controller.vcdoData.varConfigs.destroyAllContents;
                controller.vcdoData.destroy;
            end

            controller.topModelName=obj.mSysName;
        end
    end
end


