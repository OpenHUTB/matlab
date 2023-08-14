classdef VariantConfigurationsObjectDialogSchema<handle








    properties
        ConfigurationsDialogSchema;
        ConstraintsDialogSchema;
        TagPrefix='';
    end

    methods

        function obj=VariantConfigurationsObjectDialogSchema(sourceCacheObj,isStandalone,name)
            obj.ConfigurationsDialogSchema=slvariants.internal.manager.ui.config.ConfigurationsDialogSchema(sourceCacheObj,isStandalone,name);
            obj.ConstraintsDialogSchema=slvariants.internal.manager.ui.config.ConstraintsDialogSchema(sourceCacheObj,isStandalone,name);
            obj.TagPrefix=name;
        end

        function refreshVarConfigsObjDlgSchema(obj,sourceCacheObj,isStandalone,name)
            obj.ConfigurationsDialogSchema=slvariants.internal.manager.ui.config.ConfigurationsDialogSchema(sourceCacheObj,isStandalone,name);
            obj.ConstraintsDialogSchema=slvariants.internal.manager.ui.config.ConstraintsDialogSchema(sourceCacheObj,isStandalone,name);
            obj.TagPrefix=name;
        end


        function dlgstruct=getDialogSchema(obj,~)




            dlgstruct.DialogTitle='';

            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

            reductionMode=obj.ConfigurationsDialogSchema.ReduceAnalyzeModeFlag;

            if reductionMode==ReduceAnalyzeModes.CurrentActCtrlVal
                dlgstruct.Items={obj.getCurrCtrlVarSS()};
            else
                dlgstruct.Items={obj.getConfigAndGlobalConstrTabWidgetStruct()};
            end

            dlgstruct.DialogTag=[obj.TagPrefix,':','variantConfigurationsObjectDialogSchemaTag'];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.LayoutGrid=[1,1];
        end

        function currCtrlVar=getCurrCtrlVarSS(obj)
            currCtrlVar.Name='ctrlVarSS';
            currCtrlVar.Type='spreadsheet';
            currCtrlVar.Tag='currCtrlVarTag';

            currCtrlVar.Columns={
            slvariants.internal.manager.ui.config.VMgrConstants.Name...
            ,slvariants.internal.manager.ui.config.VMgrConstants.Value
            };
            currCtrlVar.Source=obj.ConfigurationsDialogSchema.CtrlVarSSSrc;
            currCtrlVar.Hierarchical=false;
            currCtrlVar.RowSpan=[2,2];
            currCtrlVar.ColSpan=[1,1];
            currCtrlVar.DialogRefresh=true;
            currCtrlVar.Enabled=false;
            currCtrlVar.Mode=true;
        end

        function topTabWidget=getConfigAndGlobalConstrTabWidgetStruct(obj)




            topTabWidget.Name='top tab widget';
            topTabWidget.Type='tab';
            topTabWidget.Tag='configsConstraintsTabWidgetTag';
            topTabWidget.Tabs={obj.getConfigurationsTabStruct(),obj.getGlobalConstraintsTabStruct()};
            topTabWidget.ActiveTab=0;
            topTabWidget.LayoutGrid=[1,1];
            topTabWidget.RowSpan=[2,2];
            topTabWidget.ColSpan=[1,1];
        end

        function configurationsTab=getConfigurationsTabStruct(obj)




            configurationsTab.Name=slvariants.internal.manager.ui.config.VMgrConstants.Configurations;
            configurationsTab.Items={obj.getConfigurationsPanelStruct()};
            configurationsTab.Tag='configurationsTabTag';
        end

        function globalConstraintsTab=getGlobalConstraintsTabStruct(obj)




            globalConstraintsTab.Name=slvariants.internal.manager.ui.config.VMgrConstants.GlobalConstraints;
            globalConstraintsTab.Items={obj.getConstraintsPanelStruct()};
            globalConstraintsTab.Tag='globalConstraintsTabTag';
        end

        function configurationsPanel=getConfigurationsPanelStruct(obj)




            configurationsDlgStruct=obj.ConfigurationsDialogSchema.getDialogSchema();
            configurationsPanel.Name='Configurations';
            configurationsPanel.Type='panel';
            configurationsPanel.Items=configurationsDlgStruct.Items;
            configurationsPanel.Tag='configurationsGroupTag';
            configurationsPanel.LayoutGrid=[1,2];
            configurationsPanel.ColStretch=[0,1];
            configurationsPanel.RowSpan=[1,1];
            configurationsPanel.ColSpan=[1,1];
        end

        function constraintsPanel=getConstraintsPanelStruct(obj)




            constraintsDlgStruct=obj.ConstraintsDialogSchema.getDialogSchema();
            constraintsPanel.Name='Global Constraints';
            constraintsPanel.Type='panel';
            constraintsPanel.Items=constraintsDlgStruct.Items;
            constraintsPanel.Tag='constraintsGroupTag';
            constraintsPanel.LayoutGrid=[1,1];
            constraintsPanel.RowSpan=[1,1];
            constraintsPanel.ColSpan=[1,1];
        end

    end

end



