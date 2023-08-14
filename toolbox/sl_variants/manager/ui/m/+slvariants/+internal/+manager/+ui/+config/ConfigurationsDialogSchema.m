classdef ConfigurationsDialogSchema<handle









    properties(SetAccess=private,GetAccess=public)

        SourceObj(1,1)Simulink.VariantConfigurationData;

        ConfigCatalogCacheWrapper slvariants.internal.manager.ui.config.VariantConfigurationsCacheWrapper;

        ConfigSSSrc slvariants.internal.manager.ui.config.VariantConfigurationSource;

        GlobalConfigSSSrc slvariants.internal.manager.ui.config.GlobalConfigurationSource;

        CtrlVarSSSrc slvariants.internal.manager.ui.config.ControlVariableSource;



        ControlVariableUsageMap;

        IsHierarchy(1,1)logical=false;

        ConfigDescription='';

        SelectedConfig=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceTitle;

        SelectedCtrlVarIdx=1;

        IsStandalone(1,1)logical=false;

        BDHandle;

        ConfigObjVarName='';

        EditParamListenerHandle;

        EditParamUpdateTimer=[];

        IsSelectedConfigActivatedConfig(1,1)logical=true;

        EditParamDlgHandle;

        ActivatedConfig(1,:)char='';
    end

    properties(Dependent,SetAccess=private,GetAccess=public)
        BDName;

        TagId;
    end

    properties(Hidden)
        ReduceAnalyzeModeFlag=slvariants.internal.manager.ui.config.ReduceAnalyzeModes.Unset;

        IsControlVarsTableDirty(1,1)logical=true;
        ExportedConfig(1,:)char='';
    end

    properties(Access=private)
    end

    properties(SetAccess=private,GetAccess=public)
        IsCompBrowserVisible(1,1)logical=false;
    end

    properties(SetAccess=public,GetAccess=public)
        IsSourceObjDirtyFlag(1,1)logical=false;
        CompBrowserSSSrc slvariants.internal.manager.ui.compbrowser.CompBrowserSSSource;
    end

    properties(Constant)
        SelectColSize='21';
    end

    methods

        function obj=ConfigurationsDialogSchema(sourceCacheObj,isStandalone,nameOrHandle)


            import slvariants.internal.manager.ui.config.VariantConfigurationSource
            import slvariants.internal.manager.ui.config.GlobalConfigurationSource
            import slvariants.internal.manager.ui.config.ControlVariableSource

            if nargin==0
                return;
            end

            obj.IsStandalone=isStandalone;
            if isStandalone

                obj.ConfigObjVarName=nameOrHandle;
            else

                obj.BDHandle=nameOrHandle;
                obj.ConfigObjVarName=get_param(obj.BDName,'VariantConfigurationObject');
            end

            obj.ConfigCatalogCacheWrapper=sourceCacheObj;
            obj.SourceObj=sourceCacheObj.VariantConfigurationCatalogCache;
            obj.ConfigSSSrc=VariantConfigurationSource(obj);

            if obj.IsStandalone
                if~isempty(obj.SourceObj.Configurations)
                    obj.SelectedConfig=obj.SourceObj.Configurations(1).Name;
                    obj.CtrlVarSSSrc=obj.ConfigSSSrc.CtrlVarSources(1);
                else
                    obj.SelectedConfig='';
                    isEnabled=false;
                    obj.CtrlVarSSSrc=ControlVariableSource(...
                    obj.SourceObj,'',obj,false,isEnabled);
                end
            else
                obj.SelectedConfig=sourceCacheObj.ConfigWorkspace;
                obj.GlobalConfigSSSrc=GlobalConfigurationSource(obj);
                obj.CtrlVarSSSrc=obj.GlobalConfigSSSrc.CtrlVarSources(1);
            end

            if obj.IsStandalone
                return;
            end

            obj.ControlVariableUsageMap=containers.Map('keyType','char','valueType','any');


            obj.ActivatedConfig=obj.GlobalConfigSSSrc.Children(1).VarConfigName;
            obj.CompBrowserSSSrc=slvariants.internal.manager.ui.compbrowser.CompBrowserSSSource.empty;
            obj.ExportedConfig=obj.ConfigCatalogCacheWrapper.ConfigWorkspace;
        end


        function delete(obj)

            obj.ControlVariableUsageMap=containers.Map('keyType','char','valueType','any');

            if~isempty(obj.EditParamDlgHandle)...
                &&isa(obj.EditParamDlgHandle,'DAStudio.Dialog')...
                &&obj.EditParamDlgHandle.isVisible()



                delete(obj.EditParamDlgHandle);
            end
        end

        function tagId=get.TagId(obj)
            if(obj.IsStandalone)
                tagId=obj.ConfigObjVarName;
            else
                tagId=getfullname(obj.BDHandle);
            end
        end

        function bdName=get.BDName(obj)
            if(obj.IsStandalone)
                bdName='';
            else
                bdName=getfullname(obj.BDHandle);
            end
        end

        function setControlVariablesUsageMap(obj,map)
            obj.ControlVariableUsageMap=map;
        end


        function priorActivatedConfigName=updateActivatedConfigName(obj)

            priorActivatedConfigName=obj.ActivatedConfig;
            obj.ActivatedConfig=obj.SelectedConfig;
            obj.IsSelectedConfigActivatedConfig=true;
        end
    end

    methods(Hidden)

        function dlgstruct=getDialogSchema(obj,~)

            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag='configurationsDialogSchemaTag';

            dlgstruct.DialogMode='Slim';
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.Spacing=0;
            dlgstruct.OpenCallback=@obj.openCB;

            if(obj.ReduceAnalyzeModeFlag==ReduceAnalyzeModes.CurrentActCtrlVal)
                dlgstruct.Items={obj.getCurrCtrlVarSS};
                dlgstruct.LayoutGrid=[1,1];
            else
                dlgstruct.Items={obj.getConfigurationsPanel,...
                obj.getControlVarsPanel,...
                obj.getPrefConfigPanel};
                dlgstruct.LayoutGrid=[3,1];
                dlgstruct.RowStretch=[0,1,0];
            end

        end

        function stopAndDeleteTimer(obj)
            if isa(obj.EditParamUpdateTimer,'timer')
                try %#ok<TRYNC>
                    obj.EditParamUpdateTimer.stop();
                    delete(obj.EditParamUpdateTimer);
                end
            end
        end
    end

    methods(Access={?mwslvariants.variantmanager.ui.v2helpers.BaseVMGRV2Tester,...
        ?slvariants.internal.manager.ui.config.VariantConfigurationsObjectDialogSchema,...
        ?slvariants.internal.manager.ui.config.VariantConfigurationRow})

        function currCtrlVar=getCurrCtrlVarSS(obj)
            currCtrlVar.Name='ctrlVarSS';
            currCtrlVar.Type='spreadsheet';
            currCtrlVar.Tag='currCtrlVarTag';

            currCtrlVar.Columns={
            slvariants.internal.manager.ui.config.VMgrConstants.Name...
            ,slvariants.internal.manager.ui.config.VMgrConstants.Value
            };
            currCtrlVar.Source=obj.CtrlVarSSSrc;
            currCtrlVar.Hierarchical=false;
            currCtrlVar.RowSpan=[1,1];
            currCtrlVar.ColSpan=[1,1];
            currCtrlVar.DialogRefresh=true;
            currCtrlVar.Enabled=false;
            currCtrlVar.Mode=true;
        end

        function workspaceSS=getGlobalWorkspaceSS(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

            workspaceSS.Name='Global WS Spreadsheet Widget';
            workspaceSS.Type='spreadsheet';
            workspaceSS.Tag='globalWSSSWidgetTag';
            workspaceSS.Columns={VMgrConstants.Name};
            workspaceSS.Source=obj.GlobalConfigSSSrc;
            workspaceSS.Hierarchical=false;
            workspaceSS.RowSpan=[1,1];
            workspaceSS.ColSpan=[1,1];
            workspaceSS.MinimumSize=[100,30];
            workspaceSS.PreferredSize=[250,30];
            workspaceSS.MaximumSize=[10000,30];
            workspaceSS.Config='{ "hidecolumns":true }';
            workspaceSS.DialogRefresh=true;
            workspaceSS.Enabled=true;
            workspaceSS.Mode=true;
            workspaceSS.ItemClickedCallback=@obj.configItemClicked;
            workspaceSS.ItemDoubleClickedCallback=@obj.configItemDoubleClicked;
        end

        function configsSSColumns=getConfigsSSWidgetColumns(obj)
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            import slvariants.internal.manager.ui.config.VMgrConstants;

            configsSSColumns={VMgrConstants.Name};

            switch obj.ReduceAnalyzeModeFlag
            case{ReduceAnalyzeModes.SpecifyVariantConfig,ReduceAnalyzeModes.SpecifyVariableGrps}
                configsSSColumns=[VMgrConstants.SelectCol;configsSSColumns(1)];
            end
        end

        function configsSSConfig=getConfigsSSWidgetConfig(obj)
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            import slvariants.internal.manager.ui.config.VMgrConstants;

            configsSSConfig='{ "hidecolumns":true }';

            switch obj.ReduceAnalyzeModeFlag
            case{ReduceAnalyzeModes.SpecifyVariantConfig,ReduceAnalyzeModes.SpecifyVariableGrps}
                selColName=VMgrConstants.SelectCol;
                configsSSConfig=[configsSSConfig(1:end-2),','...
                ,' "columns":[{"name" : "',selColName,'", "width" : ',obj.SelectColSize,', "minsize" : ',obj.SelectColSize,', "maxsize" : ',obj.SelectColSize,'}] }'];

            end

        end

        function configsSSWidget=getConfigsSSWidgetStruct(obj)





            configsSSWidget.Name='Configurations Spreadsheet Widget';
            configsSSWidget.Type='spreadsheet';
            configsSSWidget.Tag='configsSSWidgetTag';
            configsSSWidget.Columns=getConfigsSSWidgetColumns(obj);
            configsSSWidget.Source=obj.ConfigSSSrc;
            configsSSWidget.Hierarchical=obj.IsHierarchy;
            configsSSWidget.RowSpan=[3,3];
            configsSSWidget.ColSpan=[1,1];
            configsSSWidget.MinimumSize=[100,150];
            configsSSWidget.PreferredSize=[250,150];
            configsSSWidget.MaximumSize=[10000,150];
            configsSSWidget.Config=getConfigsSSWidgetConfig(obj);
            configsSSWidget.DialogRefresh=true;
            configsSSWidget.Enabled=true;
            configsSSWidget.Mode=true;
            configsSSWidget.ItemClickedCallback=@obj.configItemClicked;
            configsSSWidget.SelectionChangedCallback=@obj.configSelectionChanged;
        end

        function configurationsPanel=getConfigurationsPanel(obj)
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            configurationsPanel.Name=slvariants.internal.manager.ui.config.VMgrConstants.Configurations;
            configurationsPanel.Tag='configsTogglePanel';
            configurationsPanel.Type='panel';
            configurationsPanel.Alignment=0;
            configurationsPanel.Expand=true;
            if(obj.ReduceAnalyzeModeFlag==ReduceAnalyzeModes.Unset)&&~obj.IsStandalone
                configurationsPanel.LayoutGrid=[3,1];
                configurationsPanel.Items={obj.getGlobalWorkspaceSS,...
                obj.getConfigButtonsPanelStruct(),...
                obj.getConfigsSSWidgetStruct()};
            else
                configurationsPanel.LayoutGrid=[2,1];
                configurationsPanel.Items={obj.getConfigButtonsPanelStruct(),...
                obj.getConfigsSSWidgetStruct()};
                configurationsPanel.Items{1}.RowSpan=[1,1];
                configurationsPanel.Items{2}.RowSpan=[2,2];
            end
            configurationsPanel.RowSpan=[1,1];
            configurationsPanel.ColSpan=[1,1];
        end

        function addButton=getAddConfigButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            addButton.ToolTip=VMgrConstants.AddConfigButtonToolTip;
            addButton.FilePath=VMgrConstants.AddRowIcon;
            addButton.Type='pushbutton';
            addButton.Tag='addConfigButtonTag';
            addButton.RowSpan=[1,1];
            addButton.ColSpan=[1,1];
            addButton.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.addConfigCB';
            addButton.MatlabArgs={'%dialog',obj};
            addButton.MaximumSize=[25,25];
        end

        function deleteButton=getDeleteConfigButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            deleteButton.ToolTip=VMgrConstants.DeleteConfigButtonToolTip;
            deleteButton.FilePath=VMgrConstants.DeleteRowIcon;
            deleteButton.Type='pushbutton';
            deleteButton.Tag='deleteConfigButtonTag';
            deleteButton.RowSpan=[1,1];
            deleteButton.ColSpan=[3,3];
            deleteButton.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.deleteConfigCB';
            deleteButton.MatlabArgs={'%dialog',obj};
            deleteButton.MaximumSize=[25,25];
            deleteButton.Enabled=false;
        end

        function copyButton=getCopyConfigButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            copyButton.ToolTip=VMgrConstants.CopyConfigButtonToolTip;
            copyButton.FilePath=VMgrConstants.CopyRowIcon;
            copyButton.Type='pushbutton';
            copyButton.Tag='copyConfigButtonTag';
            copyButton.RowSpan=[1,1];
            copyButton.ColSpan=[2,2];
            copyButton.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.copyConfigCB';
            copyButton.MatlabArgs={'%dialog',obj};
            copyButton.MaximumSize=[25,25];
            copyButton.Enabled=false;
        end

        function configButtonsPanel=getConfigButtonsPanelStruct(obj)


            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            configButtonsPanel.Name='configsButtonsPanel';
            configButtonsPanel.Type='panel';
            configButtonsPanel.Items={obj.getAddConfigButtonStruct(),...
            obj.getCopyConfigButtonStruct(),...
            obj.getDeleteConfigButtonStruct(),...
            obj.createSpacer(1,4)};
            configButtonsPanel.Tag='configButtonsPanelTag';
            configButtonsPanel.LayoutGrid=[1,4];
            configButtonsPanel.RowSpan=[2,2];
            configButtonsPanel.ColSpan=[1,1];
            configButtonsPanel.Visible=(obj.ReduceAnalyzeModeFlag==ReduceAnalyzeModes.Unset);
        end



        function configNamePanel=getConfigNamePanel(obj)





            configNameValue.Type='text';
            configNameValue.Name=obj.SelectedConfig;
            configNameValue.Tag='configNameLabelTag';
            configNameValue.Bold=true;
            configNameValue.FontPointSize=10;
            configNameValue.ColSpan=[2,2];
            configNameValue.RowSpan=[1,1];
            configNameValue.Alignment=1;

            configNamePanel.Type='panel';
            configNamePanel.ColSpan=[1,1];
            configNamePanel.RowSpan=[1,1];
            configNamePanel.LayoutGrid=[1,1];
            configNamePanel.Items={configNameValue};
        end

        function importButton=getImportButtonStruct(obj)




            import slvariants.internal.manager.ui.config.VMgrConstants
            importButton.ToolTip=VMgrConstants.ImportButtonToolTip;
            importButton.FilePath=VMgrConstants.ImportCtrlVarsBtnIcon;
            importButton.Type='pushbutton';
            importButton.Tag='importVariantControlVarButtonTag';
            importButton.RowSpan=[1,1];
            importButton.ColSpan=[1,1];
            importButton.MatlabMethod='slvariants.internal.manager.ui.importVariantControlVars';
            importButton.MatlabArgs={'%dialog',obj};
            importButton.MaximumSize=[25,25];
        end

        function addButton=getAddCtrlVarButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            addButton.ToolTip=VMgrConstants.AddCtrlVarButtonToolTip;
            addButton.FilePath=VMgrConstants.AddRowIcon;
            addButton.UseButtonStyleForDefaultAction=true;
            addButton.Type='splitbutton';
            addButton.ButtonStyle='IconOnly';
            addButton.Tag='addCtrlVarSplitButtonTag';
            addButton.RowSpan=[1,1];
            addButton.ColSpan=[2,2];
            addButton.MaximumSize=[40,25];
            addButton.ActionEntries={
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            getString(message("Simulink:VariantManagerUI:AddSimulinkVariantControlCtrlVar")),...
            'addSLVarCtrlVariable',VMgrConstants.SLVarCtrlNormalTypeIcon),...
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            getString(message("Simulink:VariantManagerUI:AddNormalCtrlVar")),...
            'addNormalVariable',VMgrConstants.NormalTypeIcon),...
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            getString(message("Simulink:VariantManagerUI:AddSimulinkParamCtrlVar")),...
            'addParamVariable',VMgrConstants.ParamTypeIcon),...
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            getString(message("Simulink:VariantManagerUI:AddAUTOSARParamCtrlVar")),...
            'addAUTOSARParamVariable',VMgrConstants.ParamTypeIcon)};
            addButton.DefaultAction='addSLVarCtrlVariable';
            addButton.ActionCallback=@(dlg,addBtnTag,action)slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.addCtrlVarCB(obj,dlg,addBtnTag,action);
            addButton.DialogRefresh=true;
        end

        function deleteButton=getDeleteCtrlVarButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            deleteButton.ToolTip=VMgrConstants.DeleteCtrlVarButtonToolTip;
            deleteButton.FilePath=VMgrConstants.DeleteRowIcon;
            deleteButton.Type='pushbutton';
            deleteButton.Tag='deleteCtrlVarButtonTag';
            deleteButton.RowSpan=[1,1];
            deleteButton.ColSpan=[4,4];
            deleteButton.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.deleteCtrlVarCB';
            deleteButton.MatlabArgs={'%dialog',obj};
            deleteButton.MaximumSize=[25,25];
            deleteButton.Enabled=false;
        end

        function copyButton=getCopyCtrlVarButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            copyButton.ToolTip=VMgrConstants.CopyCtrlVarButtonToolTip;
            copyButton.FilePath=VMgrConstants.CopyRowIcon;
            copyButton.Type='pushbutton';
            copyButton.Tag='copyCtrlVarButtonTag';
            copyButton.RowSpan=[1,1];
            copyButton.ColSpan=[3,3];
            copyButton.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.copyCtrlVarCB';
            copyButton.MatlabArgs={'%dialog',obj};
            copyButton.MaximumSize=[25,25];
            copyButton.Enabled=false;
        end

        function convertTypesSplitButton=getConvertTypesSplitButtonStruct(obj)




            import slvariants.internal.manager.ui.config.VMgrConstants
            convertTypesSplitButton.ToolTip=VMgrConstants.ToggleSLVarCtrlButtonToolTip;
            convertTypesSplitButton.FilePath=VMgrConstants.ToggleSLVarCtrlBtnIcon;
            convertTypesSplitButton.UseButtonStyleForDefaultAction=true;
            convertTypesSplitButton.Type='splitbutton';
            convertTypesSplitButton.ButtonStyle='IconOnly';
            convertTypesSplitButton.Tag='convertTypesSplitButtonTag';
            convertTypesSplitButton.RowSpan=[1,1];
            convertTypesSplitButton.ColSpan=[6,6];
            convertTypesSplitButton.MaximumSize=[40,25];
            convertTypesSplitButton.Enabled=true;
            convertTypesSplitButton.ActionEntries={
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            VMgrConstants.ToggleSLVarCtrlButtonToolTip,...
            'ConvertToSLVarCtrlVariable',VMgrConstants.ToggleSLVarCtrlBtnIcon),...
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            VMgrConstants.SimulinkParameterConvertButtonToolTip,...
            'ConvertToSLParamVariable',VMgrConstants.ParamTypeIcon),...
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            VMgrConstants.AUTOSARParameterConvertButtonToolTip,...
            'ConvertToAUTOSARParamVariable',VMgrConstants.ParamTypeIcon),...
            slvariants.internal.manager.ui.config.SplitButtonAction(...
            VMgrConstants.ConvertToNormalCtrlButtonToolTip,...
            'ConvertToNormalCtrlVariable',VMgrConstants.NormalTypeIcon)};


            convertTypesSplitButton.DefaultAction='ConvertToSLVarCtrlVariable';
            convertTypesSplitButton.ActionCallback=@(dlg,tag,action)...
            slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.toggleTypeOfCtrlVars(obj,tag,dlg,action);
            convertTypesSplitButton.DialogRefresh=true;
        end

        function simulinkParameterEditButton=getSimulinkParameterEditDialogButtonStruct(~)




            import slvariants.internal.manager.ui.config.VMgrConstants
            simulinkParameterEditButton.ToolTip=VMgrConstants.SimulinkParameterEditButtonToolTip;
            simulinkParameterEditButton.FilePath=VMgrConstants.SimParamEditBtnIcon;
            simulinkParameterEditButton.Type='pushbutton';
            simulinkParameterEditButton.Tag='simulinkParameterEditButtonTag';
            simulinkParameterEditButton.RowSpan=[1,1];
            simulinkParameterEditButton.ColSpan=[7,7];
            simulinkParameterEditButton.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.openSimulinkParameterDialog';
            simulinkParameterEditButton.MatlabArgs={'%dialog'};
            simulinkParameterEditButton.MaximumSize=[25,25];
            simulinkParameterEditButton.Enabled=false;
        end

        function showUsage=getShowUsageButtonStruct(obj)

            import slvariants.internal.manager.ui.config.VMgrConstants
            showUsage.ToolTip=VMgrConstants.ShowUsageButtonToolTip;
            showUsage.FilePath=VMgrConstants.ShowUsageButtonIcon;
            showUsage.Type='pushbutton';
            showUsage.Tag='showUsageVariantControlVarButtonTag';
            showUsage.RowSpan=[1,1];
            showUsage.ColSpan=[8,8];
            showUsage.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.showUsageForCtrlVar';
            showUsage.MatlabArgs={'%dialog',obj};
            showUsage.MaximumSize=[25,25];
            showUsage.Enabled=false;
        end

        function hideUsage=getHideUsageButtonStruct(obj)

            import slvariants.internal.manager.ui.config.VMgrConstants
            hideUsage.ToolTip=VMgrConstants.HideUsageButtonToolTip;
            hideUsage.FilePath=VMgrConstants.HideUsageButtonIcon;
            hideUsage.Type='pushbutton';
            hideUsage.Tag='hideUsageVariantControlVarButtonTag';
            hideUsage.RowSpan=[1,1];
            hideUsage.ColSpan=[9,9];
            hideUsage.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.hideUsageForCtrlVar';
            hideUsage.MatlabArgs={'%dialog',obj};
            hideUsage.MaximumSize=[25,25];
            hideUsage.Enabled=false;
        end

        function exportButton=getExportButtonStruct(obj)

            import slvariants.internal.manager.ui.config.VMgrConstants
            exportButton.ToolTip=VMgrConstants.ExportButtonToolTip;
            exportButton.FilePath=VMgrConstants.ExportCtrlVarsBtnIcon;
            exportButton.Type='pushbutton';
            exportButton.Tag='exportVariantControlVarButtonTag';
            exportButton.RowSpan=[1,1];
            exportButton.ColSpan=[10,10];
            exportButton.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.exportVariantControlVars';
            exportButton.MatlabArgs={'%dialog',obj};
            exportButton.MaximumSize=[25,25];
            exportButton.Enabled=obj.IsControlVarsTableDirty&&...
            ~strcmp(obj.SelectedConfig,obj.ExportedConfig);
        end

        function spacer=createSpacer(~,rowIdx,colIdx)
            spacer.Name='';
            spacer.Type='text';
            spacer.RowSpan=[rowIdx,rowIdx];
            spacer.ColSpan=[colIdx,colIdx];
        end

        function controlVariableButtonsPanel=getControlVariableButtonsPanelStruct(obj)




            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            controlVariableButtonsPanel.Name='';
            controlVariableButtonsPanel.Flat=false;
            controlVariableButtonsPanel.Items={obj.getImportButtonStruct(),...
            obj.getAddCtrlVarButtonStruct(),...
            obj.getCopyCtrlVarButtonStruct(),...
            obj.getDeleteCtrlVarButtonStruct(),...
            obj.getConvertTypesSplitButtonStruct(),...
            obj.getSimulinkParameterEditDialogButtonStruct(),...
            obj.getShowUsageButtonStruct(),...
            obj.getHideUsageButtonStruct(),...
            obj.getExportButtonStruct(),...
            obj.createSpacer(1,11)};
            controlVariableButtonsPanel.Tag='controlVariableButtonsPanelTag';
            controlVariableButtonsPanel.LayoutGrid=[1,10];
            controlVariableButtonsPanel.Type='panel';
            controlVariableButtonsPanel.RowSpan=[2,2];
            controlVariableButtonsPanel.ColSpan=[1,1];
            controlVariableButtonsPanel.Visible=(obj.ReduceAnalyzeModeFlag==ReduceAnalyzeModes.Unset);
            if obj.IsStandalone

                controlVariableButtonsPanel.Items(end-3:end-1)=[];
                controlVariableButtonsPanel.Items(1)=[];
                controlVariableButtonsPanel.LayoutGrid=[1,6];
            end
        end

        function controlVariablesSSWidget=getControlVariablesSSWidgetStruct(obj)




            import slvariants.internal.manager.ui.config.VMgrConstants
            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema
            import slvariants.internal.manager.ui.config.ctrlVarContextMenu
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes
            controlVariablesSSWidget.Name='ControlVariables Spreadsheet Widget';
            controlVariablesSSWidget.Type='spreadsheet';
            controlVariablesSSWidget.Tag='controlVariablesSSWidgetTag';


            controlVariablesSSWidget.Config=jsonencode(struct('enablesort',false));
            controlVariablesSSWidget.Columns={
' '
            VMgrConstants.Name
            VMgrConstants.Value
            VMgrConstants.ActivationTime
            VMgrConstants.Source};
            controlVariablesSSWidget.Source=obj.CtrlVarSSSrc;
            controlVariablesSSWidget.Hierarchical=obj.IsHierarchy;
            controlVariablesSSWidget.RowSpan=[3,3];
            controlVariablesSSWidget.ColSpan=[1,1];
            controlVariablesSSWidget.DialogRefresh=true;
            controlVariablesSSWidget.Enabled=true;
            controlVariablesSSWidget.Mode=true;

            controlVariablesSSWidget.ValueChangedCallback=@obj.ctrlVarItemChanged;
            controlVariablesSSWidget.SelectionChangedCallback=@(tag,sels,dlg)ConfigurationsDialogSchema.ctrlVarSelectionChanged(tag,sels,dlg,obj);
            if~obj.IsStandalone






                controlVariablesSSWidget.ContextMenuCallback=@(tag,sels,dlg)ctrlVarContextMenu(tag,sels,dlg);
            end
        end

        function descriptionEditAreaWidget=getDescriptionEditAreaWidgetStruct(obj)




            descriptionEditAreaWidget.Type='editarea';
            descriptionEditAreaWidget.Tag='configDescEditAreaWidgetTag';
            descriptionEditAreaWidget.Value=obj.ConfigDescription;
            descriptionEditAreaWidget.RowSpan=[1,1];
            descriptionEditAreaWidget.ColSpan=[1,1];
            descriptionEditAreaWidget.WordWrap=true;
            descriptionEditAreaWidget.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.updateConfigurationDescription';
            descriptionEditAreaWidget.MatlabArgs={'%value',obj};
            descriptionEditAreaWidget.MinimumSize=[100,100];
            descriptionEditAreaWidget.PreferredSize=[200,100];
            descriptionEditAreaWidget.MaximumSize=[5000,100];
        end

        function descriptionTogglePanel=getDescriptionTogglePanel(obj)
            descriptionTogglePanel.Name=slvariants.internal.manager.ui.config.VMgrConstants.Description;
            descriptionTogglePanel.Tag='configDescTogglePanel';
            descriptionTogglePanel.Type='togglepanel';
            descriptionTogglePanel.Alignment=0;
            descriptionTogglePanel.Expand=false;
            descriptionTogglePanel.RowSpan=[5,5];
            descriptionTogglePanel.ColSpan=[1,1];
            descriptionTogglePanel.LayoutGrid=[1,1];
            descriptionTogglePanel.Items={obj.getDescriptionEditAreaWidgetStruct()};
            descriptionTogglePanel.Enabled=obj.CtrlVarSSSrc.IsEnabled&&~obj.CtrlVarSSSrc.IsGlobalWksConfig;
            descriptionTogglePanel.Visible=obj.CtrlVarSSSrc.IsEnabled&&~obj.CtrlVarSSSrc.IsGlobalWksConfig;
        end

        function controlVarsPanel=getControlVarsPanel(obj)
            controlVarsPanel.Name=slvariants.internal.manager.ui.config.VMgrConstants.ControlVariables;
            controlVarsPanel.Tag='ctrlVarsTogglePanel';
            controlVarsPanel.Type='togglepanel';
            controlVarsPanel.Alignment=0;
            controlVarsPanel.Expand=true;
            controlVarsPanel.RowSpan=[2,2];
            controlVarsPanel.ColSpan=[1,1];
            controlVarsPanel.LayoutGrid=[5,1];
            controlVarsPanel.Items={obj.getConfigNamePanel(),...
            obj.getControlVariableButtonsPanelStruct(),...
            obj.getControlVariablesSSWidgetStruct(),...
            obj.getCompConfigsPanel(),...
            obj.getDescriptionTogglePanel()};
            controlVarsPanel.RowStretch=[0,0,1,0,0];
            controlVarsPanel.Enabled=obj.CtrlVarSSSrc.IsEnabled;
        end

        function compConfigsPanel=getCompConfigsPanel(obj)
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

            compConfigsPanel.Name='';
            compConfigsPanel.Tag='compConfigsPanel';
            compConfigsPanel.Type='panel';
            compConfigsPanel.Flat=false;
            compConfigsPanel.LayoutGrid=[1,2];
            compConfigsPanel.Items={obj.getCompBrowserToggle(),...
            obj.getShowAllCtrlVarsCheckboxStruct()};
            compConfigsPanel.RowSpan=[4,4];
            compConfigsPanel.ColSpan=[1,1];
            compConfigsPanel.Visible=slfeature('vmgrcompbrowser')>0...
            &&~obj.IsStandalone...
            &&~obj.CtrlVarSSSrc.IsGlobalWksConfig...
            &&(obj.ReduceAnalyzeModeFlag==ReduceAnalyzeModes.Unset);
        end

        function compConfigsTglBtn=getCompBrowserToggle(obj)

            import slvariants.internal.manager.ui.config.VMgrConstants;
            compConfigsTglBtn.Value=obj.IsCompBrowserVisible;
            if obj.IsCompBrowserVisible
                btnName=VMgrConstants.HideComponentConfigurations;
            else
                btnName=VMgrConstants.ShowComponentConfigurations;
            end
            compConfigsTglBtn.Name=btnName;
            compConfigsTglBtn.Type='togglebutton';
            compConfigsTglBtn.Tag='compConfigsToggleBtnTag';
            compConfigsTglBtn.ToolTip=message('Simulink:VariantManagerUI:CompBrowserButtonToolTip').getString();
            compConfigsTglBtn.RowSpan=[1,1];
            compConfigsTglBtn.ColSpan=[1,1];
            compConfigsTglBtn.MatlabMethod='slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.compBrowserToggle';
            compConfigsTglBtn.MatlabArgs={obj.BDName};
            compConfigsTglBtn.DialogRefresh=true;
        end

        function showAllCtrlVarsCheckbox=getShowAllCtrlVarsCheckboxStruct(obj)




            import slvariants.internal.manager.ui.config.VMgrConstants
            showAllCtrlVarsCheckbox.Name=VMgrConstants.ShowAll;
            showAllCtrlVarsCheckbox.ToolTip=message('Simulink:VariantManagerUI:ControlVariablesButtonShowEntireModel').getString();
            showAllCtrlVarsCheckbox.Type='checkbox';
            showAllCtrlVarsCheckbox.Value=true;
            showAllCtrlVarsCheckbox.Alignment=7;
            showAllCtrlVarsCheckbox.Tag='showAllCtrlVarsCheckboxTag';
            showAllCtrlVarsCheckbox.RowSpan=[1,1];
            showAllCtrlVarsCheckbox.ColSpan=[2,2];

            showAllCtrlVarsCheckbox.Visible=false;
            showAllCtrlVarsCheckbox.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.showAllCtrlVarsUpdate';
            showAllCtrlVarsCheckbox.MatlabArgs={'%dialog','%value'};
        end

        function prefConfigPanel=getPrefConfigPanel(obj)
            prefConfigPanel.Name=message('Simulink:VariantManagerUI:PreferredConfiguration').getString();
            prefConfigPanel.Tag='prefConfigTogglePanel';
            prefConfigPanel.Type='togglepanel';
            prefConfigPanel.Alignment=0;
            prefConfigPanel.Expand=false;
            prefConfigPanel.RowSpan=[3,3];
            prefConfigPanel.ColSpan=[1,1];
            prefConfigPanel.LayoutGrid=[1,1];
            prefConfigPanel.Items={obj.getPrefConfigCombobox};
        end

        function prefConfigCombobox=getPrefConfigCombobox(obj)




            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema;
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            prefConfigCombobox.Name='';
            prefConfigCombobox.ToolTip=message('Simulink:VariantManagerUI:PreferredConfigurationTooltip').getString();
            prefConfigCombobox.Type='combobox';
            prefConfigCombobox.Value=obj.SourceObj.getPreferredConfiguration();
            prefConfigCombobox.Entries=ConfigurationsDialogSchema.getPrefConfigEntries(obj);
            prefConfigCombobox.Tag='prefConfigComboboxTag';
            prefConfigCombobox.RowSpan=[1,1];
            prefConfigCombobox.ColSpan=[1,1];
            prefConfigCombobox.Mode=true;
            prefConfigCombobox.DialogRefresh=false;
            prefConfigCombobox.MatlabMethod='slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.prefConfigUpdate';
            prefConfigCombobox.MatlabArgs={obj,'%value'};
            prefConfigCombobox.Enabled=(obj.ReduceAnalyzeModeFlag==ReduceAnalyzeModes.Unset);







        end



        function flag=getIsActivatedConfig(obj,configName)
            flag=strcmp(obj.ActivatedConfig,configName);
        end


        function setCtrlVarSSSrc(obj,ctrlVarSSSrc)
            obj.CtrlVarSSSrc=ctrlVarSSSrc;
        end
    end

    methods(Access=public)
        function updateSelectedConfig(obj,selectedConfigName)
            obj.SelectedConfig=selectedConfigName;
        end

        function updateSelectedCtrlVarIdx(obj,selectedCtrlVarIdx)
            obj.SelectedCtrlVarIdx=selectedCtrlVarIdx;
        end
    end

    methods(Static)

        function openCB(dlg)
            dlg.setEnabled('convertTypesSplitButtonTag',false);
            import slvariants.internal.manager.ui.config.VMgrConstants;

            configSSInterface=dlg.getWidgetInterface('configsSSWidgetTag');
            configSSInterface.setEmptyListMessage(VMgrConstants.ConfigurationListPlaceholder);

            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            ctrlVarSSInterface.setEmptyListMessage(VMgrConstants.CtrlVarListPlaceholder);
        end

        function prefConfigEntries=getPrefConfigEntries(obj)


            prefConfigEntries={'',obj.SourceObj.Configurations.Name};
        end

        function prefConfigUpdate(obj,value)


            prevPreferredConfig=obj.SourceObj.getPreferredConfiguration();
            if value==0
                obj.SourceObj.setPreferredConfiguration('');
            else
                configNames=obj.SourceObj.getConfigurationNames();
                newPrefConfigName=configNames{value};
                obj.SourceObj.setPreferredConfiguration(newPrefConfigName);
            end
            if~obj.IsStandalone&&~strcmp(prevPreferredConfig,obj.SourceObj.getPreferredConfiguration())




                obj.setSourceObjDirtyFlag(obj);
            end
        end

        function showAllCtrlVarsUpdate(dlg,value)
            configSchema=dlg.getSource;
            configSchema.CtrlVarSSSrc.IsShowAllCtrlVarsOn=value;
            configSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
        end

        function updateConvertTypesSplitButton(ctrlVarRowObj,dlg)
            setDisabled=ctrlVarRowObj.IsReadOnly;
            dlg.setEnabled('convertTypesSplitButtonTag',~setDisabled);
        end

        function updateSimulinkParameterEditButton(ctrlVarRowObj,dlg)
            setEnabled=ctrlVarRowObj.IsSimulinkParameter&&~ctrlVarRowObj.IsReadOnly;
            dlg.setEnabled('simulinkParameterEditButtonTag',setEnabled);
        end

        function updateShowUsageButton(ctrlVarRowObj,dlg)
            dlg.setEnabled('showUsageVariantControlVarButtonTag',~ctrlVarRowObj.IsReadOnly);
        end

        function updateHideUsageButton(ctrlVarRowObj,dlg)
            dlg.setEnabled('hideUsageVariantControlVarButtonTag',~ctrlVarRowObj.IsReadOnly);
        end

        function onBDRename(obj)



            if ishandle(obj.EditParamDlgHandle)


                currEditParamDlgTitle=obj.EditParamDlgHandle.getTitle;
                newEditParamDlgTitle=replaceBetween(currEditParamDlgTitle,'(',',',obj.BDName);
                obj.EditParamDlgHandle.setTitle(newEditParamDlgTitle);
            end
        end

        function dummyOut=ctrlVarSelectionChanged(~,sels,dlg,obj)

            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema
            dummyOut=true;
            if numel(sels)==1
                obj.SelectedCtrlVarIdx=sels{1}.CtrlVarIdx;
                ConfigurationsDialogSchema.updateConvertTypesSplitButton(sels{1},dlg);
                ConfigurationsDialogSchema.updateSimulinkParameterEditButton(sels{1},dlg);
                ConfigurationsDialogSchema.updateShowUsageButton(sels{1},dlg);
                ConfigurationsDialogSchema.updateHideUsageButton(sels{1},dlg);
                dlg.setEnabled('deleteCtrlVarButtonTag',true);
                dlg.setEnabled('copyCtrlVarButtonTag',true);
            else

                obj.SelectedCtrlVarIdx=1;
                dlg.setEnabled('deleteCtrlVarButtonTag',false);
                dlg.setEnabled('copyCtrlVarButtonTag',false);
                dlg.setEnabled('convertTypesSplitButtonTag',false);
                dlg.setEnabled('simulinkParameterEditButtonTag',false);
                if isempty(sels)
                    dlg.setEnabled('showUsageVariantControlVarButtonTag',false);
                    dlg.setEnabled('hideUsageVariantControlVarButtonTag',false);
                end
            end
        end

        function dummyOut=configSelectionChanged(~,sels,dlg,~)

            dummyOut=true;
            if numel(sels)==1&&sels{1}.VarConfigIdx~=0
                dlg.setEnabled('deleteConfigButtonTag',true);
                dlg.setEnabled('copyConfigButtonTag',true);
            else

                dlg.setEnabled('deleteConfigButtonTag',false);
                dlg.setEnabled('copyConfigButtonTag',false);
            end
        end

        function addCtrlVarCB(obj,dlg,~,action)

            ctrlVarDataSrc=obj.CtrlVarSSSrc;
            ctrlVarDataSrc.addControlVariable(dlg,action);
            ctrlVarDataSrc.DialogSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
        end

        function deleteCtrlVarCB(dlg,obj)
            import slvariants.internal.manager.ui.config.highlightVarCtrlUsageCallback

            ctrlVarDataSrc=obj.CtrlVarSSSrc;
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            if isempty(selectedRows)
                return;
            end
            ctrlVarDataRow=selectedRows{1};
            ctrlVarIdx=ctrlVarDataRow.CtrlVarIdx;
            if ctrlVarDataRow.IsHighlighted
                hideUsage=false;
                highlightVarCtrlUsageCallback(ctrlVarDataRow.DialogSchema.BDName,ctrlVarIdx,hideUsage);
            end
            ctrlVarDataRow.IsHighlighted=0;

            ctrlVarDataSrc.removeControlVariable(ctrlVarDataRow,dlg);

            ctrlVarDataSrc.DialogSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
            if ctrlVarIdx==1
                if numel(ctrlVarDataSrc.getControlVariableNames())>0
                    ctrlVarSSInterface.select(ctrlVarDataSrc.Children(ctrlVarIdx));
                end
            else
                ctrlVarSSInterface.select(ctrlVarDataSrc.Children(ctrlVarIdx-1));
            end
        end

        function copyCtrlVarCB(dlg,obj)
            ctrlVarDataSrc=obj.CtrlVarSSSrc;
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            if isempty(selectedRows)
                return;
            end
            ctrlVarDataRow=selectedRows{1};

            ctrlVarDataSrc.copyControlVariable(ctrlVarDataRow,dlg);
            ctrlVarDataSrc.DialogSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
            ctrlVarSSInterface.select(ctrlVarDataSrc.Children(ctrlVarDataRow.CtrlVarIdx+1));
        end

        function openSimulinkParameterDialog(dlg)
            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            ctrlVarRowObj=selectedRows{1};


            ctrlVarRowObj.DialogSchema.disableUI(dlg);

            varCtrlValue=ctrlVarRowObj.getControlVariableValue();
            if ctrlVarRowObj.IsSLVarControl
                paramValue=varCtrlValue.Value;
            else
                paramValue=varCtrlValue;
            end
            originalParamValue=copy(paramValue);
            dialogHandle=DAStudio.Dialog(paramValue);
            if ishandle(dialogHandle)

                paramClassName=class(paramValue);
                controlVarName=ctrlVarRowObj.CtrlVarName;
                topObjectName=ctrlVarRowObj.DialogSchema.TagId;
                configName=ctrlVarRowObj.CtrlVarSSSrc.ConfigName;
                title=[paramClassName,' : ',controlVarName,' (',topObjectName,', ',configName,')'];
                dialogHandle.setTitle(title);
                ctrlVarRowObj.DialogSchema.EditParamDlgHandle=dialogHandle;

                l=handle.listener(dialogHandle,'ObjectBeingDestroyed',...
                @(s,e)(ConfigurationsDialogSchema.onEditParamDialogDestruction(dlg,originalParamValue,paramValue,dialogHandle)));
                ctrlVarRowObj.DialogSchema.EditParamListenerHandle=l;
            end
        end

        function disableUI(dlg)
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            ctrlVarRowObj=selectedRows{1};
            configSchema=ctrlVarRowObj.DialogSchema;
            if configSchema.IsStandalone


                dlg.setEnabled('configsConstraintsTabWidgetTag',false);
            else

                bdHandle=get_param(configSchema.BDName,'Handle');
                slvariants.internal.manager.core.disableUI(bdHandle);
            end
        end

        function onEditParamDialogDestruction(dlg,originalParamValue,paramValue,dialogHandle)
            if~isa(dlg,'DAStudio.Dialog')



                return;
            end

            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            if isempty(ctrlVarSSInterface)
                return;
            end
            selectedRows=ctrlVarSSInterface.getSelection();
            ctrlVarRowObj=selectedRows{1};
            configSchema=ctrlVarRowObj.DialogSchema;

            configSchema.stopAndDeleteTimer();

            if isa(dialogHandle,'DAStudio.Dialog')&&dialogHandle.hasUnappliedChanges()




                configSchema.EditParamUpdateTimer=timer('ExecutionMode','singleShot','StartDelay',0.05,...
                'TimerFcn',@(~,~)(...
                slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.onEditParamDialogDestruction(...
                dlg,originalParamValue,paramValue,dialogHandle)));
                configSchema.EditParamUpdateTimer.start();
            else
                if configSchema.IsStandalone
                    dlg.setEnabled('configsConstraintsTabWidgetTag',true);
                else

                    bdHandle=get_param(configSchema.BDName,'Handle');
                    if slvariants.internal.manager.core.hasOpenVM(bdHandle)
                        slvariants.internal.manager.core.enableUI(bdHandle);
                    end
                end
                isEdited=~isequal(originalParamValue,paramValue);
                if isEdited


                    configSchema.IsControlVarsTableDirty=true;
                    dlg.setEnabled('exportVariantControlVarButtonTag',true);
                    if~configSchema.CtrlVarSSSrc.IsGlobalWksConfig
                        configSchema.setSourceObjDirtyFlag(configSchema);
                    end
                end
                ctrlVarSSInterface.update(ctrlVarRowObj);
            end
            try %#ok<TRYNC>


                delete(ctrlVarRowObj.DialogSchema.EditParamDlgHandle);
            end
        end

        function toggleTypeOfCtrlVars(~,~,dlg,action)
            switch(action)
            case 'ConvertToSLVarCtrlVariable'
                slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.convertToSimulinkVarCtrl(dlg);
            case 'ConvertToSLParamVariable'
                slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.convertToSimulinkParameter(dlg);
            case 'ConvertToAUTOSARParamVariable'
                slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.convertToAUTOSARParameter(dlg);
            case 'ConvertToNormalCtrlVariable'
                slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.convertToNormalCtrlVar(dlg);
            end
        end

        function convertToSimulinkParameter(dlg)
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            ctrlVarRowObj=selectedRows{1};
            if~ctrlVarRowObj.IsSimulinkParameter||ctrlVarRowObj.IsAUTOSARParameter

                ctrlVarRowObj.convertToSimulinkParameter();
                dlg.setEnabled('simulinkParameterEditButtonTag',true);
            end
            ctrlVarSSInterface.update(ctrlVarRowObj);
        end

        function convertToAUTOSARParameter(dlg)
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            ctrlVarRowObj=selectedRows{1};
            if~ctrlVarRowObj.IsAUTOSARParameter

                ctrlVarRowObj.convertToAUTOSARParameter();
                dlg.setEnabled('simulinkParameterEditButtonTag',true);
            end
            ctrlVarSSInterface.update(ctrlVarRowObj);
        end

        function convertToNormalCtrlVar(dlg)
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            ctrlVarRowObj=selectedRows{1};
            if ctrlVarRowObj.IsSimulinkParameter||ctrlVarRowObj.IsSLVarControl
                if ctrlVarRowObj.IsSimulinkParameter||ctrlVarRowObj.IsAUTOSARParameter

                    ctrlVarRowObj.convertFromSimulinkParameter();
                    dlg.setEnabled('simulinkParameterEditButtonTag',false);
                end
                if ctrlVarRowObj.IsSLVarControl
                    ctrlVarRowObj.convertFromSlVarCtrl();
                end
            end
            ctrlVarSSInterface.update(ctrlVarRowObj);
        end

        function exportVariantControlVars(dlg,obj)
            slvariants.internal.manager.ui.exportVariantControlVars(dlg,obj);
            obj.setExportBtnStateOnExportOrActivate(dlg);
        end

        function showUsageForCtrlVar(dlg,obj)
            import slvariants.internal.manager.ui.config.highlightVarCtrlUsageCallback
            ssComp=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            rows=ssComp.getSelection;
            rowArr=vertcat(rows{:});
            rowIdcs=[rowArr(:).CtrlVarIdx];
            modelName=obj.BDName;
            isShowUsage=true;
            highlightVarCtrlUsageCallback(modelName,rowIdcs,isShowUsage);
        end

        function hideUsageForCtrlVar(dlg,obj)
            import slvariants.internal.manager.ui.config.highlightVarCtrlUsageCallback
            ssComp=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            rows=ssComp.getSelection;
            rowArr=vertcat(rows{:});
            rowIdcs=[rowArr(:).CtrlVarIdx];
            modelName=obj.BDName;
            isShowUsage=false;
            highlightVarCtrlUsageCallback(modelName,rowIdcs,isShowUsage);
        end

        function convertToSimulinkVarCtrl(dlg)
            ctrlVarSSInterface=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            selectedRows=ctrlVarSSInterface.getSelection();
            ctrlVarRowObj=selectedRows{1};
            if~ctrlVarRowObj.IsSLVarControl

                ctrlVarRowObj.convertToSlVarCtrl();
            end
            ctrlVarSSInterface.update(ctrlVarRowObj);
        end

        function addConfigCB(dlg,configSchema)

            newConfig=slvariants.internal.config.types.getConfigurationStruct();
            newConfig.Name=matlab.lang.makeUniqueStrings('Configuration',{configSchema.SourceObj.Configurations.Name});
            configSchema.ConfigSSSrc.addConfiguration(newConfig,...
            length(configSchema.ConfigSSSrc.getConfigurationNames())+1);
            configSchema.setSourceObjDirtyFlag(configSchema);

            configSchema.updateSpreadsheet(dlg,configSchema.ConfigSSSrc,'configsSSWidgetTag');

            displayConfigIdx=length(configSchema.SourceObj.Configurations);

            configRowObj=configSchema.ConfigSSSrc.Children(end);
            configSchema.updateConfigsSS(dlg,configSchema,configRowObj,displayConfigIdx,true);
        end

        function deleteConfigCB(dlg,configSchema)
            configsSSInterface=dlg.getWidgetInterface('configsSSWidgetTag');
            selectedRows=configsSSInterface.getSelection();
            if isempty(selectedRows)
                return;
            end
            configRowObj=selectedRows{1};


            displayConfigIdx=configSchema.getNextConfigIndex(configRowObj);


            configSchema.ConfigSSSrc.deleteConfiguration(configRowObj.VarConfigIdx);
            configSchema.setSourceObjDirtyFlag(configSchema);

            configSchema.updateSpreadsheet(dlg,configSchema.ConfigSSSrc,'configsSSWidgetTag');

            configSchema.updateConfigsSS(dlg,configSchema,configRowObj,displayConfigIdx,true);

            if numel(configSchema.SourceObj.Configurations)<1



                slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.setCompBrowserVisible(configSchema.BDName,false);
            end
        end

        function copyConfigCB(dlg,configSchema)
            configsSSInterface=dlg.getWidgetInterface('configsSSWidgetTag');
            selectedRows=configsSSInterface.getSelection();
            if isempty(selectedRows)
                return;
            end
            configRowObj=selectedRows{1};


            newConfigName=configSchema.copyConfigName(configSchema.SourceObj,configRowObj);
            configSchema.ConfigSSSrc.copyConfiguration(newConfigName,configRowObj.VarConfigIdx);
            configSchema.setSourceObjDirtyFlag(configSchema);

            configSchema.updateSpreadsheet(dlg,configSchema.ConfigSSSrc,'configsSSWidgetTag');

            displayConfigIdx=configRowObj.VarConfigIdx+1;

            configSchema.updateConfigsSS(dlg,configSchema,configRowObj,displayConfigIdx,true);
        end

        function success=applyVariantConfigurations(configSchema)


            success=false;
            if~isempty(configSchema.ConfigObjVarName)
                configSchema.ConfigCatalogCacheWrapper.applyVariantConfigurationCatalogCache(configSchema.ConfigObjVarName);
                configSchema.resetSourceObjDirtyFlag(configSchema);
                success=true;
                return;
            end
            currentNameOfVarConfigsObj=get_param(configSchema.BDName,'VariantConfigurationObject');
            if isempty(currentNameOfVarConfigsObj)
                dp=DAStudio.DialogProvider;
                errorMessage=DAStudio.message('Simulink:VariantManagerUI:MessageConfigdatacantexportwithemptynameError');
                dp.errordlg(errorMessage,'Error',true);
                return;
            end
            questMsg=DAStudio.message('Simulink:VariantManagerUI:MessageConfigdatacantexportwithemptyname');
            ok=message('MATLAB:uistring:popupdialogs:OK').getString();
            cancel=message('MATLAB:uistring:popupdialogs:Cancel').getString();
            selection=questdlg(questMsg,configSchema.BDName,ok,cancel,cancel);

            switch selection
            case ok
                configSchema.ConfigCatalogCacheWrapper.applyVariantConfigurationCatalogCache(configSchema.ConfigObjVarName);
                configSchema.resetSourceObjDirtyFlag(configSchema);
                success=true;
            case cancel
            end

        end

        function toggleCompBrowserVisibility(dlg)
            configSchema=dlg.getSource;
            configSchema.IsCompBrowserVisible=~configSchema.IsCompBrowserVisible;
            if configSchema.IsCompBrowserVisible
                isShowAllCtrlVarsOn=configSchema.CtrlVarSSSrc.IsShowAllCtrlVarsOn;
                dlg.setWidgetValue('showAllCtrlVarsCheckboxTag',isShowAllCtrlVarsOn);
            end
            dlg.setVisible('showAllCtrlVarsCheckboxTag',configSchema.IsCompBrowserVisible);
        end

        function showHideCompBrowser(dlg,isVisible)
            configSchema=dlg.getSource;
            if isVisible
                dlg.setWidgetValue('showAllCtrlVarsCheckboxTag',true);
                isShowAllCtrlVarsOn=configSchema.CtrlVarSSSrc.IsShowAllCtrlVarsOn;
                dlg.setWidgetValue('showAllCtrlVarsCheckboxTag',isShowAllCtrlVarsOn);
            end
            configSchema.IsCompBrowserVisible=isVisible;
            dlg.refreshWidget('compConfigsToggleBtnTag');
            dlg.setVisible('showAllCtrlVarsCheckboxTag',isVisible);
        end

        function refreshVariantConfigurations(dlg,configSchema)


            configSchema.loadVariantConfigurations(dlg,configSchema);
            import slvariants.internal.manager.ui.config.findDDGByTagIdAndTag;
            constrDlg=findDDGByTagIdAndTag(configSchema.TagId,'constraintsDialogSchemaTag');
            constrDlg.getSource().refreshGlobalConstraints(constrDlg);
            configSchema.resetSourceObjDirtyFlag(configSchema);
        end

        function loadVariantConfigurations(dlg,configSchema)

            import slvariants.internal.manager.ui.config.VariantConfigurationSource
            import slvariants.internal.manager.ui.config.ControlVariableSource
            import slvariants.internal.manager.ui.config.VMgrConstants

            configSchema.ConfigCatalogCacheWrapper.refreshVariantConfigurationCatalog(configSchema.ConfigObjVarName);
            configSchema.SourceObj=configSchema.ConfigCatalogCacheWrapper.VariantConfigurationCatalogCache;
            configSchema.ConfigSSSrc=VariantConfigurationSource(configSchema);

            configSchema.ConfigDescription='';
            configSchema.CtrlVarSSSrc=ControlVariableSource(configSchema.SourceObj,configSchema.ConfigSSSrc.GlobalWksConfig.Name,configSchema,true);
            configSchema.SelectedConfig=configSchema.ConfigCatalogCacheWrapper.ConfigWorkspace;


            dlg.setWidgetValue('configNameLabelTag',configSchema.SelectedConfig);


            dlg.setWidgetValue('configDescEditAreaWidgetTag',configSchema.ConfigDescription);

            configSchema.updateSpreadsheet(dlg,configSchema.ConfigSSSrc,'configsSSWidgetTag');
            configSchema.updateSpreadsheet(dlg,configSchema.CtrlVarSSSrc,'controlVariablesSSWidgetTag');
            ddSpec=get_param(configSchema.BDName,'DataDictionary');
            baseWorkspace=getString(message('Simulink:VariantManagerUI:BaseWorkspace'));
            if isempty(ddSpec)
                importVarConfigMsg=MException(message('Simulink:VariantManagerUI:VariantManagerImportSuccessfulMessage',configSchema.ConfigObjVarName,baseWorkspace));
            else
                importVarConfigMsg=MException(message('Simulink:VariantManagerUI:VariantManagerImportSuccessfulMessage',configSchema.ConfigObjVarName,ddSpec));
            end
            sldiagviewer.reportInfo(importVarConfigMsg);
        end

        function setSourceObjDirtyFlag(configSchema)



            if configSchema.IsStandalone||configSchema.IsSourceObjDirtyFlag


                return;
            end

            bdHandle=get_param(configSchema.BDName,'Handle');
            slvariants.internal.manager.ui.setVCDOinVMDirty(bdHandle);
        end

        function resetSourceObjDirtyFlag(configSchema)
            import slvariants.internal.manager.ui.config.VariantConfigurationSource
            import slvariants.internal.manager.ui.config.ControlVariableSource
            import slvariants.internal.manager.ui.config.VMgrConstants
            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema

            if configSchema.IsStandalone||~configSchema.IsSourceObjDirtyFlag


                return;
            end
            bdHandle=get_param(configSchema.BDName,'Handle');
            configSchema.IsSourceObjDirtyFlag=false;

            slvariants.internal.manager.core.setTitleDirty(bdHandle,false);
        end

        function saveCacheToSourceObj(configSchema)


            configSchema.ConfigCatalogCacheWrapper.saveCacheToVariantConfigurationCatalog();
            configSchema.resetSourceObjDirtyFlag(configSchema);
        end

        function success=updateVariantConfigurationsName(value,configSchema)
            success=false;
            if strcmp(configSchema.ConfigObjVarName,value)
                return;
            end






            if configSchema.IsSourceObjDirtyFlag&&~isempty(configSchema.ConfigObjVarName)
                yes=message('MATLAB:uistring:popupdialogs:Yes').getString();
                no=message('MATLAB:uistring:popupdialogs:No').getString();
                questMsg=DAStudio.message('Simulink:VariantManagerUI:VariantManagerPromptUnexportedVcdochanges',...
                configSchema.ConfigObjVarName,configSchema.ConfigCatalogCacheWrapper.ConfigWorkspace);
                selection=questdlg(questMsg,configSchema.BDName,yes,no,no);
                switch selection
                case yes
                    configSchema.ConfigCatalogCacheWrapper.applyVariantConfigurationCatalogCache(configSchema.ConfigObjVarName);
                case no
                end
            end
            if isempty(value)
                ok=message('MATLAB:uistring:popupdialogs:OK').getString();
                cancel=message('MATLAB:uistring:popupdialogs:Cancel').getString();
                emptyNameQuestMsg=DAStudio.message('Simulink:VariantManagerUI:MessageClearassociation');
                emptyNameSelection=questdlg(emptyNameQuestMsg,configSchema.BDName,ok,cancel,cancel);
                switch emptyNameSelection
                case ok
                case cancel
                    return;
                end
            end
            configSchema.ConfigObjVarName=value;
            success=true;
            configSchema.ConfigCatalogCacheWrapper.deepCopyVariantConfigurationCatalog();


            modelHandle=get_param(configSchema.BDName,'handle');
            if~Simulink.variant.utils.existsVCDO(modelHandle,configSchema.ConfigObjVarName)
                configSchema.setSourceObjDirtyFlag(configSchema);
            else
                configSchema.resetSourceObjDirtyFlag(configSchema);
            end
        end

        function updateConfigurationDescription(value,configSchema)


            configSchema.SourceObj.setConfigurationDescription(configSchema.CtrlVarSSSrc.ConfigName,value);
            configSchema.setSourceObjDirtyFlag(configSchema);
        end

        function ctrlVarItemChanged(~,sels,propName,~,dlg)
            import slvariants.internal.manager.ui.config.VMgrConstants
            if strcmp(propName,VMgrConstants.Value)
                ConfigurationsDialogSchema.ctrlVarAffordanceUpdate(sels{1},dlg);
            end
            ctrlVarSS=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            ctrlVarSS.update(sels{1});
        end

        function ctrlVarAffordanceUpdate(sels,dlg)
            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema
            ConfigurationsDialogSchema.updateConvertTypesSplitButton(sels,dlg);
            ConfigurationsDialogSchema.updateSimulinkParameterEditButton(sels,dlg);
        end

        function removeCompSpecificCtrlVarIndex(compBrowserSSRows,ctrlVarIdx)


            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema
            for compBrowserSSRowIdx=1:numel(compBrowserSSRows)
                compBrowserSSRow=compBrowserSSRows(compBrowserSSRowIdx);
                compBrowserSSRow.CompSpecificCtrlVarIndices(compBrowserSSRow.CompSpecificCtrlVarIndices==ctrlVarIdx)=[];
                compBrowserSSRow.CompSpecificCtrlVarIndices=compBrowserSSRow.CompSpecificCtrlVarIndices...
                -(compBrowserSSRow.CompSpecificCtrlVarIndices>ctrlVarIdx);
                ConfigurationsDialogSchema.removeCompSpecificCtrlVarIndex(compBrowserSSRow.Children,ctrlVarIdx);
            end
        end

        function copyUpdateCompSpecificCtrlVarIndices(compBrowserSSRows,ctrlVarIdx)


            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema
            for compBrowserSSRowIdx=1:numel(compBrowserSSRows)
                compBrowserSSRow=compBrowserSSRows(compBrowserSSRowIdx);
                compBrowserSSRow.CompSpecificCtrlVarIndices=compBrowserSSRow.CompSpecificCtrlVarIndices...
                +(compBrowserSSRow.CompSpecificCtrlVarIndices>ctrlVarIdx);
                ConfigurationsDialogSchema.copyUpdateCompSpecificCtrlVarIndices(compBrowserSSRow.Children,ctrlVarIdx);
            end
        end

        function copyCtrlVar(selRowObj,configSchema,ctrlVarNames)


            import slvariants.internal.manager.ui.config.ControlVariableRow
            ctrlVarSSSrc=selRowObj.CtrlVarSSSrc;
            varConfigs=ctrlVarSSSrc.VariantConfigs;
            ctrlVarIdx=selRowObj.CtrlVarIdx;
            newCtrlVarName=matlab.lang.makeUniqueStrings(selRowObj.CtrlVarName,ctrlVarNames);
            varConfigs.copyControlVariableByPos(ctrlVarSSSrc.ConfigName,ctrlVarIdx,newCtrlVarName);
            newCtrlVarIdx=ctrlVarIdx+1;
            newRow=ControlVariableRow(ctrlVarSSSrc,newCtrlVarName,newCtrlVarIdx);
            ctrlVarSSSrc.Children=[ctrlVarSSSrc.Children(1:ctrlVarIdx),newRow,ctrlVarSSSrc.Children(ctrlVarIdx+1:end)];
            if~isempty(configSchema.CompBrowserSSSrc)
                configSchema.copyUpdateCompSpecificCtrlVarIndices(configSchema.CompBrowserSSSrc.Children,ctrlVarIdx);
            end
            if~configSchema.CtrlVarSSSrc.IsShowAllCtrlVarsOn...
                &&configSchema.IsCompBrowserVisible
                currCompBrowserRow=configSchema.CompBrowserSSSrc.CurrentCompRow;
                compSpecificCtrlVarIndices=currCompBrowserRow.CompSpecificCtrlVarIndices;
                ctrlVarRowIdx=find(compSpecificCtrlVarIndices==ctrlVarIdx);
                currCompBrowserRow.CompSpecificCtrlVarIndices=[compSpecificCtrlVarIndices(1:ctrlVarRowIdx),newCtrlVarIdx,compSpecificCtrlVarIndices(ctrlVarRowIdx+1:end)];
            end


            configSchema.updateIndicesForRowsBelow(ctrlVarSSSrc.Children,newCtrlVarIdx,1);
        end

        function compBrowserItemClicked(~,item,~,dlg)
            compBrowserSSRow=item{1};
            compBrowserSSSource=compBrowserSSRow.CompBrowserViewSrc;
            compBrowserSSSource.CurrentCompRow=compBrowserSSRow;
            configSchema=compBrowserSSSource.ConfigDialogSchema;
            if configSchema.CtrlVarSSSrc.IsShowAllCtrlVarsOn
                return;
            end
            configSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
        end

        function updateConfigsSS(dlg,configSchema,configRowObj,displayConfigIdx,configChanged)
            configSchema.updateConfigurationContents(dlg,displayConfigIdx,configRowObj);
            if configSchema.IsStandalone
                return;
            end



            configSchema.updateHierarchyTableAffordance(configSchema);
            configSchema.showHideCompBrowser(dlg,configSchema.IsCompBrowserVisible);

            if configChanged

                configSchema.CtrlVarSSSrc.clearHighlightForAllCtrlVar(dlg);
                slvariants.internal.manager.core.clearHighlightForAllHierViewRows(get_param(configSchema.BDName,'Handle'));

                configSchema.IsControlVarsTableDirty=~isempty(configRowObj.CtrlVarSSSrc.Children);





                modelHandle=get_param(configSchema.BDName,'handle');
                studio=slvariants.internal.manager.core.getStudio(modelHandle);

                toolStrip=studio.getToolStrip;

                as=toolStrip.getActionService();
                as.refreshAction('navigateLeftChoicesAction');
                as.refreshAction('navigateRightChoicesAction');
                as.refreshAction('viewBlocksFilterAction');
                as.refreshAction('navigateChoicesComboBoxAction');
                as.refreshAction('navigateLabelAction');
                as.refreshAction('viewBlocksLabelAction');
                as.refreshAction('activateConfigPushButtonAction');

                dlg.refresh;
                dlg.setEnabled('convertTypesSplitButtonTag',false);
            end

            slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.updateCompBrowser(configSchema.BDName);
        end

        function configItemClicked(~,item,~,dlg)

            configSchema=item{1}.VarConfigSSSrc.DialogSchema;
            lastSelectedRow=configSchema.SelectedConfig;
            displayConfigIdx=item{1}.VarConfigIdx;


            currentSelectedRow=item{1}.VarConfigName;
            configChanged=~strcmp(lastSelectedRow,currentSelectedRow);
            configSchema.updateConfigsSS(dlg,configSchema,item{1},displayConfigIdx,configChanged);
            if strcmp(currentSelectedRow,dlg.getSource.ConfigSSSrc.GlobalWksConfig.Name)



                slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.setCompBrowserVisible(dlg.getSource.BDName,false);
            end
        end

        function configItemDoubleClicked(tagName,item,propName,dlg)%#ok<INUSD>

            disp(tagName);
        end

        function nextConfigIdx=getNextConfigIndex(selRowObj)


            configIdx=selRowObj.VarConfigIdx;


            if configIdx+1<=length(selRowObj.VarConfigSSSrc.VariantConfigs.Configurations)
                nextConfigIdx=configIdx;
            else
                nextConfigIdx=configIdx-1;
            end
        end

        function updateHierarchyTableAffordance(configSchema)
            isCurrentSelectedConfigActivatedConfig=strcmp(configSchema.SelectedConfig,configSchema.ActivatedConfig);
            updateAffordance=xor(isCurrentSelectedConfigActivatedConfig,configSchema.IsSelectedConfigActivatedConfig);
            if updateAffordance
                configSchema.IsSelectedConfigActivatedConfig=isCurrentSelectedConfigActivatedConfig;
                slvariants.internal.manager.core.setIsSelectedConfigInSync(get_param(configSchema.BDName,'Handle'),configSchema.IsSelectedConfigActivatedConfig);
            end
        end




        function updateConfigurationContents(dlg,configIdx,selRowObj)
            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema
            import slvariants.internal.manager.ui.config.ControlVariableSource

            configSrc=selRowObj.VarConfigSSSrc;
            configSchema=configSrc.DialogSchema;
            if configIdx==0
                if configSchema.IsStandalone

                    selectedConfigName='';
                else
                    configSrc=configSchema.GlobalConfigSSSrc;
                    selectedConfigName=configSrc.Children(1).VarConfigName;
                end
            else
                selectedConfigName=configSrc.VariantConfigs.Configurations(configIdx).Name;
            end

            if strcmp(configSchema.SelectedConfig,selectedConfigName)
                return;
            end
            configSchema.SelectedConfig=selectedConfigName;
            dlg.setEnabled('exportVariantControlVarButtonTag',...
            ~strcmp(configSchema.SelectedConfig,configSchema.ExportedConfig));

            configSSWidget=dlg.getWidgetInterface('configsSSWidgetTag');
            if~isempty(configSSWidget)
                if configIdx>0
                    configSSWidget.select(configSrc.Children(configIdx));
                else
                    configSSWidget.select([]);
                end
            end

            globalConfigSSWidget=dlg.getWidgetInterface('globalWSSSWidgetTag');
            if~isempty(globalConfigSSWidget)
                if configIdx>0
                    globalConfigSSWidget.select([]);
                else
                    globalConfigSSWidget.select(configSrc.Children(1));
                end
            end

            dlg.setEnabled('ctrlVarsTogglePanel',~isempty(configSchema.SelectedConfig));
            dlg.setEnabled('configDescTogglePanel',~isempty(configSchema.SelectedConfig));
            dlg.setVisible('configDescTogglePanel',~isempty(configSchema.SelectedConfig));



            dlg.setEnabled('compConfigsPanel',~configSchema.IsStandalone&&configIdx~=0);
            dlg.setVisible('compConfigsPanel',~configSchema.IsStandalone&&configIdx~=0);

            if configIdx==0
                if configSchema.IsStandalone
                    isEnabled=false;
                    configSchema.CtrlVarSSSrc=ControlVariableSource(...
                    configSchema.SourceObj,'',configSchema,false,isEnabled);
                else
                    configSchema.CtrlVarSSSrc=configSrc.CtrlVarSources(1);
                end
            else
                configSchema.CtrlVarSSSrc=configSrc.CtrlVarSources(configIdx);
                configSchema.ConfigDescription=configSchema.CtrlVarSSSrc.VariantConfigs.getConfigurationDescription(configSchema.CtrlVarSSSrc.ConfigName);
            end


            dlg.refreshWidget('prefConfigComboboxTag');


            dlg.setWidgetValue('configNameLabelTag',configSchema.SelectedConfig);


            dlg.setWidgetValue('configDescEditAreaWidgetTag',configSchema.ConfigDescription);



            dlg.setEnabled('showUsageVariantControlVarButtonTag',false);
            dlg.setEnabled('hideUsageVariantControlVarButtonTag',false);

            ConfigurationsDialogSchema.updateSpreadsheet(dlg,configSchema.CtrlVarSSSrc,'controlVariablesSSWidgetTag');

            ssComp=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            ctrlVarIdxToSel=min(configSchema.SelectedCtrlVarIdx,numel(selRowObj.CtrlVarSSSrc.Children)-1);
            if ctrlVarIdxToSel>0


                ssComp.select(selRowObj.CtrlVarSSSrc.Children(ctrlVarIdxToSel));
                configSchema.SelectedCtrlVarIdx=ctrlVarIdxToSel;
            end
        end

        function newConfigName=copyConfigName(sourceObj,selRowObj)


            newConfig=selRowObj.VarConfigSSSrc.VariantConfigs.Configurations(selRowObj.VarConfigIdx);
            newConfigName=matlab.lang.makeUniqueStrings(newConfig.Name,{sourceObj.Configurations.Name});
        end


        function updateSpreadsheet(dlg,ssSource,ssTag)
            ssWidget=dlg.getWidgetInterface(ssTag);
            ssWidget.setSource(ssSource);
        end

        function callUpdateOnSpreadsheet(dlg,ssTag)
            ssWidget=dlg.getWidgetInterface(ssTag);
            ssWidget.update(true);
        end

        function updateSpreadsheetRow(dlg,ssRow,ssTag)

            ssWidget=dlg.getWidgetInterface(ssTag);
            ssWidget.update(ssRow);
        end

        function createErrorDialog(value,varargin)

            dp=DAStudio.DialogProvider;
            errorMessage=message(varargin{1,:}).getString();
            dp.errordlg([value,': ',errorMessage],'Error',true);
        end

    end

    methods
        function setControlVariablesDirtyFlag(configSchema,dlg,isGlobalWksConfig,flag)
            if flag&&~isGlobalWksConfig
                configSchema.setSourceObjDirtyFlag(configSchema);
            end
            configSchema.IsControlVarsTableDirty=flag;



            if flag&&strcmp(configSchema.SelectedConfig,configSchema.ExportedConfig)
                configSchema.ExportedConfig='';
            end
            dlg.setEnabled('exportVariantControlVarButtonTag',flag);
        end

        function setExportBtnStateOnExportOrActivate(obj,dlg)
            obj.IsControlVarsTableDirty=false;
            dlg.setEnabled('exportVariantControlVarButtonTag',false);
            obj.ExportedConfig=obj.SelectedConfig;
        end

        function setSelectedConfigName(obj,configName)
            obj.SelectedConfig=configName;
        end
    end

end





