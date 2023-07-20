function updateDeps=InputMapping(cs,~)


    updateDeps=false;
    model=cs.getModel;
    if~isempty(model)
        modelName=get_param(model,'Name');
        inputconnector('Model',modelName);
    end

