function selectMode(userdata,cbinfo)




    modelName=cbinfo.model.Name;
    if~isempty(modelName)

        appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
        appContext.setMode(userdata);
    end
end


