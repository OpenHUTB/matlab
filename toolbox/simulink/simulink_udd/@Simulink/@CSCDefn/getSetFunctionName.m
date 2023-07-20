function result=getSetFunctionName(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));


    ca=hData.CoderInfo.CustomAttributes;
    if isprop(ca,'SetFunction')
        result=ca.SetFunction;
    else
        result=hCSCDefn.CSCTypeAttributes.SetFunction;
    end



