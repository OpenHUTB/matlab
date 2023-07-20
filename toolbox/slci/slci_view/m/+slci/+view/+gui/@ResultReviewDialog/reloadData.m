



function reloadData(obj)

    obj.populateInspectionSummaryData();
    obj.populateBlockData();
    obj.populateCodeSliceData();
    obj.populateInterfaceData();
    obj.populateTempVarData();
    obj.populateUtilFuncData();

    obj.populateStatus();

    obj.sendData();
