function schema=reqDeleteRow(cbinfo)



    schema=sl_action_schema;

    chartId=SFStudio.Utils.getChartId(cbinfo);
    schema.icon='deleteRow';
    schema.accelerator='delete';
    schema.callback=@reqTableDeleteCB;
    schema.autoDisableWhen='Locked';
    typeChain=cbinfo.Context.TypeChain;

    schema.state='Enabled';
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    if isempty(selectionInfo.RowIndex)||~any(contains(typeChain,'ROW'))
        schema.state='Disabled';
    end

end

function reqTableDeleteCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'deleteRowCB'},false);

end
