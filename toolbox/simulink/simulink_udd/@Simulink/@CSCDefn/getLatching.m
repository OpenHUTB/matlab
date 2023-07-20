function result=getLatching(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));
    assert(isa(hData,'Simulink.Data'));


    ca=hData.CoderInfo.CustomAttributes;
    if isprop(ca,'Latching')
        result=ca.Latching;
    else
        result=hCSCDefn.Latching;
    end



