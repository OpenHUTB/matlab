classdef SLFramework<Simulink.sdi.internal.AbstractFramework





    methods
        [runID,runIndex,varargout]=createRunFromModel(~,obj,model,varargin);
        recordHarnessModelMetaData(~,obj,model,runID);
        out=isSLDVData(~,varValue);
    end


    properties(Access=private)
Listeners
    end

end
