function validateCell=runCallbackCustomizeReferenceDesign(hRD,hDI,RDToolVersion)



    validateCell={};

    if isempty(hRD)||isempty(hRD.CustomizeReferenceDesignFcn)
        return;
    end















    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.HDLModelDutPath=hDI.getDutName;
    infoStruct.ReferenceDesignToolVersion=RDToolVersion;


    fcnNumOut=nargout(hRD.CustomizeReferenceDesignFcn);
    if fcnNumOut==1
        validateCell=feval(hRD.CustomizeReferenceDesignFcn,infoStruct);
    else
        feval(hRD.CustomizeReferenceDesignFcn,infoStruct);
    end

end