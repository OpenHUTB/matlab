

function inspectionStatus=computeInspectionStatus(datamgr,reportConfig)


    incompReader=datamgr.getReader('INCOMPATIBILITY');
    ck=incompReader.getKeys();
    for k=1:numel(ck)
        cObj=incompReader.getObject(ck{k});
        if cObj.getIsFatal()
            inspectionStatus=slci.internal.ReportConfig.getTopErrorStatus();
            return;
        end
    end


    errorReader=datamgr.getReader('ERROR');
    ek=errorReader.getKeys();
    if~isempty(ek)
        inspectionStatus=...
        slci.internal.ReportConfig.getTopErrorStatus();
        return;
    end


    resultTableReader=datamgr.getReader('RESULTS');
    vStatus=resultTableReader.getObject('VerificationStatus');
    tStatus=resultTableReader.getObject('TraceabilityStatus');
    uStatus=resultTableReader.getObject('UtilsStatus');
    inspectionStatus=combineStatus(reportConfig,vStatus,tStatus,uStatus);

end


function out=combineStatus(reportConfig,varargin)
    out=reportConfig.defaultStatus;
    for i=1:(nargin-1)
        status=reportConfig.getMainStatus(varargin{i});
        out=reportConfig.getHeaviestStatus(status,out);
    end
end