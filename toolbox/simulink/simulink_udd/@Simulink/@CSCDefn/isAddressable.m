function addressable=isAddressable(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));

    addressable=true;


    if hCSCDefn.IsDataInitInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        dataInit=ca.DataInit;
    else
        dataInit=hCSCDefn.DataInit;
    end

    if isequal(dataInit,'Macro')
        addressable=false;
    end


    if addressable
        ta=hCSCDefn.CSCTypeAttributes;
        if~isempty(ta)
            addressable=ta.isAddressable(hCSCDefn,hData);
        end
    end



