function BiquadFilter(obj)




    if isR2015bOrEarlier(obj.ver)




        blocks=obj.findBlocksWithMaskType('Biquad Filter',...
        'prodOutputMode','Inherit via internal rule');

        for blkIdx=1:numel(blocks)
            blk=blocks{blkIdx};
            obj.replaceWithEmptySubsystem(blk,...
            'Biquad Filter - Product output Inherit via internal rule',...
            DAStudio.message(...
            'dsp:dfiltblktoobj:InvalidProdOutputMode',...
            'Inherit via internal rule','Biquad Filter'));
        end
    end

end
