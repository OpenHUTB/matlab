function dsphdlFarrowRateConverter(obj)




    FarrowBlock='dsphdlsigops2/Farrow Rate Converter';
    verobj=obj.ver;
    blocks=obj.findLibraryLinksTo(FarrowBlock);
    n2bReplaced=length(blocks);

    if n2bReplaced>0

        if isR2021bOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};

                subsys_msg=get_param(blk,'MaskType');
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end

        elseif isReleaseOrEarlier(verobj,'R2022a')
            for i=1:n2bReplaced
                blk=blocks{i};

                rateType=hdlslResolve('RateChangeDataTypeStr',blk);
                if rateType.SignednessBool==false
                    coder.internal.warning('dsphdl:FarrowRateConverter:UnsignedExport');
                end
            end
        end


    end
end
