function bmRows=getBindableRowsFromMetadata(rowsData)



    bmRows=arrayfun(@(x)getBindableRowFromStruct(x),rowsData,'UniformOutput',false);
end

function row=getBindableRowFromStruct(metaStruct)

    if strcmp(metaStruct.bindableTypeChar,'DSM')
        sigMetaData=BindMode.SLDSMMetaData(metaStruct.bindableMetaData);
    elseif strcmp(metaStruct.bindableTypeChar,'VARIABLE')
        sigMetaData=BindMode.VariableMetaData(metaStruct.bindableMetaData);
    elseif strcmp(metaStruct.bindableTypeChar,'BUSLEAFSIGNAL')
        sigMetaData=BindMode.SLBusElementMetaData(metaStruct.bindableMetaData);
    else

        sigMetaData=BindMode.SLSignalMetaData(metaStruct.bindableMetaData);
    end
    enumType=BindMode.BindableTypeEnum.getEnumTypeFromChar(metaStruct.bindableTypeChar);
    row=BindMode.BindableRow(metaStruct.isConnected,enumType,metaStruct.bindableName,sigMetaData);
end