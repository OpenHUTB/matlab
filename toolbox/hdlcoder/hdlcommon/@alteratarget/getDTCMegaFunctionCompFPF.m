function[altMegaFunctionName,extraDir,status]=getDTCMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)




    assert(~isEqual(inType,outType));


    if~inType.isFloatType
        [wl,fl,sign]=extractFixPtParts(inType);
        convertType='fixed_to_floating';
        if outType.isDoubleType
            nameSuffix=sprintf('fixpt_s%d_w%d_f%d_to_double',sign,wl,fl);
        else
            assert(outType.isSingleType);
            nameSuffix=sprintf('fixpt_s%d_w%d_f%d_to_single',sign,wl,fl);
        end
    else
        [wl,fl,sign]=extractFixPtParts(outType);
        convertType='floating_to_fixed';
        if inType.isDoubleType
            nameSuffix=sprintf('double_to_fixpt_s%d_w%d_f%d',sign,wl,fl);
        else
            assert(inType.isSingleType);
            nameSuffix=sprintf('single_to_fixpt_s%d_w%d_f%d',sign,wl,fl);
        end
    end
    if sign
        signStr='1';
    else
        signStr='0';
    end
    fxptWidth=sprintf('--component-param=fxpt_width=%d',wl);
    fxptFraction=sprintf('--component-param=fxpt_fraction=%d',fl);
    fxptSign=sprintf('--component-param=fxpt_sign=%s',signStr);
    specificArgs=[fxptWidth,' ',fxptFraction,' ',fxptSign];


    fc=hdlgetparameter('FloatingPointTargetConfiguration');
    typeStr=inType.getTargetCompDataTypeStr(outType,true);
    ipName='convert';
    ips=fc.IPConfig.getIPSettings(ipName,typeStr);
    if(isempty(ips))
        typeStr=inType.getTargetCompDataTypeStr(outType,false);
        assert(~isempty(fc.IPConfig.getIPSettings(ipName,typeStr)));
    end

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithOneInputFPF(targetCompInventory,typeStr,className,convertType,latencyFreq,isFreqDriven,alteratarget.Convert,dryRun,deviceInfo,specificArgs,nameSuffix);




    function[wl,fl,sign]=extractFixPtParts(aType)
        assert(~aType.isFloatType);
        wl=aType.WordLength;
        fl=-aType.FractionLength;
        assert(fl>=0);
        sign=aType.Sign;


