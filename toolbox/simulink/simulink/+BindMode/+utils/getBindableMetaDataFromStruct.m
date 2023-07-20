function result=getBindableMetaDataFromStruct(bindableType,metaDataStruct)
    switch bindableType
    case 'SLSIGNAL'
        result=BindMode.SLSignalMetaData(metaDataStruct);
    case 'SLPARAMETER'
        result=BindMode.SLParamMetaData(metaDataStruct);
    case 'SLPORT'
        result=BindMode.SLPortMetaData(metaDataStruct);
    case 'VARIABLE'
        result=BindMode.VariableMetaData(metaDataStruct);
    case 'SFCHART'
        result=BindMode.SFChartMetaData(metaDataStruct);
    case 'SFSTATE'
        result=BindMode.SFStateMetaData(metaDataStruct);
    case 'SFDATA'
        result=BindMode.SFDataMetaData(metaDataStruct);
    case 'EXPRESSION'
        result=BindMode.BindableMetaData(metaDataStruct);
    otherwise
        assert(false);
    end
end