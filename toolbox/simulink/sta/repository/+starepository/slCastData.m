function castedData=slCastData(data,castToDataType)



    if~isa(data,'double')
        DAStudio.error('sl_sta_repository:data_type_cast:NonDoubleInput');
    end

    if~ischar(castToDataType)&&~isstring(castToDataType)
        DAStudio.error('sl_sta_repository:data_type_cast:NonCharDataTypeInput');
    end
    castToDataType=convertStringsToChars(castToDataType);
    if any(strcmpi(castToDataType,{'double','single','int8','uint8','int16','uint16','int32','uint32'}))
        castedData=starepository.slDataTypeCast(data,castToDataType);
    else

        try
            fcn_handle=str2func(castToDataType);
            castedData=fcn_handle(data);
        catch
            DAStudio.error('sl_sta_repository:data_type_cast:ConversionNotPossible',castToDataType);
        end

    end

end

