function updateWidgetValues(~,hDlg,taskData)










    taskParameters={...
    'taskName',{};...
    'taskType',{'Event-driven','Timer-driven'};...
    'taskPeriod',{};...
    'coreNum',{};...
    'taskPriority',{};...
    'dropOverranTasks',{};...
    'playbackRecorded',{};...
    'taskDurationSource',{'Dialog','Input port','Recorded task execution statistics'};...
    };
    for i=1:length(taskParameters)
        thisParameterName=taskParameters{i,1};
        thisParameterValue=taskData.(thisParameterName);
        widgetTag=[thisParameterName,'Tag'];
        if~isempty(taskParameters{i,2})
            widgetEntries=taskParameters{i,2};
            [~,idx]=ismember(thisParameterValue,widgetEntries);
            widgetVal=idx-1;
        else
            widgetVal=thisParameterValue;
        end
        hDlg.setWidgetValue(widgetTag,widgetVal);
    end
end
