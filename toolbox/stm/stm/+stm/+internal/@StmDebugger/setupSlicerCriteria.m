function setupSlicerCriteria(obj)






    signalMapKey=obj.getSignalMapKey();
    if isKey(obj.signalToSliceCriteriaIndexMap,signalMapKey)
        existingSlicerCriteriaIndex=obj.signalToSliceCriteriaIndexMap(signalMapKey);

        obj.resultsDebugger.switchToCriteria(existingSlicerCriteriaIndex);
    else

        obj.resultsDebugger.addSliceCriterion;


        obj.resultsDebugger.setCriteriaTag(obj.slicerCriteriaTag);

        name=getString(message('stm:general:SlicerDebugCriteriaName',...
        obj.signalObj.SignalLabel));
        obj.resultsDebugger.setCriteriaName(name);

        desc=getString(message('stm:general:SlicerDebugCriteriaDescription',...
        obj.signalObj.SignalLabel));
        obj.resultsDebugger.setCriteriaDescription(desc);
    end


    stm.internal.StmDebugger.scopeToSeedView(obj.signalObj.DataID);




    startingPoint=getStartingPoint(obj.simOutSignal,obj.signalObj,obj.ModelName);
    obj.resultsDebugger.addStartingPoint(startingPoint);


    obj.addCurrentSignalToSliceCriteriaIndexMapEntry(obj.resultsDebugger.getCurrentCriteriaIndex);


    obj.appendValuesToActivePVD();
end


function startingPoint=getStartingPoint(simOutSignalObj,signalObjToSetup,modelName)

    startingPoint=[];

    if~strcmp(simOutSignalObj.ModelSource,modelName)
        signalObj=signalObjToSetup;
    else
        signalObj=simOutSignalObj;
    end

    if(~isempty(signalObj.SID)||~isempty(signalObj.BlockSource))...
        &&~isempty(signalObj.PortIndex)


        if~isempty(signalObj.SID)
            ph=get_param(signalObj.SID,'PortHandles');
        else
            ph=get_param(signalObj.BlockSource,'PortHandles');
        end

        if~isempty(ph.Outport)&&...
            signalObj.PortIndex>0&&...
            signalObj.PortIndex<=length(ph.Outport)
            op=ph.Outport(signalObj.PortIndex);
            startingPoint=get_param(op,'line');
        end
    end


    if isempty(startingPoint)&&~isempty(signalObj.BlockSource)
        startingPoint=signalObj.BlockSource;
    end
end
