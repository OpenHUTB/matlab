function dsphdlCICDecimator(obj)




    CICDecimBlock='dsphdlfiltering2/CIC Decimator';
    verobj=obj.ver;
    blocks=obj.findLibraryLinksTo(CICDecimBlock);
    n2bReplaced=length(blocks);

    if n2bReplaced>0
        if isR2019aOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};

                subsys_msg=get_param(blk,'MaskType');
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end
        elseif isR2021bOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};
                if strcmp(get_param(blk,'DecimationSource'),'Input port')


                    maxdecimfactor=get_param(blk,'MaxDecimationFactor');
                    set_param(blk,'DecimationFactor',maxdecimfactor);









                end
            end
        end
    end
end
