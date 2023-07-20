function schema=HarnessPerspectivesMenu(fncname,cbinfo)

    fcn=str2func(fncname);
    schema=fcn(cbinfo);
end

function harness=GetHarnessInfo(cbinfo)
    ed=cbinfo.studio.App.getActiveEditor;
    pc=ed.getPerspectivesClient;
    option=pc.getActiveOption;
    target=option.getTarget;

    harnessOwner=target.ownerHandle;
    harnessName=target.harnessName;

    harness=sltest.harness.find(harnessOwner,'Name',harnessName);
end

function ClosePerspectives(cbinfo)
    ed=cbinfo.studio.App.getActiveEditor;
    pc=ed.getPerspectivesClient;
    pc.closePerspectives;
end


function schema=SimulationHarnessDuplicate(cbinfo)%#ok
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationHarnessDuplicate');
    schema.tag='Simulink:SimulationHarnessDuplicate';

    isHarnessBD=Simulink.harness.isHarnessBD(cbinfo.model.Name);

    if isHarnessBD||~isSLTInstalledAndLicensed
        schema.state='Hidden';
    elseif Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    schema.callback=@HarnessDuplicateCB;
    schema.autoDisableWhen='Busy';
end

function HarnessDuplicateCB(cbinfo)
    harness=GetHarnessInfo(cbinfo);
    ClosePerspectives(cbinfo);
    sltest.harness.clone(harness.ownerHandle,harness.name);
end


function schema=SimulationHarnessMerge(cbinfo)%#ok
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationHarnessMerge');
    schema.tag='Simulink:SimulationHarnessMerge';

    schema.state='Hidden';

    schema.callback=@HarnessMergeCB;
    schema.autoDisableWhen='Busy';
end

function HarnessMergeCB()


end


function schema=SimulationHarnessMove(cbinfo)%#ok
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationHarnessMove');
    schema.tag='Simulink:SimulationHarnessMove';

    isHarnessBD=Simulink.harness.isHarnessBD(cbinfo.model.Name);

    if isHarnessBD||~isSLTInstalledAndLicensed
        schema.state='Hidden';
    elseif~isHarnessMoveable(cbinfo)
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end

    schema.callback=@HarnessMoveCB;
    schema.autoDisableWhen='Busy';
end

function HarnessMoveCB(cbinfo)
    harness=GetHarnessInfo(cbinfo);
    ClosePerspectives(cbinfo);
    Simulink.harness.internal.move_with_confirmation(harness.ownerHandle,harness.name);
end


function schema=SimulationHarnessDelete(cbinfo)%#ok
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationHarnessDelete');
    schema.tag='Simulink:SimulationHarnessDelete';

    isHarnessBD=Simulink.harness.isHarnessBD(cbinfo.model.Name);

    if isHarnessBD
        schema.state='Hidden';
    elseif Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    schema.callback=@HarnessDeleteCB;
    schema.autoDisableWhen='Busy';
end

function HarnessDeleteCB(cbinfo)
    harness=GetHarnessInfo(cbinfo);
    ClosePerspectives(cbinfo);
    Simulink.harness.internal.delete_with_confirmation(harness.ownerHandle,harness.name);
end


function schema=SimulationHarnessProperties(cbinfo)%#ok
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationHarnessProperties');
    schema.tag='Simulink:SimulationHarnessProperties';

    if~isSLTInstalledAndLicensed
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end

    schema.callback=@HarnessPropertiesCB;
    schema.autoDisableWhen='Busy';
end

function HarnessPropertiesCB(cbinfo)
    harness=GetHarnessInfo(cbinfo);
    ClosePerspectives(cbinfo);
    Simulink.harness.dialogs.updateDialog.create(harness);
end

function ret=isHarnessMoveable(cbinfo)
    ret=0;
    harness=GetHarnessInfo(cbinfo);

    if~isempty(harness)&&...
        ~strcmp(harness.ownerType,'Simulink.BlockDiagram')&&...
        ishandle(harness.ownerHandle)&&...
        (strcmp(get_param(harness.ownerHandle,'BlockType'),'SubSystem')...
        ||strcmp(get_param(harness.ownerHandle,'BlockType'),'ModelReference'))&&...
        (strcmp(get_param(harness.ownerHandle,'LinkStatus'),'resolved')...
        ||strcmp(get_param(harness.ownerHandle,'LinkStatus'),'implicit'))&&...
        ~Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)
        ret=1;
    end
end
