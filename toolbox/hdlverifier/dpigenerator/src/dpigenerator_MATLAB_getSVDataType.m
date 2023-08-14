function retDT=dpigenerator_MATLAB_getSVDataType(CDataType,DataTypeSize,PortsDataType)





    l_CheckThereAreNo_emxArraysOrChar(CDataType);

    if contains(CDataType,'struct')
        retDT='structSV';
        return;
    end

    if any(strcmpi(PortsDataType,{'BitVector','LogicVector'}))

        if strcmpi(CDataType(1),'u')||strcmpi(CDataType(1:4),'bool')
            SignedKeyword='';
        else
            SignedKeyword='signed ';
        end


        VectorSize=['[',num2str(DataTypeSize-1),':0]'];




    end

    if strcmpi(PortsDataType,'BitVector')
        retDT=['bit ',SignedKeyword,VectorSize];
    elseif strcmpi(PortsDataType,'LogicVector')
        retDT=['logic ',SignedKeyword,VectorSize];
    else
        switch CDataType
        case{'unsigned char','uint8_T'}
            retDT='byte unsigned';
        case{'unsigned short','uint16_T'}
            retDT='shortint unsigned';
        case{'unsigned int','uint32_T'}
            retDT='int unsigned';
        case{'unsigned long','uint64_T','uint64m_T','unsigned long long'}
            retDT='longint unsigned';
        case{'signed char','int8_T'}
            retDT='byte';
        case{'short','int16_T'}
            retDT='shortint';
        case{'long','int64m_T','int64_T','long long'}
            retDT='longint';
        case{'int','int32_T'}
            retDT='int';
        case{'float','real32_T','single'}
            retDT='shortreal';
        case{'double','real_T'}
            retDT='real';
        case 'boolean_T'
            retDT='byte unsigned';
        otherwise

            retDT='';
        end
    end
end

function l_CheckThereAreNo_emxArraysOrChar(CodeInfoCTypes)
    if contains(CodeInfoCTypes,'emxArray')

        error(message('HDLLink:DPIG:emxArraysNotSupported'));
    elseif strcmp(CodeInfoCTypes,'char')

        error(message('HDLLink:DPIG:CharNotSupported'));
    end
end

