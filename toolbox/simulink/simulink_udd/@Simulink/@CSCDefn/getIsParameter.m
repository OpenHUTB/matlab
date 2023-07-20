function isParam=getIsParameter(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    isParam=hCSCDefn.DataUsage.IsParameter;



