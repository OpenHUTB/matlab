
function setDefaultInspectionStatus(datamgr,reportConfig)
    resultsTable=datamgr.getReader('RESULTS');
    defStatus=reportConfig.defaultStatus;
    datamgr.beginTransaction();
    try
        resultsTable.insertObject('Status',defStatus);
        resultsTable.insertObject('VerificationStatus',defStatus);
        resultsTable.insertObject('ModelInspectionStatus',defStatus);
        resultsTable.insertObject('CodeInspectionStatus',defStatus);
        resultsTable.insertObject('InterfaceInspectionStatus',defStatus);
        resultsTable.insertObject('TempVarInspectionStatus',defStatus);
        resultsTable.insertObject('TraceabilityStatus',defStatus);
        resultsTable.insertObject('CodeTraceabilityStatus',defStatus);
        resultsTable.insertObject('ModelTraceabilityStatus',defStatus);
        resultsTable.insertObject('TypeReplacementStatus',defStatus);
        resultsTable.insertObject('UtilsStatus',defStatus);
        datamgr.commitTransaction();
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
end
