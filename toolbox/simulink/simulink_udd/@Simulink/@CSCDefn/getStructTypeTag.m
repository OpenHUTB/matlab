function typeTag=getStructTypeTag(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    typeTag=hCSCDefn.CSCTypeAttributes.TypeTag;



