function schema=reqDeleteColumn(cbinfo)



    schema=sl_action_schema;

    chartId=SFStudio.Utils.getChartId(cbinfo);
    schema.icon='deleteColumn';
    schema.accelerator='delete';
    schema.callback=@reqTableDeleteCB;
    schema.autoDisableWhen='Locked';
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    typeChain=cbinfo.Context.TypeChain;

    if~any(contains(typeChain,'COLUMN'))||~selectionInfo.IsRequirementsTable||...
        isempty(selectionInfo.ColumnIndex)
        schema.state='Disabled';
        return;
    end

    schema.state='Enabled';
end

function reqTableDeleteCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'deleteColumnCB'},false);
end
