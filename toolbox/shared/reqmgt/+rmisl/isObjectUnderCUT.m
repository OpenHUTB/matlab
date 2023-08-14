function yesorno=isObjectUnderCUT(objh)






    yesorno=false;
    if sysarch.isSysArchObject(objh)||rmifa.isFaultInfoObj(objh)
        return;
    end

    sr=sfroot;
    if sr.isValidSlObject(objh)
        modelName=bdroot(objh);
        objInfo=get(objh,'Object');
    else
        if isa(objh,'Stateflow.Object')
            objInfo=objh;
        else
            objInfo=sr.idToHandle(objh);
        end
        modelName=get_param(objInfo.Machine.name,'Handle');
    end

    if rmisl.isComponentHarness(modelName)
        yesorno=Simulink.harness.internal.sidmap.isObjectOwnedByCUT(objInfo);
    end
end
