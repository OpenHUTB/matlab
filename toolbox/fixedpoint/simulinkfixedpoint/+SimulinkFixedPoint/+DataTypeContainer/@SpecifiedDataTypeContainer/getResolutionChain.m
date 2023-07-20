function resolutionChain=getResolutionChain(this)












    if this.isVarName&&~this.isUnknown
        resolutionQueue=getResolutionQueueForNamedType(this);
        resolutionStringWithName=cellfun(@(x)[x,this.RESOLUTIONDELIMITER],resolutionQueue,'UniformOutput',false);
        resolutionChain=[[resolutionStringWithName{:}],this.getEvalString(this.evaluatedNumericType)];
    else
        resolutionChain=this.evaluatedDTString;
    end
end