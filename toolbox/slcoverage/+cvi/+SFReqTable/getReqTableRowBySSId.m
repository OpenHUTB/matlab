function matchedRow=getReqTableRowBySSId(chartSfId,ssid)




    spec=Stateflow.ReqTable.internal.TableManager.getReqTableModel(chartSfId);
    matchedRow=spec.getImplicationFromSSId(ssid);