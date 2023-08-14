function result=getSetElementFunctionName(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));



    assert(supportsArrayAccess(hCSCDefn,hData));

    ca=hData.CoderInfo.CustomAttributes;
    if isprop(ca,'SetElementFunction')
        result=ca.SetElementFunction;
    else
        result=hCSCDefn.CSCTypeAttributes.SetElementFunction;
    end



