function setRunStartAndStopTime(this,runID,startTime,stopTime)
    if~isempty(startTime)&&~isempty(stopTime)
        this.sigRepository.setRunStartAndStopTime(runID,startTime,stopTime);
    end
end