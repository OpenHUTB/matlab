function[algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo,rtwSettingsInfo]=get_word_sizes(blockOrModelH,varargin)










    isSimTarget=true;
    if(nargin>1)
        isSimTarget=varargin{1};
    end

    modelHandle=bdroot(blockOrModelH);
    configSet=getActiveConfigSet(modelHandle);

    if(isSimTarget)










        targetHwInfo.hwDeviceType=false;
        targetHwInfo.signedDivRounding=0;
        targetHwInfo.divByZeroProtectionNotWanted=false;
        targetHwInfo.signedShiftIsArithmetic=true;
        targetHwInfo.enableLongLong=false;
    else

        devType=get_param(configSet,'TargetHWDeviceType');
        targetHwInfo.hwDeviceType=strncmp(devType,'ASIC',4);
        targetHwInfo.signedDivRounding=getSignedDivRoundingSetting(configSet,'TargetIntDivRoundTo');
        targetHwInfo.divByZeroProtectionNotWanted=false;
        targetHwInfo.signedShiftIsArithmetic=getSignedShiftIsArithmeticSetting(configSet,'TargetShiftRightIntArith');
        targetHwInfo.enableLongLong=getEnableLongLongSetting(configSet,'TargetLongLongMode');
    end





    devType=get_param(configSet,'ProdHWDeviceType');
    algorithmHwInfo.hwDeviceType=strncmp(devType,'ASIC',4);

    algorithmHwInfo.signedDivRounding=getSignedDivRoundingSetting(configSet,'ProdIntDivRoundTo');
    algorithmHwInfo.divByZeroProtectionNotWanted=false;
    algorithmHwInfo.signedShiftIsArithmetic=getSignedShiftIsArithmeticSetting(configSet,'ProdShiftRightIntArith');
    algorithmHwInfo.enableLongLong=getEnableLongLongSetting(configSet,'ProdLongLongMode');






    rtwSettingsInfo.genFunctionFixptDiv=true;
    rtwSettingsInfo.genFunctionFixptMul=true;
    rtwSettingsInfo.genFunctionFixptMisc=true;



    rtwSettingsInfo.castFloat2IntPortableWrapping=true;
    rtwSettingsInfo.mapNaN2IntZero=true;
    rtwSettingsInfo.supportNonFinites=true;

    useDivisionForNetSlopeComputationStr=get_param(configSet,'UseDivisionForNetSlopeComputation');
    rtwSettingsInfo.correctNetSlopeViaDiv=0;
    switch useDivisionForNetSlopeComputationStr
    case 'UseDivisionForReciprocalsOfIntegersOnly'
        rtwSettingsInfo.correctNetSlopeViaDiv=1;
    case 'on'
        rtwSettingsInfo.correctNetSlopeViaDiv=2;
    end
    rtwSettingsInfo.useFloatMulNetSlope=strcmp('on',get_param(configSet,'UseFloatMulNetSlope'));

    algorithmWordsizes=getWordSizes(modelHandle,'ProdHWWordLengths');


    if(isSimTarget)
        hi=hostcpuinfo();
        targetWordsizes=hi(4:8);
        if(hi(9)==0)
            targetHwInfo.enableLongLong=false;
        else
            targetHwInfo.enableLongLong=true;
        end
    else
        targetWordsizes=getWordSizes(modelHandle,'TargetHWWordLengths');
    end

end

function signedDivRounding=getSignedDivRoundingSetting(configSet,paramName)
    try
        divRndStr=get_param(configSet,paramName);
        if strcmpi(divRndStr,'ZERO')
            signedDivRounding=1;
        elseif strcmpi(divRndStr,'FLOOR')
            signedDivRounding=2;
        else
            signedDivRounding=0;
        end
    catch
        signedDivRounding=0;
    end
end

function signedShiftIsArithmetic=getSignedShiftIsArithmeticSetting(configSet,paramName)

    try
        signedShiftIsArithmetic=strcmp('on',get_param(configSet,paramName));
    catch
        signedShiftIsArithmetic=true;
    end
end

function enableLongLong=getEnableLongLongSetting(configSet,paramName)
    try
        enableLongLong=strcmp('on',get_param(configSet,paramName));
    catch
        enableLongLong=false;
    end
end

function wordSizes=getWordSizes(modelHandle,paramName)
    wordLengthStr=get_param(modelHandle,paramName);
    wordSizes=zeros(1,4);
    [s,e]=regexp(wordLengthStr,'\d+');
    assert(length(s)>=5);
    num=length(str2num(wordLengthStr));%#ok<ST2NM>
    for i=1:num
        nBitsStr=wordLengthStr(s(i):e(i));
        nBits=sscanf(nBitsStr,'%d');
        assert(~isempty(nBits));
        wordSizes(i)=nBits;
    end
end
