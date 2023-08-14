function FromAudioDeviceBlock(obj)








    if isR2014aOrEarlier(obj.ver)

        blocks=obj.findBlocksWithMaskType('From Audio Device',...
        'outputNumOverrunSamples','on');
        for i=1:numel(blocks)
            obj.replaceWithEmptySubsystem(blocks{i},'From Audio Device - Output number of overrun samples');
        end


        obj.appendRule('<Block<SourceBlock|"dspsrcs4/From Audio\nDevice"><outputNumOverrunSamples:remove>>');
    end

end
