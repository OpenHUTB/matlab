function ScramblerBlocks(obj)

    if isR2015aOrEarlier(obj.ver)
        scramblerBlocks=findScramblerblocks(obj);

        for i=1:length(scramblerBlocks)
            blk=scramblerBlocks{i};
            hConvertStringPolysToNum(blk,'poly','ascending');
        end
    end

end


function scramblerBlocks=findScramblerblocks(obj)
    scramblerBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','on','regexp','on','MaskType','^Scrambler$|^Descrambler$');
end
