function updateRunFromNamesAndValues(this,runID,VarNames,VarValues,varargin)


    locUpdateRunV2(this,runID,VarNames,VarValues,varargin{:});
end


function locUpdateRunV2(this,runID,VarNames,VarValues,varargin)
    oldSignalIDs=this.getAllSignalIDs(runID,'logged');
    if isempty(oldSignalIDs)
        addToRunFromNamesAndValues(this,runID,VarNames,VarValues,varargin{:});
    else
        addToRunFromNamesAndValues(this,runID,VarNames,VarValues,varargin{:},runID);
    end
    this.deleteRunsAndSignals(oldSignalIDs,'SDIRun');
end
