function[paramStatus,description]=sldvStrictEnhancedMCDCDisplay(~,~)




    description='not available when the feature is not enabled';

    flag=(slavteng('feature','PathBasedTestgen')~=0);

    if flag
        paramStatus=configset.internal.data.ParamStatus.Normal;
    else
        paramStatus=configset.internal.data.ParamStatus.UnAvailable;
    end

end

