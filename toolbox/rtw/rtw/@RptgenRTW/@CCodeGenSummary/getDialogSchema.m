function dlgStruct=getDialogSchema(thisComp,name)




































    wGeneral_information=thisComp.dlgWidget('General_information',...
    'RowSpan',[1,1],'ColSpan',[1,2]);

    wConfiguration_settings=thisComp.dlgWidget('Configuration_settings',...
    'RowSpan',[2,2],'ColSpan',[1,2]);

    wSubsystem=thisComp.dlgWidget('Subsystem',...
    'RowSpan',[3,3],'ColSpan',[1,2]);







    wUse_settings_from_model=thisComp.dlgWidget('Use_setting_from_model',...
    'RowSpan',[1,1],'ColSpan',[1,2],'DialogRefresh',true);

    wEliminated_virtual_blocks=thisComp.dlgWidget('Eliminated_virtual_blocks',...
    'RowSpan',[2,2],'ColSpan',[1,2]);

    wTraceable_Simulink_blocks=thisComp.dlgWidget('Traceable_Simulink_blocks',...
    'RowSpan',[3,3],'ColSpan',[1,2]);

    wTraceable_Stateflow_objects=thisComp.dlgWidget('Traceable_Stateflow_objects',...
    'RowSpan',[4,4],'ColSpan',[1,2]);

    wTraceable_Embedded_MATLAB_functions=thisComp.dlgWidget('Traceable_Embedded_MATLAB_functions',...
    'RowSpan',[5,5],'ColSpan',[1,2]);







































    cMain=thisComp.dlgContainer({
wGeneral_information
wConfiguration_settings
wSubsystem


    },DAStudio.message('RTW:report:summary'),...
    'LayoutGrid',[3,2],...
    'ColStretch',[0,1],...
    'RowStretch',[0,0,0],...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);

    cTraceOpts=thisComp.dlgContainer({
wEliminated_virtual_blocks
wTraceable_Simulink_blocks
wTraceable_Stateflow_objects
wTraceable_Embedded_MATLAB_functions
    },DAStudio.message('RTW:report:useThisSetting'),...
    'Visible',~thisComp.Use_setting_from_model,...
    'LayoutGrid',[4,2],...
    'ColStretch',[0,1],...
    'RowStretch',[0,0,0,0],...
    'ColSpan',[1,1],...
    'RowSpan',[2,2]);

    cTrace=thisComp.dlgContainer({
wUse_settings_from_model
cTraceOpts
    },DAStudio.message('RTW:configSet:RTWReportTraceReportGroupName'),...
    'LayoutGrid',[2,2],...
    'ColStretch',[0,1],...
    'RowStretch',[0,0],...
    'ColSpan',[1,1],...
    'RowSpan',[2,2]);














    dlgStruct=thisComp.dlgMain(name,{
cMain
cTrace
    },'LayoutGrid',[3,1],...
    'RowStretch',[0,0,1],...
    'ColStretch',[1]);







