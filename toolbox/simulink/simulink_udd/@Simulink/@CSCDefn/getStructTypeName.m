function typeName=getStructTypeName(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    typeName=hCSCDefn.CSCTypeAttributes.TypeName;



