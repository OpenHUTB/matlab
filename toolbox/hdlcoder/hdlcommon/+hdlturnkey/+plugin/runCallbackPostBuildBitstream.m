function[status,log]=runCallbackPostBuildBitstream(hDI)




    status=true;
    log='';

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.PostBuildBitstreamFcn)
        return;
    end
























    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.HDLModelDutPath=hDI.getDutName;
    infoStruct.BitstreamPath=hDI.hIP.getBitstreamPath;
    infoStruct.ToolProjectFolder=hDI.hIP.getEmbeddedToolProjFolder;
    infoStruct.ToolProjectName=hDI.hIP.getToolProjectFileName;
    infoStruct.ToolCommandString=hDI.hToolDriver.hTool.getToolTclCmdStrfull;
    infoStruct.IPCoreTimestamp=hDI.hTurnkey.modelgeninfo.TimestampValue;
    [status,log]=feval(hRD.PostBuildBitstreamFcn,infoStruct);

end