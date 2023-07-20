function simdType=createEmbeddedSimdType(targetPakedDataType)
    bt=numerictype(targetPakedDataType.BaseDataTypeName);
    nElems=targetPakedDataType.NumberOfElements;
    identifier=targetPakedDataType.TypeName;

    simdType=embedded.simdtype;
    simdType.Identifier=identifier;
    simdType.BaseType=bt;
    simdType.WordLength=nElems*bt.WordLength;

end