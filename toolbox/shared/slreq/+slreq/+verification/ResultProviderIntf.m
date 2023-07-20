classdef ResultProviderIntf<handle




    methods(Abstract)
        scanProject(this,project);
        [resultStatus,resultTimestamp,reason]=getResult(this,link);
        [runSuccess,resultStatus,resultTimestamp,reason]=runTest(this,link);
        navigate(this,link);
        id=getIdentifier(this);
        sourceTimestamp=getSourceTimestamp(this,link)
    end
end

