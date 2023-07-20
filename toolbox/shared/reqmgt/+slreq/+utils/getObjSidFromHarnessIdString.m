function objID=getObjSidFromHarnessIdString(harnessIdStr)















    [harnessName,localSID]=Simulink.harness.internal.sidmap.getHarnessObjectFromUniqueID(harnessIdStr,false);
    objID=[harnessName,localSID];
end
