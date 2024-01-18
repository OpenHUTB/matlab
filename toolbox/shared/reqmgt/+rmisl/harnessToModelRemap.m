function objh=harnessToModelRemap(objh)

    if isa(objh,'Simulink.BlockDiagram')
        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(objh.Name);
        objh=get_param(harnessInfo.ownerFullPath,'Object');
    else
        objSID=Simulink.harness.internal.sidmap.getHarnessObjectSID(objh);
        objHandle=Simulink.ID.getHandle(objSID);
        if isa(objHandle,'Stateflow.Object')
            objh=objHandle;
        else
            objh=get_param(objHandle,'Object');
        end
    end
end
