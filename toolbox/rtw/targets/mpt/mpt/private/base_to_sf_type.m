function sfType=base_to_sf_type(baseType)












    sfType=[];

    switch(baseType)
    case 'boolean_T'
        sfType='boolean';
    case{'uint8_T','uint8'}
        sfType='uint8';
    case{'int8_T','int8'}
        sfType='int8';
    case{'uint16_T','uint16'}
        sfType='uint16';
    case{'int16_T','int16'}
        sfType='int16';
    case{'uint32_T','uint32'}
        sfType='uint32';
    case{'int32_T','int32'}
        sfType='int32';
    case 'real32_T'
        sfType='single';
    case 'real_T'
        sfType='double';
    case{'uint64_T','uint64'}
        sfType='uint64';
    case{'int64_T','int64'}
        sfType='int64';
    otherwise
        sfType=[];
    end
