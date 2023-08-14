
function out=getRunSimMode(this,runID)
    if this.isValidRunID(runID)
        out=this.sigRepository.getRunSimMode(runID);
    else
        error(message('SDI:sdi:InvalidRunID'));
    end
end