function objH=sidToHandle(model,objId)


    if ischar(model)
        modelH=get_param(model,'Handle');
        modelName=model;
    else
        modelH=model;
        modelName=get_param(modelH,'Name');
    end
    if strcmp(objId,':')
        objH=modelH;
    else
        objH=Simulink.ID.getHandle([modelName,objId]);
        if strncmp(class(objH),'Stateflow',length('Stateflow'))
            objH=objH.Id;
        end
    end
end
