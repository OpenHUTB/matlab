

function setInspectionStatus(datamgr,reportConfig)

    resultTableReader=datamgr.getReader('RESULTS');


    Status=slci.results.computeInspectionStatus(datamgr,reportConfig);
    resultTableReader.replaceObject('Status',Status);

end
