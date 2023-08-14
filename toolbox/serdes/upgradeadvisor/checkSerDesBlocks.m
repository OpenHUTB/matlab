function result=checkSerDesBlocks(system)




    result={};%#ok<NASGU>

    maObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    status=false;
    maObj.setCheckResultStatus(status);


    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubTitle(DAStudio.message('serdes:advisor:upgradeCheckSubTitle'));
    ft.setColTitles({'Block','Parameter','Required upgrade'});

    changes=upgradeSerDesBlocks(system,'dryRun','on');
    if isempty(changes)
        maObj.setCheckResultStatus(true);
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('serdes:advisor:noBlocksToUpgrade'));
        maObj.setActionEnable(false);
        maObj.setCheckResultStatus(true);
    else
        ft.setSubResultStatus('Warn');
        maObj.setCheckResultStatus(false);
        ft.setSubResultStatusText(DAStudio.message('serdes:advisor:blocksToUpgrade'));
        for chgIdx=1:length(changes)
            ft.addRow(changes{chgIdx});
        end
        maObj.setActionEnable(true);
        maObj.setCheckResultStatus(false);
    end

    ft.setSubBar(0);
    result=ft;
end
