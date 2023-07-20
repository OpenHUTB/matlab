function[runID,runIdx,varargout]=createRunFromNamesAndValues(~,varargin)



    [runID,runIdx,sigIDs]=Simulink.sdi.internal.import.createRunFromNamesAndValues(varargin{:});
    if nargout>2
        varargout{1}=sigIDs;
    end
end

