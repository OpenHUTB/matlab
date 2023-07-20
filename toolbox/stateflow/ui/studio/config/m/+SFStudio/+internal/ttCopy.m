function schema=ttCopy(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:Copy';
    schema.icon='copy';
    schema.accelerator='Ctrl+C';
    schema.callback=@truthTableCopyCB;
    schema.refreshCategories={'interval#12','GenericEvent:Clipboard','GenericEvent:Select','SelectionChanged'};
    schema.state='Enabled';
    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        schema.state='Disabled';
        return;
    end
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Copy');

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
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Copy');
    elseif selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtCopyCellActionText');
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtCopyRowActionText');
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtCopyColumnActionText');
    end

    schema.state='Enabled';
    schema.autoDisableWhen='Never';
end

function truthTableCopyCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.TruthTable.TruthTableManager.copy(subviewerId);
end
