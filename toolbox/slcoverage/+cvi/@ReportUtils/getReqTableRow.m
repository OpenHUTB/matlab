function req=getReqTableRow(sfId,chartId)





    req=[];

    try
        model=Stateflow.ReqTable.internal.TableManager.getDataModel(chartId);
        spec=Stateflow.ReqTable.internal.TableManager.getSpecBlockFromModel(model);
        rows=spec.requirementsTable.getAllTableRowsRecursively();
        ssid=sf('get',sfId,'.ssIdNumber');





        req=rows([rows.preConditionSSId]==ssid);
        if isempty(req)
            req=rows([rows.postConditionSSId]==ssid);
        end
    catch SlCovMEx %#ok<NASGU>
    end
