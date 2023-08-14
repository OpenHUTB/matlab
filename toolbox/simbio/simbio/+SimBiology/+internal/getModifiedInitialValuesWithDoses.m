function[modifiedObjects,modifiedValues]=...
    getModifiedInitialValuesWithDoses(model,configset,variants,doses)





























    [modifiedObjects,modifiedValues,doseTargets,doseModifications]=...
    SimBiology.internal.getModifiedInitialValues(model,configset,variants,doses);

    if isempty(doseTargets)

        return;
    end


    odedata=model.ODESimulationData;
    allStateUuids=[odedata.XUuids;odedata.PUuids];
    allStateObjs=SimBiology.internal.getModelObjectsForUuids(model,allStateUuids);
    doseTargetUuids=get(doseTargets,{'UUID'});


    if isempty(modifiedObjects)
        modifiedObjectUUIDs={};
    else
        modifiedObjectUUIDs=get(modifiedObjects,{'UUID'});
    end
    [modifiedLogical,modifiedPosition]=ismember(allStateUuids,modifiedObjectUUIDs);

    [~,doseToStatesIndex]=ismember(doseTargetUuids,allStateUuids);

    for doseIndex=length(doseTargets):-1:1


        stateIndex=doseToStatesIndex(doseIndex);

        change=doseModifications(doseIndex);
        if~isempty(odedata.XUCM)
            change=change.*odedata.XUCM(stateIndex);
        end

        if modifiedLogical(stateIndex)
            modifiedValues(modifiedPosition(stateIndex))=...
            modifiedValues(modifiedPosition(stateIndex))+change;
            doseModifications(doseIndex)=[];
            doseTargets(doseIndex)=[];
        else
            doseModifications(doseIndex)=...
            allStateObjs(stateIndex).Value+change;
        end

    end



    modifiedObjects=[modifiedObjects;doseTargets'];
    modifiedValues=[modifiedValues;doseModifications'];

end