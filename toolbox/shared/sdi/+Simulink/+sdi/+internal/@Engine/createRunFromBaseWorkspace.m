function[runID,runIdx,varargout]=createRunFromBaseWorkspace(~,runName,varNames,varargin)



    [runID,runIdx,sigs]=Simulink.sdi.internal.import.createRunFromBaseWorkspace(...
    runName,...
    varNames,...
    varargin{:});
    if nargout>2
        varargout{1}=sigs;
    end
end
