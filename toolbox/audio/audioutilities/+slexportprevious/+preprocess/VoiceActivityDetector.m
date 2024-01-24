function VoiceActivityDetector(obj)

    verobj=obj.ver;

    if isR2019bOrEarlier(verobj)
        blocks=obj.findBlocksWithMaskType('audio.simulink.VoiceActivityDetector');

        numDRBlks=length(blocks);

        if numDRBlks>0
            for blkIdx=1:numDRBlks
                blk=blocks{blkIdx};
                p1=strcmp(get_param(blk,'SilenceToSpeechProbabilityPort'),'on');
                p2=strcmp(get_param(blk,'SpeechToSilenceProbabilityPort'),'on');

                if p1||p2
                    replaceWithEmpty(obj,blk)
                end
            end
        end

    end

end


function replaceWithEmpty(obj,blk)
    blkName=getString(message('audio:vad:BlockIcon'));
    obj.replaceWithEmptySubsystem(blk,blkName);
    msgStr=DAStudio.message('audio:dynamicrange:NewFeaturesNotAvailable');
    set_param(blk,'InitFcn',sprintf('error(''%s'')',msgStr));

end
