function schema=ttPaste(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:Paste';
    schema.icon='paste';
    schema.accelerator='Ctrl+V';
    schema.callback=@truthTablePasteCB;
    schema.refreshCategories={'GenericEvent:Clipboard'};
    schema.state='Enabled';
    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        schema.state='Disabled';
        return;
    end
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Paste');

    if any(strcmp(cbinfo.Context.TypeChain,'TruthTableEditorAutoChartContext'))
        schema.state='Disabled';
        return;
    end

    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(ttObjectId);
    selectionInfo=ttMan.TruthTableSelectionInfo;
    if isempty(selectionInfo.RowIndex)||isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Paste');
    elseif selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtPasteCellActionText');
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtPasteRowActionText');
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtPasteColumnActionText');
    end

    if selectionInfo.CanPaste
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
    schema.autoDisableWhen='Locked';

end

function truthTablePasteCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.TruthTable.TruthTableManager.paste(subviewerId);
end
