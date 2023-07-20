function schema=ttDelete(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:Delete';
    schema.icon='delete';
    schema.accelerator='delete';
    schema.callback=@truthTableDeleteCB;
    schema.autoDisableWhen='Locked';
    schema.state='Enabled';
    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        schema.state='Disabled';
        return;
    end
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Delete');

    if any(strcmp(cbinfo.Context.TypeChain,'TruthTableEditorAutoChartContext'))
        schema.state='Disabled';
        return;
    end

    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(ttObjectId);
    typeChain=ttMan.TruthTableSelectionInfo.TypeChain;
    if size(typeChain,2)<2
        schema.state='Disabled';
        return;
    end

    selectionInfo=ttMan.TruthTableSelectionInfo;
    if isempty(selectionInfo.RowIndex)||isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Delete');
    elseif selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtClearActionText');
        schema.icon='clear';
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtDeleteRowActionText');
        schema.icon='deleteRow';
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtDeleteColumnActionText');
        schema.icon='deleteColumn';
    end

    schema.state='Enabled';
end

function truthTableDeleteCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(subviewerId);
    ttMan.dispatchUIRequest('deleteSelection',{},false);
end
