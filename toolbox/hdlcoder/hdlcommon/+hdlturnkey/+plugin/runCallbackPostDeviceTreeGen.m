function[status,log]=runCallbackPostDeviceTreeGen(hDI)




    status=true;
    log='';

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.PostDeviceTreeGenerationFcn)
        return;
    end
















    hDeviceTreeGen=hDI.hTurnkey.hDeviceTreeGen;


    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.DeviceTreeSourceFile=hDeviceTreeGen.DeviceTreeSourceFilePath;

    [status,log]=feval(hRD.PostDeviceTreeGenerationFcn,infoStruct);

end