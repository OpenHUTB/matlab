classdef(Sealed,Hidden)ModelHierTitleViewDialogSchema




    methods(Hidden)

        function obj=ModelHierTitleViewDialogSchema(modelName)
            obj.ModelHandle=get_param(modelName,'Handle');
        end

        function dlgStruct=getDialogSchema(obj,~)


            dlgStruct.DialogTitle='';
            dlgStruct.DialogTag='mdlHierTitleViewDlg';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.Spacing=0;
            dlgStruct.IsScrollable=false;
            dlgStruct.ContentsMargins=[0,0,0,0];

            if obj.getIsCompBrowserTab()
                dlgStruct.Items={obj.getCompBrowserTitleViewPanel()};
            else
                dlgStruct.Items={obj.getModelHierTitleViewPanel()};
            end
        end

        function isCBTab=getIsCompBrowserTab(obj)
            isCBTab=false;
            if~slvariants.internal.manager.core.hasOpenVM(obj.ModelHandle)
                return;
            end
            vmStudioHandle=slvariants.internal.manager.core.getStudio(obj.ModelHandle);
            ssModelHierComp=vmStudioHandle.getComponent('GLUE2:SpreadSheet',...
            message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
            if ssModelHierComp.getCurrentTab()>2
                isCBTab=true;
            end
        end

        function mainPanel=getModelHierTitleViewPanel(obj)
            actConfigLabel.Type='text';
            actConfigLabel.Name=getString(message('Simulink:VariantManagerUI:ModelHierConfigActivatedFor'));
            actConfigLabel.Tag='activatedConfigLabelTag';
            actConfigLabel.Bold=false;

            actConfigLabel.ColSpan=[1,1];
            actConfigLabel.RowSpan=[1,1];
            actConfigLabel.Alignment=1;

            actConfigName.Type='text';
            actConfigName.Name=obj.getActivatedConfig();
            actConfigName.Tag='configNameLabelTag';
            actConfigName.Bold=true;

            actConfigName.ColSpan=[2,2];
            actConfigName.RowSpan=[1,1];
            actConfigName.Alignment=1;
            actConfigName.DialogRefresh=true;

            mainPanel.Type='panel';
            mainPanel.ColSpan=[1,1];
            mainPanel.RowSpan=[1,1];
            mainPanel.LayoutGrid=[1,2];
            mainPanel.ColStretch=[0,1];
            mainPanel.Items={actConfigLabel,actConfigName};
        end

        function mainPanel=getCompBrowserTitleViewPanel(~)
            compBrowserHint.Type='text';
            compBrowserHint.Name=message('Simulink:VariantManagerUI:CompBrowserViewTabTooltip').getString();
            compBrowserHint.Tag='compBrowserHintTextTag';
            compBrowserHint.Bold=false;

            compBrowserHint.ColSpan=[1,1];
            compBrowserHint.RowSpan=[1,1];
            compBrowserHint.Alignment=1;





            mainPanel.Type='panel';
            mainPanel.ColSpan=[1,1];
            mainPanel.RowSpan=[1,1];
            mainPanel.LayoutGrid=[1,1];
            mainPanel.Items={compBrowserHint};
        end

        function activatedConfig=getActivatedConfig(obj)
            activatedConfig=get_param(obj.ModelHandle,'DataDictionary');
            if isempty(activatedConfig)
                activatedConfig=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceTitle;
            end
            if~slvariants.internal.manager.core.hasOpenVM(obj.ModelHandle)
                return;
            end
            configsDlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(getfullname(obj.ModelHandle));
            if isempty(configsDlg)
                return;
            end
            configsSchema=configsDlg.getSource();
            activatedConfig=configsSchema.ActivatedConfig;
        end

    end

    properties(SetAccess=private,GetAccess=public)

        ModelHandle(1,1)double;

    end

end


