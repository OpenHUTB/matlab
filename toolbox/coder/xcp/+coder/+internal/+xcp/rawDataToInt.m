function val=rawDataToInt(bytes,memUnitTransformer)
















    if(~isa(bytes,'uint8'))
        DAStudio.error('coder_xcp:host:InputArrayElementTypeNotSupported');
    end


    if(isscalar(bytes))
        val=bytes;
        return;
    end

    switch length(bytes)
    case 1
        typeName='uint8';
    case 2
        typeName='uint16';
    case 4
        typeName='uint32';
    case 8
        typeName='uint64';
    otherwise
        assert(false,...
        'Length of input  must be either 1, 2, 4 or 8');
    end

    if~isempty(memUnitTransformer)
        bytes=memUnitTransformer.transform(...
        typeName,...
        coder.internal.connectivity.MemUnitTransformDirection.INBOUND,...
        bytes);

    end
    val=typecast(bytes,typeName);
end