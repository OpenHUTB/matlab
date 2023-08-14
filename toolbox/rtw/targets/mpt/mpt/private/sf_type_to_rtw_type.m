function[rtwDataTypeName]=sf_type_to_rtw_type(dataTypeID)





















    dataTypeID=get_mpt_data_registry('dataType',dataTypeID);





    switch(dataTypeID)
    case 0
        rtwDataTypeName='real_T';
    case 1
        rtwDataTypeName='boolean_T';
    case 3
        rtwDataTypeName='uint8_T';
    case 4
        rtwDataTypeName='int8_T';
    case 5
        rtwDataTypeName='uint16_T';
    case 6
        rtwDataTypeName='int16_T';
    case 7
        rtwDataTypeName='uint32_T';
    case 8
        rtwDataTypeName='int32_T';
    case 9
        rtwDataTypeName='real32_T';
    case 10
        rtwDataTypeName='real_T';
    case 'boolean'
        rtwDataTypeName='boolean_T';
    case 'uint8'
        rtwDataTypeName='uint8_T';
    case 'int8'
        rtwDataTypeName='int8_T';
    case 'uint16'
        rtwDataTypeName='uint16_T';
    case 'int16'
        rtwDataTypeName='int16_T';
    case 'uint32'
        rtwDataTypeName='uint32_T';
    case 'int32'
        rtwDataTypeName='int32_T';
    case 'single'
        rtwDataTypeName='real32_T';
    case 'double'
        rtwDataTypeName='real_T';
    case 'uint64'
        rtwDataTypeName='uint64_T';
    case 'int64'
        rtwDataTypeName='int64_T';
    otherwise
        rtwDataTypeName='UNKNOWN SF DATATYPE';
    end

    return
