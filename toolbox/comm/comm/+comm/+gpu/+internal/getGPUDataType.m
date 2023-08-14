function gT=getGPUDataType(mT)









    switch mT
    case 'double'
        gT='double';

    case 'single'
        gT='float';

    case 'int64'
        gT='long long';

    case 'int32'
        gT='int';

    case 'int16'
        gT='short';

    case 'int8'
        gT='char';

    case 'uint64'
        gT='unsigned long long';

    case 'uint32'
        gT='unsigned int';

    case 'uint16'
        gT='unsigned short';

    case 'uint8'
        gT='unsigned char';

    case 'logical'
        gT='bool';

    otherwise
        error(message('comm:system:gpu:CUDAKernelSystemBase:unsupportedDataType'));
    end
end
