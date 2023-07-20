
function out=getSignalIDByIndex(this,runID,index)
    out=this.sigRepository.getSignalIDByIndex(int32(runID),int32(index));
end