function dtInfo=getFixptDataTypeInfo(obj,prefixes,nomiscparams)





















































    if nargin<2
        matlab.system.internal.error('MATLAB:system:prefixesParamNotProvided');
    end
    if nargin<3
        nomiscparams=false;
    end
    dtInfo=[];
    for ii=1:length(prefixes)
        dtInfo=processParamSection(obj,dtInfo,prefixes{ii});
    end

    if~nomiscparams








        roundMode=obj.RoundingMethod;
        overflowMode=obj.OverflowAction;
        switch lower(roundMode)
        case 'ceiling'
            dtInfo.RoundingMethod=1;
        case 'convergent'
            dtInfo.RoundingMethod=2;
        case 'floor'
            dtInfo.RoundingMethod=3;
        case 'nearest'
            dtInfo.RoundingMethod=4;
        case 'round'
            dtInfo.RoundingMethod=5;
        case 'simplest'
            dtInfo.RoundingMethod=6;
        otherwise

            dtInfo.RoundingMethod=7;
        end


        if strcmpi(overflowMode,'wrap')
            dtInfo.OverflowAction=1;
        else
            dtInfo.OverflowAction=2;
        end
    else
        dtInfo.RoundingMethod=0;
        dtInfo.OverflowAction=0;
    end
end
