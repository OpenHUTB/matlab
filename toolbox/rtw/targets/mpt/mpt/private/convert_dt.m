function type=convert_dt(dType)




    if isempty(dType)==0
        switch(dType)
        case{'single','real32_T'}
            type='real32_T';
        case{'double','real64_T','real_T'}
            type='real_T';
        case{'int16','int16_T'}
            type='int16_T';
        case{'int8','int8_T'}
            type='int8_T';
        case{'int32','int32_T'}
            type='int32_T';
        case{'uint8','uint8_T'}
            type='uint8_T';
        case{'uint16','uint16_T'}
            type='uint16_T';
        case{'uint32','uint32_T'}
            type='uint32_T';
        case{'boolean'}
            type='boolean_T';
        case{'uint64','uint64_T'}
            type='uint64_T';
        case{'int64','int64_T'}
            type='int64_T';
        otherwise
            type=dType;
        end
    else
        type=dType;
    end
