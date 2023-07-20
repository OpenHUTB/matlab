function ChannelizerHDLOptimized(obj)




    ChannelizerBlock='dsp.HDLChannelizer';

    verobj=obj.ver;
    blocks=obj.findBlocksWithMaskType(ChannelizerBlock);

    if~isempty(blocks)
        if isR2016bOrEarlier(verobj)
            subsys_err=DAStudio.message('dsp:HDLChannelizer:BlockNotAvailableBefore17a',blocks{1});

            for i=1:numel(blocks)
                obj.replaceWithEmptySubsystem(blocks{i},[],subsys_err);
            end
        elseif isR2017bOrEarlier(verobj)
            subsys_err=DAStudio.message('dsp:HDLChannelizer:BlockBehaviorChangedFrom18a',blocks{1});
            warning('dsp:HDLChannelizer:BlockBehaviorChangedFrom18a',subsys_err);
        end
    end
end

