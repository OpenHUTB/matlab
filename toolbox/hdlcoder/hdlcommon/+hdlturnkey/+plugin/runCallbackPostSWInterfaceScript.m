function[status,log]=runCallbackPostSWInterfaceScript(hDI)





    status=true;
    log='';

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.PostSWInterfaceScriptFcn)
        return;
    end


















    hScriptGen=hDI.hTurnkey.hScriptGen;


    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.SetupFileName=hScriptGen.SetupFileName;
    infoStruct.ScriptFileName=hScriptGen.ScriptFileName;

    [status,log]=feval(hRD.PostSWInterfaceScriptFcn,infoStruct);

end