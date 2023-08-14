function result=getIsReusable(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    if hCSCDefn.IsReusableInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        result=ca.IsReusable;
    else
        result=hCSCDefn.IsReusable;
    end



