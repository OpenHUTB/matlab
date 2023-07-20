classdef VariantConfigurationSource<handle






    properties(SetAccess=private)
        Children(1,:)slvariants.internal.manager.ui.config.VariantConfigurationRow;



        CtrlVarSources(1,:)slvariants.internal.manager.ui.config.ControlVariableSource;


        GlobalWksConfig(1,1)struct=slvariants.internal.config.types.getConfigurationStruct();




        DialogSchema(1,1)

        VariantConfigs(1,1)Simulink.VariantConfigurationData;
    end

    methods(Access=private)

        function populateChildren(obj)
            numberOfConfigs=numel(obj.VariantConfigs.Configurations);

            children(1:numberOfConfigs)=slvariants.internal.manager.ui.config.VariantConfigurationRow();

            for idx=1:numberOfConfigs
                children(idx)=...
                slvariants.internal.manager.ui.config.VariantConfigurationRow(...
                obj,obj.VariantConfigs.Configurations(idx).Name,idx,...
                obj.CtrlVarSources(idx));
            end

            obj.Children=children;
        end

        function createControlVariableSources(obj)
            nCtrlVarSources=numel(obj.VariantConfigs.Configurations);
            ctrlVarSources(1:nCtrlVarSources)=slvariants.internal.manager.ui.config.ControlVariableSource();

            for idx=1:nCtrlVarSources
                ctrlVarSources(idx)=slvariants.internal.manager.ui.config.ControlVariableSource(...
                obj.VariantConfigs,obj.VariantConfigs.Configurations(idx).Name,obj.DialogSchema,false);
            end

            obj.CtrlVarSources=ctrlVarSources;
        end

        function incrementConfigIndices(obj,index)
            for idx=index:length(obj.Children)
                obj.Children(idx).VarConfigIdx=obj.Children(idx).VarConfigIdx+1;
            end
        end

        function decrementConfigIndices(obj,index)
            for idx=index:length(obj.Children)
                obj.Children(idx).VarConfigIdx=obj.Children(idx).VarConfigIdx-1;
            end
        end

        function updateChildrenAndSources(obj,newConfigName,newConfigIdx)
            aCtrlVarSSSrc=slvariants.internal.manager.ui.config.ControlVariableSource(obj.VariantConfigs,newConfigName,obj.DialogSchema,false);
            newRowObj=slvariants.internal.manager.ui.config.VariantConfigurationRow(obj,newConfigName,newConfigIdx,aCtrlVarSSSrc);
            obj.Children=[obj.Children(1:newConfigIdx-1),newRowObj,obj.Children(newConfigIdx:end)];
            obj.incrementConfigIndices(newConfigIdx+1);
            obj.CtrlVarSources=[obj.CtrlVarSources(1:newConfigIdx-1),aCtrlVarSSSrc,obj.CtrlVarSources(newConfigIdx:end)];
        end

    end

    methods(Hidden)

        function obj=VariantConfigurationSource(dialogSchema)
            if nargin==0
                return;
            end
            obj.VariantConfigs=dialogSchema.SourceObj;
            obj.DialogSchema=dialogSchema;
            if~obj.DialogSchema.IsStandalone
                obj.GlobalWksConfig.Name=dialogSchema.ConfigCatalogCacheWrapper.ConfigWorkspace;
            end
            dialogSchema.SourceObj.updateSource(slvariants.internal.config.utils.getGlobalWorkspaceName(''),...
            slvariants.internal.config.utils.getGlobalWorkspaceName_R2020b(''));
            obj.createControlVariableSources();
        end

        function children=getChildren(obj,~)


            if isempty(obj.Children)
                obj.populateChildren();
            end
            children=obj.Children;
        end

        function addConfiguration(obj,config,configIdx)
            catalog=obj.VariantConfigs;
            catalog.setConfigurations([catalog.Configurations(1:configIdx-1),config,catalog.Configurations(configIdx:end)]);
            obj.updateChildrenAndSources(config.Name,configIdx);
        end

        function copyConfiguration(obj,newConfigName,configIdx)
            catalog=obj.VariantConfigs;
            catalog.copyConfigurationByPos(configIdx,newConfigName);
            obj.updateChildrenAndSources(newConfigName,configIdx+1);
        end

        function deleteConfiguration(obj,configIdx)
            obj.Children(configIdx)=[];
            obj.decrementConfigIndices(configIdx);

            obj.CtrlVarSources(configIdx)=[];

            configNames=obj.VariantConfigs.getConfigurationNames();
            toBeRemovedconfigName=configNames{configIdx};
            prefConfigName=obj.VariantConfigs.getPreferredConfiguration();
            if strcmp(toBeRemovedconfigName,prefConfigName)
                obj.VariantConfigs.setPreferredConfiguration('');
            end

            obj.VariantConfigs.removeConfigurationByPos(configIdx);
        end

        function child=getChildByName(obj,configName)
            child=[];
            for i=1:numel(obj.Children)
                if strcmp(obj.Children(i).VarConfigName,configName)
                    child=obj.Children(i);
                    break;
                end
            end
        end

        function configNames=getConfigurationNames(obj)
            configNames=obj.VariantConfigs.getConfigurationNames();
        end

        function updateGlobalWksConfigName(obj,newName)
            obj.GlobalWksConfig.Name=newName;
            if obj.DialogSchema.IsStandalone
                return;
            end


        end
    end
end


