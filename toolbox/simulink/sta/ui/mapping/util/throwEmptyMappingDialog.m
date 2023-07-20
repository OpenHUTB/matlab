function errorMsg=throwEmptyMappingDialog(mappingMode,modelName,fullChannel)







    switch lower(mappingMode)
    case 'index'
        mappingModeWarningStr=DAStudio.message('sl_sta:mapping:radioIndex');
    case 'signalname'
        mappingModeWarningStr=DAStudio.message('sl_inputmap:inputmap:radioSignalName');
    case 'blockname'
        mappingModeWarningStr=DAStudio.message('sl_inputmap:inputmap:radioBlockName');
    case 'blockpath'
        mappingModeWarningStr=DAStudio.message('sl_inputmap:inputmap:radioBlockPath');
    case 'custom'
        mappingModeWarningStr=DAStudio.message('sl_inputmap:inputmap:radioCustom');
    end

    errorMsg=DAStudio.message('sl_inputmap:inputmap:emptyMapping',mappingModeWarningStr,modelName);


    slwebwidgets.warndlgweb(fullChannel,...
    'sl_inputmap:inputmap:warnMapping',...
    errorMsg);