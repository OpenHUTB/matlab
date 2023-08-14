function req=selectionLink(objH,make2way,varargin)

    if rmism.isSafetyManagerSelectionValid()
        targetObj=sm.internal.SafetyManager.getCurrentLinkable();
    else
        warndlg(getString(message('Slvnv:rmism:MakeValidSelection')),...
        getString(message('Slvnv:rmism:LinkToCurrent')),...
        'modal');
        req=[];
        return;
    end

    if make2way
        callerInfoStruct=rmi.makeReq(objH,targetObj);
        if isempty(callerInfoStruct)

            req=[];
            return;
        else
            rmi.catReqs(targetObj,callerInfoStruct);
        end
    end

    oldStructType=false;

    if nargin>2
        oldStructType=varargin{1};
    end

    req=rmism.getRmiStruct(targetObj,oldStructType);
end