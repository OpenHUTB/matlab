function PerInstanceMemory=isAutosarPerInstanceMemory(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));

    PerInstanceMemory=hCSCDefn.IsAutosarPerInstanceMemory;




