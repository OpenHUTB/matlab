classdef(Hidden,Sealed)VariantConstraintSource<handle






    properties
        VariantConfigs(1,1)Simulink.VariantConfigurationData;

        ConfigName(1,:)char='';

        Children(1,:)slvariants.internal.manager.ui.config.VariantConstraintRow;

        DialogSchema(1,1);


        IsEnabled(1,1)logical=true;
    end

    methods

        function obj=VariantConstraintSource(aVariantConfigs,aConfig,aDialogSchema,isEnabled)
            if nargin==0
                return;
            end

            obj.VariantConfigs=aVariantConfigs;
            obj.ConfigName=aConfig;
            obj.DialogSchema=aDialogSchema;

            if nargin<=3
                return;
            end
            obj.IsEnabled=isEnabled;
        end

        function children=getChildren(obj,~)



            children=slvariants.internal.manager.ui.config.VariantConstraintRow.empty();
            if~obj.IsEnabled
                return;
            end

            if~isempty(obj.Children)
                children=obj.Children;
                return;
            end

            constrNames=obj.getConstraintNames;
            nVarConstraints=numel(constrNames);

            children(1:nVarConstraints)=slvariants.internal.manager.ui.config.VariantConstraintRow();

            for idx=1:nVarConstraints
                aConstrName=constrNames{idx};
                children(idx)=slvariants.internal.manager.ui.config.VariantConstraintRow(obj,aConstrName,idx);
            end
            obj.Children=children;
        end

        function names=getConstraintNames(obj)
            names=obj.VariantConfigs.getGlobalConstraintNames();
        end


        function fixIndices(obj,selectedIdx)
            for cI=selectedIdx:numel(obj.Children)
                obj.Children(cI).VarConstrIdx=cI;
            end
        end

    end
end


