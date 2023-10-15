classdef AppGenerator < handle




    properties ( Constant, Hidden )


        SLRTAppGenerator_tag = "SLRTAppGenerator"
        ApplicationTreePanel_tag = "ApplicationTreePanel"
        ComponentsDocumentGroup_tag = "ComponentsDocumentGroup"
        BindingsDocument_tag = "BindingsDocument"
        ParameterPropsFigPanel_tag = "ParameterPropsFigPanel"
        ParameterControlPropsFigPanel_tag = "ParameterControlPropsFigPanel"
        ParameterOptionPropsFigPanel_tag = "ParameterOptionPropsFigPanel"
        ParameterContext_tag = "ParmeterContext"
        SignalPropsFigPanel_tag = "SignalPropsFigPanel"
        SignalControlPropsFigPanel_tag = "SignalControlPropsFigPanel"
        SignalOptionPropsFigPanel_tag = "SignalOptionPropsFigPanel"
        SignalLinePropsFigPanel_tag = "SignalLinePropsFigPanel"
        SignalContext_tag = "SignalContext"
        SignalWithLineContext_tag = "SignalWithLineContext"
        Tabs_tag = "Tabs"
        TabDesigner_tag = "TabDesigner"
        TabDesignerSectionFile_tag = "TabDesignerSectionFile"
        TabDesignerSectionFileColumnNew_tag = "TabDesignerSectionFileColumnNew"
        TabDesignerSectionFileColumnOpen_tag = "TabDesignerSectionFileColumnOpen"
        TabDesignerSectionFileColumnSave_tag = "TabDesignerSectionFileColumnSave"
        TabDesignerSectionConfigure_tag = "TabDesignerSectionConfigure"
        TabDesignerSectionConfigureColumnOptions_tag = "TabDesignerSectionConfigureColumnOptions"
        TabDesignerSectionBindings_tag = "TabDesignerSectionBindings"
        TabDesignerSectionBindingsColumnAddFromModel_tag = "TabDesignerSectionBindingsColumnAddFromModel"
        TabDesignerSectionBindingsColumnHighlight_tag = "TabDesignerSectionBindingsColumnHighlight"
        TabDesignerSectionBindingsColumnRemove_tag = "TabDesignerSectionBindingsColumnRemove"
        TabDesignerSectionBindingsColumnValidate_tag = "TabDesignerSectionBindingsColumnValidate"
        TabDesignerSectionInstrumentPanel_tag = "TabDesignerSectionInstrumentPanel"
        TabDesignerSectionInstrumentPanelColumnGenerate_tag = "TabDesignerSectionInstrumentPanelColumnGenerate"
        TabDesignerSectionInstrumentPanelColumnModify_tag = "TabDesignerSectionInstrumentPanelColumnModify"



        GenericFile_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'genericFile_16.png' )
        RecentFiles_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'recentFiles_16.png' )
        New_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'new_16.png' )
        New_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'new_24.png' )
        Open_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'open_16.png' )
        Open_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'Open_24.png' )
        Save_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'save_16.png' )
        Save_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'save_24.png' )
        SaveAs_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'saveAs_16.png' )
        SaveCopyAs_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'saveCopyAs_16.png' )
        Settings_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'settings_24.png' )
        Settings_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'settings_16.png' )
        ModelFile_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'mdlFile_24.png' )
        ModelFile_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'model_16.png' )
        HighlightInModel_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'highlight_model_24.png' )
        Remove_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'remove_24.png' )
        NewInstrumentPanel_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'inst_panel_new_24.png' )
        EditInstrumentPanel_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'inst_panel_edit_24.png' )
        AddRow_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'add_row_16.gif' )
        Parameter_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'parameter_16.png' )
        Signal_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'signal_16.png' )
        Search_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'Search_16.png' )
        Remove_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'remove_16.png' )
        RightArrow_icon12 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'triangleSmallRightBlack_12.png' )
        DownArrow_icon12 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'triangleSmallDownBlack_12.png' )
        Refresh_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'refresh_16.png' )
        Validate_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'validate_24.png' )
        EditBindingSource_icon16 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'edit_binding_source_16.png' )
        TargetSelector_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'dropdown_24.png' )
        Load_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'load_24.png' )
        Connect_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'connect_24.png' )
        Start_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'run_24.png' )
        StopTime_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'stopTime_24.png' )
        SystemLog_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'systemLog_24.png' )
        StatusBar_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'statusBar_24.png' )
        Menu_icon24 = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'menu_24.png' )



        signalIconStyle = uistyle( 'Icon', slrealtime.internal.guis.AppGenerator.Signal_icon16, 'HorizontalAlignment', 'center', 'IconAlignment', 'center' );
        parameterIconStyle = uistyle( 'Icon', slrealtime.internal.guis.AppGenerator.Parameter_icon16, 'HorizontalAlignment', 'center', 'IconAlignment', 'center' );
        invalidBindingStyle = uistyle( 'BackgroundColor', 'red' );



        Error_msg = getString( message( 'slrealtime:appdesigner:Error' ) )
        Info_msg = getString( message( 'slrealtime:appdesigner:Info' ) )
        Success_msg = getString( message( 'slrealtime:appdesigner:Success' ) )
        ValidatingTitle_msg = getString( message( 'slrealtime:appdesigner:ValidatingTitle' ) )
        ValidatingMsg_msg = getString( message( 'slrealtime:appdesigner:Validating' ) )
        CreatingNewSessionTitle_msg = getString( message( 'slrealtime:appdesigner:CreatingNewSessionTitle' ) )
        CreatingNewSessionMsg_msg = getString( message( 'slrealtime:appdesigner:CreatingNewSession' ) )
        SaveSessionToFile_msg = getString( message( 'slrealtime:appdesigner:SaveSessionToFile' ) )
        AskToSaveSession_msg = getString( message( 'slrealtime:appdesigner:AskToSaveSession' ) )
        AskToSaveSessionTitle_msg = getString( message( 'slrealtime:appdesigner:AskToSaveSessionTitle' ) )
        AskToUpdateDiagram_msg = getString( message( 'slrealtime:appdesigner:AskToUpdateDiagram' ) )
        AskToUpdateDiagramTitle_msg = getString( message( 'slrealtime:appdesigner:AskToUpdateDiagramTitle' ) )
        SessionNotSaved_msg = getString( message( 'slrealtime:appdesigner:SessionNotSaved' ) )
        SessionNotSavedTitle_msg = getString( message( 'slrealtime:appdesigner:SessionNotSavedTitle' ) )
        Yes_msg = getString( message( 'slrealtime:appdesigner:Yes' ) )
        No_msg = getString( message( 'slrealtime:appdesigner:No' ) )
        OK_msg = getString( message( 'slrealtime:appdesigner:OK' ) )
        Confirm_msg = getString( message( 'slrealtime:appdesigner:Confirm' ) )
        Continue_msg = getString( message( 'slrealtime:appdesigner:Continue' ) )
        Abort_msg = getString( message( 'slrealtime:appdesigner:Abort' ) )
        Cancel_msg = getString( message( 'slrealtime:appdesigner:Cancel' ) )
        AppTitle_msg = getString( message( 'slrealtime:appdesigner:AppTitle' ) )
        ApplicationTree_msg = getString( message( 'slrealtime:appdesigner:ApplicationTree' ) )
        ApplicationData_msg = getString( message( 'slrealtime:appdesigner:ApplicationData' ) )
        Binding_msg = getString( message( 'slrealtime:appdesigner:Binding' ) )
        Bindings_msg = getString( message( 'slrealtime:appdesigner:Bindings' ) )
        BlockPath_msg = getString( message( 'slrealtime:appdesigner:BlockPath' ) )
        PortIndex_msg = getString( message( 'slrealtime:appdesigner:PortIndex' ) )
        Signal_msg = getString( message( 'slrealtime:appdesigner:Signal' ) )
        Signals_msg = getString( message( 'slrealtime:appdesigner:Signals' ) )
        SignalName_msg = getString( message( 'slrealtime:appdesigner:SignalName' ) )
        Control_msg = getString( message( 'slrealtime:appdesigner:Control' ) )
        ControlName_msg = getString( message( 'slrealtime:appdesigner:ControlName' ) )
        ControlType_msg = getString( message( 'slrealtime:appdesigner:ControlType' ) )
        Parameter_msg = getString( message( 'slrealtime:appdesigner:Parameter' ) )
        Parameters_msg = getString( message( 'slrealtime:appdesigner:Parameters' ) )
        ParameterName_msg = getString( message( 'slrealtime:appdesigner:ParameterName' ) )
        ConvertToComponent_msg = getString( message( 'slrealtime:appdesigner:ConvertToComponent' ) )
        ConvertToTarget_msg = getString( message( 'slrealtime:appdesigner:ConvertToTarget' ) )
        Options_msg = getString( message( 'slrealtime:appdesigner:Options' ) )
        PropertyName_msg = getString( message( 'slrealtime:appdesigner:PropertyName' ) )
        Element_msg = getString( message( 'slrealtime:appdesigner:Element' ) )
        BusElement_msg = getString( message( 'slrealtime:appdesigner:BusElement' ) )
        ArrayIndex_msg = getString( message( 'slrealtime:appdesigner:ArrayIndex' ) )
        Decimation_msg = getString( message( 'slrealtime:appdesigner:Decimation' ) )
        Callback_msg = getString( message( 'slrealtime:appdesigner:Callback' ) )
        AxesLine_msg = getString( message( 'slrealtime:appdesigner:AxesLine' ) )
        LineWidth_msg = getString( message( 'slrealtime:appdesigner:LineWidth' ) )
        LineStyle_msg = getString( message( 'slrealtime:appdesigner:LineStyle' ) )
        LineColor_msg = getString( message( 'slrealtime:appdesigner:LineColor' ) )
        LineMarker_msg = getString( message( 'slrealtime:appdesigner:LineMarker' ) )
        LineMarkerSize_msg = getString( message( 'slrealtime:appdesigner:LineMarkerSize' ) )
        Designer_msg = getString( message( 'slrealtime:appdesigner:Designer' ) )
        Configure_msg = getString( message( 'slrealtime:appdesigner:Configure' ) )
        ConfigureComps_msg = getString( message( 'slrealtime:appdesigner:ConfigureComps' ) )
        BindMode_msg = getString( message( 'slrealtime:appdesigner:BindMode' ) )
        SelectBindings_msg = getString( message( 'slrealtime:appdesigner:SelectBindings' ) )
        File_msg = getString( message( 'slrealtime:appdesigner:File' ) )
        New_msg = getString( message( 'slrealtime:appdesigner:New' ) )
        NewWithDots_msg = getString( message( 'slrealtime:appdesigner:NewWithDots' ) )
        Open_msg = getString( message( 'slrealtime:appdesigner:Open' ) )
        OpenWithDots_msg = getString( message( 'slrealtime:appdesigner:OpenWithDots' ) )
        RECENTFILES_msg = getString( message( 'slrealtime:appdesigner:RECENTFILES' ) )
        RecentFiles_msg = getString( message( 'slrealtime:appdesigner:RecentFiles' ) )
        Save_msg = getString( message( 'slrealtime:appdesigner:Save' ) )
        SaveAs_msg = getString( message( 'slrealtime:appdesigner:SaveAs' ) )
        SaveCopyAs_msg = getString( message( 'slrealtime:appdesigner:SaveCopyAs' ) )
        OptionsToolstripName_msg = getString( message( 'slrealtime:appdesigner:OptionsToolstripName' ) )
        OptionsToolstripDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsToolstripDesc' ) )
        OptionsMenuName_msg = getString( message( 'slrealtime:appdesigner:OptionsMenuName' ) )
        OptionsMenuDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsMenuDesc' ) )
        OptionsStatusBarName_msg = getString( message( 'slrealtime:appdesigner:OptionsStatusBarName' ) )
        OptionsStatusBarDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsStatusBarDesc' ) )
        OptionsTETName_msg = getString( message( 'slrealtime:appdesigner:OptionsTETName' ) )
        OptionsTETDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsTETDesc' ) )
        OptionsInstSignalsName_msg = getString( message( 'slrealtime:appdesigner:OptionsInstSignalsName' ) )
        OptionsInstSignalsDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsInstSignalsDesc' ) )
        OptionsDashboardName_msg = getString( message( 'slrealtime:appdesigner:OptionsDashboardName' ) )
        OptionsDashboardDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsDashboardDesc' ) )
        OptionsCallbackName_msg = getString( message( 'slrealtime:appdesigner:OptionsCallbackName' ) )
        OptionsCallbackDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsCallbackDesc' ) )
        OptionsUseGridName_msg = getString( message( 'slrealtime:appdesigner:OptionsUseGridName' ) )
        OptionsUseGridDesc_msg = getString( message( 'slrealtime:appdesigner:OptionsUseGridDesc' ) )
        OptionsConnectButton_msg = getString( message( 'slrealtime:appdesigner:OptionsConnectButton' ) )
        OptionsLoadButton_msg = getString( message( 'slrealtime:appdesigner:OptionsLoadButton' ) )
        OptionsStartStopButton_msg = getString( message( 'slrealtime:appdesigner:OptionsStartStopButton' ) )
        OptionsStatusBar_msg = getString( message( 'slrealtime:appdesigner:OptionsStatusBar' ) )
        OptionsStopTime_msg = getString( message( 'slrealtime:appdesigner:OptionsStopTime' ) )
        OptionsSystemLog_msg = getString( message( 'slrealtime:appdesigner:OptionsSystemLog' ) )
        OptionsTargetSelector_msg = getString( message( 'slrealtime:appdesigner:OptionsTargetSelector' ) )
        OptionsMenu_msg = getString( message( 'slrealtime:appdesigner:OptionsMenu' ) )
        AddFromModel_msg = getString( message( 'slrealtime:appdesigner:AddFromModel' ) )
        HiliteInModel_msg = getString( message( 'slrealtime:appdesigner:HiliteInModel' ) )
        Remove_msg = getString( message( 'slrealtime:appdesigner:Remove' ) )
        Validate_msg = getString( message( 'slrealtime:appdesigner:Validate' ) )
        InstrumentPanel_msg = getString( message( 'slrealtime:appdesigner:InstrumentPanel' ) )
        Generate_msg = getString( message( 'slrealtime:appdesigner:Generate' ) )
        Modify_msg = getString( message( 'slrealtime:appdesigner:Modify' ) )
        SelectAppFile_msg = getString( message( 'slrealtime:appdesigner:SelectAppFile' ) )
        SelectSavedSessionFile_msg = getString( message( 'slrealtime:appdesigner:SelectSavedSessionFile' ) )
        InvalidControlName_msg = getString( message( 'slrealtime:appdesigner:InvalidControlName' ) )
        ControlNameInUse_msg = getString( message( 'slrealtime:appdesigner:ControlNameInUse' ) )
        ControlNameInUseByType_msg = getString( message( 'slrealtime:appdesigner:ControlNameInUseByType' ) )
        ControlNameInUseChange_msg = getString( message( 'slrealtime:appdesigner:ControlNameInUseChange' ) )
        InvalidConvToComp_msg = getString( message( 'slrealtime:appdesigner:InvalidConvToComp' ) )
        InvalidConvToTarget_msg = getString( message( 'slrealtime:appdesigner:InvalidConvToTarget' ) )
        InvalidArrayIndex_msg = getString( message( 'slrealtime:appdesigner:InvalidArrayIndex' ) )
        InvalidDecimation_msg = getString( message( 'slrealtime:appdesigner:InvalidDecimation' ) )
        InvalidCallback_msg = getString( message( 'slrealtime:appdesigner:InvalidCallback' ) )
        InvalidLineWidth_msg = getString( message( 'slrealtime:appdesigner:InvalidLineWidth' ) )
        InvalidLineColor_msg = getString( message( 'slrealtime:appdesigner:InvalidLineColor' ) )
        InvalidLineMarkerSize_msg = getString( message( 'slrealtime:appdesigner:InvalidLineMarkerSize' ) )
        TreeProgressDlgTitle_msg = getString( message( 'slrealtime:appdesigner:TreeProgressDlgTitle' ) )
        TreeProgressDlgMsg_msg = getString( message( 'slrealtime:appdesigner:TreeProgressDlg' ) )
        Refresh_msg = getString( message( 'slrealtime:appdesigner:Refresh' ) )
        GenerateDlgTitle_msg = getString( message( 'slrealtime:appdesigner:GenerateDlgTitle' ) )
        GenerateDlgMsg_msg = getString( message( 'slrealtime:appdesigner:GenerateDlgMsg' ) )
        OpenInAppDes_msg = getString( message( 'slrealtime:appdesigner:OpenInAppDes' ) )
        SelectMLAPPFile_msg = getString( message( 'slrealtime:appdesigner:SelectMLAPPFile' ) )





        BlockPathParamPropTooltip_msg = ''
        ParameterNameParamPropTooltip_msg = ''
        ElementParamPropTooltip_msg = ''
        ControlNameParamPropTooltip_msg = ''
        ControlTypeParamPropTooltip_msg = ''
        ConvToCompParamPropTooltip_msg = ''
        ConvToTargetParamPropTooltip_msg = ''
        BlockPathSignalPropTooltip_msg = ''
        PortIndexSignalPropTooltip_msg = ''
        SignalNameSignalPropTooltip_msg = ''
        ControlNameSignalPropTooltip_msg = ''
        ControlTypeSignalPropTooltip_msg = ''
        PropertyNameSignalPropTooltip_msg = ''
        BusElementSignalPropTooltip_msg = ''
        ArrayIndexSignalPropTooltip_msg = ''
        DecimationSignalPropTooltip_msg = ''
        CallbackSignalPropTooltip_msg = ''
        LineWidthSignalPropTooltip_msg = ''
        LineStyleSignalPropTooltip_msg = ''
        LineColorSignalPropTooltip_msg = ''
        LineMarkerSignalPropTooltip_msg = ''
        LineMarkerSizeSignalPropTooltip_msg = ''



        OptionsToolstripItemDefaultValue = true;
        OptionsMenuItemDefaultValue = false;
        OptionsStatusBarItemDefaultValue = true;
        OptionsTETMonitorItemDefaultValue = false;
        OptionsInstrumentedSignalsItemDefaultValue = true;
        OptionsDashboardItemDefaultValue = false;
        OptionsCallbackItemDefaultValue = false;
        OptionsUseGridItemDefaultValue = true;
        TreeConfigureSignalsDefaultValue = true;
        TreeConfigureParametersDefaultValue = true;








        ModelFileIcon = 'model';
        MLDATXFileIcon = 'mldatx';
        SessionFileIcon = 'session';
    end

    properties ( Access = private, SetObservable )






        SessionSource = struct(  ...
            'SourceFile', {  },  ...
            'ModelName', {  },  ...
            'NumSigsAndParams', {  } )






        SessionSavedToFile






        Dirty = false





        BindingData
    end

    properties ( Access = private )


        App( 1, 1 )matlab.ui.container.internal.AppContainer;



        PropListeners



        Tabs
        DesignerTab
        FileSection
        NewButton
        OpenButton
        SaveButton
        ConfigureSection
        OptionsButton
        OptionsToolstripItem
        OptionsMenuItem
        OptionsStatusBarItem
        OptionsTETMonitorItem
        OptionsInstrumentedSignalsItem
        OptionsDashboardItem
        OptionsUseGridItem
        OptionsCallbackItem
        BindingsSection
        AddFromModelButton
        HighlightInModelButton
        RemoveButton
        ValidateButton
        InstrumentPanelSection
        GenerateButton
        ModifyButton



        SearchImage
        SearchEditField
        SearchRemoveButton
        TreeConfigureImage
        TreeConfigureLabel
        TreeConfigurePanel
        TreeConfigureSignals
        TreeConfigureParameters
        TreeConfigureRefreshButton
        Tree
        AddButton
        EditButton
        BindingTable



        ParameterBlockPathEditField
        ParameterNameEditField
        ParameterControlNameEditField
        ParameterControlTypeDropDown
        ParameterControlConfigureButton
        ParameterConvToCompEditField
        ParameterConvToTargetEditField
        ParameterElementEditField
        SignalBlockPathEditField
        SignalPortIndexEditField
        SignalNameEditField
        SignalControlNameEditField
        SignalControlTypeDropDown
        SignalControlConfigureButton
        SignalBusElementEditField
        SignalPropertyNameEditField
        SignalDecimationEditField
        SignalArrayIndexEditField
        SignalCallbackEditField
        SignalLineWidthEditField
        SignalLineStyleDropDown
        SignalLineColorEditField
        SignalLineColorPickerPanel
        SignalLineColorPickerDropDown
        SignalLineColorPickerButton
        SignalLineMarkerDropDown
        SignalLineMarkerSizeEditField





        ControlCntr = 1
        ControlPrefix = 'comp'



        ParameterControlTypes =  ...
            {  ...
            'Edit Field (numeric)',  ...
            'Edit Field (text)',  ...
            'Knob',  ...
            'Slider',  ...
            'Parameter Table' ...
            };



        SignalControlTypes =  ...
            {  ...
            'NONE',  ...
            'Edit Field (numeric)',  ...
            'Edit Field (text)',  ...
            'Gauge',  ...
            '90 Degree Gauge',  ...
            'Linear Gauge',  ...
            'Semicircular Gauge',  ...
            'Lamp',  ...
            'Axes',  ...
            'Signal Table' ...
            }



        BindingTableTypeColIdx = 1;
        BindingTableAppDataColIdx = 2;
        BindingTableControlNameColIdx = 3;
        BindingTableControlTypeColIdx = 4;



        TreeProgressDlg
        TreeFullyProcessed = false
        TreeTotalLeafNodes = 0
        TreeNumLeafNodes = 0









        ProgressDialog





        IsSimulinkAvailable




        GenerateLastFolder = ''
        GenerateLastName = ''






        DummyFig
        PropsTargetSelector
        PropsConnectButton
        PropsLoadButton
        PropsStartStopButton
        PropsStopTime
        PropsSystemLog
        PropsStatusBar
        PropsMenu
        PropsMap
    end

    events
        Closing
    end




    methods
        function this = AppGenerator(  )
            function syncUIAndMarkAsDirty( this )
                this.syncUI(  );
                this.markAsDirty(  );
            end
            function ret = canClose( this )
                ret = false;
                cancelled = this.askToSaveSession(  );
                if cancelled, return ;end
                notify( this, 'Closing' );
                ret = true;
            end

            this.createAllPropsControls(  );

            this.IsSimulinkAvailable = license( 'test', 'SIMULINK' ) && ~isempty( ver( 'simulink' ) );

            options.Tag = this.SLRTAppGenerator_tag;
            this.App = matlab.ui.container.internal.AppContainer( options );
            this.App.CanCloseFcn = @( o )canClose( this );

            this.createToolstrip(  );
            this.createTreePanel(  );
            this.createBindingTable(  );
            this.createParameterPropertyPanel(  );
            this.createParameterControlPropertyPanel(  );
            this.createParameterOptionsPropertyPanel(  );
            this.createSignalPropertyPanel(  );
            this.createSignalControlPropertyPanel(  );
            this.createSignalOptionsPropertyPanel(  );
            this.createSignalLinePropertyPanel(  );
            this.createContexts(  );

            this.syncTitle(  );
            this.syncUI(  );

            this.PropListeners = addlistener( this, 'SessionSource', 'PostSet', @( o, e )this.syncUI(  ) );
            this.PropListeners( end  + 1 ) = addlistener( this, 'SessionSavedToFile', 'PostSet', @( o, e )this.syncTitle(  ) );
            this.PropListeners( end  + 1 ) = addlistener( this, 'Dirty', 'PostSet', @( o, e )this.syncTitle(  ) );
            this.PropListeners( end  + 1 ) = addlistener( this, 'BindingData', 'PostSet', @( o, e )syncUIAndMarkAsDirty( this ) );

            this.PropListeners( end  + 1 ) = addlistener( this, 'Closing', @( o, e )this.cleanup(  ) );

            this.OptionsToolstripItem.ValueChangedFcn = @( o, e )this.markAsDirty;
            this.OptionsMenuItem.ValueChangedFcn = @( o, e )this.markAsDirty;
            this.OptionsStatusBarItem.ValueChangedFcn = @( o, e )this.markAsDirty;
            this.OptionsTETMonitorItem.ValueChangedFcn = @( o, e )this.markAsDirty;
            this.OptionsInstrumentedSignalsItem.ValueChangedFcn = @( o, e )this.markAsDirty;
            this.OptionsDashboardItem.ValueChangedFcn = @( o, e )this.markAsDirty;
            this.OptionsUseGridItem.ValueChangedFcn = @( o, e )this.markAsDirty;
            this.OptionsCallbackItem.ValueChangedFcn = @( o, e )this.markAsDirty;





            this.App.Visible = true;
            if this.App.State ~= matlab.ui.container.internal.appcontainer.AppState.RUNNING
                waitfor( this.App, 'State' );
            end
            for i = 1:200
                try
                    isvalid( this.getUIFigure );
                catch
                    pause( 0.01 );
                    continue ;
                end
                break ;
            end
        end

        function cleanup( this )
            this.destoryAllPropsControls(  );

            arrayfun( @( x )delete( x ), this.PropListeners );
        end

        function delete( this )
            this.cleanup(  );
        end
    end




    methods


        syncUI( this )
        showSignalPropertyPanels( this )
        showSignalWithLinePropertyPanels( this )
        showParameterPropertyPanels( this )
        updateSignalPropertyPanels( this, row )
        updateParameterPropertyPanels( this, row )
        function hideAllPropertyPanels( this )
            this.App.ActiveContexts = {  };
        end
        createTreePanel( this )
        createBindingTable( this )
        createParameterPropertyPanel( this )
        createParameterControlPropertyPanel( this )
        createParameterOptionsPropertyPanel( this )
        createSignalPropertyPanel( this )
        createSignalControlPropertyPanel( this )
        createSignalOptionsPropertyPanel( this )
        createSignalLinePropertyPanel( this )
        createContexts( this )
        updateEditButtonEnable( this )
        bindingTableCellSelectionCB( this )
        treeSelectionChanged( this )



        createToolstrip( this )
        toolstripNewRecentFileCB( this, fileName, fileFullPath )
        toolstripNewButtonCB( this )
        toolstripOpenRecentFileCB( this, fileName, fileFullPath )
        toolstripOpenButtonCB( this )
        toolstripSaveButtonCB( this )
        toolstripSaveAsButtonCB( this )
        toolstripSaveCopyAsButtonCB( this )
        toolstripAddFromModelButtonCB( this )
        toolstripHighlightInModelCB( this )
        toolstripRemoveCB( this )
        toolstripValidateButtonCB( this )
        addToRecentMLDATXFiles( this, fileName, fileFullPath )
        addToRecentSessionFiles( this, fileName, fileFullPath )



        revertSessionToDefaults( this )
        newSession( this, sourceFile )
        cancelled = saveSession( this )
        openSession( this, sessionFullPath )
        cancelled = askToSaveSession( this )



        createTree( this, treeSource, varargin )
        cancelled = populateTree( this )
        populateNodeAndChildren( this, node )
        refreshTree( this )
        function collapseTree( this )
            function collapseNode( node )
                node.collapse(  );
                arrayfun( @( x )collapseNode( x ), node.Children );
            end
            collapseNode( this.Tree );
        end



        function openPropertyInspector( this, comp )
            this.PropertyInspectorComp = comp;
            this.markAsDirty(  );
            inspect( comp );
        end
        function closePropertyInspector( this )
            this.PropertyInspectorComp = [  ];
            inspect -close;
        end
        function copyPropValues( this, source, dest )%#ok


            props = fields( source );
            for i = 1:numel( props )
                prop = props{ i };
                if any( strcmp( prop, { 'Type', 'Parent', 'Children', 'ContextMenu', 'Position', 'InnerPosition', 'OuterPosition', 'Layout' } ) ), continue ;end
                try
                    dest.( prop ) = source.( prop );
                catch

                end
            end
        end
        function vals = savePropValues( this, comp )%#ok
            vals = [  ];
            props = properties( comp );
            for i = 1:numel( props )
                prop = props{ i };
                if any( strcmp( prop, { 'Parent', 'Children', 'ContextMenu', 'Position', 'InnerPosition', 'OuterPosition', 'Layout' } ) ), continue ;end
                try
                    vals.( prop ) = comp.( prop );
                catch

                end
            end
        end
        function destoryAllPropsControls( this )
            delete( this.PropsTargetSelector );
            delete( this.PropsConnectButton );
            delete( this.PropsLoadButton );
            delete( this.PropsStartStopButton );
            delete( this.PropsStopTime );
            delete( this.PropsSystemLog );
            delete( this.PropsStatusBar );
            delete( this.PropsMenu );

            cellfun( @( x )delete( x ), this.PropsMap.values );
            delete( this.PropsMap );

            delete( this.DummyFig );
        end
        function createAllPropsControls( this )
            this.DummyFig = uifigure( 'Visible', false );

            this.PropsTargetSelector = slrealtime.ui.control.TargetSelector( this.DummyFig );
            this.PropsConnectButton = slrealtime.ui.control.ConnectButton( this.DummyFig );
            this.PropsLoadButton = slrealtime.ui.control.LoadButton( this.DummyFig );
            this.PropsLoadButton.ShowLoadedApplication = false;
            this.PropsStartStopButton = slrealtime.ui.control.StartStopButton( this.DummyFig );
            this.PropsStopTime = slrealtime.ui.control.StopTimeEditField( this.DummyFig );
            this.PropsSystemLog = slrealtime.ui.control.SystemLog( this.DummyFig );
            this.PropsStatusBar = slrealtime.ui.control.StatusBar( this.DummyFig );
            this.PropsMenu = slrealtime.ui.container.Menu( this.DummyFig );
            prop = findprop( this.PropsMenu, 'TargetSelector' );
            prop.Hidden = true;

            this.PropsMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
        end
        function createComponentForPropsMap( this, controlName, controlType )
            if ~this.PropsMap.isKey( controlName )
                switch controlType
                    case { 'Parameter Table', 'slrealtime.ui.control.ParameterTable', 'slrealtime.ui.control.parametertable' }
                        comp = slrealtime.ui.control.ParameterTable( this.DummyFig );
                    case { 'Signal Table', 'slrealtime.ui.control.SignalTable', 'slrealtime.ui.control.signaltable' }
                        comp = slrealtime.ui.control.SignalTable( this.DummyFig );
                    case { 'Edit Field (numeric)', 'matlab.ui.control.NumericEditField', 'uinumericeditfield' }
                        comp = uieditfield( this.DummyFig, 'numeric' );
                    case { 'Edit Field (text)', 'matlab.ui.control.EditField', 'uieditfield' }
                        comp = uieditfield( this.DummyFig, 'text' );
                    case { 'Gauge', 'matlab.ui.control.Gauge', 'uigauge' }
                        comp = uigauge( this.DummyFig, 'circular' );
                    case { '90 Degree Gauge', 'matlab.ui.control.NinetyDegreeGauge', 'uininetydegreegauge' }
                        comp = uigauge( this.DummyFig, 'ninetydegree' );
                    case { 'Linear Gauge', 'matlab.ui.control.LinearGauge', 'uilineargauge' }
                        comp = uigauge( this.DummyFig, 'linear' );
                    case { 'Semicircular Gauge', 'matlab.ui.control.SemicircularGauge', 'uisemicirculargauge' }
                        comp = uigauge( this.DummyFig, 'semicircular' );
                    case { 'Lamp', 'matlab.ui.control.Lamp', 'uilamp' }
                        comp = uilamp( this.DummyFig );
                    case { 'Axes', 'matlab.ui.control.UIAxes', 'axes' }
                        comp = uiaxes( this.DummyFig );
                    case { 'Knob', 'matlab.ui.control.Knob', 'uiknob' }
                        comp = uiknob( this.DummyFig );
                    case { 'Slider', 'matlab.ui.control.Slider', 'uislider' }
                        comp = uislider( this.DummyFig );
                    otherwise
                        comp = [  ];
                end
                this.PropsMap( controlName ) = comp;
            end
        end



        [ allControlNames, allControlTypes ] = getAllControlNamesAndTypes( this, excludeRow )
        checkControlNames( this, controlNames, components )
        controlName = getUniqueControlName( this )
        updated = handleUpdateDiagramOrRethrow( this, ME )
        addSignal( this, displayText, blockPath, portIndex, signalLabel )
        addParameter( this, displayText, blockPath, parameterName )
        refreshStyles( this )
        function val = isBindingParameter( this, idx )
            assert( numel( idx ) == 1 );
            val = false;
            if isfield( this.BindingData{ idx }, 'ParamName' ), val = true;end
        end
        function val = isTableSelectionParameter( this )
            val = false;
            if numel( this.BindingTable.Selection ) > 1, return ;end
            val = this.isBindingParameter( this.BindingTable.Selection );
        end
        function markAsDirty( this )
            if ~this.Dirty, this.Dirty = true;end
        end
        function bringToFront( this )
            this.App.bringToFront(  );
        end
        function errorDlg( this, msgId, varargin )
            uialert( this.getUIFigure(  ), slrealtime.internal.replaceHyperlinks( getString( message( msgId, varargin{ : } ) ) ), this.Error_msg );
        end
        function infoDlg( this, msgId, varargin )
            uialert( this.getUIFigure(  ), slrealtime.internal.replaceHyperlinks( getString( message( msgId, varargin{ : } ) ) ), this.Info_msg, 'Icon', 'info' );
        end
        function syncTitle( this )
            title = this.AppTitle_msg;
            if ~isempty( this.SessionSavedToFile )
                title = strcat( title, " - ", this.SessionSavedToFile );
            end
            if this.Dirty
                title = strcat( title, "*" );
            end
            this.App.Title = title;
        end
        function fig = getUIFigure( this )
            fig = [  ];
            documents = this.App.getDocuments;
            for i = 1:length( documents )
                if documents{ i }.Showing
                    fig = documents{ i }.Figure;
                    return ;
                end
            end
        end



        function iconFile = getIconFile( this, iconFileForSettings )
            switch ( iconFileForSettings )
                case { this.ModelFileIcon }
                    iconFile = this.ModelFile_icon16;
                case { this.MLDATXFileIcon }
                    iconFile = this.GenericFile_icon16;
                case { this.SessionFileIcon }
                    iconFile = this.GenericFile_icon16;
                otherwise
                    iconFile = this.GenericFile_icon16;
            end
        end
    end




    methods ( Static )


        names = getNamesForAllExistingComponents( components )
        addDesignTimeProperties( comp, codeName )
        str = convertToStrForMLAPPCode( blockpath )
        [ controlNames, controlTypes ] = getControlNamesAndTypes( bindingData )
        code = getInstrumentedSignalsCode( sourceFile, modelName, uiaxesName, appArgName )
        [ guiInstrument, nSignals, tooltipCode, callbackCode ] = createInstrument( bindingData, compMap, appArgName )
        bindingCode = createBindingCode( guiInstrument, bindingData, nSignals, uifigureName, appArgName, targetSelectorVarName )
    end
    methods
        newInstrumentPanel( this )
        modifyInstrumentPanel( this )
    end




    properties ( Hidden )

















        AskToSaveSessionSelection = [  ]









        AskToSaveSessionCancelFilePickerSelection = [  ]







        UpdateDiagramSelection = [  ]







        ReplaceExistingFilesSelection = [  ]




        PropertyInspectorComp = [  ]
    end
    methods ( Hidden )
        function clearAllTestingProperties( this )
            this.AskToSaveSessionSelection = [  ];
            this.AskToSaveSessionCancelFilePickerSelection = [  ];
            this.UpdateDiagramSelection = [  ];
            this.ReplaceExistingFilesSelection = [  ];
        end
        function out = getPropertyForTesting( this, prop )
            assert( ischar( prop ) || isStringScalar( prop ) );
            assert( isprop( this, prop ) );
            out = this.( prop );
        end
        function closeForTesting( this, force )
            arguments
                this
                force( 1, 1 )logical = false
            end

            if isempty( this ) || ~isvalid( this ), return ;end



            this.App.close( 'force', force );




            if force
                notify( this, 'Closing' );
            end
        end
    end
    methods ( Static, Hidden )
        function clearSettings(  )
            s = settings;

            s.slrealtime.slrtAppGenerator.newRecentFiles.text.PersonalValue = {  };
            s.slrealtime.slrtAppGenerator.newRecentFiles.tag.PersonalValue = {  };
            s.slrealtime.slrtAppGenerator.newRecentFiles.iconFile.PersonalValue = {  };
            s.slrealtime.slrtAppGenerator.newRecentFiles.description.PersonalValue = {  };

            s.slrealtime.slrtAppGenerator.openRecentFiles.text.PersonalValue = {  };
            s.slrealtime.slrtAppGenerator.openRecentFiles.tag.PersonalValue = {  };
            s.slrealtime.slrtAppGenerator.openRecentFiles.iconFile.PersonalValue = {  };
            s.slrealtime.slrtAppGenerator.openRecentFiles.description.PersonalValue = {  };
        end
    end
end



