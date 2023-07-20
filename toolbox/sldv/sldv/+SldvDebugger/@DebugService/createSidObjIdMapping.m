






function createSidObjIdMapping(obj)

    sldvData=obj.sldvData;


    remove(obj.sidObjIdMap,keys(obj.sidObjIdMap));


    for i=1:length(sldvData.ModelObjects)
        modelObject=sldvData.ModelObjects(i);
        if~isempty(modelObject.objectives)
            debugObjectives=[];
            for j=1:length(modelObject.objectives)
                objectiveId=modelObject.objectives(j);

                if obj.isObjectiveDebuggable(objectiveId)
                    debugObjectives=[debugObjectives,objectiveId];
                end
            end


            model=strtok(modelObject.designSid,':');
            if~isempty(model)&&~bdIsLoaded(model)
                load_system(model);
            end

            if~isempty(model)
                try
                    SID=Simulink.ID.getSID(Simulink.ID.getHandle(modelObject.designSid));
                catch


                    continue;
                end
                obj.sidObjIdMap(SID)=debugObjectives;
            end
        end
    end
end
