function newStr=getSFInternalVarReplacementTextHelper(chartSfId,ssidStr)




    ssid=str2double(ssidStr);
    matchedRow=cvi.SFReqTable.getReqTableRowBySSId(chartSfId,ssid);
    assert(numel(matchedRow)==1);
    if matchedRow.isDefault
        newStr=message('Stateflow:requirementstable:Else').getString();
    else
        newStr=message('Slvnv:simcoverage:cvhtml:SFReqTablePredicate',matchedRow.idString).getString();
    end