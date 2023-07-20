function props=getProperties(this)





    props={'Name','Type','Description'};

    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(this.TargetUserData)
        customProps=this.TargetUserData.getPossibleProperties;
        customFullProps=strcat('TargetUserData.',customProps);
        props=[props,customFullProps'];
    end
