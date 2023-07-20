function[status,log]=runCallbackSWModelGeneration(hDI,ipcoreInfo)




    status=true;
    log='';

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.CallbackSWModelGeneration)
        return;
    end



















    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.IPCoreInfo=ipcoreInfo;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;

    [status,log]=feval(hRD.CallbackSWModelGeneration,infoStruct);

end