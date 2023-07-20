function widget=createElementDiagnosticWidget(messages,element,dwRegistry)
    if isempty(messages)||isempty(element)
        widget=classdiagram.app.core.notifications.output.DiagnosticWidget.empty;
        return;
    end
    widgetData=createDiagnosticWidgetData(messages);
    spec=createPositionSpec(element);
    widget=classdiagram.app.core.notifications.output.DiagnosticWidget(element,widgetData,spec,dwRegistry);
    widget.debugMode(1);
end

function spec=createPositionSpec(element)

    spec=classdiagram.app.core.notifications.output.PositionSpecification;
    spec.setPreferredSide(classdiagram.app.core.notifications.output.utils.PreferredSide.RIGHT);
end

function output=createDiagnosticWidgetData(messages)
    output=[];
    for i=1:length(messages)
        helpCB=function_handle.empty;
        ignoreCB=function_handle.empty;
        dataObj=classdiagram.app.core.notifications.output.DiagnosticWidgetData(messages(i));
        output=[output,dataObj];
    end
end

function helpCDNotification(message)
    disp('helpCDNotification called');
end

function ignoreCDNotification(message)
    disp('ignoreCDNotification called');
end

function helpNotification(notification)
    if~isempty(notification)
        cm=edittimecheck.CheckManager.getInstance;
        helpLinks=cm.getHelp(notification);
        map_path=['mapkey:',helpLinks.mapkey];
        topic_id=helpLinks.topicid;
        if~isempty(map_path)&&~isempty(topic_id)
            helpview(map_path,topic_id,'CSHelpWindow');
        end
    end
end

function ignoreNotification(model,notification)
    prop=slcheck.getPropertySchema;
    prop.value=strrep(Simulink.ID.getFullName(notification.Data),newline,' ');
    prop.checkIDs={notification.CheckID};
    exEditor=Advisor.getExclusionEditor(bdroot(Simulink.ID.getFullName(notification.Data)));
    exEditor.addExclusion(prop,true);
end
