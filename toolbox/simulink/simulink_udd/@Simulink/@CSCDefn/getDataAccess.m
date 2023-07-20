function dataAccess=getDataAccess(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    if hCSCDefn.IsDataAccessInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        dataAccess=ca.DataAccess;
    else
        dataAccess=hCSCDefn.DataAccess;
    end



