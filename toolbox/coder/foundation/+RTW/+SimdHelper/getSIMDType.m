function simdType=getSIMDType(identifier,baseType,nElems,loadStorePointerType)




    bt=numerictype(baseType);

    simdType=embedded.simdtype;
    simdType.Identifier=identifier;
    simdType.BaseType=bt;
    simdType.WordLength=nElems*bt.WordLength;
    simdType.LoadStorePointerType=loadStorePointerType;




    simdType.LoadInstruction="";
    simdType.StoreInstruction="";
    simdType.BroadcastInstruction="";
end
