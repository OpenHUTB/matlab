function visibilityInfo=getVarPropertyVisibility(varScope,varPortType)




    isExternalVariable=strcmpi(varScope,'External');
    isInOutVariable=strcmpi(varScope,'InOut');

    isPortableVariable=~isExternalVariable&&ismember(varScope,{'Input';'Output';'InOut';'Input Symbol';'Output Symbol'});
    isPortIndexShown=isPortableVariable&&~strcmpi(varPortType,'Hidden');
    isDataTypeSizeInitValueShown=~isExternalVariable&&~isInOutVariable;

    visibilityInfo.PortType=slplc.utils.logical2OnOff(isPortableVariable);
    visibilityInfo.PortIndex=slplc.utils.logical2OnOff(isPortIndexShown);
    visibilityInfo.DataType=slplc.utils.logical2OnOff(isDataTypeSizeInitValueShown);
    visibilityInfo.DataSize=slplc.utils.logical2OnOff(isDataTypeSizeInitValueShown);
    visibilityInfo.InitialValue=slplc.utils.logical2OnOff(isDataTypeSizeInitValueShown);
end