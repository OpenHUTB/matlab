function validateCell=runCallbackPostTargetReferenceDesign(hDI)




    validateCell={};

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)||isempty(hRD.PostTargetReferenceDesignFcn)
        return;
    end












    infoStruct.ReferenceDesignObject=hRD;
    infoStruct.BoardObject=hDI.hTurnkey.hBoard;
    infoStruct.ParameterStruct=hRD.getParameterStructFormat;
    infoStruct.HDLModelDutPath=hDI.getDutName;


    fcnNumOut=nargout(hRD.PostTargetReferenceDesignFcn);
    if fcnNumOut==1
        validateCell=feval(hRD.PostTargetReferenceDesignFcn,infoStruct);
    else
        feval(hRD.PostTargetReferenceDesignFcn,infoStruct);
    end

end
