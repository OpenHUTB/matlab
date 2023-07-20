function removeEmptyRun(this,runID,runsToDecIndex)
    this.sigRepository.removeRun(runID);
    if nargin>2
        this.sigRepository.decrementRunNumbers(runsToDecIndex);
    end
end