function[paramStatus,description]=sldvParamTableEnable(cs,~)


    description='not available when the feature is not enabled';

    isRefConfigSet=isempty(cs.getModel);
    flag=(slavteng('feature','RefConfigSetSLDV')~=0);




    if~flag&&isRefConfigSet
        paramStatus=configset.internal.data.ParamStatus.ReadOnly;
    else
        paramStatus=configset.internal.data.ParamStatus.Normal;
    end

end

