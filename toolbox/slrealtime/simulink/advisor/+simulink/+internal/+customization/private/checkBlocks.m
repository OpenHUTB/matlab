function blockUpgTable=checkBlocks(model)




    changes={};


    udpConfigBlocks=findSLRTObsoleteBlocks(model,'UDPConfig');



    obsoleteUDPBlocks=findSLRTObsoleteBlocks(model,'OtherUDP');

    if~isempty(udpConfigBlocks)
        changes{end+1}={udpConfigBlocks,getString(message('slrealtime:advisor:udpConfig'))};
    end

    if~isempty(obsoleteUDPBlocks)
        changes{end+1}={obsoleteUDPBlocks,getString(message('slrealtime:advisor:obsoleteUDP'))};
    end


    scopes=slrealtime.internal.logging.UpgradeUtils.findScopes(model);
    if~isempty(scopes)
        for i=1:length(scopes)
            type=slrealtime.internal.logging.UpgradeUtils.getScopeType(scopes{i});
            switch type
            case 'Target'
                changes{end+1}={scopes{i},DAStudio.message('slrealtime:advisor:replaceWithLiveStream')};%#ok<AGROW>
            case 'File'
                changes{end+1}={scopes{i},DAStudio.message('slrealtime:advisor:replaceWithFileLog')};%#ok<AGROW>
            case 'Host'
                changes{end+1}={scopes{i},DAStudio.message('slrealtime:advisor:replaceWithLiveStream')};%#ok<AGROW>
            otherwise
                error('Invalid Use Case');
            end
        end
    end


    ptpBlocks=findSLRTObsoleteBlocks(model,'PTP');
    if~isempty(ptpBlocks)
        changes{end+1}={ptpBlocks,DAStudio.message('slrealtime:advisor:ptpBlock')};
    end


    j1939Blocks=findSLRTObsoleteBlocks(model,'J1939');
    if~isempty(j1939Blocks)
        changes{end+1}={j1939Blocks,getString(message('slrealtime:advisor:j1939Block'))};
    end


    fpgaBlocks=findSLRTObsoleteBlocks(model,'FPGA');
    if~isempty(fpgaBlocks)
        changes{end+1}={fpgaBlocks,getString(message('slrealtime:advisor:fpgaBlock'))};
    end


    overloadBehaviorBlocks=findSLRTObsoleteBlocks(model,'Overload');
    if~isempty(overloadBehaviorBlocks)
        changes{end+1}={overloadBehaviorBlocks,getString(message('slrealtime:advisor:overloadBehaviorBlock'))};
    end


    irqBlocks=findSLRTObsoleteBlocks(model,'IRQ');
    if~isempty(irqBlocks)
        changes{end+1}={irqBlocks,getString(message('slrealtime:advisor:irqBlock'))};
    end


    fromFileBlocks=findSLRTObsoleteBlocks(model,'FromFile');
    if~isempty(fromFileBlocks)
        changes{end+1}={fromFileBlocks,getString(message('slrealtime:advisor:fromFileBlock'))};
    end



    foundBlocks={};
    for i=1:length(changes)
        foundBlocks=[foundBlocks;changes{i}{1}];%#ok<AGROW>
    end
    allSLRTObsolete=findSLRTObsoleteBlocks(model,'All');
    otherBlocks=setdiff(allSLRTObsolete,foundBlocks);
    if~isempty(otherBlocks)
        changes{end+1}={otherBlocks,getString(message('slrealtime:advisor:OtherObsoleteBlock'))};
    end



    blockUpgTable=ModelAdvisor.FormatTemplate('TableTemplate');
    blockUpgTable.setSubTitle(DAStudio.message('slrealtime:advisor:upgradeCheckSubTitle'));
    blockUpgTable.setColTitles({DAStudio.message('slrealtime:advisor:blockName'),DAStudio.message('slrealtime:advisor:action')});

    if isempty(changes)
        blockUpgTable.setSubResultStatus('Pass');
        blockUpgTable.setSubResultStatusText(DAStudio.message('slrealtime:advisor:noBlocksToUpgrade'));
    else
        blockUpgTable.setSubResultStatus('Fail');
        blockUpgTable.setSubResultStatusText(DAStudio.message('slrealtime:advisor:blocksToUpgrade'));
        for chgIdx=1:length(changes)
            blockUpgTable.addRow(changes{chgIdx});
        end
    end


