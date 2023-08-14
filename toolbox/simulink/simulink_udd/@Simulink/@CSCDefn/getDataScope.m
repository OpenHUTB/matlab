function dataScope=getDataScope(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    if hCSCDefn.IsDataScopeInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        dataScope=ca.DataScope;
    else
        dataScope=hCSCDefn.DataScope;
    end



