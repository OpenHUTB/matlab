function OctaveFilter(obj)

    verobj=obj.ver;

    blocks={};
    if isR2016bOrEarlier(verobj)
        blocks=obj.findBlocksWithMaskType('audio.simulink.OctaveFilter',...
        'BandwidthType','2/3 octave');
    end

    if isR2017aOrEarlier(verobj)

        blocks=[blocks;...
        obj.findBlocksWithMaskType('audio.simulink.OctaveFilter',...
        'CenterFrequencyPort','on')];
    end

    for blkIdx=1:numel(blocks)
        blk=blocks{blkIdx};
        obj.replaceWithEmptySubsystem(blk,getString(message('audio:octave:BlockTitle')));
        msgStr=DAStudio.message('audio:octave:NewFeaturesNotAvailable');
        set_param(blk,'InitFcn',sprintf('error(''%s'')',msgStr));
    end

end
