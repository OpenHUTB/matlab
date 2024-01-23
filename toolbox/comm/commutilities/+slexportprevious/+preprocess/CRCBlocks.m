function CRCBlocks(obj)

    if isR2015aOrEarlier(obj.ver)

        crcBlocks=findCRCblocks(obj);

        for i=1:length(crcBlocks)
            blk=crcBlocks{i};
            hConvertStringPolysToNum(blk,'genPoly','descending');
        end
    end

end


function crcBlocks=findCRCblocks(obj)
    crcBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
    'IncludeCommented','on','regexp','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'MaskType','^General CRC Generator$|^General CRC Syndrome Detector$');

end
