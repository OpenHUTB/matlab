function Reverberator(obj)

    verobj=obj.ver;

    if isR2019bOrEarlier(verobj)
        blocks=obj.findBlocksWithMaskType('audio.simulink.Reverberator');

        numDRBlks=length(blocks);

        if numDRBlks>0
            for blkIdx=1:numDRBlks
                blk=blocks{blkIdx};
                p1=strcmp(get_param(blk,'PreDelayPort'),'on');
                p2=strcmp(get_param(blk,'DiffusionPort'),'on');
                p3=strcmp(get_param(blk,'DecayFactorPort'),'on');
                p4=strcmp(get_param(blk,'HighFrequencyDampingPort'),'on');
                p5=strcmp(get_param(blk,'WetDryMixPort'),'on');
                p6=strcmp(get_param(blk,'HighCutFrequencyPort'),'on');

                if p1||p2||p3||p4||p5||p6
                    replaceWithEmpty(obj,blk)
                end
            end
        end

    end

end


function replaceWithEmpty(obj,blk)
    blkName=getString(message('audio:reverberator:Icon'));
    obj.replaceWithEmptySubsystem(blk,blkName);
    msgStr=DAStudio.message('audio:dynamicrange:NewFeaturesNotAvailable');
    set_param(blk,'InitFcn',sprintf('error(''%s'')',msgStr));

end
