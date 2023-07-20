function allPropsToDisp=getPropertyListToDisp(this)











    assert(isscalar(this));



    subclassProps=properties(this);
    superclassProps=properties('Simulink.Data');



    subclassUniqueProps=setdiff(subclassProps,superclassProps,'stable');
    mainProps=[superclassProps;subclassUniqueProps];



    featureSpecificProps={};

    if slfeature('SLDataDictionarySetUserData')>0
        featureSpecificProps{end+1}='TargetUserData';
    end

    allPropsToDisp=[mainProps;featureSpecificProps];



    if~this.LoggingInfo.DataLogging
        allPropsToDisp(allPropsToDisp=="LoggingInfo")=[];
    end

    if strcmp(this.SamplingMode,'auto')
        allPropsToDisp(allPropsToDisp=="SamplingMode")=[];
    end

end

