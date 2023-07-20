function dlgstruct=getMaskDialogSchema(this)




    block=this.getBlock();

    if isempty(this.DialogData)



        this.iniDialogData();
    end




    this.iniDynData();


    isSimUsingNativeSimulinkBehavior=slfeature('FMUNativeSimulinkBehavior')&&...
    strcmpi(block.SimulateUsing,'Native Simulink Behavior');

    block_description.Name=block.MaskDescription;
    block_description.Type='text';
    block_description.WordWrap=true;
    block_description.ColSpan=[1,1];
    block_description.RowSpan=[1,1];
    block_description.Alignment=1;


    fmu_doclink.Name=DAStudio.message('FMUBlock:FMU:OpenFMUDocumentationFile');
    fmu_doclink.Type='hyperlink';
    fmu_doclink.Tag='FMUDocumentationFileLink';
    if startsWith(block.FMIVersion,'2')&&exist(fullfile(block.FMUWorkingDirectory,'documentation','index.html'),'file')
        fmu_doclink.ToolTip=fullfile(block.FMUWorkingDirectory,'documentation','index.html');
        fmu_doclink.Enabled=1;
    elseif startsWith(block.FMIVersion,'1')&&exist(fullfile(block.FMUWorkingDirectory,'documentation','_main.html'),'file')
        fmu_doclink.ToolTip=fullfile(block.FMUWorkingDirectory,'documentation','_main.html');
        fmu_doclink.Enabled=1;
    else
        fmu_doclink.ToolTip='';
        fmu_doclink.Enabled=0;
    end

    fmu_doclink.MatlabMethod='dialogCallback';
    fmu_doclink.MatlabArgs={this,'%dialog','open_log_file_tag',fmu_doclink.ToolTip};
    fmu_doclink.ColSpan=[1,1];
    fmu_doclink.RowSpan=[2,2];
    fmu_doclink.Alignment=1;

















    description_group.Type='group';
    description_group.LayoutGrid=[2,1];
    description_group.Name=block.MaskType;
    if isSimUsingNativeSimulinkBehavior


        description_group.Items={block_description};
    else
        description_group.Items={block_description,fmu_doclink};
    end
    description_group.RowSpan=[1,1];
    description_group.ColSpan=[1,1];





















    filter_edit.Type='spreadsheetfilter';
    filter_edit.Name=DAStudio.message('FMUBlock:FMU:SearchParameter');
    filter_edit.RowSpan=[1,1];
    filter_edit.ColSpan=[1,1];
    filter_edit.TargetSpreadsheet='fmu_param_table';
    filter_edit.PlaceholderText=DAStudio.message('FMUBlock:FMU:SearchParameterToolTip');
    filter_edit.Clearable=true;
    filter_edit.Visible=true;



    fmu_params.Type='spreadsheet';
    fmu_params.Tag='fmu_param_table';
    fmu_params.Columns={...
    DAStudio.message('FMUBlock:FMU:Parameter'),...
    DAStudio.message('FMUBlock:FMU:Value'),...
    DAStudio.message('FMUBlock:FMU:Unit'),...
    DAStudio.message('FMUBlock:FMU:Description')};
    fmu_params.RowSpan=[2,2];
    fmu_params.ColSpan=[1,1];
    fmu_params.DialogRefresh=false;
    fmu_params.Hierarchical=true;
    fmu_params.Source=this.DialogData.ParameterTreeViewSource;





    fmu_params_tab.Name=DAStudio.message('FMUBlock:FMU:Parameters');
    fmu_params_tab.LayoutGrid=[2,1];
    fmu_params_tab.Items={filter_edit,fmu_params};



    rowCounter=1;
    if slfeature('FMUNativeSimulinkBehavior')


        simulate_using.Name=DAStudio.message('FMUBlock:FMU:SimulateUsing');
        simulate_using.Type='combobox';
        simulate_using.Entries={...
        message('FMUBlock:FMU:SimulateUsingPrm_FMU').getString,...
        message('FMUBlock:FMU:SimulateUsingPrm_NATIVE_SIMULINK_BEHAVIOR').getString};
        simulate_using.Tag='FMUModelMode';

        simulate_using.MatlabMethod='dialogCallback';
        simulate_using.MatlabArgs={this,'%dialog','simulate_using_tag','%value'};
        simulate_using.Source=block;
        simulate_using.Value=block.SimulateUsing;
        simulate_using.Alignment=2;
        simulate_using.ColSpan=[1,4];
        simulate_using.RowSpan=[1,1];
        simulate_using.Enabled=~strcmpi(block.SimulateUsing,'Off');

        simulate_using_group.Type='group';
        simulate_using_group.Flat=true;
        simulate_using_group.Name=DAStudio.message('FMUBlock:FMU:SpecifyMode');
        simulate_using_group.Tag='FMUSpecifyMode';
        simulate_using_group.LayoutGrid=[1,1];
        simulate_using_group.ColSpan=[1,1];
        simulate_using_group.RowSpan=[rowCounter,rowCounter];
        simulate_using_group.Alignment=0;
        simulate_using_group.Items={simulate_using};
        simulate_using_group.Visible=~strcmpi(block.SimulateUsing,'Off');
        rowCounter=rowCounter+1;
    end


    layout_counter=1;

    fmuMode=block.FMUMode;
    fmuVer=strtrim(block.FMIVersion);

    toleranceWidgetRequired=(strcmpi(fmuMode,'ModelExchange')||strcmpi(fmuVer,'2.0'));

    sampleTimeWidgetRequired=(~strcmpi(fmuMode,'ModelExchange'));

    if toleranceWidgetRequired

        fmu_isToleranceUsed.Name=DAStudio.message('FMUBlock:FMU:FMUTolerance');
        fmu_isToleranceUsed.Type='checkbox';
        fmu_isToleranceUsed.ToolTip=DAStudio.message('FMUBlock:FMU:FMUToleranceToolTip');
        fmu_isToleranceUsed.Tag='FMUIsToleranceUsed';
        fmu_isToleranceUsed.ObjectProperty=fmu_isToleranceUsed.Tag;
        fmu_isToleranceUsed.Source=block;
        fmu_isToleranceUsed.Value=block.FMUIsToleranceUsed;
        fmu_isToleranceUsed.MatlabMethod='dialogCallback';
        fmu_isToleranceUsed.MatlabArgs={this,'%dialog','fmu_is_tolerance_used_tag','%value'};
        fmu_isToleranceUsed.ArgDataTypes={'handle','string','mxArray'};
        fmu_isToleranceUsed.ColSpan=[1,1];
        fmu_isToleranceUsed.Alignment=1;
        fmu_isToleranceUsed.RowSpan=[layout_counter,layout_counter];


        fmu_toleranceValue.Name=DAStudio.message('FMUBlock:FMU:FMUToleranceValue');
        fmu_toleranceValue.Type='edit';
        fmu_toleranceValue.ToolTip=DAStudio.message('FMUBlock:FMU:FMUToleranceValueToolTip');
        fmu_toleranceValue.Tag='FMUToleranceValue';
        fmu_toleranceValue.ObjectProperty=fmu_toleranceValue.Tag;
        fmu_toleranceValue.Source=block;
        fmu_toleranceValue.Value=block.FMUToleranceValue;
        fmu_toleranceValue.MatlabMethod='dialogCallback';
        fmu_toleranceValue.MatlabArgs={this,'%dialog','fmu_tolerance_value_tag','%value'};
        fmu_toleranceValue.ArgDataTypes={'handle','string','mxArray'};
        fmu_toleranceValue.ColSpan=[2,2];
        fmu_toleranceValue.Alignment=0;
        fmu_toleranceValue.RowSpan=[layout_counter,layout_counter];
        fmuToleranceDefault=block.FMUDefaultTolerance;
        if~isempty(fmuToleranceDefault)
            fmu_toleranceValue.PlaceholderText=[DAStudio.message('FMUBlock:FMU:PreferredValue'),' ',fmuToleranceDefault];
            fmu_toleranceValue.ToolTip=[fmu_toleranceValue.ToolTip,' ',fmu_toleranceValue.PlaceholderText];
        end
        fmu_toleranceValue.Enabled=strcmp(fmu_isToleranceUsed.Value,'on');
        layout_counter=layout_counter+1;
    end


    if sampleTimeWidgetRequired
        fmuSampleTimeDefault=block.FMUDefaultStepSize;

        fmu_sample_time.Type='edit';
        fmu_sample_time.ToolTip=DAStudio.message('FMUBlock:FMU:CommunicationStepSize');
        fmu_sample_time.Tag='FMUSampleTime';
        fmu_sample_time.ObjectProperty=fmu_sample_time.Tag;
        fmu_sample_time.Source=block;
        fmu_sample_time.Value=block.FMUSampleTime;
        fmu_sample_time.MatlabMethod='dialogCallback';
        fmu_sample_time.MatlabArgs={this,'%dialog','fmu_sample_time_tag','%value'};
        fmu_sample_time.ArgDataTypes={'handle','string','mxArray'};
        fmu_sample_time.RowSpan=[layout_counter,layout_counter];
        fmu_sample_time.ColSpan=[2,2];
        fmu_sample_time.Alignment=0;
        if~isempty(fmuSampleTimeDefault)
            fmu_sample_time.PlaceholderText=[DAStudio.message('FMUBlock:FMU:PreferredValue'),' ',fmuSampleTimeDefault];
            fmu_sample_time.ToolTip=[fmu_sample_time.ToolTip,' ',fmu_sample_time.PlaceholderText];
        end

        fmu_sample_time_title.Type='text';
        fmu_sample_time_title.Tag='FMUSampleTimeTitle';
        fmu_sample_time_title.Name=DAStudio.message('FMUBlock:FMU:FMUSampleTime');
        fmu_sample_time_title.ToolTip=fmu_sample_time.ToolTip;
        fmu_sample_time_title.RowSpan=[layout_counter,layout_counter];
        fmu_sample_time_title.ColSpan=[1,1];
        layout_counter=layout_counter+1;
    end

    if~strcmpi(fmuMode,'ModelExchange')

        fmu_setting_group.Name=DAStudio.message('FMUBlock:FMU:FMUCSSettings');
    else

        fmu_setting_group.Name=DAStudio.message('FMUBlock:FMU:FMUMESettings');
    end
    fmu_setting_group.Type='group';
    fmu_setting_group.Flat=true;
    fmu_setting_group.Tag='FMUSettingGroup';
    fmu_setting_group.LayoutGrid=[1,layout_counter-1];
    fmu_setting_group.ColSpan=[1,1];
    fmu_setting_group.RowSpan=[rowCounter,rowCounter];
    fmu_setting_group.Alignment=0;
    fmu_setting_group.Items={};
    if toleranceWidgetRequired
        fmu_setting_group.Items=[fmu_setting_group.Items,fmu_isToleranceUsed,fmu_toleranceValue];
    end
    if sampleTimeWidgetRequired
        fmu_setting_group.Items=[fmu_setting_group.Items,fmu_sample_time_title,fmu_sample_time];
    end


    fmu_setting_group.Visible=~isSimUsingNativeSimulinkBehavior;
    rowCounter=rowCounter+1;



    fmu_workingdir.Name=DAStudio.message('FMUBlock:FMU:OpenFMUWorkingDirectory');
    fmu_workingdir.Type='hyperlink';
    fmu_workingdir.Tag='FMUWorkingDirectoryLink';
    fmu_workingdir.ToolTip=block.FMUWorkingDirectory;
    fmu_workingdir.MatlabMethod='dialogCallback';
    fmu_workingdir.MatlabArgs={this,'%dialog','open_working_directory_tag',block.FMUWorkingDirectory};
    fmu_workingdir.ArgDataTypes={'handle','string','mxArray'};
    fmu_workingdir.ColSpan=[1,1];
    fmu_workingdir.RowSpan=[1,1];
    fmu_workingdir.Alignment=1;


    fmu_logfile.Name=DAStudio.message('FMUBlock:FMU:OpenFMULogFile');
    fmu_logfile.Type='hyperlink';
    fmu_logfile.Tag='FMULogFileLink';
    if exist(block.FMULogFile,'file')
        fmu_logfile.ToolTip=block.FMULogFile;
        fmu_logfile.Enabled=1;
    else
        fmu_logfile.ToolTip='';
        fmu_logfile.Enabled=0;
    end
    fmu_logfile.MatlabMethod='dialogCallback';
    fmu_logfile.MatlabArgs={this,'%dialog','open_log_file_tag',block.FMULogFile};
    fmu_logfile.ArgDataTypes={'handle','string','mxArray'};
    fmu_logfile.ColSpan=[2,2];
    fmu_logfile.RowSpan=[1,1];
    fmu_logfile.Alignment=1;


    fmu_logging.Name=DAStudio.message('FMUBlock:FMU:FMULogging');
    fmu_logging.Type='checkbox';
    fmu_logging.ToolTip=DAStudio.message('FMUBlock:FMU:FMULoggingToolTip');
    fmu_logging.Tag='FMUDebugLogging';
    fmu_logging.ObjectProperty=fmu_logging.Tag;
    fmu_logging.Source=block;
    fmu_logging.Value=block.FMUDebugLogging;
    fmu_logging.MatlabMethod='dialogCallback';
    fmu_logging.MatlabArgs={this,'%dialog','logging_toggle_tag','%value'};
    fmu_logging.ArgDataTypes={'handle','string','mxArray'};
    fmu_logging.ColSpan=[1,1];
    fmu_logging.RowSpan=[2,2];
    fmu_logging.Enabled=~this.isHierarchySimulating||block.isTunableProperty(fmu_logging.Tag);
    enable_fmu_logging=strcmp(fmu_logging.Value,'on');


    fmu_loggingDest.Name=DAStudio.message('FMUBlock:FMU:RedirectLoggingTo');
    fmu_loggingDest.Type='combobox';
    fmu_loggingDest.Entries={...
    message('FMUBlock:FMU:FMULoggingDestination_FILE').getString,...
    message('FMUBlock:FMU:FMULoggingDestination_MATLAB').getString};
    fmu_loggingDest.ToolTip=DAStudio.message('FMUBlock:FMU:RedirectLoggingToToolTip');
    fmu_loggingDest.Tag='FMUDebugLoggingRedirect';
    fmu_loggingDest.ObjectProperty=fmu_loggingDest.Tag;
    fmu_loggingDest.Source=block;
    fmu_loggingDest.Value=block.FMUDebugLoggingRedirect;
    fmu_loggingDest.ColSpan=[2,2];
    fmu_loggingDest.RowSpan=[2,2];
    fmu_loggingDest.Alignment=1;
    fmu_loggingDest.Enabled=enable_fmu_logging&&(~this.isHierarchySimulating||block.isTunableProperty(fmu_loggingDest.Tag));


    loggingEntries={...
    'FMUBlock:FMU:FMULoggingStatus_OK',...
    'FMUBlock:FMU:FMULoggingStatus_WARNING',...
    'FMUBlock:FMU:FMULoggingStatus_DISCARD',...
    'FMUBlock:FMU:FMULoggingStatus_ERROR',...
    'FMUBlock:FMU:FMULoggingStatus_FATAL',...
    'FMUBlock:FMU:FMULoggingStatus_PENDING',...
    };
    untranslatedEntries={...
    'OK','Warning','Discard','Error','Fatal','Pending'};
    fmu_loggingFilterCheckBoxList=cell(1,length(loggingEntries));
    for i=1:length(loggingEntries)
        fmu_loggingFilterCheckBoxList{i}.Name=message(loggingEntries{i}).getString;
        fmu_loggingFilterCheckBoxList{i}.ToolTip=message([loggingEntries{i},'_prompt']).getString;
        fmu_loggingFilterCheckBoxList{i}.Type='checkbox';
        fmu_loggingFilterCheckBoxList{i}.Tag=['FMUDebugLoggingFilterCheckBox',i];
        fmu_loggingFilterCheckBoxList{i}.Value=~isempty(find(ismember(block.FMUDebugLoggingFilter,untranslatedEntries{i}),1));
        fmu_loggingFilterCheckBoxList{i}.ObjectMethod='dialogCallback';
        fmu_loggingFilterCheckBoxList{i}.MethodArgs={'%dialog','logging_filter_tag','%value'};
        fmu_loggingFilterCheckBoxList{i}.ArgDataTypes={'handle','string','mxArray'};
        fmu_loggingFilterCheckBoxList{i}.ColSpan=[i,i];
        fmu_loggingFilterCheckBoxList{i}.RowSpan=[1,1];
        fmu_loggingFilterCheckBoxList{i}.Alignment=2;
        fmu_loggingFilterCheckBoxList{i}.Enabled=~this.isHierarchySimulating||block.isTunableProperty('FMUDebugLoggingFilter');
    end
    fmu_loggingFilterGroup.Name=DAStudio.message('FMUBlock:FMU:LoggingFilterGroup');
    fmu_loggingFilterGroup.Type='group';
    fmu_loggingFilterGroup.Tag='FMUDebugLoggingFilterGroup';
    fmu_loggingFilterGroup.LayoutGrid=[1,length(loggingEntries)];
    fmu_loggingFilterGroup.ColSpan=[1,2];
    fmu_loggingFilterGroup.RowSpan=[1,1];
    fmu_loggingFilterGroup.Items=fmu_loggingFilterCheckBoxList;
    fmu_loggingFilterGroup.Alignment=0;


    fmu_logging_panel.Type='panel';
    fmu_logging_panel.Tag='FMUDebugLoggingPanel';
    fmu_logging_panel.LayoutGrid=[1,1];
    fmu_logging_panel.ColSpan=[1,2];
    fmu_logging_panel.RowSpan=[3,3];
    fmu_logging_panel.Items={fmu_loggingFilterGroup};
    fmu_logging_panel.Alignment=0;
    fmu_logging_panel.Enabled=enable_fmu_logging;

    fmu_logging_group.Name=DAStudio.message('FMUBlock:FMU:FMUDebugSettings');
    fmu_logging_group.Type='group';
    fmu_logging_group.Flat=true;
    fmu_logging_group.Tag='FMULoggingGroup';
    fmu_logging_group.LayoutGrid=[1,3];
    fmu_logging_group.ColSpan=[1,1];
    fmu_logging_group.RowSpan=[rowCounter,rowCounter];
    fmu_logging_group.Items=fmu_loggingFilterCheckBoxList;
    fmu_logging_group.Alignment=0;
    fmu_logging_group.Visible=~isSimUsingNativeSimulinkBehavior;
    fmu_logging_group.Items={fmu_workingdir,fmu_logfile,fmu_logging,fmu_loggingDest,fmu_logging_panel};


    fmu_sim_tab.Name=DAStudio.message('FMUBlock:FMU:FMUSimulation');
    fmu_sim_tab.LayoutGrid=[3,1];
    fmu_sim_tab.RowStretch=[0,0,1];
    if slfeature('FMUNativeSimulinkBehavior')
        fmu_sim_tab.Items={simulate_using_group,fmu_setting_group,fmu_logging_group};
    else
        fmu_sim_tab.Items={fmu_setting_group,fmu_logging_group};
    end




    if slfeature('FMUInterfaceManagement')

        fmu_input=this.createInputGroup;

        fmu_input_tab.Name=DAStudio.message('FMUBlock:FMU:InputTab');
        fmu_input_tab.LayoutGrid=[1,1];
        fmu_input_tab.RowStretch=[0,1];
        fmu_input_tab.Items={fmu_input};
    else
        if(isempty(this.DialogData.InputBusStruct))
            fmu_input_bus_table.Type='text';
            fmu_input_bus_table.Name=message('FMUBlock:FMU:FMUInputNoBusType').getString;
            fmu_input_bus_table.ColSpan=[1,1];
            fmu_input_bus_table.RowSpan=[1,1];


            fmu_input_tab.Name=DAStudio.message('FMUBlock:FMU:Input');
            fmu_input_tab.LayoutGrid=[1,1];
            fmu_input_tab.RowStretch=[0,0,1];
            fmu_input_tab.Items={fmu_input_bus_table};
        else
            fmu_input_bus_table.Type='table';
            fmu_input_bus_table.Tag='fmu_input_table';
            fmu_input_bus_table.RowSpan=[1,3];
            fmu_input_bus_table.ColSpan=[1,1];
            fmu_input_bus_table.Size=size(this.DialogData.InputBusStructTable);
            fmu_input_bus_table.HeaderVisibility=[0,1];
            fmu_input_bus_table.ColHeader={DAStudio.message('FMUBlock:FMU:BusTablePort'),DAStudio.message('FMUBlock:FMU:BusTableVarName'),DAStudio.message('FMUBlock:FMU:BusTableBusName')};
            fmu_input_bus_table.ColumnCharacterWidth=[5,20,20];
            fmu_input_bus_table.Data=this.DialogData.InputBusStructTable;
            fmu_input_bus_table.Editable=true;
            fmu_input_bus_table.ValueChangedCallback=@fmuInputBusObjectTableCallback;

            fmu_input_tab_desc.Name=message('FMUBlock:FMU:BusTableInputDescription').getString;
            fmu_input_tab_desc.Type='text';
            fmu_input_tab_desc.WordWrap=true;
            fmu_input_tab_desc.ColSpan=[1,1];
            fmu_input_tab_desc.RowSpan=[4,4];


            fmu_input_tab.Name=DAStudio.message('FMUBlock:FMU:Input');
            fmu_input_tab.LayoutGrid=[4,1];
            fmu_input_tab.RowStretch=[0,0,1];
            fmu_input_tab.Items={fmu_input_bus_table,fmu_input_tab_desc};
        end
    end
    fmu_input_tab.Tag='fmu_input_tab';
    fmu_input_tab.Visible=~isSimUsingNativeSimulinkBehavior;



    if slfeature('FMUInterfaceManagement')

        fmu_output=this.createOutputGroup;

        fmu_output_tab.Name=DAStudio.message('FMUBlock:FMU:OutputTab');
        fmu_output_tab.LayoutGrid=[1,1];
        fmu_output_tab.RowStretch=[0,1];
        fmu_output_tab.Items={fmu_output};
    else
        if(isempty(this.DialogData.OutputBusStruct))
            fmu_output_bus_table.Type='text';
            fmu_output_bus_table.Name=message('FMUBlock:FMU:FMUOutputNoBusType').getString;
            fmu_output_bus_table.ColSpan=[1,1];
            fmu_output_bus_table.RowSpan=[1,1];


            fmu_output_tab.Name=DAStudio.message('FMUBlock:FMU:Output');
            fmu_output_tab.LayoutGrid=[1,1];
            fmu_output_tab.RowStretch=[0,0,1];
            fmu_output_tab.Items={fmu_output_bus_table};
        else
            fmu_output_bus_table.Type='table';
            fmu_output_bus_table.Tag='fmu_output_table';
            fmu_output_bus_table.RowSpan=[1,3];
            fmu_output_bus_table.ColSpan=[1,1];
            fmu_output_bus_table.Size=size(this.DialogData.OutputBusStructTable);
            fmu_output_bus_table.HeaderVisibility=[0,1];
            fmu_output_bus_table.ColHeader={DAStudio.message('FMUBlock:FMU:BusTablePort'),DAStudio.message('FMUBlock:FMU:BusTableVarName'),DAStudio.message('FMUBlock:FMU:BusTableBusName')};
            fmu_output_bus_table.ColumnCharacterWidth=[5,20,20];
            fmu_output_bus_table.Data=this.DialogData.OutputBusStructTable;
            fmu_output_bus_table.Editable=true;
            fmu_output_bus_table.ValueChangedCallback=@fmuOutputBusObjectTableCallback;

            fmu_output_tab_desc.Name=message('FMUBlock:FMU:BusTableOutputDescription').getString;
            fmu_output_tab_desc.Type='text';
            fmu_output_tab_desc.WordWrap=true;
            fmu_output_tab_desc.ColSpan=[1,1];
            fmu_output_tab_desc.RowSpan=[4,4];


            fmu_output_tab.Name=DAStudio.message('FMUBlock:FMU:Output');
            fmu_output_tab.LayoutGrid=[4,1];
            fmu_output_tab.RowStretch=[0,0,1];
            fmu_output_tab.Items={fmu_output_bus_table,fmu_output_tab_desc};
        end
    end
    fmu_output_tab.Visible=~isSimUsingNativeSimulinkBehavior;
    fmu_output_tab.Tag='fmu_output_tab';



    fmu_tab.Type='tab';
    fmu_tab.Name='';
    fmu_tab.Tabs={fmu_params_tab,fmu_sim_tab,fmu_input_tab,fmu_output_tab};
    fmu_tab.RowSpan=[2,2];
    fmu_tab.ColSpan=[1,1];





    dlgstruct.Items={description_group,fmu_tab};
    dlgstruct.LayoutGrid=[2,1];



    dlgstruct.PreApplyMethod='fmuPreApplyCallback';
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.PreApplyArgsDT={'handle'};


    dlgstruct.CloseMethod='fmuCloseCallback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};

end

function fmuInputBusObjectTableCallback(dlg,row,~,value)
    dlg.getDialogSource.DialogData.InputBusStructTableDataChanged=true;
    dlg.getDialogSource.DialogData.InputBusStructTableData{row+1,1}=value;
end


function fmuOutputBusObjectTableCallback(dlg,row,~,value)
    dlg.getDialogSource.DialogData.OutputBusStructTableDataChanged=true;
    dlg.getDialogSource.DialogData.OutputBusStructTableData{row+1,1}=value;
end
