function PerInstanceMemory=isAutosarPerInstanceMemory(hThis,hData)




    assert(isa(hData,'Simulink.Data'));

    actualDefnObj=hThis.getRefDefnObj;
    PerInstanceMemory=actualDefnObj.IsAutosarPerInstanceMemory;




