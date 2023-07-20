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
    case 'datascope'
        propValue=this.DataScope;
    case 'headerfile'
        propValue=this.HeaderFile;
    case 'alignment'
        propValue=num2str(this.Alignment);
    case 'preserveelementdimensions'
        if sl('busUtils','NDIdxBusUI')
            propValue=num2str(this.PreserveElementDimensions);
        else
            propValue='';
        end
    case 'description'
        propValue=this.Description;
    otherwise
        propValue='';
    end


