function qualifier=getHeaderFile(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    if hCSCDefn.IsHeaderFileInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        qualifier=ca.HeaderFile;
    else
        qualifier=hCSCDefn.HeaderFile;
    end



