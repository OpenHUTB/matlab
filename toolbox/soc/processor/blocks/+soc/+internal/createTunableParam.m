function msg=createTunableParam(tunableParamName)




    try
        evalin('base',tunableParamName+" = Simulink.Parameter(0);");
        evalin('base',tunableParamName+".CoderInfo.StorageClass = 'ExportedGlobal';");
        evalin('base',tunableParamName+".DataType = 'uint32';");
        msg="Created Simulink.Parameter object named '"+tunableParamName+"' in the base workspace.";
    catch EX

        newEX=MException(message('soc:utils:FailedToCreateTunableParameter',tunableParamName,EX.message));
        newEX=addCause(newEX,EX);
        throw(newEX);
    end
end
