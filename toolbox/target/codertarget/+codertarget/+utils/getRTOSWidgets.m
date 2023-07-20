function widgetInfo=getRTOSWidgets(hObj)





    widgetInfo.ParameterGroups={};
    widgetInfo.Parameters={};
    attrInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
    hwInfo=codertarget.targethardware.getHardwareConfiguration(hObj);
    isMdlSoCCompatible=codertarget.utils.isMdlConfiguredForSoC(hObj);

    displayOSSelection=true;
    if~isempty(hwInfo)&&isprop(hwInfo,'ESBCompatible')
        if hwInfo.ESBCompatible>1&&isMdlSoCCompatible
            displayOSSelection=false;
        end
    end

    if isempty(hwInfo),return;end
    osEntries={};
    osNames=loc_getSupportedOSNames(hwInfo);
    if~isempty(codertarget.scheduler.getSupportedSchedulerNames(hObj))||...
        numel(osNames)==0
        osEntries{1}='Baremetal';
    end
    osEntries=[osEntries,osNames];
    widgetInfo.ParameterGroups={'Operating system options'};
    widgetInfo.Parameters={};
    idxPrm=1;
    p=loc_GetDefaultParameterInfo;
    p.Name=DAStudio.message('codertarget:ui:OSOperatingSystemLabel');
    p.Type='combobox';
    p.Tag='Target_RTOS';
    p.Enabled=~hObj.isValidProperty('CoderTargetData')||...
    ~hObj.isReadonlyProperty('CoderTargetData');



    p.Visible=numel(osEntries)>1&&displayOSSelection;
    p.Entries=osEntries;
    if codertarget.data.isParameterInitialized(hObj,'RTOS')
        osName=codertarget.data.getParameterValue(hObj,'RTOS');
    else
        osName=osEntries{1};
    end
    p.Value=osName;
    p.RowSpan=[idxPrm,idxPrm];
    p.DialogRefresh=1;
    p.Storage='RTOS';
    p.Callback='rtosChangedCallback';
    widgetInfo.Parameters{1}{idxPrm}=p;
    osInfo={};
    if~isempty(osNames)
        idxPrm=idxPrm+1;
        p=loc_GetDefaultParameterInfo;
        p.Name=DAStudio.message('codertarget:ui:OSBaseRateTaskPriorityLabel');
        p.Type='edit';
        p.Tag='Base_Rate_Task_Priority';
        p.Enabled=~hObj.isValidProperty('CoderTargetData')||...
        ~hObj.isReadonlyProperty('CoderTargetData');
        baseRatePriority=[];
        osInfo=codertarget.rtos.getSupportedRTOSInfoForHardwareName(hwInfo);
        if~isempty(osInfo{1})
            baseRatePriority=osInfo{1}.getBaseRatePriority;
        end
        if codertarget.data.isParameterInitialized(hObj,'RTOS')
            os=codertarget.rtos.getTargetHardwareRTOS(hObj);
            p.Visible=~isempty(os)&&~isempty(os.getBaseRatePriority)&&~isMdlSoCCompatible;
        else
            p.Visible=1;
        end
        if isempty(baseRatePriority)
            p.Value='40';
        else
            p.Value=baseRatePriority;
        end
        p.RowSpan=[idxPrm,idxPrm];
        p.Storage='RTOSBaseRateTaskPriority';
        widgetInfo.Parameters{1}{idxPrm}=p;
        if~isempty(attrInfo)&&~isempty(attrInfo.DetectOverrun)&&...
            attrInfo.DetectOverrun
            idxPrm=idxPrm+1;
            p=loc_GetDefaultParameterInfo;
            p.Name=DAStudio.message('codertarget:ui:OSDetectTaskOverruns');
            p.Type='checkbox';
            p.Tag='Detect_Task_Overruns';
            p.RowSpan=[idxPrm,idxPrm];
            p.Storage='DetectTaskOverruns';
            p.Visible=~isMdlSoCCompatible;
            widgetInfo.Parameters{1}{idxPrm}=p;
        end
    end
    if~isequal(osName,'Baremetal')&&...
        isMdlSoCCompatible&&...
        ~isempty(osInfo)
        widgetInfo=loc_AddOSSimulationWidgets(widgetInfo,idxPrm,osInfo{1});
    end
end



function info=loc_AddOSSimulationWidgets(info,idxPrm,osInfo)
    idxPrm=idxPrm+1;
    p=loc_GetDefaultParameterInfo;
    p.Name=DAStudio.message('codertarget:ui:OSKernelLatencyLabel');
    p.ToolTip=DAStudio.message('codertarget:ui:OSKernelLatencyToolTip');
    p.Type='edit';
    p.Value=osInfo.KernelLatency;
    p.Enabled=osInfo.EnableEdit;
    p.Tag='Kernel_Latency';
    p.RowSpan=[idxPrm,idxPrm];
    p.Storage='OS.KernelLatency';
    p.ValueType='double';
    p.ValueRange='[0,1e15]';
    p.Callback='kernelLatencyChangedCallback';
    info.Parameters{1}{idxPrm}=p;
    idxPrm=idxPrm+1;

    p=loc_GetDefaultParameterInfo;
    p.Name=DAStudio.message('codertarget:ui:OSTaskContextSaveTimeLabel');
    p.ToolTip=DAStudio.message('codertarget:ui:OSTaskContextSaveTimeToolTip');
    p.Type='edit';
    p.Value=osInfo.TaskContextSaveTime;
    p.Enabled=osInfo.EnableEdit;
    p.Visible=0;
    p.Tag='Task_Context_Save_Time';
    p.RowSpan=[idxPrm,idxPrm];
    p.Storage='OS.TaskContextSaveTime';
    p.ValueType='double';
    p.ValueRange='[0,1e15]';
    info.Parameters{1}{idxPrm}=p;
    idxPrm=idxPrm+1;

    p=loc_GetDefaultParameterInfo;
    p.Name=DAStudio.message('codertarget:ui:OSTaskContextRestoreTimeLabel');
    p.ToolTip=DAStudio.message('codertarget:ui:OSTaskContextRestoreTimeToolTip');
    p.Type='edit';
    p.Value=osInfo.TaskContextRestoreTime;
    p.Enabled=osInfo.EnableEdit;
    p.Visible=0;
    p.Tag='Task_Context_Restore_Time';
    p.RowSpan=[idxPrm,idxPrm];
    p.Storage='OS.TaskContextRestoreTime';
    p.ValueType='double';
    p.ValueRange='[0,1e15]';
    info.Parameters{1}{idxPrm}=p;















end


function out=loc_getSupportedOSNames(hwInfo)
    out=codertarget.rtos.getNamesOfSupportedRTOSForHardwareName(hwInfo);
    unSupportedOS='VxWorks';
    if isequal(hwInfo.Name,'Xilinx Zynq ZC706 evaluation kit')&&...
        ~codertarget.internal.isSpPkgInstalled('xilinxzynq_ec')
        if any(ismember(out,unSupportedOS))
            out(strncmpi(out,unSupportedOS,numel(unSupportedOS)))=[];
        end
    end
end


function p=loc_GetDefaultParameterInfo
    p=struct('Name','','ToolTip','','Type','','Tag','','Enabled',1,...
    'Visible',1,'Entries',[],'Value',0,'Data',[],'RowSpan',[3,3],...
    'ColSpan',[1,3],'Alignment',0,'DialogRefresh',0,'Storage','',...
    'DoNotStore',false,'Callback','widgetChangedCallback',...
    'SaveValueAsString',true,'ValueType','','ValueRange','');
    p.Entries={};
end


