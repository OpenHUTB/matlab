function result=getCriticalSection(hCSCDefn,hData)




    assert(isAccessMethod(hCSCDefn,hData));
    assert(isa(hData,'Simulink.Data'));

    result=hCSCDefn.CriticalSection;



