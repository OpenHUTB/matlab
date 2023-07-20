function[newRunID,runIndex,signalIDs]=copyRun(this,runID,varargin)



    if this.isValidRunID(runID)
        if nargin==3
            appStr=varargin{1};
        else
            appStr='sdirun';
        end
        newRunID=this.sigRepository.copyRun(runID,appStr);
        runIndex=this.getRunCount;
        signalIDs=this.getAllSignalIDs(newRunID);
    else
        error(message('SDI:sdi:InvalidRunID'));
    end

    this.newRunIDs=newRunID;
    this.updateFlag=this.getRunName(newRunID);
end


