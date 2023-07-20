function info=getHardwareDiagnosticsWidgets(hObj)




    hwObj=codertarget.targethardware.getTargetHardware(hObj);
    isSimOnlyHW=hwObj.SupportsOnlySimulation;

    info.ParameterGroups={};
    info.Parameters={};

    groupLabel='HardwareDiagnostics';
    info.ParameterGroups={groupLabel};
    info.Parameters={};

    label=DAStudio.message('codertarget:ui:HWDiagShowInSDILabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagShowInSDIToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage');
    pHWShowInSDI.Name=label;
    pHWShowInSDI.ToolTip=toolTip;
    pHWShowInSDI.Type='checkbox';
    pHWShowInSDI.Tag='SOCB_HW_Show_In_SDI';
    pHWShowInSDI.Enabled=~isSimOnlyHW;
    pHWShowInSDI.Visible=true;
    pHWShowInSDI.Entries={};
    pHWShowInSDI.Value=codertarget.profile.internal.isProfilingEnabled(hObj);
    pHWShowInSDI.Data={};
    pHWShowInSDI.RowSpan=[1,1];
    pHWShowInSDI.ColSpan=[1,3];
    pHWShowInSDI.Alignment=0;
    pHWShowInSDI.DialogRefresh=0;
    pHWShowInSDI.Storage=storage;
    pHWShowInSDI.DoNotStore=false;
    pHWShowInSDI.Callback=...
    'codertarget.profile.internal.hwDiagShowInSDICallback';
    pHWShowInSDI.SaveValueAsString=true;
    pHWShowInSDI.ValueType='';
    pHWShowInSDI.ValueRange='';
    info.Parameters{1}{1}=pHWShowInSDI;

    label=DAStudio.message('codertarget:ui:HWDiagSaveToFileLabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagSaveToFileToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagSaveToFileStorage');
    pHWSaveToFile.Name=label;
    pHWSaveToFile.ToolTip=toolTip;
    pHWSaveToFile.Type='checkbox';
    pHWSaveToFile.Tag='SOCB_HW_Save_To_File';
    pHWSaveToFile.Enabled=~isSimOnlyHW;
    pHWSaveToFile.Visible=...
    locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage'));
    pHWSaveToFile.Entries={};
    pHWSaveToFile.Value=false;
    pHWSaveToFile.Data={};
    pHWSaveToFile.RowSpan=[2,2];
    pHWSaveToFile.ColSpan=[1,1];
    pHWSaveToFile.Alignment=0;
    pHWSaveToFile.DialogRefresh=0;
    pHWSaveToFile.Storage=storage;
    pHWSaveToFile.DoNotStore=false;
    pHWSaveToFile.Callback='widgetChangedCallback';
    pHWSaveToFile.SaveValueAsString=true;
    pHWSaveToFile.ValueType='';
    pHWSaveToFile.ValueRange='';
    info.Parameters{1}{2}=pHWSaveToFile;

    label=DAStudio.message('codertarget:ui:HWDiagOverwriteFileLabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagOverwriteFileToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagOverwriteFileStorage');
    pHWOverwriteFile.Name=label;
    pHWOverwriteFile.ToolTip=toolTip;
    pHWOverwriteFile.Type='checkbox';
    pHWOverwriteFile.Tag='SOCB_HW_Overwrite_File';
    pHWOverwriteFile.Enabled=~isSimOnlyHW;
    pHWOverwriteFile.Visible=...
    locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage'))&&...
    locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:HWDiagSaveToFileStorage'));
    pHWOverwriteFile.Entries={};
    pHWOverwriteFile.Value=false;
    pHWOverwriteFile.Data={};
    pHWOverwriteFile.RowSpan=[2,2];
    pHWOverwriteFile.ColSpan=[2,2];
    pHWOverwriteFile.Alignment=0;
    pHWOverwriteFile.DialogRefresh=0;
    pHWOverwriteFile.Storage=storage;
    pHWOverwriteFile.DoNotStore=false;
    pHWOverwriteFile.Callback='widgetChangedCallback';
    pHWOverwriteFile.SaveValueAsString=true;
    pHWOverwriteFile.ValueType='';
    pHWOverwriteFile.ValueRange='';
    info.Parameters{1}{3}=pHWOverwriteFile;

    label=DAStudio.message('codertarget:ui:HWDiagInstrumentationLabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagInstrumentationToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage');
    pInstrumentation.Name=label;
    pInstrumentation.ToolTip=toolTip;
    pInstrumentation.Type='combobox';
    pInstrumentation.Tag='SOCB_HW_Instrumentation';
    pInstrumentation.Enabled=~isSimOnlyHW;
    pInstrumentation.Visible=...
    locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage'));
    if codertarget.utils.isBaremetal(hObj)
        pInstrumentation.Entries={'Code'};

        pInstrumentation.Visible=false;
    else
        pInstrumentation.Entries={'Code','Kernel'};
    end


    pInstrumentation.Value='Code';
    pInstrumentation.Data={};
    pInstrumentation.RowSpan=[3,3];
    pInstrumentation.ColSpan=[1,3];
    pInstrumentation.Alignment=0;
    pInstrumentation.DialogRefresh=0;
    pInstrumentation.Storage=storage;
    pInstrumentation.DoNotStore=false;
    pInstrumentation.Callback=...
    'codertarget.profile.internal.hwDiagInstrumentationCallback';
    pInstrumentation.SaveValueAsString=true;
    pInstrumentation.ValueType='';
    pInstrumentation.ValueRange='';
    info.Parameters{1}{4}=pInstrumentation;

    label=DAStudio.message('codertarget:ui:HWDiagRecordingLabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagRecordingToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagRecordingStorage');
    pRecording.Name=label;
    pRecording.ToolTip=toolTip;
    pRecording.Type='combobox';
    pRecording.Tag='SOCB_HW_Recording';
    pRecording.Enabled=~isSimOnlyHW;
    pRecording.Visible=false;
    pRecording.Entries={'Continuous','Single-shot'};
    pRecording.Value='Continuous';
    pRecording.Data={};
    pRecording.RowSpan=[4,4];
    pRecording.ColSpan=[1,3];
    pRecording.Alignment=0;
    pRecording.DialogRefresh=0;
    pRecording.Storage=storage;
    pRecording.DoNotStore=false;
    pRecording.Callback='codertarget.profile.internal.hwDiagRecordingCallback';
    pRecording.SaveValueAsString=true;
    pRecording.ValueType='';
    pRecording.ValueRange='';
    info.Parameters{1}{5}=pRecording;

    label=DAStudio.message('codertarget:ui:HWDiagStreamingModeTypeLabel');
    itemOneNameUnlmtd=DAStudio.message('codertarget:ui:HWDiagStreamingModeUnLimValue');
    itemTwoNameLmtd=DAStudio.message('codertarget:ui:HWDiagStreamingModeLimValue');
    toolTip=DAStudio.message('codertarget:ui:HWDiagStreamingModeTypeToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagStreamingModeTypeStorage');
    pStreamingType.Name=label;
    pStreamingType.ToolTip=toolTip;
    pStreamingType.Type='combobox';
    pStreamingType.Tag='SOCB_HW_StreamingModeType';
    pStreamingType.Enabled=~isSimOnlyHW;
    pStreamingType.Visible=locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage'))&&...
    locIsParamEqual(hObj,...
    DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage'),'Kernel')&&...
    locIsParamEqual(hObj,...
    DAStudio.message('codertarget:ui:HWDiagRecordingStorage'),'Continuous');

    pStreamingType.Entries={itemOneNameUnlmtd,itemTwoNameLmtd};
    pStreamingType.Value=itemOneNameUnlmtd;
    pStreamingType.Data={};
    pStreamingType.RowSpan=[5,5];
    pStreamingType.ColSpan=[1,3];
    pStreamingType.Alignment=0;
    pStreamingType.DialogRefresh=0;
    pStreamingType.Storage=storage;
    pStreamingType.DoNotStore=false;
    pStreamingType.Callback='widgetChangedCallback';
    pStreamingType.SaveValueAsString=true;
    pStreamingType.ValueType='';
    pStreamingType.ValueRange='';
    info.Parameters{1}{6}=pStreamingType;

    label=DAStudio.message('codertarget:ui:HWDiagBufferSizeLabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagBufferSizeToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagBufferSizeStorage');
    pBufferSize.Name=label;
    pBufferSize.ToolTip=toolTip;
    pBufferSize.Type='edit';
    pBufferSize.Tag='SOCB_HW_BufferSize';
    pBufferSize.Enabled=~isSimOnlyHW;






    pBufferSize.Visible=false;
    pBufferSize.Entries={};
    pBufferSize.Value=1024;
    pBufferSize.Data={};
    pBufferSize.RowSpan=[6,6];
    pBufferSize.ColSpan=[1,3];
    pBufferSize.Alignment=0;
    pBufferSize.DialogRefresh=0;
    pBufferSize.Storage=storage;
    pBufferSize.DoNotStore=false;
    pBufferSize.Callback='widgetChangedCallback';
    pBufferSize.SaveValueAsString=true;
    pBufferSize.ValueType='';
    pBufferSize.ValueRange='';
    info.Parameters{1}{7}=pBufferSize;

    label=DAStudio.message('codertarget:ui:HWDiagNumBuffersLabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagNumBuffersToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagNumBuffersStorage');
    pNumBuffers.Name=label;
    pNumBuffers.ToolTip=toolTip;
    pNumBuffers.Type='edit';
    pNumBuffers.Tag='SOCB_HW_NumBuffers';
    pNumBuffers.Enabled=~isSimOnlyHW;






    pNumBuffers.Visible=false;
    pNumBuffers.Entries={};
    pNumBuffers.Value=1;
    pNumBuffers.Data={};
    pNumBuffers.RowSpan=[7,7];
    pNumBuffers.ColSpan=[1,3];
    pNumBuffers.Alignment=0;
    pNumBuffers.DialogRefresh=0;
    pNumBuffers.Storage=storage;
    pNumBuffers.DoNotStore=false;
    pNumBuffers.Callback='widgetChangedCallback';
    pNumBuffers.SaveValueAsString=true;
    pNumBuffers.ValueType='';
    pNumBuffers.ValueRange='';
    info.Parameters{1}{8}=pNumBuffers;

    label=DAStudio.message('codertarget:ui:HWDiagViewLevelLabel');
    toolTip=DAStudio.message('codertarget:ui:HWDiagViewLevelToolTip');
    storage=DAStudio.message('codertarget:ui:HWDiagViewLevelStorage');
    pViewLevel.Name=label;
    pViewLevel.ToolTip=toolTip;
    pViewLevel.Type='combobox';
    pViewLevel.Tag='SOCB_HW_ViewLevel';
    pViewLevel.Enabled=~isSimOnlyHW;
    pViewLevel.Visible=false;
    pViewLevel.Entries={'Task manager tasks','All model tasks (Advanced)'};
    pViewLevel.Value='Task manager tasks';
    pViewLevel.Data={};
    pViewLevel.RowSpan=[8,8];
    pViewLevel.ColSpan=[1,3];
    pViewLevel.Alignment=0;
    pViewLevel.DialogRefresh=0;
    pViewLevel.Storage=storage;
    pViewLevel.DoNotStore=false;
    pViewLevel.Callback='widgetChangedCallback';
    pViewLevel.SaveValueAsString=true;
    pViewLevel.ValueType='';
    pViewLevel.ValueRange='';
    info.Parameters{1}{9}=pViewLevel;
end


function ret=locIsParameterOn(hObj,param)
    ret=codertarget.data.isParameterInitialized(hObj,param)&&...
    codertarget.data.getParameterValue(hObj,param);
end


function ret=locIsParamEqual(hObj,param,val)
    ret=false;
    if codertarget.data.isParameterInitialized(hObj,param)
        parVal=codertarget.data.getParameterValue(hObj,param);
        ret=isequal(parVal,val);
    end
end

