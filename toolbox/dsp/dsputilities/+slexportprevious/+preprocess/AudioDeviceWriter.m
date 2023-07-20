function AudioDeviceWriter(obj)




    if isR2016bOrEarlier(obj.ver)




        blocks=obj.findBlocksWithMaskType('Audio Device Writer',...
        'Driver','WASAPI');

        for i=1:numel(blocks)
            obj.replaceWithEmptySubsystem(blocks{i},getString(message('dsp:audioDeviceIO:WASAPI_ADW')));
        end

    end

end
