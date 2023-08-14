function[runID,runIndex,signalIDs]=createRun(~,varargin)


    [runID,runIndex,signalIDs]=Simulink.sdi.createRun(varargin{:});
end