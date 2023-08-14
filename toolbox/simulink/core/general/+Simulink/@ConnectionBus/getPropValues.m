function propValue=getPropValues(this,propName)






    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(this.TargetUserData)
        [token,rem]=strtok(propName,'.');
        if strcmp(token,'TargetUserData')
            customPropName=rem(2:end);
            propValue=this.TargetUserData.getPropValue(customPropName);
            return;
        end
    end

    switch lower(propName)
    case 'description'
        propValue=this.Description;
    otherwise
        propValue='';
    end
