function schema=SimulinkTestMenu(fncname,cbinfo)



    fcn=str2func(fncname);
    schema=fcn(cbinfo);
end


function schema=SimulationHarnessMenu(cbinfo)%#ok<*DEFNU> % ( menu, cbinfo )
    schema=sl_container_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationHarnessMenu');
    schema.tag='Simulink:SimulationHarnessMenu';
    schema.generateFcn=@generateSimulationHarnessMenuChildren;

    isHarnessBD=Simulink.harness.isHarnessBD(cbinfo.model.Name);
    if slreq.utils.selectionHasMarkup(cbinfo)
        sel=[];
    else
        sel=cbinfo.getSelection();
    end
    isIncompatSel=~isempty(sel)&&((numel(sel)~=1)||...
    ~Simulink.harness.internal.isValidHarnessOwnerObject(sel));

    if~isIncompatSel&&(numel(sel)~=1)&&...
        Simulink.internal.isArchitectureModel(get_param(cbinfo.model.name,'Handle'))
        ownerGraphHandle=SLStudio.Utils.getDiagramHandle(cbinfo);
        isIncompatSel=~Simulink.harness.internal.isValidHarnessOwnerObject(get_param(ownerGraphHandle,'Object'));
    end

    isMWLib=false;
    if Simulink.harness.internal.isMathWorksLibrary(get_param(cbinfo.model.name,'Handle'))
        isMWLib=true;
    end

    if~isSLTInstalledAndLicensed()||Simulink.harness.internal.isCodeContextBD(cbinfo.model.name)

        schema.state='Hidden';
    elseif isHarnessBD&&cbinfo.isContextMenu

        schema.state='Hidden';
    elseif isIncompatSel&&cbinfo.isContextMenu
        schema.state='Hidden';
    elseif isMWLib

        schema.state='Hidden';
    else
        schema.state='Enabled';
    end

    schema.autoDisableWhen='Busy';
end


