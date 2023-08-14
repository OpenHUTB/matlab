classdef(Sealed)ConfigCtrlVariablesDialogSchema<handle








    properties(Access=private)

        ConfigCtrlVarsSrc slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesSource;

        ModelName(1,:)char;
    end

    methods
        function obj=ConfigCtrlVariablesDialogSchema(configCtrlVarsInfo,bdName)
            obj.ConfigCtrlVarsSrc=slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesSource(configCtrlVarsInfo,bdName);
            obj.ModelName=bdName;
        end

        function delete(obj)
            obj.ConfigCtrlVarsSrc.delete();
        end

        function configCtrlVarsSrc=getConfigCtrlVariablesSource(obj)
            configCtrlVarsSrc=obj.ConfigCtrlVarsSrc;
        end

        function ctrlVarsData=getCtrlVarsData(obj)
            children=obj.ConfigCtrlVarsSrc.getChildren();
            numChildren=numel(children);
            if numChildren>0
                ctrlVarsData=children(1).getControlVariableInfo();
                for idx=2:numChildren
                    ctrlVarsData(end+1)=children(idx).getControlVariableInfo();
                end
            else
                ctrlVarsData=[];
            end
        end

        function resetCtrlVarsData(obj)

            cfgCtrlVarsInitial=obj.ConfigCtrlVarsSrc.getControlVarsInfoInitial();
            obj.ConfigCtrlVarsSrc=slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesSource(cfgCtrlVarsInitial,obj.ModelName);
        end

        function dlgstruct=getDialogSchema(obj,~)

            dlgstruct.DialogTitle='';
            dlgstruct.Items={obj.getConfigCtrlVarsTopPanelStruct()};
            dlgstruct.DialogTag=[obj.ModelName,':','configCtrlVariablesDialogSchemaTag'];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.LayoutGrid=[1,1];
        end

        function configCtrlVarsTopPanel=getConfigCtrlVarsTopPanelStruct(obj)

            configCtrlVarsTopPanel.Name='configCtrlVarsTopPanel';
            configCtrlVarsTopPanel.Type='panel';
            configCtrlVarsTopPanel.Items={obj.getConfigCtrlVarsButtonsPanelStruct(),...
            obj.getConfigCtrlVarsSpreadSheetStruct()};
            configCtrlVarsTopPanel.Tag='configCtrlVarsTopPanelTag';
            configCtrlVarsTopPanel.LayoutGrid=[2,1];
            configCtrlVarsTopPanel.RowStretch=[0,1];
        end

        function configCtrlVarsButtonsPanel=getConfigCtrlVarsButtonsPanelStruct(obj)

            configCtrlVarsButtonsPanel.Name='configCtrlVarsButtonsPanel';
            configCtrlVarsButtonsPanel.Type='panel';
            configCtrlVarsButtonsPanel.Items={obj.getMoveUpButtonStruct(),...
            obj.getMoveDownButtonStruct(),...
            obj.createSpacer(1,3)};
            configCtrlVarsButtonsPanel.Tag='configCtrlVarsButtonsPanelTag';
            configCtrlVarsButtonsPanel.LayoutGrid=[1,3];
            configCtrlVarsButtonsPanel.RowSpan=[1,1];
            configCtrlVarsButtonsPanel.ColSpan=[1,1];
        end

        function moveUpButton=getMoveUpButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            moveUpButton.ToolTip=VMgrConstants.MoveUpButtonToolTip;
            moveUpButton.FilePath=VMgrConstants.MoveUpButtonIcon;
            moveUpButton.Type='pushbutton';
            moveUpButton.Tag='moveUpButtonTag';
            moveUpButton.RowSpan=[1,1];
            moveUpButton.ColSpan=[1,1];
            moveUpButton.MatlabMethod='slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesDialogSchema.moveControlVariableUp';
            moveUpButton.MatlabArgs={'%dialog',obj};
            moveUpButton.MaximumSize=[25,25];
            moveUpButton.Enabled=false;
        end

        function moveDownButton=getMoveDownButtonStruct(obj)

            import slvariants.internal.manager.ui.config.VMgrConstants
            moveDownButton.ToolTip=VMgrConstants.MoveDownButtonToolTip;
            moveDownButton.FilePath=VMgrConstants.MoveDownButtonIcon;
            moveDownButton.Type='pushbutton';
            moveDownButton.Tag='moveDownButtonTag';
            moveDownButton.RowSpan=[1,1];
            moveDownButton.ColSpan=[2,2];
            moveDownButton.MatlabMethod='slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesDialogSchema.moveControlVariableDown';
            moveDownButton.MatlabArgs={'%dialog',obj};
            moveDownButton.MaximumSize=[25,25];
            moveDownButton.Enabled=false;
        end

        function spacer=createSpacer(~,rowIdx,colIdx)
            spacer.Name='';
            spacer.Type='text';
            spacer.RowSpan=[rowIdx,rowIdx];
            spacer.ColSpan=[colIdx,colIdx];
        end

        function configCtrlVarsSpreadSheet=getConfigCtrlVarsSpreadSheetStruct(obj)

            configCtrlVarsSpreadSheet.Name='configCtrlVarsSpreadSheet';
            configCtrlVarsSpreadSheet.Type='spreadsheet';
            configCtrlVarsSpreadSheet.Tag='configCtrlVarsSpreadSheetTag';
            import slvariants.internal.manager.ui.config.VMgrConstants;
            configCtrlVarsSpreadSheet.Columns={
            VMgrConstants.Name
            VMgrConstants.AutoGenConfigDataType
            VMgrConstants.AutoGenConfigValues};
            configCtrlVarsSpreadSheet.Source=obj.ConfigCtrlVarsSrc;
            configCtrlVarsSpreadSheet.Hierarchical=false;
            configCtrlVarsSpreadSheet.RowSpan=[2,2];
            configCtrlVarsSpreadSheet.ColSpan=[1,1];
            configCtrlVarsSpreadSheet.DialogRefresh=true;
            configCtrlVarsSpreadSheet.Enabled=true;
            configCtrlVarsSpreadSheet.Mode=true;
            configCtrlVarsSpreadSheet.SelectionChangedCallback=@(tag,sels,dlg)slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesDialogSchema.ctrlVarSelectionChanged(tag,sels,dlg,obj);
            configCtrlVarsSpreadSheet.Config='{ "enablesort":false, "enablegrouping":false }';
        end

    end

    methods(Static)

        function dummyOut=ctrlVarSelectionChanged(~,sels,dlg,obj)

            dummyOut=true;
            if numel(sels)==1
                ctrlVarRows=obj.ConfigCtrlVarsSrc.getChildren();
                obj.ConfigCtrlVarsSrc.setSelectedCtrlVarName(sels{1}.getControlVariableInfo().Name);
                moveUpBtnEnableFlag=~isequal(sels{1}.getControlVariableInfo().Name,ctrlVarRows(1).getControlVariableInfo().Name);
                moveDownBtnEnableFlag=~isequal(sels{1}.getControlVariableInfo().Name,ctrlVarRows(end).getControlVariableInfo().Name);
                dlg.setEnabled('moveUpButtonTag',moveUpBtnEnableFlag);
                dlg.setEnabled('moveDownButtonTag',moveDownBtnEnableFlag);
            else

                obj.ConfigCtrlVarsSrc.setSelectedCtrlVarName('');
                dlg.setEnabled('moveUpButtonTag',false);
                dlg.setEnabled('moveDownButtonTag',false);
            end
        end

        function moveControlVariableUp(dlg,obj)
            if isempty(obj.ConfigCtrlVarsSrc.getSelectedCtrlVarName())
                return;
            end

            obj.ConfigCtrlVarsSrc.moveControlVariableUp(obj.ConfigCtrlVarsSrc.getSelectedCtrlVarName());
            dlg.refresh;
            configCtrlVarSSInterface=dlg.getWidgetInterface('configCtrlVarsSpreadSheetTag');
            selectedRows=configCtrlVarSSInterface.getSelection();
            slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesDialogSchema.ctrlVarSelectionChanged('configCtrlVarsSpreadSheetTag',selectedRows,dlg,obj);
        end

        function moveControlVariableDown(dlg,obj)
            if isempty(obj.ConfigCtrlVarsSrc.getSelectedCtrlVarName())
                return;
            end

            obj.ConfigCtrlVarsSrc.moveControlVariableDown(obj.ConfigCtrlVarsSrc.getSelectedCtrlVarName());
            dlg.refresh;
            configCtrlVarSSInterface=dlg.getWidgetInterface('configCtrlVarsSpreadSheetTag');
            selectedRows=configCtrlVarSSInterface.getSelection();
            slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesDialogSchema.ctrlVarSelectionChanged('configCtrlVarsSpreadSheetTag',selectedRows,dlg,obj);
        end
    end
end
