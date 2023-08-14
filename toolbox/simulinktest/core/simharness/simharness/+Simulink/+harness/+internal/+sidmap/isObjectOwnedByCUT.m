function[result,harnessObjHandle,harnessInfo]=isObjectOwnedByCUT(obj)
    result=false;
    harnessObjHandle=[];
    harnessInfo=[];
    if isa(obj,'Simulink.Block')||isa(obj,'Simulink.Subsystem')
        objHandle=obj.Handle;
    elseif isa(obj,'Stateflow.Chart')||...
        isa(obj,'Stateflow.EMChart')||isa(obj,'Stateflow.TruthTableChart')||...
        isa(obj,'Stateflow.StateTransitionTableChart')||isa(obj,'Stateflow.ReactiveTestingTableChart')
        objHandle=get_param(obj.Path,'Handle');
    elseif isa(obj,'Stateflow.Object')
        objHandle=get_param(obj.Chart.Path,'Handle');
    else

        return;
    end
    harnessObjHandle=objHandle;

    harnessModel=bdroot(objHandle);
    if~strcmp(get_param(harnessModel,'isHarness'),'on')
        return;
    end
    harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(harnessModel);



    if~Simulink.harness.internal.isHarnessObjInMainModel(harnessInfo,harnessObjHandle)
        return;
    end

    systemModel=Simulink.harness.internal.getHarnessOwnerBD(harnessModel);

    sutHandle=get_param(Simulink.harness.internal.getActiveHarnessCUT(systemModel),'Handle');
    if isempty(sutHandle)
        result=true;
        return;
    end

    modelHandle=get_param(harnessModel,'Handle');
    while(objHandle~=modelHandle)
        if objHandle==sutHandle
            result=true;
            break;
        end
        objHandle=get_param(get_param(objHandle,'Parent'),'Handle');
    end
end
