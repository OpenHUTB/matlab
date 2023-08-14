function dataInit=getDataInit(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    if hCSCDefn.IsDataInitInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        dataInit=ca.DataInit;
    else
        dataInit=hCSCDefn.DataInit;
    end



