function structName=getStructName(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    if hCSCDefn.CSCTypeAttributes.IsStructNameInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        structName=ca.StructName;
    else
        structName=hCSCDefn.CSCTypeAttributes.StructName;
    end



