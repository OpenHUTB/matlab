function propValue=getPropValues(this,propName)




    propValue='';

    switch lower(propName)
    case 'name'
        propValue=this.Name;
    case 'type'
        propValue=this.Type;
    case 'description'
        propValue=this.Description;
    end

    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(this.TargetUserData)
        [token,rem]=strtok(propName,'.');
        if strcmp(token,'TargetUserData')
            customPropName=rem(2:end);
            propValue=this.TargetUserData.getPropValue(customPropName);
            return;
        end
    end
