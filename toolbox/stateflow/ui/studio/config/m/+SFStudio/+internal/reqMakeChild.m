function schema=reqMakeChild(cbinfo)
    schema=sl_action_schema;
    schema.icon='appendTransitionColumn';
    schema.autoDisableWhen='Locked';
    schema.callback=@reqMakeChildCB;
    schema.icon='makeChildReq';

    chartId=SFStudio.Utils.getChartId(cbinfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    if~selectionInfo.CanDemote
        schema.state='Disabled';
    end
end


function reqMakeChildCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,...
    'evalContextMenuFunctions',{'demoteRowCB'},false);
end