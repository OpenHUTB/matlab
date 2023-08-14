function result=getGetFunctionName(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));


    ca=hData.CoderInfo.CustomAttributes;
    if isprop(ca,'GetFunction')
        result=ca.GetFunction;
    else
        result=hCSCDefn.CSCTypeAttributes.GetFunction;
    end



