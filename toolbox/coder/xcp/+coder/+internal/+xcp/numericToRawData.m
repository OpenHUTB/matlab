function bytes=numericToRawData(val,memUnitTransformer)













    typeName=class(val);
    assert(ismember(typeName,{'uint8','uint16','uint32','int32','double','single'}));
    bytes=typecast(val,'uint8');
    if~isempty(memUnitTransformer)
        bytes=memUnitTransformer.transform(...
        typeName,...
        coder.internal.connectivity.MemUnitTransformDirection.OUTBOUND,...
        bytes);
    end
end