function schema=reqAppendRow(userdata,cbinfo)
    schema=sl_action_schema;

    schema.icon='appendRow';
    schema.autoDisableWhen='Locked';

    if isempty(userdata)
        schema.callback=@reqTableAppendCB;
        return
    end
    chartId=SFStudio.Utils.getChartId(cbinfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);

    isAppendAnd=strcmp(userdata,'and');
    isAppendOr=strcmp(userdata,'or');
    isappend=isAppendAnd||...
    isAppendOr||strcmp(userdata,'requirement');
    canAppendFromCell=selectionInfo.CanAppendRowFromCell&&contains(selectionInfo.TypeChain,"CELL");
    canAppendFromRow=selectionInfo.CanAppendRowToEnd&&isappend;


    if(canAppendFromCell&&~isAppendAnd&&~isAppendOr)||canAppendFromRow
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    switch userdata
    case 'requirement'
        schema.callback=@reqTableAppendCB;
        if selectionInfo.IsRequirementsTable
            schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddRequirement');
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddRequirementDescription');
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddAssumption');
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddAssumptionDescription');
        end

    case 'child'
        schema.callback=@reqTableAppendChildCB;
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddChild');
        if selectionInfo.IsRequirementsTable
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddChildRequirementDescription');
        else
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddChildAssumptionDescription');
        end

        if selectionInfo.CanAppendChild
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    case 'and'
        schema.callback=@reqTableAppendAndCB;
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddAnd');
        if selectionInfo.IsRequirementsTable
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddAndRequirementDescription');
        else
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddAndAssumptionDescription');
        end
    case 'or'
        schema.callback=@reqTableAppendOrCB;
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddOr');
        if selectionInfo.IsRequirementsTable
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddOrRequirementDescription');
        else
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddOrAssumptionDescription');
        end
    case 'else'
        schema.callback=@reqTableAppendDefaultCB;
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddElse');

        if selectionInfo.CanAppendDefaultRowToEnd
            schema.state='Enabled';
        end

        if selectionInfo.IsRequirementsTable
            schema.tooltip=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:AddDefaultRequirementDescription');
        end
    end
end

function reqTableAppendCB(cbInfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbInfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(subviewerId);
    if contains(selectionInfo.TypeChain,'CELL')
        dispatchToContextMenuFcn(cbInfo,'appendRowFromCellCB');
    else
        dispatchToContextMenuFcn(cbInfo,'appendRowToEnd','RegularRow');
    end
end

function reqTableAppendChildCB(cbInfo)
    dispatchToContextMenuFcn(cbInfo,'appendSubRowCB');
end

function reqTableAppendAndCB(cbInfo)
    dispatchToContextMenuFcn(cbInfo,'appendRowToEnd','AndRow');
end

function reqTableAppendOrCB(cbInfo)
    dispatchToContextMenuFcn(cbInfo,'appendRowToEnd','OrRow');
end

function reqTableAppendDefaultCB(cbinfo)
    dispatchToContextMenuFcn(cbinfo,'appendRowToEnd','DefaultRow');
end
