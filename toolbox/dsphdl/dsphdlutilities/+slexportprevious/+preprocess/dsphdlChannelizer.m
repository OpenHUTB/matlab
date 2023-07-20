function dsphdlChannelizer(obj)




    ChannelizerBlock='dsphdlfiltering2/Channelizer';
    verobj=obj.ver;
    blocks=obj.findLibraryLinksTo(ChannelizerBlock);
    n2bReplaced=length(blocks);

    if n2bReplaced>0
        if isR2016bOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};

                subsys_msg=get_param(blk,'MaskType');
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end
        elseif isR2017bOrEarlier(verobj)
            subsys_err=DAStudio.message('dsp:HDLChannelizer:BlockBehaviorChangedFrom18a',blocks{1});
            warning('dsp:HDLChannelizer:BlockBehaviorChangedFrom18a',subsys_err);
        end
    end
end
