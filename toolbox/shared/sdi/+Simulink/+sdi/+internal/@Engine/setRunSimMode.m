
function setRunSimMode(this,runID,mode)
    if this.isValidRunID(runID)
        this.sigRepository.setRunSimMode(runID,mode);
    else
        error(message('SDI:sdi:InvalidRunID'));
    end
end