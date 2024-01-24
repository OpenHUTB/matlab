function CepstralFeatureExtractor(obj)

    verobj=obj.ver;

    if isR2018bOrEarlier(verobj)
        CF_blocks=obj.findBlocksWithMaskType('audio.simulink.CepstralFeatureExtractor');

        numDRBlks=length(CF_blocks);

        if numDRBlks>0
            for blkIdx=1:numDRBlks
                blk=CF_blocks{blkIdx};
                fbank=get_param(blk,'FilterBank');

                if strcmp(fbank,'Gammatone')
                    replaceWithEmpty(obj,blk)
                end
            end
        end

    end

end


function replaceWithEmpty(obj,blk)
    blkName=getString(message('audio:cepstralFeatureExtractor:BlockIcon'));
    obj.replaceWithEmptySubsystem(blk,blkName);
    msgStr=DAStudio.message('audio:dynamicrange:NewFeaturesNotAvailable');
    set_param(blk,'InitFcn',sprintf('error(''%s'')',msgStr));

end
