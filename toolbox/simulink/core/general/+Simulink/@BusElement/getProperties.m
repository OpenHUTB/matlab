function props=getProperties(this)





    props={'Name'};
    props{end+1}='DataType';
    props{end+1}='Complexity';
    props{end+1}='Dimensions';
    props{end+1}='DimensionsMode';

    props{end+1}='SampleTime';

    props{end+1}='Min';
    props{end+1}='Max';

    props{end+1}='Unit';

    props{end+1}='Description';

    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(this.TargetUserData)
        customProps=this.TargetUserData.getPossibleProperties;
        customFullProps=strcat('TargetUserData.',customProps);
        props=[props,customFullProps'];
    end
