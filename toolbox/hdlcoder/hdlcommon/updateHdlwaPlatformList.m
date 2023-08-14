function updateHdlwaPlatformList(workflow)


    if isempty(which('simulink'))
        return
    end

    modelAdvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

    if isempty(modelAdvObj)
        return;
    elseif~strcmpi(modelAdvObj.CustomTARootID,'com.mathworks.HDL.WorkflowAdvisor')
        return;
    end

    switch lower(workflow)
    case 'ip_core'

        system=modelAdvObj.System;
        hModel=bdroot(system);
        hDriver=hdlmodeldriver(hModel);
        hDI=hDriver.DownstreamIntegrationDriver;
        if~hDI.isIPWorkflow

            hDI.set('Workflow','IP Core Generation');
        end
        hDI.hIP.reloadPlatformList;


        taskobj=modelAdvObj.getTaskObj('com.mathworks.HDL.SetTargetDevice');
        targetInputParams=modelAdvObj.getInputParameters(taskobj.MAC);
        workflowOption=targetInputParams{1};
        if~strcmp(workflowOption.Value,hDI.get('Workflow'))
            workflowOption.Value=hDI.get('Workflow');
        end
        boardOption=targetInputParams{2};
        boardOption.Entries=hDI.set('Board');
        if~strcmp(boardOption.Value,hDI.get('Board'))
            boardOption.Value=hDI.get('Board');
        end


        taskobj.resetgui;
    end
