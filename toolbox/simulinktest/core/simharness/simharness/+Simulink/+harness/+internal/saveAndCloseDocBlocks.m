function saveAndCloseDocBlocks(ssBlock)


    if~(strcmpi(get_param(ssBlock,'BlockType'),'SubSystem'))
        return;
    end

    s=warning('off','Simulink:Libraries:MissingLibrary');
    sCleanup=onCleanup(@()warning(s));

    try

        docblocks=find_system(ssBlock,...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'IncludeCommented','on',...
        'FollowLinks','on',...
        'MaskType','DocBlock');

        if isempty(docblocks)
            return;
        end

        for i=1:length(docblocks)
            bh=docblocks(i);

            assert(ishandle(bh));


            blk=[get_param(bh,'Parent'),'/',get_param(bh,'name')];


            filename=docblock('getBlockFileName',blk);
            if exist(filename,'file')
                docblock('close_document',blk);
            end
        end
    catch ME
        Simulink.harness.internal.warn(ME);
    end
end
