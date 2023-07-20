


function res=hasInternalRequirements(blockHandle,modelHandle)
    res=false;
    if(rmi.objHasReqs(blockHandle,[]))
        res=strcmpi(get_param(modelHandle,'hasReqInfo'),'on');
    end
end