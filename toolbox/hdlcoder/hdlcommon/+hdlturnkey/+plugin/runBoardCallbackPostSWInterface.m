function[status,log]=runBoardCallbackPostSWInterface(hDI)





    status=true;
    log='';

    hBoard=hDI.hTurnkey.hBoard;
    if isempty(hBoard)||isempty(hBoard.PostSWInterfaceFcn)
        return;
    end




















    hModelGen=hDI.hTurnkey.hModelGen;


    infoStruct.BoardObject=hBoard;
    infoStruct.HDLModelDutPath=hDI.getDutName;
    infoStruct.SWModelDutPath=hModelGen.tifDutPath;

    if strcmpi(hdlfeature('IPCoreSoftwareInterfaceLibrary'),'on')
        infoStruct.SWLibBlockPath=hModelGen.blockPath;
        infoStruct.SWLibFolderPath='';
    end

    [status,log]=feval(hBoard.PostSWInterfaceFcn,infoStruct);

end