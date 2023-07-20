function selectProfilingMode(cbinfo)




    data=cbinfo.EventData;
    if~isempty(data)
        modelName=cbinfo.model.Name;
        if~isempty(modelName)

            appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
            appContext.setProfilingMode(data);
        end
    end
end


