function imported=isImported(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));

    imported=false;


    if hCSCDefn.IsDataScopeInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        dataScope=ca.DataScope;
    else
        dataScope=hCSCDefn.DataScope;
    end

    if isequal(dataScope,'Imported')
        imported=true;
    end



