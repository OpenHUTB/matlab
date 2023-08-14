classdef VariableGroupsDialogSchema<handle



    properties
        VarGrpNamesSSSrc(1,1)slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSSource;
        VarGrpSSSrc slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSSource;
    end

    properties(Dependent,SetAccess=private,GetAccess=public)
        TagId;
    end

    methods
        function tagId=get.TagId(obj)
            tagId=obj.VarGrpNamesSSSrc.ModelName;
        end
    end

    methods(Hidden)
        function obj=VariableGroupsDialogSchema(cachedSrc)
            obj.VarGrpNamesSSSrc=cachedSrc;
            obj.VarGrpSSSrc=obj.VarGrpNamesSSSrc.RootRow.VariableGroupsSrc;
        end

        function dlg=getDialogSchema(obj,~)
            dlg.DialogTitle='';
            dlg.Items={obj.getMainPanel()};
            dlg.DialogTag='varGrpsDDG';
            dlg.DialogMode='Slim';
            dlg.StandaloneButtonSet={''};
            dlg.EmbeddedButtonSet={''};
            dlg.LayoutGrid=[1,1];
        end

        function mdlName=getModelName(obj)
            mdlName=obj.VarGrpNamesSSSrc.ModelName;
        end
    end

    methods(Access='private')

        function panel=getMainPanel(obj)
            panel.Name='mainPanel';
            panel.Type='panel';
            panel.Tag='mainPanel';
            panel.LayoutGrid=[2,1];
            panel.RowStretch=[0,1];
            panel.RowSpan=[1,1];
            panel.ColSpan=[1,1];
            panel.Items={obj.getVariableGroupNamesPanel(),obj.getVariableGroupPanel()};
            panel.Enabled=true;
        end

        function varGrpNamesPanel=getVariableGroupNamesPanel(obj)
            varGrpNamesPanel.Name='varGrpNamesPanel';
            varGrpNamesPanel.Type='panel';
            varGrpNamesPanel.Items={obj.getVarGrpButtonsPanelStruct(),...
            obj.getVariableGroupNamesSS()};
            varGrpNamesPanel.LayoutGrid=[2,1];
            varGrpNamesPanel.Tag='varGrpNamesPanelTag';
            varGrpNamesPanel.RowSpan=[1,1];
            varGrpNamesPanel.ColSpan=[1,1];
        end

        function addButton=getAddVarGrpButtonStruct(~)


            import slvariants.internal.manager.ui.config.VMgrConstants
            addButton.ToolTip=VMgrConstants.AddVarGrpButtonToolTip;
            addButton.FilePath=VMgrConstants.AddRowIcon;
            addButton.Type='pushbutton';
            addButton.Tag='addVarGrpButtonTag';
            addButton.RowSpan=[1,1];
            addButton.ColSpan=[1,1];
            addButton.MatlabMethod='slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow.addVarGrpCB';
            addButton.MatlabArgs={'%dialog'};
            addButton.MaximumSize=[25,25];
        end

        function deleteButton=getDeleteVarGrpButtonStruct(~)


            import slvariants.internal.manager.ui.config.VMgrConstants
            deleteButton.ToolTip=VMgrConstants.DeleteVarGrpButtonToolTip;
            deleteButton.FilePath=VMgrConstants.DeleteRowIcon;
            deleteButton.Type='pushbutton';
            deleteButton.Tag='deleteVarGrpButtonTag';
            deleteButton.RowSpan=[1,1];
            deleteButton.ColSpan=[2,2];
            deleteButton.MatlabMethod='slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow.deleteVarGrpCB';
            deleteButton.MatlabArgs={'%dialog'};
            deleteButton.MaximumSize=[25,25];
            deleteButton.Enabled=false;
        end

        function copyButton=getCopyVarGrpButtonStruct(~)


            import slvariants.internal.manager.ui.config.VMgrConstants
            copyButton.ToolTip=VMgrConstants.CopyVarGrpButtonToolTip;
            copyButton.FilePath=VMgrConstants.CopyRowIcon;
            copyButton.Type='pushbutton';
            copyButton.Tag='copyVarGrpButtonTag';
            copyButton.RowSpan=[1,1];
            copyButton.ColSpan=[3,3];
            copyButton.MatlabMethod='slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow.copyVarGrpCB';
            copyButton.MatlabArgs={'%dialog'};
            copyButton.MaximumSize=[25,25];
            copyButton.Enabled=false;
        end

        function spacer=createSpacer(~,rowIdx,colIdx)
            spacer.Name='';
            spacer.Type='text';
            spacer.RowSpan=[rowIdx,rowIdx];
            spacer.ColSpan=[colIdx,colIdx];
        end

        function varGrpButtonsPanel=getVarGrpButtonsPanelStruct(obj)


            varGrpButtonsPanel.Name='varGrpsButtonsPanel';
            varGrpButtonsPanel.Type='panel';
            varGrpButtonsPanel.Items={obj.getAddVarGrpButtonStruct(),...
            obj.getCopyVarGrpButtonStruct(),...
            obj.getDeleteVarGrpButtonStruct(),...
            obj.createSpacer(1,4)};
            varGrpButtonsPanel.Tag='varGrpsButtonsPanelTag';
            varGrpButtonsPanel.LayoutGrid=[1,4];
            varGrpButtonsPanel.RowSpan=[1,1];
            varGrpButtonsPanel.ColSpan=[1,1];
            varGrpButtonsPanel.Visible=true;
        end

        function varGrpNamesSS=getVariableGroupNamesSS(obj)
            import slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;
            varGrpNamesSS.Name='varGrpNamesSS';
            varGrpNamesSS.Type='spreadsheet';
            varGrpNamesSS.Tag='varGrpNamesSS';
            varGrpNamesSS.Columns={
            slvariants.internal.manager.ui.config.VMgrConstants.SelectCol
            slvariants.internal.manager.ui.config.VMgrConstants.VariableGroupTitle
            };

            selColName=slvariants.internal.manager.ui.config.VMgrConstants.SelectCol;
            varGrpNamesSS.Config=['{ "hidecolumns":true, "columns":['...
            ,' {"name" : "',selColName,'", "width" : 21, "minsize" : 21, "maxsize" : 21}] }'];
            varGrpNamesSS.Source=obj.VarGrpNamesSSSrc;
            varGrpNamesSS.Hierarchical=false;
            varGrpNamesSS.RowSpan=[2,2];
            varGrpNamesSS.ColSpan=[1,1];
            varGrpNamesSS.DialogRefresh=true;
            varGrpNamesSS.Enabled=true;
            varGrpNamesSS.Mode=true;
            varGrpNamesSS.ItemClickedCallback=@VariableGroupNamesSSRow.variableGroupNameClicked;
            varGrpNamesSS.SelectionChangedCallback=@VariableGroupNamesSSRow.varGrpSelectionChanged;
        end

        function panel=getVariableGroupPanel(obj)
            panel.Name='varGrpPanel';
            panel.Type='panel';
            panel.Tag='varGrpsPanel';
            panel.LayoutGrid=[2,1];
            panel.RowStretch=[0,1];
            panel.RowSpan=[2,2];
            panel.ColSpan=[1,1];
            panel.Items={obj.getGroupNameLabel(),obj.getVariableGroupSS()};
            panel.Enabled=true;
        end

        function label=getGroupNameLabel(obj)
            label.Name=obj.VarGrpSSSrc.getGroupName();
            label.Type='text';
            label.Tag='grpNameLabelTag';
            label.Bold=true;
            label.RowSpan=[1,1];
            label.ColSpan=[1,1];
        end

        function varGrpSS=getVariableGroupSS(obj)
            varGrpSS.Name='varGrpSS';
            varGrpSS.Type='spreadsheet';
            varGrpSS.Tag='varGrpSS';
            varGrpSS.Columns={
' '...
            ,slvariants.internal.manager.ui.config.VMgrConstants.Name...
            ,slvariants.internal.manager.ui.config.VMgrConstants.Values...
            ,slvariants.internal.manager.ui.config.VMgrConstants.ReferenceValue...
            ,slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime...
            };
            varGrpSS.Source=obj.VarGrpSSSrc;
            varGrpSS.Hierarchical=false;
            varGrpSS.RowSpan=[2,2];
            varGrpSS.ColSpan=[1,1];
            varGrpSS.DialogRefresh=true;
            varGrpSS.Enabled=true;
        end

    end

    methods(Static)

        function modifyGroupNameText(currRow,dlg)
            grpName=currRow.GroupName;
            dlg.setWidgetValue('grpNameLabelTag',grpName);
        end
    end
end


