function DynamicRange(obj)




    verobj=obj.ver;

    if isR2020bOrEarlier(verobj)


        DR_blocks=[obj.findBlocksWithMaskType('audio.simulink.DynamicRangeCompressor'),...
        obj.findBlocksWithMaskType('audio.simulink.DynamicRangeExpander'),...
        obj.findBlocksWithMaskType('audio.simulink.DynamicRangeLimiter'),...
        obj.findBlocksWithMaskType('audio.simulink.DynamicRangeGate')];
        numDRBlks=length(DR_blocks);
        if numDRBlks>0
            for blkIdx=1:numDRBlks
                blk=DR_blocks{blkIdx};
                params=get_param(blk,'MaskNames');
                if ismember('EnableSidechain',params)&&strcmp(get_param(blk,'EnableSidechain'),'on')
                    replaceWithEmpty(obj,blk)
                end
            end
        end
    end

    if isR2017aOrEarlier(verobj)



        DR_blocks=[obj.findBlocksWithMaskType('audio.simulink.DynamicRangeCompressor'),...
        obj.findBlocksWithMaskType('audio.simulink.DynamicRangeExpander'),...
        obj.findBlocksWithMaskType('audio.simulink.DynamicRangeLimiter'),...
        obj.findBlocksWithMaskType('audio.simulink.DynamicRangeGate')];
        numDRBlks=length(DR_blocks);

        if numDRBlks>0
            for blkIdx=1:numDRBlks
                blk=DR_blocks{blkIdx};
                numInp=1;

                params=get_param(blk,'MaskNames');
                if ismember('ThresholdPort',params)&&strcmp(get_param(blk,'ThresholdPort'),'on')
                    numInp=numInp+1;
                end
                if ismember('RatioPort',params)&&strcmp(get_param(blk,'RatioPort'),'on')
                    numInp=numInp+1;
                end
                if ismember('KneeWidthPort',params)&&strcmp(get_param(blk,'KneeWidthPort'),'on')
                    numInp=numInp+1;
                end
                if ismember('AttackTimePort',params)&&strcmp(get_param(blk,'AttackTimePort'),'on')
                    numInp=numInp+1;
                end
                if ismember('ReleaseTimePort',params)&&strcmp(get_param(blk,'ReleaseTimePort'),'on')
                    numInp=numInp+1;
                end
                if ismember('HoldTimePort',params)&&strcmp(get_param(blk,'HoldTimePort'),'on')
                    numInp=numInp+1;
                end

                if numInp>1
                    replaceWithEmpty(obj,blk)
                end
            end
        end

    end

end

function replaceWithEmpty(obj,blk)


    mt=get_param(blk,'MaskType');
    switch mt
    case 'audio.simulink.DynamicRangeCompressor'
        blkName=getString(message('audio:dynamicrange:CompressorIcon'));
    case 'audio.simulink.DynamicRangeExpander'
        blkName=getString(message('audio:dynamicrange:ExpanderIcon'));
    case 'audio.simulink.DynamicRangeLimiter'
        blkName=getString(message('audio:dynamicrange:LimiterIcon'));
    case 'audio.simulink.DynamicRangeGate'
        blkName=getString(message('audio:dynamicrange:NoiseGateIcon'));
    end

    obj.replaceWithEmptySubsystem(blk,blkName);

    msgStr=DAStudio.message('audio:dynamicrange:NewFeaturesNotAvailable');
    set_param(blk,'InitFcn',sprintf('error(''%s'')',msgStr));

end
