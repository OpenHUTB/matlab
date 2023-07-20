function utilAdjustTargetReferenceDesignTaskOnly(mdladvObj,hDI)




    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetReferenceDesign');


    inputParams=mdladvObj.getInputParameters(targetObj.MAC);
    rfNameOption=hdlwa.utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAReferenceDesign'));
    rfVersionOption=hdlwa.utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWARDToolVersion'));
    rfIgnoreOption=hdlwa.utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWARDToolVersionIgnore'));


    rfNameOption.Entries=hDI.hIP.getReferenceDesignAll;
    rfNameOption.Value=hDI.hIP.getReferenceDesign;

    rfVersionOption.Entries=hDI.hIP.getRDToolVersionAll;
    rfVersionOption.Value=hDI.hIP.getRDToolVersion;

    rfIgnoreOption.Value=hDI.hIP.getIgnoreRDToolVersionMismatch;


    if length(hDI.hIP.getReferenceDesignAll)>1
        rfNameOption.Enable=true;
    else
        rfNameOption.Enable=false;
    end


    if hDI.hIP.isRDToolVersionMatch
        rfVersionOption.Enable=false;
        rfIgnoreOption.Enable=false;
    else
        rfVersionOption.Enable=true;
        rfIgnoreOption.Enable=true;
    end


    hdlwa.utilUpdateRDParameterTable(mdladvObj,hDI);


    hdlwa.WorkflowManager.updateWorkflow(mdladvObj);

end

