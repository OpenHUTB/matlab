function modelobject=getObject(ssid)




    try
        modelobject=Simulink.ID.getHandle(ssid);
    catch SlCovExcpt
        if contains(ssid,'.m')

            modelobject=[];
        else
            rethrow(SlCovExcpt);
        end
    end

    if~isempty(modelobject)&&~contains(class(modelobject),'Stateflow.')
        modelobject=get_param(modelobject,'object');
    end
end