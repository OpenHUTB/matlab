function result=getStructValueViaReturnArgument(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));

    result=getStructValueViaReturnArgument(hCSCDefn.CSCTypeAttributes);



