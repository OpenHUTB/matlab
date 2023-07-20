function info=getSchedulerWidgets(hObj)





    info.ParameterGroups={};
    info.Parameters={};

    schedulerChoices1=codertarget.scheduler.getSupportedSchedulerNames(hObj);
    schedulerChoices2={};

    hwInfo=codertarget.targethardware.getHardwareConfiguration(hObj);
    if isempty(hwInfo),return;end

    hwName=hwInfo.Name;
    hRTOSInfo=codertarget.rtos.getSupportedRTOSInfoForHardwareName(hwInfo);

    selectedRTOS=loc_GetSelectedRTOS(hObj,hwInfo);

    for i=1:numel(hRTOSInfo)
        if~isempty(hRTOSInfo{i})
            if isequal(hRTOSInfo{i}.Name,selectedRTOS)
                baseRateTriggers=hRTOSInfo{i}.getBaseRateTriggers();
                for j=1:numel(baseRateTriggers)
                    schedulerChoices2{end+1}=baseRateTriggers{j};%#ok<AGROW>
                end
            end
        end
    end

    if isempty(schedulerChoices1)&&isempty(schedulerChoices2)
        return
    end

    data=codertarget.data.getData(hObj);
    if isfield(data,'RTOS')&&~isequal(data.RTOS,'Baremetal')
        schedulerChoices=schedulerChoices2;
    else
        schedulerChoices=schedulerChoices1;
    end

    info.ParameterGroups={'Scheduler options'};

    p1.Name=DAStudio.message('codertarget:ui:OSSchedulerBaseRateTriggerLabel');
    p1.Type='combobox';
    p1.Tag='Scheduler_interrupt_source';
    p1.Enabled=~hObj.isValidProperty('CoderTargetData')||...
    ~hObj.isReadonlyProperty('CoderTargetData');
    p1.Visible=numel(schedulerChoices)>1;
    p1.Entries=schedulerChoices;
    p1.Value=0;
    p1.Data={};
    p1.RowSpan=[1,1];
    p1.ColSpan=[1,2];
    p1.Alignment=0;
    p1.DialogRefresh=1;
    p1.Storage='';
    p1.DoNotStore=false;
    p1.Callback='widgetChangedCallback';
    p1.SaveValueAsString=false;
    p1.ValueType='';
    p1.ValueRange='';

    info.Parameters={};
    info.Parameters{1}{1}=p1;
end


function osName=loc_GetSelectedRTOS(hObj,hwInfo)
    if codertarget.data.isParameterInitialized(hObj,'RTOS')
        osName=codertarget.data.getParameterValue(hObj,'RTOS');
    else
        osEntries={};
        osNames=codertarget.rtos.getNamesOfSupportedRTOSForHardwareName(hwInfo);
        if~isempty(codertarget.scheduler.getSupportedSchedulerNames(hObj))||...
            numel(osNames)==0
            osEntries{1}='Baremetal';
        end
        osEntries=[osEntries,osNames];
        osName=osEntries{1};
    end
end


