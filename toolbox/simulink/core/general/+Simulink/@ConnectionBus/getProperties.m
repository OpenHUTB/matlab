function props=getProperties(this)






    props={'Description'};

    if slfeature('SLDataDictionarySetUserData')>0&&~isempty(this.TargetUserData)
        customProps=this.TargetUserData.getPossibleProperties;
        customFullProps=strcat('TargetUserData.',customProps);
        props=[props,customFullProps'];
    end