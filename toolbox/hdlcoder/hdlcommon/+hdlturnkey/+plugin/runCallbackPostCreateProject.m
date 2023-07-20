function[status,log]=runCallbackPostCreateProject(hDI)




    status=true;
    log='';

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.PostCreateProjectFcn)
        return;
    end




















    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.HDLModelDutPath=hDI.getDutName;
    infoStruct.ToolProjectFolder=hDI.hIP.getEmbeddedToolProjFolder;
    infoStruct.ToolProjectName=hDI.hIP.getToolProjectFileName;
    infoStruct.ToolCommandString=hDI.hToolDriver.hTool.getToolTclCmdStrfull;


    [status,log]=feval(hRD.PostCreateProjectFcn,infoStruct);

end