function utilAdjustGenerateHDLCodeTaskOnly(mdladvObj,hDI)




    taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.GenerateHDLCodeAndReport');


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    GenerateRTLCode=hdlwa.utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateRTLCode'));
    GenerateTestbench=hdlwa.utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateTestbench'));
    GenerateValidationModel=hdlwa.utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateCovalidationModel'));


    GenerateRTLCode.Value=hDI.GenerateRTLCode;
    GenerateTestbench.Value=hDI.GenerateTestbench;
    GenerateValidationModel.Value=hDI.GenerateValidationModel;

    if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow||hDI.isFILWorkflow)
        GenerateRTLCode.Enable=false;
    else
        GenerateRTLCode.Enable=true;
    end



    if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow)
        GenerateTestbench.Enable=false;

    else
        GenerateTestbench.Enable=true;

    end


    system=mdladvObj.System;
    model=bdroot(system);
    cs=getActiveConfigSet(model);

    hDI.saveGenerateHDLSettingToModel(model,GenerateRTLCode.Value,GenerateTestbench.Value,GenerateValidationModel.Value);
    cs.refreshDialog;

end


