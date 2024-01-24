function AudioDeviceReader(obj)

    if isR2016bOrEarlier(obj.ver)

        blocks=obj.findBlocksWithMaskType('Audio Device Reader',...
        'Driver','WASAPI');

        for blkIdx=1:numel(blocks)
            blk=blocks{blkIdx};
            obj.replaceWithEmptySubsystem(blk,...
            getString(message('dsp:audioDeviceIO:WASAPI_ADR')));

            msgStr=DAStudio.message('dsp:audioDeviceIO:NewFeaturesNotAvailable');
            set_param(blk,'InitFcn',sprintf('error(''%s'')',msgStr));

        end
    end

end
