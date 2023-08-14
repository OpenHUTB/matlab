classdef(Sealed,Hidden)VMgrConstants










    properties(Constant)


        DiagMdlNamePrefix='_vmgr_';

        DiagComponentName=message('Simulink:VariantManager:ComponentNameForDiagnosticsMessage').getString();

        DiagAutoGenConfigCategory=message('Simulink:VariantManager:AutoGenConfigCategoryForDiagnosticsMessage').getString();


        OpenRootMdl='OpenRootModel'

        OpenAsRootMdl='OpenAsRootModel';

        OpenProtectedRefMdl='OpenProtectedRefModel';

        OpenRefMdl='OpenRefModel';

        OpenChart='OpenSFChart';

        OpenRefSubSys='OpenReferencedSubSystem';

        OpenSFTransition='OpenSFTransition';

        OpenBlk='OpenBlk';

        OpenParentBlkParams='OpenParentBlkParams';

        OpenBlkParams='OpenBlkParams';

        OpenParentChartParams='OpenParentChartParams';

        OpenChartParams='OpenChartParams';

        LabelModeActiveChoice='LabelModeActiveChoice';

        ShowUsage='ShowUsage';

        HideUsage='HideUsage';


        BaseWorkspaceTitle='Base workspace';

        BaseWorkspaceSource='base workspace';

        DataDictionarySource='data dictionary';

        CommonOpen=getString(message('Simulink:VariantManagerUI:CommonOpen'));

        DefaultFilter=message('Simulink:VariantManagerUI:DefaultSearchString').getString();

        Name=message('Simulink:VariantManagerUI:CommonName').getString();

        VariantCondition=message('Simulink:VariantManagerUI:HierarchyColumnsControl').getString();

        Condition=message('Simulink:VariantManagerUI:HierarchyColumnsCondition').getString();

        Configurations=message('Simulink:VariantManagerUI:ConfigsTitle').getString();

        Constraint=message('Simulink:VariantManagerUI:ConstraintTitle').getString();

        Constraints=message('Simulink:VariantManagerUI:ConstraintsTitle').getString();

        Description=message('Simulink:VariantManagerUI:CommonDescription').getString();

        ControlVariables=message('Simulink:VariantManagerUI:ControlVariablesTitle').getString();

        Activate=message('Simulink:VariantManagerUI:HierarchyButtonActivate').getString();

        ShowAll=message('Simulink:VariantManagerUI:ControlVariablesButtonShowAll').getString();

        Apply=message('Simulink:VariantManagerUI:VariantConfigurationsApplyButton').getString();

        Refresh=message('Simulink:VariantManagerUI:VariantConfigurationsRefreshButton').getString();

        Reload=message('Simulink:VariantManagerUI:VariantConfigurationsReloadButton').getString();

        Import=message('Simulink:VariantManagerUI:VariantConfigurationsImportButton').getString();

        Export=message('Simulink:VariantManagerUI:VariantConfigurationsExportButton').getString();

        Value=message('Simulink:VariantManagerUI:ControlVariablesColumnValue').getString();

        Source=message('Simulink:VariantManagerUI:ControlVariablesColumnSource').getString();

        Usage=message('Simulink:VariantManagerUI:ControlVariablesColumnUsage').getString();

        ActivationTime=message('Simulink:VariantManagerUI:ControlVariablesColumnActivationTime').getString();

        ComponentConfigurations=message('Simulink:VariantManagerUI:CompBrowserTitle').getString();

        ShowComponentConfigurations=message('Simulink:VariantManagerUI:ShowComponentConfigurations').getString();

        HideComponentConfigurations=message('Simulink:VariantManagerUI:HideComponentConfigurations').getString();

        ComponentColName=message('Simulink:VariantManagerUI:CompBrowserComponentColumnTitle').getString();

        SelectedConfigColName=message('Simulink:VariantManagerUI:CompBrowserSelectedConfigurationColumnTitle').getString();

        CustomSelectedConfig=message('Simulink:VariantManagerUI:CompBrowserCustomSelectedConfig').getString();

        AddConfigButtonToolTip=getString(message('Simulink:VariantManagerUI:ConfigsButtonAdd'));
        DeleteConfigButtonToolTip=getString(message('Simulink:VariantManagerUI:ConfigsButtonDelete'));
        CopyConfigButtonToolTip=getString(message('Simulink:VariantManagerUI:ConfigsButtonCopy'));

        AddCtrlVarButtonToolTip=getString(message('Simulink:VariantManagerUI:ControlVariablesButtonAdd'));
        DeleteCtrlVarButtonToolTip=getString(message('Simulink:VariantManagerUI:ControlVariablesButtonDelete'));
        CopyCtrlVarButtonToolTip=getString(message('Simulink:VariantManagerUI:ControlVariablesButtonClone'));

        AddConstraintButtonToolTip=getString(message('Simulink:VariantManagerUI:ConstraintsButtonAdd'));
        DeleteConstraintButtonToolTip=getString(message('Simulink:VariantManagerUI:ConstraintsButtonDelete'));
        CopyConstraintButtonToolTip=getString(message('Simulink:VariantManagerUI:ConstraintsButtonCopy'));

        AddVarGrpButtonToolTip=getString(message('Simulink:VariantManagerUI:VarGrpsButtonAdd'));
        DeleteVarGrpButtonToolTip=getString(message('Simulink:VariantManagerUI:VarGrpsButtonDelete'));
        CopyVarGrpButtonToolTip=getString(message('Simulink:VariantManagerUI:VarGrpsButtonCopy'));

        ImportButtonToolTip=message('Simulink:VariantManagerUI:ControlVariablesButtonImport').getString();

        ExportButtonToolTip=message('Simulink:VariantManagerUI:ButtonExportControlvarsTooltip').getString();

        ShowUsageButtonToolTip=message('Simulink:VariantManagerUI:ControlVariablesButtonShowusage').getString();

        HideUsageButtonToolTip=message('Simulink:VariantManagerUI:ControlVariablesButtonHideusage').getString();

        SimulinkParameterConvertButtonToolTip=message('Simulink:VariantManagerUI:ConvertToSLPrmType').getString();

        AUTOSARParameterConvertButtonToolTip=message('Simulink:VariantManagerUI:ConvertToAUTOSARPrmType').getString();

        SimulinkParameterEditButtonToolTip=message('Simulink:VariantManagerUI:ControlVariablesButtonEditparameter').getString();


        ActivationTimeUD='update diagram';

        ActivationTimeUDAAC='update diagram analyze all choices';

        ActivationTimeCC='code compile';

        ActivationTimeStartup='startup';

        ConfigurationListPlaceholder=getString(message('Simulink:VariantManagerUI:ConfigListPlaceholderText'));
        CtrlVarListPlaceholder=getString(message('Simulink:VariantManagerUI:ControlVarListPlaceholderText'));


        ConstraintName=message('Simulink:VariantManagerUI:ConstraintNameLbl').getString();
        ConstraintCondition=message('Simulink:VariantManagerUI:ConstraintsColumnCondition').getString();
        ConstraintDescription=message('Simulink:VariantManagerUI:CommonDescription').getString();
        ConstraintList=message('Simulink:VariantManagerUI:ConstraintsListTitle').getString();
        ConstraintDefinition=message('Simulink:VariantManagerUI:ConstraintDefinitionTitleWithNoConstraint').getString();
        ConstraintPanel=message('Simulink:VariantManagerUI:ConstraintsTitle').getString();
        ConstraintListPlaceholder=message('Simulink:VariantManagerUI:ConstraintListPlaceholderText').getString();
        ConstraintConditionPlaceholder=message('Simulink:VariantManagerUI:ConstraintConditionPlaceholderText').getString();
        ConstraintDescriptionPlaceholder=message('Simulink:VariantManagerUI:ConstraintDescriptionPlaceholderText').getString();
        ConstraintInfoMssg=message('Simulink:VariantManagerUI:ConstraintDefinitionInfoMssg').getString();


        Help=getString(message('Simulink:VariantManagerUI:HelpTitle'));
        DefineConfigsHelpTabLabel=message('Simulink:VariantManagerUI:DefineConfigsHelpTabLabel').getString();
        DefineConfigsHelpHeader=message('Simulink:VariantManagerUI:DefineConfigsHelpHeader').getString();
        DefineConfigsHelpText=message('Simulink:VariantManagerUI:DefineConfigsHelpText').getString();
        DefineConstraintsHelpHeader=message('Simulink:VariantManagerUI:DefineConstraintsHelpHeader').getString();
        DefineConstraintsHelpText=message('Simulink:VariantManagerUI:DefineConstraintsHelpText').getString();
        ActivateConfigHelpTabLabel=message('Simulink:VariantManagerUI:ActivateConfigHelpTabLabel').getString();
        ActivateConfigHelpHeader=message('Simulink:VariantManagerUI:ActivateConfigHelpHeader').getString();
        ActivateConfigHelpText=message('Simulink:VariantManagerUI:ActivateConfigHelpText').getString();
        GenerateConfigsHelpTabLabel=message('Simulink:VariantManagerUI:GenerateConfigsHelpTabLabel').getString();
        GenerateConfigsHelpHeader=message('Simulink:VariantManagerUI:GenerateConfigsHelpHeader').getString();
        GenerateConfigsHelpText=message('Simulink:VariantManagerUI:GenerateConfigsHelpText').getString();
        ComposeComponentsHelpTabLabel=message('Simulink:VariantManagerUI:ComposeComponentsHelpTabLabel').getString();
        ComposeComponentsHelpHeader=message('Simulink:VariantManagerUI:ComposeComponentsHelpHeader').getString();
        ComposeComponentsHelpText=message('Simulink:VariantManagerUI:ComposeComponentsHelpText').getString();
        ReduceHelpTabLabel=message('Simulink:VariantManagerUI:ReduceHelpTabLabel').getString();
        ReduceHelpHeader=message('Simulink:VariantManagerUI:ReduceHelpHeader').getString();
        ReduceHelpText=message('Simulink:VariantManagerUI:ReduceHelpText').getString();
        AnalyzeHelpTabLabel=message('Simulink:VariantManagerUI:AnalyzeHelpTabLabel').getString();
        AnalyzeHelpHeader=message('Simulink:VariantManagerUI:AnalyzeHelpHeader').getString();
        AnalyzeHelpText=message('Simulink:VariantManagerUI:AnalyzeHelpText').getString();



        ReferenceValue=message('Simulink:VariantManagerUI:VariantReducerCtrlvarTableRefvaluecolumnheader').getString();

        SelectCol='__';

        Values=message('Simulink:VariantManagerUI:VariantReducerCtrlvarTableValuecolumnheader').getString();

        FullRange='Full-range';

        Ignored='Ignored';

        DefaultGroupName='Group';

        VariableGroupTitle=message('Simulink:VariantManagerUI:VariableGroupsTabTitle').getString();

        AutoGenConfigDataType=message('Simulink:VariantManagerUI:AutoGenConfigDataTypeColumnHeader').getString();

        AutoGenConfigValues=message('Simulink:VariantManagerUI:AutoGenConfigValuesColumnHeader').getString();

        AutoGenConfigValidityStatus=message('Simulink:VariantManagerUI:AutoGenConfigValidityStatusColumnHeader').getString();

        MoveUpButtonToolTip=message('Simulink:VariantManagerUI:AutoGenConfigMoveUpButtonToolTip').getString();

        MoveDownButtonToolTip=message('Simulink:VariantManagerUI:AutoGenConfigMoveDownButtonToolTip').getString();

        SelectAllButtonToolTip=message('Simulink:VariantManagerUI:AutoGenConfigSelectAllButtonToolTip').getString();

        DeselectAllButtonToolTip=message('Simulink:VariantManagerUI:AutoGenConfigDeselectAllButtonToolTip').getString();

        AutoGenConfigTabId='generateConfigTab';

        SerialNum='#';



        ToggleSLVarCtrlButtonToolTip=message('Simulink:VariantManagerUI:ConvertToSLVarCtrlType').getString();

        ConvertToNormalCtrlButtonToolTip=message('Simulink:VariantManagerUI:ConvertToNormalCtrlType').getString();

        IconsDir=fullfile(matlabroot,'toolbox','sl_variants','manager','ui','icons');

        AddRowIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'add_16.png'];

        DeleteRowIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'delete_16.png'];

        CopyRowIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'copy_16.png'];

        ActivateBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'refresh_16.png'];

        ImportCtrlVarsBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'import_data_16.png'];

        ExportCtrlVarsBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'export_data_16.png'];

        SimParamConvertBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'toggle_var_type_16.png'];

        ToggleSLVarCtrlBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'toggle_sl_vctrl_16.png'];

        SimParamEditBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'edit_param_16.png'];

        ExpandCompBrowserBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'right_shift_16.png'];

        CollapseCompBrowserBtnIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'left_shift_16.png'];

        CompBrowserHasCtrlVarsIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'cog_20.png'];

        NormalTypeIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'normal_value_16.png'];

        ParamTypeIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'param_value_16.png'];

        ShowUsageButtonIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'show_usage_16.png'];

        HideUsageButtonIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'hide_usage_16.png'];

        SLVarCtrlNormalTypeIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'sl_vctrl_norm_val_16.png'];

        SLVarCtrlParamTypeIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'sl_vctrl_param_val_16.png'];

        InfoIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'info_16.png'];

        CloseIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'close_16.png'];

        MoveUpButtonIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'navigate_up_16.png'];

        MoveDownButtonIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'navigate_down_16.png'];

        SelectAllButtonIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'select_all_16.png'];

        DeselectAllButtonIcon=[slvariants.internal.manager.ui.config.VMgrConstants.IconsDir,filesep,'deselect_all_16.png'];

        PropField2ObjFieldMap=containers.Map({...
        slvariants.internal.manager.ui.config.VMgrConstants.Name...
        ,slvariants.internal.manager.ui.config.VMgrConstants.Value...
        ,slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime...
        ,slvariants.internal.manager.ui.config.VMgrConstants.Source...
        ,slvariants.internal.manager.ui.config.VMgrConstants.Usage...
        ,slvariants.internal.manager.ui.config.VMgrConstants.Constraint...
        ,slvariants.internal.manager.ui.config.VMgrConstants.Description...
        },...
        {...
'Name'...
        ,'Value'...
        ,'ActivationTime'...
        ,'Source'...
        ,'Usage'...
        ,'Constraint'...
        ,'Description'...
        });
    end

end




