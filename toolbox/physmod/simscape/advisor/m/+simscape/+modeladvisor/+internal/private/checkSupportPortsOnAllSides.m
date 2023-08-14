function obj=checkSupportPortsOnAllSides(objType)



    checkId='checkSupportPortsOnAllSides';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,@actionCallBack,...
    context='None',...
    checkedByDefault=true);
end

function result=checkCallback(system)
    mdlName=get_param(system,'Name');

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(mdlName);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setColTitles({lGetMsg('Column1'),lGetMsg('Column2')});

    blocks=simscape.modeladvisor.internal.findBlocks(mdlName);

    if isempty(blocks)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(lGetMsg('PassStatus'));
        ft.setSubBar(false);
        mdladvObj.setCheckResultStatus(true);
    else
        ft.setSubResultStatus('Warn');
        status=ModelAdvisor.Paragraph;
        status.addItem(lGetMsg('WarnStatus1'));
        actionsOne=ModelAdvisor.List();
        actionsOne.setType('Bulleted');
        upgradeAllBlocks=lGetMsg('UpgradeAllBlocks');
        actionsOne.addItem([lGetMsg('WarnAction1'),sprintf('<a href="matlab: simscape.modeladvisor.internal.update_all_blocks(''%s'') "> %s </a>',system,upgradeAllBlocks)]);
        actionTwo=ModelAdvisor.List();
        actionTwo.setType('Bulleted');
        status.addItem(actionsOne);
        actionTwo.addItem(lGetMsg('WarnAction2'));
        status.addItem(actionTwo);
        ft.setSubResultStatusText(status);
        upgrade=lGetMsg('Upgrade');

        for blockIdx=1:length(blocks)
            thisBlock=blocks{blockIdx};
            sids=Simulink.ID.getSID(blocks{blockIdx});
            ft.addRow({thisBlock,sprintf('<a href="matlab: simscape.modeladvisor.internal.update_block(''%s'') "> %s </a>',sids,upgrade)});
        end

        mdladvObj.setCheckResultStatus(false);
    end
    result={ft};
end

function result=actionCallBack(taskObj)

    system=get_param(taskObj.MAObj.System,'Name');
    simscape.modeladvisor.internal.update_all_blocks(system);
    result=lGetMsg('ActionInformation');
end

function msg=lGetMsg(id)

    messageCatalog='physmod:simscape:advisor:modeladvisor:checkSupportPortsOnAllSides';
    msg=DAStudio.message([messageCatalog,':',id]);
end

