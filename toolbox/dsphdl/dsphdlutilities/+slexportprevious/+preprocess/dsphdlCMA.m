function dsphdlCMA(obj)




    CMABlock='dsphdlmathfun2/Complex to Magnitude-Angle';
    verobj=obj.ver;
    blocks=obj.findLibraryLinksTo(CMABlock);
    n2bReplaced=length(blocks);

    if n2bReplaced>0
        if isR2014aOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};

                subsys_msg=get_param(blk,'MaskType');
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end
        end
    end
end
