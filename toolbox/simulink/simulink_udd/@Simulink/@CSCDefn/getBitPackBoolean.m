function bitPack=getBitPackBoolean(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    bitPack=hCSCDefn.CSCTypeAttributes.BitPackBoolean;



