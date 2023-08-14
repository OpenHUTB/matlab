function dsphdlNCO(obj)




    NCOBlock='dsphdlsigops2/NCO';
    verobj=obj.ver;
    blocks=obj.findLibraryLinksTo(NCOBlock);
    n2bReplaced=length(blocks);

    if n2bReplaced>0
        if isR2012bOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};

                subsys_msg=get_param(blk,'MaskType');
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end
        end
    end
end
