function src=harnessToModelRemap(src)




    objH=Simulink.ID.getHandle(src);
    if isa(objH,'Stateflow.Object')
        harnessObj=objH;
    else
        harnessObj=get_param(objH,'Object');
    end
    if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(src)
        mdlObj=rmisl.harnessToModelRemap(harnessObj);
        src=Simulink.ID.getSID(mdlObj);
    else



        src=Simulink.harness.internal.sidmap.getHarnessObjectSID(harnessObj);
    end
end
