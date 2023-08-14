function out=checkStatus(obj,pValue,pStatus)

    if pStatus==configset.internal.data.ParamStatus.UnAvailable
        out=configset.internal.data.ParamStatus.UnAvailable;
    else
        out=obj.Dependency.checkStatus(pValue);
    end
