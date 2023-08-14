function typeInfo=getTypeInfo(configSet,isCompiledWithPWS)







    if isCompiledWithPWS

        wordLengths=rtwhostwordlengths;
        typeInfo=rtw.connectivity.ExtendedHardwareConfig.buildTypeInfo(...
        [wordLengths.CharNumBits,wordLengths.ShortNumBits,wordLengths.IntNumBits,wordLengths.LongNumBits,wordLengths.LongLongNumBits],...
        wordLengths.WordSize,...
        wordLengths.FloatNumBits,...
        wordLengths.DoubleNumBits);
    else

        bitSizeParams={'TargetBitPerChar','TargetBitPerShort','TargetBitPerInt','TargetBitPerLong'};
        if strcmp(get_param(configSet,'TargetLongLongMode'),'on')
            bitSizeParams{end+1}='TargetBitPerLongLong';
        end
        typeInfo=rtw.connectivity.ExtendedHardwareConfig.buildTypeInfo(...
        cellfun(@(x)get_param(configSet,x),bitSizeParams),...
        get_param(configSet,'TargetWordSize'),...
        get_param(configSet,'TargetBitPerFloat'),...
        get_param(configSet,'TargetBitPerDouble'));
    end

end
