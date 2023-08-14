


function setRunDateCreated(this,runID,date)
    this.sigRepository.setDateCreated(runID,date);
    this.dirty=true;
end