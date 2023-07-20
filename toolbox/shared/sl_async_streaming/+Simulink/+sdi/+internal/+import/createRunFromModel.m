function[runID,runIndex,varargout]=createRunFromModel(mdl,varargin)


    interface=Simulink.sdi.internal.Framework.getFramework();
    repo=sdi.Repository(1);
    [runID,runIndex,varargout{1:nargout-2}]=...
    interface.createRunFromModel(repo,mdl,varargin{:});
end