function schema=SimulationAndTestManagerMenu(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SimulationAndTestManagerMenu';
    schema.label=DAStudio.message('Simulink:studio:SimulationAndTestManagerMenu');
    schema.callback=@sltest.internal.menus.Callbacks.openSTM;

    if~isSLTInstalledAndLicensed()

        schema.state='Hidden';
    elseif bdIsLibrary(cbinfo.model.Name)
        isHarnessBD=false;
        if strcmp(get_param(cbinfo.model.Name,'Lock'),'off')||...
            sltest.internal.menus.isMenuActionEnabled(cbinfo,isHarnessBD)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    else
        schema.state='Enabled';
    end
    schema.autoDisableWhen='Busy';
end


function children=generateSimulationHarnessMenuChildren(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    children={...
    im.getAction('Simulink:CreateSimulationHarnessForBD')...
    ,im.getAction('Simulink:CreateSimulationHarnessForBlock')...
    ,im.getAction('Simulink:ImportSimulationHarnessForBD')...
    ,im.getAction('Simulink:ImportSimulationHarnessForBlock')...
    ,'separator'...
    ,im.getAction('Simulink:ListSimulationHarness')...
    ,im.getAction('Simulink:PushSimulationHarness')...
    ,im.getAction('Simulink:RebuildSimulationHarness')...
    ,'separator'...
    ,im.getAction('Simulink:ConvertEmbeddedHarnesses')...
    ,im.getAction('Simulink:ConvertExternalHarnesses')...
    ,im.getAction('Simulink:ExportHarnessesToIndependent')...
    ,im.getAction('Simulink:ExportHarnessToIndependent')...
    ,im.getAction('Simulink:CompareSimulationHarness')...
    ,'separator'...
    ,im.getAction('Simulink:UpdateSimulationHarness')...
    };
end

function schema=CreateSimulationHarnessForBlock(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CreateSimulationHarnessForBlock';
    schema.label=DAStudio.message('Simulink:studio:CreateSimulationHarnessForBlock','');

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)

        schema.state='Hidden';
    else
        [sel,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);
        if isCompatSingleSel
            schema.label=DAStudio.message('Simulink:studio:CreateSimulationHarnessForBlock',['''',sel.Name,'''']);
            if sltest.internal.menus.isMenuActionEnabled(cbinfo,false)
                schema.state='Enabled';
            else
                schema.state='Disabled';
            end
        else
            schema.state='Hidden';
        end
    end

    schema.autoDisableWhen='Never';
    schema.callback=@sltest.internal.menus.Callbacks.createHarnessForBlock;
end

function schema=CreateSimulationHarnessForBD(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CreateSimulationHarnessForBD';
    schema.label=DAStudio.message('Simulink:studio:CreateSimulationHarnessForBD');

    [~,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);
    isInBlock=isa(get_param(gcs,'Object'),'Simulink.SubSystem');

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)

        schema.state='Hidden';
    elseif(isCompatSingleSel||isInBlock)&&cbinfo.isContextMenu


        schema.state='Hidden';
    elseif sltest.internal.menus.isMenuActionEnabled(cbinfo,false)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';
    schema.callback=@sltest.internal.menus.Callbacks.createHarnessForBD;
end

function schema=ListSimulationHarness(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:ListSimulationHarness');
    schema.tag='Simulink:ListSimulationHarness';

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end
    schema.callback=@sltest.internal.menus.Callbacks.openHarnessListDialog;
    schema.autoDisableWhen='Never';
end

function schema=ConvertEmbeddedHarnesses(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:ConvertEmbeddedHarnesses');
    schema.tag='Simulink:ConvertEmbeddedHarnesses';

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)
        schema.state='Hidden';
    else
        if~cbinfo.isContextMenu&&sltest.internal.menus.isMenuActionEnabled(cbinfo,false)
            harnesses=Simulink.harness.internal.getHarnessList(cbinfo.model.Name,'all');
            if~isempty(harnesses)&&...
                ~Simulink.harness.internal.isSavedIndependently(cbinfo.model.Name)
                schema.state='Enabled';
            else
                schema.state='Hidden';
            end
        else
            schema.state='Hidden';
        end
    end

    schema.callback=@sltest.internal.menus.Callbacks.convertToExternal;
    schema.autoDisableWhen='Busy';
end

function schema=ConvertExternalHarnesses(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:ConvertExternalHarnesses');
    schema.tag='Simulink:ConvertExternalHarnesses';

    fileName=get_param(cbinfo.model.Name,'FileName');
    [~,~,ext]=fileparts(fileName);

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)||...
        strcmp(ext,'.mdl')
        schema.state='Hidden';
    else
        if~cbinfo.isContextMenu&&sltest.internal.menus.isMenuActionEnabled(cbinfo,false)
            harnesses=Simulink.harness.internal.getHarnessList(cbinfo.model.Name,'all');
            if~isempty(harnesses)&&...
                Simulink.harness.internal.isSavedIndependently(cbinfo.model.Name)
                schema.state='Enabled';
            else
                schema.state='Hidden';
            end
        else
            schema.state='Hidden';
        end
    end

    schema.callback=@sltest.internal.menus.Callbacks.convertToInternal;
    schema.autoDisableWhen='Busy';
end

function schema=ExportHarnessesToIndependent(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:ExportHarnessesToIndependent');
    schema.tag='Simulink:ExportHarnessesToIndependent';

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)
        schema.state='Hidden';
    else
        if~cbinfo.isContextMenu&&sltest.internal.menus.isMenuActionEnabled(cbinfo,false)
            harnesses=Simulink.harness.internal.getHarnessList(cbinfo.model.Name,'all');
            if~isempty(harnesses)
                schema.state='Enabled';
            else
                schema.state='Hidden';
            end
        else
            schema.state='Hidden';
        end
    end

    schema.callback=@sltest.internal.menus.Callbacks.convertAllToIndependent;
    schema.autoDisableWhen='Busy';
end


function schema=ExportHarnessToIndependent(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:ExportHarnessToIndependent');
    schema.tag='Simulink:ExportHarnessToIndependent';

    if~Simulink.harness.isHarnessBD(cbinfo.model.Name)
        schema.state='Hidden';
    elseif sltest.internal.menus.isMenuActionEnabled(cbinfo,true)
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

    schema.callback=@sltest.internal.menus.Callbacks.convertToIndependent;
    schema.autoDisableWhen='Busy';
end


function schema=ImportSimulationHarnessForBlock(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ImportSimulationHarnessForBlock';
    schema.label=DAStudio.message('Simulink:studio:ImportSimulationHarnessForBlock','');

    [sel,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);
    if isCompatSingleSel
        schema.label=DAStudio.message('Simulink:studio:ImportSimulationHarnessForBlock',['''',sel.Name,'''']);
        if sltest.internal.menus.isMenuActionEnabled(cbinfo,false)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    else
        schema.state='Hidden';
    end

    schema.autoDisableWhen='Never';
    schema.callback=@sltest.internal.menus.Callbacks.importHarnessForBlock;
end

function schema=ImportSimulationHarnessForBD(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ImportSimulationHarnessForBD';
    schema.label=DAStudio.message('Simulink:studio:ImportSimulationHarnessForBD');

    [~,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);
    isInBlock=isa(get_param(gcs,'Object'),'Simulink.SubSystem');
    bd=get_param(bdroot,'object');

    if bd.isLibrary

        schema.state='Hidden';
    elseif(isCompatSingleSel||isInBlock)&&cbinfo.isContextMenu


        schema.state='Hidden';
    elseif sltest.internal.menus.isMenuActionEnabled(cbinfo,false)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';
    schema.callback=@sltest.internal.menus.Callbacks.importHarnessForBD;
end

function schema=PushSimulationHarness(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:PushSimulationHarness');
    schema.tag='Simulink:PushSimulationHarness';
    if Simulink.harness.isHarnessBD(cbinfo.model.Name)
        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(cbinfo.model.Name);
        if bdIsLibrary(harnessInfo.model)
            schema.state='Hidden';
        else
            schema.state='Enabled';
        end
    else
        schema.state='Hidden';
    end
    schema.callback=@sltest.internal.menus.Callbacks.pushHarness;
    schema.autoDisableWhen='Busy';
end


function schema=RebuildSimulationHarness(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:RebuildSimulationHarness');
    schema.tag='Simulink:RebuildSimulationHarness';

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)
        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(cbinfo.model.Name);
        if bdIsLibrary(harnessInfo.model)
            schema.state='Hidden';
        else
            schema.state='Enabled';
        end
    else
        schema.state='Hidden';
    end
    schema.callback=@sltest.internal.menus.Callbacks.rebuildHarness;
    schema.autoDisableWhen='Busy';
end

function schema=CompareSimulationHarness(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:CompareSimulationHarness');
    schema.tag='Simulink:CompareSimulationHarness';
    schema.state='Enabled';

    if~Simulink.harness.isHarnessBD(cbinfo.model.Name)

        schema.state='Hidden';
    end
    schema.callback=@sltest.internal.menus.Callbacks.harnessCheck;
    schema.autoDisableWhen='Busy';
end

function schema=UpdateSimulationHarness(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:UpdateSimulationHarness');
    schema.tag='Simulink:UpdateSimulationHarness';

    if Simulink.harness.isHarnessBD(cbinfo.model.Name)
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

    schema.callback=@sltest.internal.menus.Callbacks.openHarnessPropertiesDialog;
    schema.autoDisableWhen='Busy';
end


