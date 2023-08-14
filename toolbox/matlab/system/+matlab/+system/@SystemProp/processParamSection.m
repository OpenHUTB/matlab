function dtInfo=processParamSection(obj,dtInfo,prefix)












    modeStr=[prefix,'DataType'];
    typeStr=['Custom',prefix,'DataType'];

    switch obj.(modeStr)
    case 'Custom'
        nt=obj.(typeStr);
        if strcmpi(nt.Scaling,'unspecified')
            modeValue=1;
        else
            modeValue=0;
        end

    case{'Same as input',...
        'Same as first input',...
        'Same word length as input',...
        'Same word length as first input',...
        'Same as output'}
        modeValue=2;

    case 'Same as product'
        modeValue=3;

    case 'Same as accumulator'
        modeValue=4;

    case{'Full precision','Internal rule'}
        modeValue=5;

    otherwise
        modeValue=-2;
    end

    if modeValue==0
        wlValue=obj.(typeStr).WordLength;
        flValue=obj.(typeStr).FractionLength;
    elseif modeValue==1
        wlValue=obj.(typeStr).WordLength;
        flValue=0;
    else
        wlValue=0;
        flValue=0;
    end

    dtInfo.(modeStr)=modeValue;
    dtInfo.([prefix,'WordLength'])=wlValue;
    dtInfo.([prefix,'FracLength'])=flValue;
end
