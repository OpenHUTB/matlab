function result=getGetElementFunctionName(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));



    assert(supportsArrayAccess(hCSCDefn,hData));

    ca=hData.CoderInfo.CustomAttributes;
    if isprop(ca,'GetElementFunction')
        result=ca.GetElementFunction;
    else
        result=hCSCDefn.CSCTypeAttributes.GetElementFunction;
    end



