function dsphdlUpsampler(obj)




    UpsamplerBlock='dsphdlsigops2/Upsampler';
    verobj=obj.ver;
    blocks=obj.findLibraryLinksTo(UpsamplerBlock);
    n2bReplaced=length(blocks);

    if n2bReplaced>0
        if isR2022aOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};

                subsys_msg=get_param(blk,'MaskType');
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end
        end
    end
end
