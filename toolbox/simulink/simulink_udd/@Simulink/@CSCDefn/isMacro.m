function macro=isMacro(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));

    macro=false;


    if hCSCDefn.IsDataInitInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        dataInit=ca.DataInit;
    else
        dataInit=hCSCDefn.DataInit;
    end

    if isequal(dataInit,'Macro')
        macro=true;
    end



