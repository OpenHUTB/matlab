function result=checkSerDesBlocksAction(taskObj)




    result={};%#ok<NASGU>

    maObj=taskObj.MAobj;
    system=bdroot(maObj.System);


    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubTitle(DAStudio.message('serdes:advisor:upgradeActionSubTitle'));
    ft.setColTitles({'Block','Parameter','Upgrade change'});

    changes=upgradeSerDesBlocks(system,'dryRun','off');
    if~isempty(changes)
        ft.setSubResultStatusText(DAStudio.message('serdes:advisor:blocksUpgraded'));
        for chgIdx=1:length(changes)
            ft.addRow(changes{chgIdx});
        end
    end

    ft.setSubBar(0);
    result=ft;
end
