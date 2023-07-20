function result=upgradeBlocks(model)




    result={};
    foundBlocks={};


    udpConfigBlocks=findSLRTObsoleteBlocks(model,'UDPConfig');
    if~isempty(udpConfigBlocks)
        obsoleteUDPEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:udpConfigNotUpgraded'));
        obsoleteUDPEntry.setColor('Warn');
        result{end+1}=obsoleteUDPEntry;
        foundBlocks=[foundBlocks;udpConfigBlocks];
    end

    obsoleteUDPBlocks=findSLRTObsoleteBlocks(model,'OtherUDP');
    if~isempty(obsoleteUDPBlocks)
        obsoleteUDPEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:obsoleteUDPNotUpgraded'));
        obsoleteUDPEntry.setColor('Warn');
        result{end+1}=obsoleteUDPEntry;
        foundBlocks=[foundBlocks;obsoleteUDPBlocks];
    end


    if~isempty(slrealtime.internal.logging.UpgradeUtils.findScopes(model))
        slrealtime.internal.logging.UpgradeUtils.convertScopes(model);
        scopesEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:scopesUpgraded'));
        scopesEntry.setColor('Pass');
        result{end+1}=scopesEntry;
    end


    obsoletePTPBlocks=findSLRTObsoleteBlocks(model,'PTP');
    if~isempty(obsoletePTPBlocks)
        ptpEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:ptpBlocksNotUpgraded'));
        ptpEntry.setColor('Warn');
        result{end+1}=ptpEntry;
        foundBlocks=[foundBlocks;obsoletePTPBlocks];
    end


    obsoleteJ1939Blocks=findSLRTObsoleteBlocks(model,'J1939');
    if~isempty(obsoleteJ1939Blocks)
        j1939Entry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:j1939BlocksNotUpgraded'));
        j1939Entry.setColor('Warn');
        result{end+1}=j1939Entry;
        foundBlocks=[foundBlocks;obsoleteJ1939Blocks];
    end


    obsoleteFPGABlocks=findSLRTObsoleteBlocks(model,'FPGA');
    if~isempty(obsoleteFPGABlocks)
        fpgaEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:fpgaBlocksNotUpgraded'));
        fpgaEntry.setColor('Warn');
        result{end+1}=fpgaEntry;
        foundBlocks=[foundBlocks;obsoleteFPGABlocks];
    end


    obsoleteOverloadBlocks=findSLRTObsoleteBlocks(model,'Overload');
    if~isempty(obsoleteOverloadBlocks)
        overloadEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:overloadBehaviorBlocksNotUpgraded'));
        overloadEntry.setColor('Warn');
        result{end+1}=overloadEntry;
        foundBlocks=[foundBlocks;obsoleteOverloadBlocks];
    end


    obsoleteIRQBlocks=findSLRTObsoleteBlocks(model,'IRQ');
    if~isempty(obsoleteIRQBlocks)
        irqEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:irqBlocksNotUpgraded'));
        irqEntry.setColor('Warn');
        result{end+1}=irqEntry;
        foundBlocks=[foundBlocks;obsoleteIRQBlocks];
    end


    obsoleteFromFileBlocks=findSLRTObsoleteBlocks(model,'FromFile');
    if~isempty(obsoleteFromFileBlocks)
        fromFileEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:fromFileBlocksNotUpgraded'));
        fromFileEntry.setColor('Warn');
        result{end+1}=fromFileEntry;
        foundBlocks=[foundBlocks;obsoleteFromFileBlocks];
    end



    allSLRTObsolete=findSLRTObsoleteBlocks(model,'All');
    if~isempty(setdiff(allSLRTObsolete,foundBlocks))
        otherBlocksEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:OtherObsoleteBlocksNotUpgraded'));
        otherBlocksEntry.setColor('Warn');
        result{end+1}=otherBlocksEntry;
    end
