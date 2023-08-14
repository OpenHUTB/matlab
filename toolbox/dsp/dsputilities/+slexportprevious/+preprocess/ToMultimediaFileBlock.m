function ToMultimediaFileBlock(obj)





    verobj=obj.ver;


    if isReleaseOrEarlier(verobj,'R2022a')
        tmmfBlocks=obj.findBlocksWithMaskType('To Multimedia File','fileType','OPUS');
        for ii=1:numel(tmmfBlocks)
            obj.replaceWithEmptySubsystem(tmmfBlocks{ii},'To Multimedia File');
        end
    end




    if isR2013bOrEarlier(verobj)&&~isR2012bOrEarlier(verobj)
        tmmfBlocks=obj.findBlocksWithMaskType('To Multimedia File',...
        'fileType','MPEG4');

        for cnt=1:numel(tmmfBlocks)
            streamSelected=get_param(tmmfBlocks{cnt},'streamSelection');
            if strcmp(streamSelected,'Audio only')
                set_param(tmmfBlocks{cnt},'fileType','M4A');
                set_param(tmmfBlocks{cnt},'streamSelection','Audio only');
            else
                set_param(tmmfBlocks{cnt},'fileType','AVI');
            end
        end
    end

    if isR2009bOrEarlier(verobj)
        tmmfBlocks=obj.findBlocksWithMaskType('To Multimedia File',...
        'fileType','WAV');

        for i=1:numel(tmmfBlocks)
            obj.replaceWithEmptySubsystem(tmmfBlocks{i},'To Multimedia File');
        end
    end
end
