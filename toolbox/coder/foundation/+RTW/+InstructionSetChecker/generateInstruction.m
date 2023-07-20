function instruction=generateInstruction(aSimdEntry)
    try
        aSimdEmbeddedType=aSimdEntry.ConceptualArgs(1).Type;
        intrinsic=getIntrinsic(aSimdEntry.Key);
        baseType=aSimdEmbeddedType.BaseType;
        baseTypeStr=baseType.tostringInternalSlName;
        width=aSimdEmbeddedType.WordLength/baseType.WordLength;
        instruction=target.internal.create('Instruction','Intrinsic',intrinsic,...
        'BaseType',baseTypeStr,'Width',width);
    catch
        instruction=[];
    end
end

function simdKey=getIntrinsic(IntrinsicString)

    simdKey=getSimdKeyFromIntrinsicString(IntrinsicString);

    if(isempty(simdKey))
        error('unsupported SIMD CRL key')
    end
end
