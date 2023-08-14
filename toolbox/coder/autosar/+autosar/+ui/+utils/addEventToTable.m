




function addEventToTable(dlg,obj)

    arExplorer=autosar.ui.utils.findExplorer(obj.M3iObject.modelM3I);
    assert(~isempty(arExplorer));
    eventData=arExplorer.EventData;
    eventsObj=obj.M3iObject.containerM3I.Events;


    eventName=autosar.ui.wizard.PackageString.DefaultEventName;
    protectedNames={};
    for index=1:length(eventData)
        protectedNames{end+1}=eventData(index).Name;%#ok<AGROW>
    end
    for index=1:eventsObj.size()
        protectedNames{end+1}=eventsObj.at(index).Name;%#ok<AGROW>
    end
    runnables=obj.M3iObject.containerM3I.Runnables;
    for jj=1:runnables.size()
        protectedNames{end+1}=runnables.at(jj).Name;%#ok<AGROW>
        protectedNames{end+1}=runnables.at(jj).symbol;%#ok<AGROW>
    end
    irvs=obj.M3iObject.containerM3I.IRV;
    for jj=1:irvs.size()
        protectedNames{end+1}=irvs.at(jj).Name;%#ok<AGROW>
    end
    if~isempty(protectedNames)
        eventName=genvarname(eventName,protectedNames);
    end

    if isempty(eventData)
        eventData=autosar.ui.metamodel.Event.empty(1,0);
    end

    eventData(end+1)=autosar.ui.metamodel.Event(eventName,...
    autosar.ui.wizard.PackageString.EventTypes{1},...
    DAStudio.message('RTW:autosar:selectERstr'),...
    obj.M3iObject.Name);
    arExplorer.EventData=eventData;


    dlg.refresh;
    dlg.enableApplyButton(true);
end


