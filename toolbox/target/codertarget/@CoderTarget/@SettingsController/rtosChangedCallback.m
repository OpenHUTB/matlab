function rtosChangedCallback(hObj,hDlg,tag,arg)





    if isequal(hDlg.getComboBoxText(tag),codertarget.data.getParameterValue(hObj,'RTOS'))
        return
    end

    widgetChangedCallback(hObj,hDlg,tag,arg);

    rtosInfo=codertarget.rtos.getTargetHardwareRTOS(hObj);

    tagPrefix='Tag_ConfigSet_CoderTarget_';
    parameterTag='Base_Rate_Task_Priority';
    parameterStorage='RTOSBaseRateTaskPriority';
    priorityWidgetTag=[tagPrefix,parameterTag];
    if~isempty(rtosInfo)
        hDlg.setVisible(priorityWidgetTag,~isempty(rtosInfo.BaseRatePriority));
        if~isempty(rtosInfo.BaseRatePriority)
            hDlg.setWidgetValue(priorityWidgetTag,rtosInfo.BaseRatePriority);
            hObj.CoderTargetData.(parameterStorage)=rtosInfo.BaseRatePriority;
        else
            hDlg.setVisible(priorityWidgetTag,false);
        end
        if~isempty(rtosInfo.SelectFcn)
            fhandle=str2func(rtosInfo.SelectFcn);
            fhandle(hObj,hDlg,tag);
        end
    else
        hDlg.setVisible(priorityWidgetTag,false);
    end

    parameterTag='Scheduler_interrupt_source';
    parameterStorage=parameterTag;
    schedulerWidgetTag=[tagPrefix,parameterTag];
    hDlg.setWidgetValue(schedulerWidgetTag,0);
    hObj.CoderTargetData.(parameterStorage)=0;

end
