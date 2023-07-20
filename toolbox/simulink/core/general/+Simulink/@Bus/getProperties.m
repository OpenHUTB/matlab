function props=getProperties(this)





    props={'DataScope','HeaderFile','Alignment'};
    if sl('busUtils','NDIdxBusUI')
        props{end+1}='PreserveElementDimensions';
    end
    props{end+1}='Description';

    if slfeature('SLDataDictionarySetUserData')>0&&~isempty(this.TargetUserData)
        customProps=this.TargetUserData.getPossibleProperties;
        customFullProps=strcat('TargetUserData.',customProps);
        props=[props,customFullProps'];
    end