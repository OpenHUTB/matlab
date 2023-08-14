function isReset=utilParseGenerateHDLCode(mdladvObj,hDI)



    isReset=false;

    inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.GenerateHDLCodeAndReport');
    GenerateRTLCode=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateRTLCode'));
    GenerateTestbench=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateTestbench'));
    GenerateValidationModel=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateCovalidationModel'));


    if(GenerateRTLCode.Value~=hDI.GenerateRTLCode)
        hDI.GenerateRTLCode=GenerateRTLCode.Value;
    end
    if(GenerateTestbench.Value~=hDI.GenerateTestbench)
        hDI.GenerateTestbench=GenerateTestbench.Value;
    end
    if(GenerateValidationModel.Value~=hDI.GenerateValidationModel)
        hDI.GenerateValidationModel=GenerateValidationModel.Value;
    end

end


