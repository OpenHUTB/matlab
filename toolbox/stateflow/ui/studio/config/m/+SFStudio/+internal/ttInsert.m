function schema=ttInsert(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:Insert';
    schema.icon='insertRow';
    schema.callback=@truthTableInsertCB;
    schema.autoDisableWhen='Locked';
    schema.state='Enabled';
    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        schema.state='Disabled';
        return;
    end
    schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtInsertRowActionText');

    if any(strcmp(cbinfo.Context.TypeChain,'TruthTableEditorAutoChartContext'))
        schema.state='Disabled';
        return;
    end
    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(ttObjectId);
    typeChain=ttMan.TruthTableSelectionInfo.TypeChain;
    if size(typeChain,2)<1
        schema.state='Disabled';
        return;
    elseif size(typeChain,2)==1




        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtAppendRowActionText');
        schema.icon='appendRow';
        schema.state='Enabled';
        schema.callback=@truthTableAppendRowCB;
        return;
    end


    schema.state='Enabled';

    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(ttObjectId);
    selectionInfo=ttMan.TruthTableSelectionInfo;
    if selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtInsertRowActionText');
        schema.icon='insertRow';
        schema.state='Disabled';
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtInsertRowActionText');
        schema.icon='insertRow';
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtInsertColumnActionText');
        schema.icon='insertTransitionColumn';
    end
end

function truthTableInsertCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(subviewerId);
    ttMan.dispatchUIRequest('insertNewItem',{},false);
end

function truthTableAppendRowCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(subviewerId);
    ttMan.dispatchUIRequest('appendNewItem',{'ROW'},false);
end
