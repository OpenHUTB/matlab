classdef modelWordLengthInfo<handle


































    methods(Static)
        function wordLengths=wordLengthsProductionHardware(modelName)
            wordLengths=getNativeWordLengths(modelName,true);
        end

        function wordLengths=wordLengthsCurrentCodeGenHardware(modelName)

            isProduction=isCurrentCodeGenProduction(modelName);
            wordLengths=getNativeWordLengths(modelName,isProduction);
        end

        function isNative=isWordLengthProductionHardware(modelName,wordLength)
            wlv=fixed.internal.modelWordLengthInfo.wordLengthsProductionHardware(modelName);
            isNative=any(wlv==wordLength);
        end

        function isNative=isWordLengthCurrentCodeGenHardware(modelName,wordLength)
            wlv=fixed.internal.modelWordLengthInfo.wordLengthsCurrentCodeGenHardware(modelName);
            isNative=any(wlv==wordLength);
        end

    end
end

function b=isCurrentCodeGenProduction(modelName)

    paramValue=get_param(modelName,'ProdEqTarget');

    b=strcmp('on',paramValue);
end

function wordLengths=getNativeWordLengths(modelName,isProduction)

    if isProduction
        prefix='Prod';
    else
        prefix='Target';
    end

    useLongParamName=sprintf('%sLongLongMode',prefix);
    useLongParamValue=get_param(modelName,useLongParamName);
    useLong=strcmp('on',useLongParamValue);

    Suffices={
'Char'
'Short'
'Int'
'Long'
'LongLong'
    };

    n=numel(Suffices)-(~useLong);

    wordLengths=zeros(1,n);

    for i=1:n
        suffix=Suffices{i};
        paramName=sprintf('%sBitPer%s',prefix,suffix);
        wordLengths(i)=get_param(modelName,paramName);
    end

    wordLengths=unique(wordLengths);
end

