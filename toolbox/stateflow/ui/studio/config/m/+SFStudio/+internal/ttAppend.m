function schema=ttAppend(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:Append';
    schema.icon='appendRow';
    schema.callback=@truthTableAppendCB;
    schema.autoDisableWhen='Locked';
    schema.state='Enabled';
    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        schema.state='Disabled';
        return;
    end
    schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtAppendRowActionText');

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




        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtAppendColumnActionText');
        schema.icon='appendTransitionColumn';
        schema.state='Enabled';
        schema.callback=@truthTableAppendColumnCB;
        if strcmp(typeChain{1,1},'ActionTable')
            schema.state='Disabled';
        end
        return;
    end

    schema.state='Enabled';

    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(ttObjectId);
    selectionInfo=ttMan.TruthTableSelectionInfo;
    if selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtAppendRowActionText');
        schema.icon='appendRow';
        schema.state='Disabled';
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtAppendRowActionText');
        schema.icon='appendRow';
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtAppendColumnActionText');
        schema.icon='appendTransitionColumn';
    end
end

function truthTableAppendCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(subviewerId);
    ttMan.dispatchUIRequest('appendNewItem',{},false);
end

function truthTableAppendColumnCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(subviewerId);
    ttMan.dispatchUIRequest('appendNewItem',{'COLUMN'},false);
end
