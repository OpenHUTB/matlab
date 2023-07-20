function schema=reqMakeParent(cbinfo)
    schema=sl_action_schema;
    schema.icon='makeParentReq';
    schema.autoDisableWhen='Locked';
    schema.callback=@reqMakeParentCB;

    chartId=SFStudio.Utils.getChartId(cbinfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    if~selectionInfo.CanPromote
        schema.state='Disabled';
    end
end


function reqMakeParentCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,...
    'evalContextMenuFunctions',{'promoteRowCB'},false);
end