function type=tmw_to_baseguiname(dType)




    if isempty(dType)==0
        switch(dType)
        case{'single','real32_T'},
            type='single';
        case{'double','real64_T','real_T'}
            type='double';
        case{'int16','int16_T'}
            type='int16';
        case{'int8','int8_T'}
            type='int8';
        case{'int32','int32_T'}
            type='int32';
        case{'uint8','uint8_T'}
            type='uint8';
        case{'uint16','uint16_T'}
            type='uint16';
        case{'uint32','uint32_T'}
            type='uint32';
        case{'boolean','boolean_T'}
            type='boolean';
        otherwise
            type=dType;
        end
    else
        type=dType;
    end
