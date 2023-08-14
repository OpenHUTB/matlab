function setESBPluginAttached(hCS,action)




    if locIsESBInstalled&&~isempty(hCS.getModel)
        if action
            soc.internal.configureESBPlugin(hCS.getModel,'attach');
        else
            soc.internal.configureESBPlugin(hCS.getModel,'detach');
        end
    end
end


function res=locIsESBInstalled
    res=isequal(exist('esb_task','file'),3);
end


