classdef(Sealed)GeneratedConfigsDialogSchema<handle








    properties(Access=private)

        GeneratedConfigsSrc slvariants.internal.manager.ui.configgen.GeneratedConfigsSource;

        ConfigCtrlVarsInfo;

        ModelName(1,:)char;
    end

    methods
        function obj=GeneratedConfigsDialogSchema(configCtrlVarsInfo,bdName)
            obj.GeneratedConfigsSrc=slvariants.internal.manager.ui.configgen.GeneratedConfigsSource(Simulink.VariantConfigurationData(),{},bdName);
            obj.ConfigCtrlVarsInfo=configCtrlVarsInfo;
            obj.ModelName=bdName;
        end

        function delete(obj)
            obj.GeneratedConfigsSrc.delete();
        end

        function setGeneratedConfigurations(obj,vcdGenerated,configsInfo,configCtrlVarsInfo,dlg)
            obj.GeneratedConfigsSrc=slvariants.internal.manager.ui.configgen.GeneratedConfigsSource(vcdGenerated,configsInfo,obj.ModelName);

            obj.ConfigCtrlVarsInfo=configCtrlVarsInfo;
            generatedConfigsSSInterface=dlg.getWidgetInterface('generatedConfigsSpreadSheetTag');
            columnNames=obj.getColumnNames();
            generatedConfigsSSInterface.setColumns(columnNames,'','',false);
        end

        function generatedCfgsSrc=getGeneratedConfigsSource(obj)
            generatedCfgsSrc=obj.GeneratedConfigsSrc;
        end

        function updateGenerateArgsLabel(~,argsStr,dlg)
            dlg.setWidgetValue('generateArgsLabelTag',argsStr);
        end

        function configs=getSelectedConfigurations(obj)
            configs=[];
            childRows=obj.GeneratedConfigsSrc.getChildren();
            for idx=1:numel(childRows)
                genCfgRow=childRows(idx);
                if genCfgRow.getIsSelected()
                    newConfig=obj.rearrangeControlVarsInConfig(genCfgRow.getConfiguration());
                    configs=[configs,newConfig];
                end
            end
        end

        function dlgstruct=getDialogSchema(obj,~)

            dlgstruct.DialogTitle='';
            dlgstruct.Items={obj.getGeneratedConfigsTopPanelStruct()};
            dlgstruct.DialogTag=[obj.ModelName,':','generatedConfigsDialogSchemaTag'];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.LayoutGrid=[1,1];
        end

        function configCtrlVarsTopPanel=getGeneratedConfigsTopPanelStruct(obj)

            configCtrlVarsTopPanel.Name='generatedConfigsTopPanel';
            configCtrlVarsTopPanel.Type='panel';
            configCtrlVarsTopPanel.Items={obj.getGeneratedConfigsButtonsPanelStruct(),...
            obj.getGeneratedConfigsSpreadSheetStruct()};
            configCtrlVarsTopPanel.Tag='generatedConfigsTopPanelTag';
            configCtrlVarsTopPanel.LayoutGrid=[2,1];
        end

        function configCtrlVarsButtonsPanel=getGeneratedConfigsButtonsPanelStruct(obj)

            configCtrlVarsButtonsPanel.Name='genConfigsButtonsPanel';
            configCtrlVarsButtonsPanel.Type='panel';
            configCtrlVarsButtonsPanel.Items={obj.getSelectAllButtonStruct(),...
            obj.getDeselectAllButtonStruct(),...
            obj.getGenerateArgsLabelStruct()};
            configCtrlVarsButtonsPanel.Tag='genConfigsButtonsPanelTag';
            configCtrlVarsButtonsPanel.LayoutGrid=[1,3];
            configCtrlVarsButtonsPanel.RowSpan=[1,1];
            configCtrlVarsButtonsPanel.ColSpan=[1,1];
        end

        function selectAllButton=getSelectAllButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            selectAllButton.ToolTip=VMgrConstants.SelectAllButtonToolTip;
            selectAllButton.FilePath=VMgrConstants.SelectAllButtonIcon;
            selectAllButton.Type='pushbutton';
            selectAllButton.Tag='selectAllButtonTag';
            selectAllButton.RowSpan=[1,1];
            selectAllButton.ColSpan=[1,1];
            selectAllButton.MatlabMethod='slvariants.internal.manager.ui.configgen.GeneratedConfigsDialogSchema.selectAllButtonClicked';
            selectAllButton.MatlabArgs={'%dialog',obj};
            selectAllButton.MaximumSize=[25,25];
            selectAllButton.Enabled=numel(obj.GeneratedConfigsSrc.getGeneratedVCD().Configurations)>0;
        end

        function deselectAllButton=getDeselectAllButtonStruct(obj)

            import slvariants.internal.manager.ui.config.VMgrConstants
            deselectAllButton.ToolTip=VMgrConstants.DeselectAllButtonToolTip;
            deselectAllButton.FilePath=VMgrConstants.DeselectAllButtonIcon;
            deselectAllButton.Type='pushbutton';
            deselectAllButton.Tag='deselectAllButtonTag';
            deselectAllButton.RowSpan=[1,1];
            deselectAllButton.ColSpan=[2,2];
            deselectAllButton.MatlabMethod='slvariants.internal.manager.ui.configgen.GeneratedConfigsDialogSchema.deselectAllButtonClicked';
            deselectAllButton.MatlabArgs={'%dialog',obj};
            deselectAllButton.MaximumSize=[25,25];
            deselectAllButton.Enabled=numel(obj.GeneratedConfigsSrc.getGeneratedVCD().Configurations)>0;
        end

        function generateCmdLabelInfo=getGenerateArgsLabelStruct(~)


            generateCmdLabelInfo.Name='';
            generateCmdLabelInfo.Type='text';
            generateCmdLabelInfo.Tag='generateArgsLabelTag';
            generateCmdLabelInfo.Bold=false;
            generateCmdLabelInfo.RowSpan=[1,1];
            generateCmdLabelInfo.ColSpan=[3,3];
        end

        function genCfgsSpreadSheet=getGeneratedConfigsSpreadSheetStruct(obj)

            genCfgsSpreadSheet.Name='generatedConfigsSpreadSheet';
            genCfgsSpreadSheet.Type='spreadsheet';
            genCfgsSpreadSheet.Tag='generatedConfigsSpreadSheetTag';
            genCfgsSpreadSheet.Hierarchical=false;
            genCfgsSpreadSheet.RowSpan=[2,2];
            genCfgsSpreadSheet.ColSpan=[1,1];
            genCfgsSpreadSheet.DialogRefresh=true;
            genCfgsSpreadSheet.Enabled=true;
            genCfgsSpreadSheet.Mode=true;
            genCfgsSpreadSheet.Columns=obj.getColumnNames();
            genCfgsSpreadSheet.Source=obj.GeneratedConfigsSrc;
            import slvariants.internal.manager.ui.config.VMgrConstants;
            genCfgsSpreadSheet.Config=['{"columns":['...
            ,' {"name" : "',VMgrConstants.SelectCol,'", "width" : 21, "minsize" : 21, "maxsize" : 21},'...
            ,' {"name" : "',VMgrConstants.SerialNum,'", "width" : 30, "minsize" : 15, "maxsize" : 75}] }'];
        end

    end

    methods(Access=private)

        function columnNames=getColumnNames(obj)
            numOfFixedCols=4;
            numOfCtrlVars=numel(obj.ConfigCtrlVarsInfo);
            columnNames=cell(numOfCtrlVars+numOfFixedCols,1);

            import slvariants.internal.manager.ui.config.VMgrConstants;
            columnNames{1}=VMgrConstants.SelectCol;
            columnNames{2}=VMgrConstants.SerialNum;
            columnNames{3}=VMgrConstants.Name;
            columnNames{4}=VMgrConstants.AutoGenConfigValidityStatus;
            for idx=1:numOfCtrlVars
                columnNames{idx+numOfFixedCols}=obj.ConfigCtrlVarsInfo(idx).Name;
            end
        end

        function reArrangedConfig=rearrangeControlVarsInConfig(obj,config)


            reArrangedConfig=config;
            numOfCtrlVars=numel(obj.ConfigCtrlVarsInfo);
            for idx=1:numOfCtrlVars
                for cfgIdx=1:numel(config.ControlVariables)
                    if isequal(obj.ConfigCtrlVarsInfo(idx).Name,config.ControlVariables(cfgIdx).Name)
                        reArrangedConfig.ControlVariables(idx)=config.ControlVariables(cfgIdx);
                        break;
                    end
                end
            end
        end
    end

    methods(Static)
        function selectAllButtonClicked(dlg,obj)
            if isempty(obj.GeneratedConfigsSrc)
                return;
            end
            obj.GeneratedConfigsSrc.selectAllConfigs();
            dlg.refresh();
        end

        function deselectAllButtonClicked(dlg,obj)
            if isempty(obj.GeneratedConfigsSrc)
                return;
            end
            obj.GeneratedConfigsSrc.deselectAllConfigs();
            dlg.refresh();
        end
    end
end
