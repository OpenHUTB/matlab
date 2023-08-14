function[result,harnessObjHandle,harnessInfo]=isObjectOwnedByActiveCUT(obj)
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

    systemModel=bdroot(objHandle);
    harnessInfo=Simulink.harness.internal.getActiveHarness(systemModel);
    if isempty(harnessInfo)
        return;
    end

    ownerHandle=get_param(harnessInfo.ownerFullPath,'Handle');
    if isempty(ownerHandle)
        result=true;
        return;
    end

    modelHandle=get_param(systemModel,'Handle');
    while(objHandle~=modelHandle)
        if objHandle==ownerHandle
            result=true;
            break;
        end
        objHandle=get_param(get_param(objHandle,'Parent'),'Handle');
    end
end
