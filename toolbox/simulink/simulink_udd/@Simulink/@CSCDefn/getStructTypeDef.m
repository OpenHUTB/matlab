function typeDef=getStructTypeDef(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    typeDef=hCSCDefn.CSCTypeAttributes.IsTypeDef;



