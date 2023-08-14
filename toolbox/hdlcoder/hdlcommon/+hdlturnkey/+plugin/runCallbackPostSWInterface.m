function[status,log]=runCallbackPostSWInterface(hDI)





    status=true;
    log='';

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.PostSWInterfaceFcn)
        return;
    end






















    hModelGen=hDI.hTurnkey.hModelGen;


    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.HDLModelDutPath=hDI.getDutName;
    infoStruct.SWModelDutPath=hModelGen.tifDutPath;

    if strcmpi(hdlfeature('IPCoreSoftwareInterfaceLibrary'),'on')
        infoStruct.SWLibBlockPath=hModelGen.blockPath;
        infoStruct.SWLibFolderPath='';
    end

    [status,log]=feval(hRD.PostSWInterfaceFcn,infoStruct);

end