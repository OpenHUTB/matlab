function FromMultimediaFileBlock(obj)





    verobj=obj.ver;


    if isReleaseOrEarlier(verobj,'R2022a')
        tmmfBlocks=obj.findBlocksWithMaskType('From Multimedia File');
        for ii=1:numel(tmmfBlocks)
            filename=get_param(tmmfBlocks{ii},'inputFilename');
            if endsWith(filename,'.opus','IgnoreCase',true)
                obj.replaceWithEmptySubsystem(tmmfBlocks{ii},'From Multimedia File');
            end
        end
    end
end
