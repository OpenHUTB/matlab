


function clear(obj)
    obj.callbackFcn=[];
    obj.setObjButtonVisible=[];
    obj.resetObjective();
    if obj.initialized
        obj.clearChecks();
    end
end
