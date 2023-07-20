




function out=isBranchedFunctionCall(blkHandle)

    if get_param(blkHandle,'BranchedFunctionCallOrder')==-1
        out=false;
    else
        out=true;
    end

end
