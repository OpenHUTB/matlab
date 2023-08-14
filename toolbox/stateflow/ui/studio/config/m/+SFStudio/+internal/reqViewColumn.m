function schema=reqViewColumn(userdata,cbinfo)
    schema=sl_toggle_schema;
    schema.autoDisableWhen='Locked';
    chartId=SFStudio.Utils.getChartId(cbinfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    spec=Stateflow.ReqTable.internal.TableManager.getReqTableModel(chartId);
    if selectionInfo.IsRequirementsTable
        table=spec.requirementsTable;
    else
        table=spec.assumptionsTable;
    end

    isSchemaEnabled=false;
    isSchemaChecked=false;
    switch userdata
    case 'duration'
        schema.callback=@reqViewDurationColumnCB;
        isSchemaEnabled=selectionInfo.CanToggleDuration&&selectionInfo.IsRequirementsTable;
        isSchemaChecked=table.durationVisible;

    case 'postcondition'
        schema.label=SLStudio.Utils.getMessage(cbinfo,...
        'stateflow_ui:studio:resources:ViewPostcondition');
        schema.callback=@reqViewPostconditionColumnCB;
        isSchemaEnabled=selectionInfo.CanTogglePostCondition&&selectionInfo.IsRequirementsTable;
        isSchemaChecked=table.postConditionVisible;

    case 'precondition'
        schema.label=SLStudio.Utils.getMessage(cbinfo,...
        'stateflow_ui:studio:resources:ViewPrecondition');
        schema.callback=@reqViewPreconditionColumnCB;
        isSchemaEnabled=selectionInfo.CanTogglePreCondition&&~selectionInfo.IsRequirementsTable;
        isSchemaChecked=table.preConditionVisible;

    case 'action'
        schema.label=SLStudio.Utils.getMessage(cbinfo,...
        'stateflow_ui:studio:resources:ViewAction');
        schema.callback=@reqViewActionCB;
        isSchemaEnabled=selectionInfo.CanToggleAction&&selectionInfo.IsRequirementsTable;
        isSchemaChecked=table.actionVisible;
    end

    if isSchemaEnabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end


    if isSchemaChecked
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.userdata='';
end


function reqViewDurationColumnCB(cbinfo,varargin)
    dispatchToContextMenuFcn(cbinfo,'durationColumnToggleCB',varargin{1});
end

function reqViewPreconditionColumnCB(cbinfo,varargin)
    dispatchToContextMenuFcn(cbinfo,'preConditionColumnToggleCB',varargin{1});
end


function reqViewPostconditionColumnCB(cbinfo,varargin)
    dispatchToContextMenuFcn(cbinfo,'postConditionColumnToggleCB',varargin{1});
end


function reqViewActionCB(cbinfo,varargin)
    dispatchToContextMenuFcn(cbinfo,'actionColumnToggleCB',varargin{1});
end
