function result=supportsArrayAccess(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));

    result=hCSCDefn.CSCTypeAttributes.SupportsArrayAccess;



