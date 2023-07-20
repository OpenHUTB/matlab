function bytesPerMultiWordChunk=getBytesPerMultiWordChunk(model)




    typeInfo=coder.internal.xcp.getTypeInfo(model,false);
    if typeInfo.native64
        bytesPerMultiWordChunk=8;
    else
        bytesPerMultiWordChunk=4;
    end
end