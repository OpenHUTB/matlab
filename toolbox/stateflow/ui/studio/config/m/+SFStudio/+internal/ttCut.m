function schema=ttCut(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:Cut';
    schema.icon='cut';
    schema.accelerator='Ctrl+X';
    schema.callback=@truthTableCutCB;
    schema.refreshCategories={'interval#12','GenericEvent:Clipboard','GenericEvent:Select','SelectionChanged'};
    schema.state='Enabled';
    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        schema.state='Disabled';
        return;
    end
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Cut');

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
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Cut');
    elseif selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtCutCellActionText');
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtCutRowActionText');
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtCutColumnActionText');
    end

    schema.state='Enabled';
    schema.autoDisableWhen='Busy';
    schema.autoDisableWhen='Locked';

end

function truthTableCutCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.TruthTable.TruthTableManager.cut(subviewerId);
end
