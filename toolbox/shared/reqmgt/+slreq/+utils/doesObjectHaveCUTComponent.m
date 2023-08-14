function[yesorno,harnessObjInfo]=doesObjectHaveCUTComponent(objh)


    yesorno=false;
    harnessObjInfo=[];
    tf=license('test','Simulink_Test')&&...
    dig.isProductInstalled('Simulink Test');
    if~tf
        return;
    end

    if sysarch.isSysArchObject(objh)
        return;
    end

    sr=sfroot;
    if sr.isValidSlObject(objh)

        modelHandle=bdroot(objh);
        objInfo=get(objh,'Object');
        isSf=false;
    else
        if isa(objh,'Stateflow.Object')

            objInfo=objh;
        else

            objInfo=sr.idToHandle(objh);
        end
        isSf=true;
        modelHandle=get_param(objInfo.Machine.name,'Handle');
    end

    openedHarness=Simulink.harness.internal.getActiveHarness(modelHandle);

    if~isempty(openedHarness)
        if isSf
            sidInCUT=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(objInfo);
            if~isempty(sidInCUT)
                yesorno=true;
                sfObj=Simulink.ID.getHandle(sidInCUT);
                harnessObjInfo.modelHandle=modelHandle;
                harnessObjInfo.Id=sfObj.Id;
                harnessObjInfo.harnessName=openedHarness.name;
                harnessObjInfo.harnessOwnerHandle=openedHarness.ownerHandle;
                harnessObjInfo.harnessModelHandle=get_param(openedHarness.name,'Handle');
                harnessObjInfo.isSf=true;
            end
        else
            objInfo=get(objh,'Object');
            sidInCUT=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(objInfo);
            if~isempty(sidInCUT)
                yesorno=true;
                objIDInCUT=Simulink.ID.getHandle(sidInCUT);
                harnessObjInfo.Id=objIDInCUT;
                harnessObjInfo.modelHanel=modelHandle;
                harnessObjInfo.harnessName=openedHarness.name;
                harnessObjInfo.harnessOwnerHandle=openedHarness.ownerHandle;
                harnessObjInfo.harnessModelHandle=get_param(openedHarness.name,'Handle');
                harnessObjInfo.isSf=false;
            end
        end

    end

end
