function[runID,runIndex,varargout]=createRunFromModel(~,mdl,varargin)



    [runID,runIndex,varargout{1:nargout-2}]=...
    Simulink.sdi.internal.import.createRunFromModel(mdl,varargin{:});
end