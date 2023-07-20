function ToAudioDeviceBlock(obj)








    if isR2014aOrEarlier(obj.ver)

        blocks=obj.findBlocksWithMaskType('To Audio Device',...
        'outputNumUnderrunSamples','on');
        for i=1:numel(blocks)
            obj.replaceWithEmptySubsystem(obj,'To Audio Device - Output number of underrun samples');
        end


        obj.appendRule('<Block<SourceBlock|"dspsnks4/To Audio\nDevice"><outputNumUnderrunSamples:remove>>');
    end

end
