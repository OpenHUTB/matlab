function defFile=getDefinitionFile(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    if hCSCDefn.IsDefinitionFileInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        defFile=ca.DefinitionFile;
    else
        defFile=hCSCDefn.DefinitionFile;
    end



