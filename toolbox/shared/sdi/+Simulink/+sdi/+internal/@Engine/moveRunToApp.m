function moveRunToApp(this,runID,newAppName,varargin)







    currentAppName=this.sigRepository.getRunAppAsString(runID);
    if~strcmpi(newAppName,currentAppName)
        this.sigRepository.setRunApp(runID,newAppName,varargin{:});
        Simulink.sdi.internalMoveRunToApp(runID,newAppName,currentAppName);
    end
end
