classdef GlobalConfigurationSource<handle




    properties(SetAccess=private)
        Children(1,1)slvariants.internal.manager.ui.config.VariantConfigurationRow;

        CtrlVarSources(1,1)slvariants.internal.manager.ui.config.ControlVariableSource;




        DialogSchema(1,1)

        VariantConfigs(1,1)Simulink.VariantConfigurationData;
    end

    methods(Hidden)

        function obj=GlobalConfigurationSource(dialogSchema)
            if nargin==0
                return;
            end
            obj.VariantConfigs=dialogSchema.SourceObj;
            obj.DialogSchema=dialogSchema;
            globalWSName=dialogSchema.ConfigCatalogCacheWrapper.ConfigWorkspace;
            obj.CtrlVarSources=slvariants.internal.manager.ui.config.ControlVariableSource(...
            obj.VariantConfigs,globalWSName,obj.DialogSchema,true);
            obj.Children=slvariants.internal.manager.ui.config.VariantConfigurationRow(...
            obj,globalWSName,0,obj.CtrlVarSources);
        end

        function children=getChildren(obj,~)
            children=obj.Children;
        end

        function updateGlobalWksConfigName(obj,newName)
            if obj.DialogSchema.IsStandalone
                return;
            end
            obj.Children.VarConfigName=newName;
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
    end
end


