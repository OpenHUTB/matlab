function sigName=extractSignalNameFromDims(this,sigNameWithDims)
    dimsInd=regexp(sigNameWithDims,this.DimsRx);
    lastDimsInd=dimsInd(end);
    sigName=strtrim(sigNameWithDims(1:lastDimsInd-1));
end