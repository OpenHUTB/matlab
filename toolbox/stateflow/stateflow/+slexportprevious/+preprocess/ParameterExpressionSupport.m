function ParameterExpressionSupport(obj)





    if~isR2017aOrEarlier(obj.ver)
        return;
    end


    machine=getStateflowMachine(obj);
    if isempty(machine)
        return;
    end
    machineId=machine.id;
    dataIn=sf('find',sf('DataIn',machineId),'data.initFromWorkspace',1,'data.props.resolveToSignalObject',0,'~data.scope','PARAMETER_DATA');
    affectedData=dataIn(arrayfun(@(dataId)~isequal(sf('get',dataId,'.props.initialValue'),sf('get',dataId,'.name')),dataIn));
    for dataId=affectedData(:)'
        ver=obj.ver;
        obj.reportWarning('Stateflow:misc:ParameterExprsConvertedToDataName',...
        sf('GetHyperLinkedNameForObject',dataId),...
        ver.release...
        );
        sf('set',dataId,'.initFromWorkspace',0);
    end
end



