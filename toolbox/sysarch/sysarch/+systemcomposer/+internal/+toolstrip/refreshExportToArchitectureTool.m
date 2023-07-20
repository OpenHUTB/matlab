function refreshExportToArchitectureTool(cbinfo,action)



    if isvalid(action)
        if strcmp(get_param(cbinfo.model.Name,'SimulinkSubDomain'),'Simulink')
            action.enabled=true;
        else
            action.enabled=false;
        end
    end

end
