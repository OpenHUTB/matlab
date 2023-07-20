function[flag,errMsg]=isValidDataType(~,paramName,paramValue,positiveFlag,integerFlag)



    errMsg=[];
    if nargin<4
        positiveFlag=false;
    end
    if nargin<5
        integerFlag=false;
    end
    flag=isreal(paramValue)&&isscalar(paramValue)&&...
    isa(paramValue,'double')&&~isinf(paramValue)&&~isnan(paramValue);
    if positiveFlag
        flag=flag&&(paramValue>0);
        id='dspshared:SpectrumAnalyzer:InvalidDataTypePositive';
    else
        id='dspshared:SpectrumAnalyzer:InvalidDataType';
    end
    if~flag&&integerFlag
        if(round(paramValue)-paramValue)~=0
            id='dspshared:SpectrumAnalyzer:InvalidDataTypeInteger';
        end
    end
    if~flag
        errMsg=getString(message(id,paramName));
    end

end
