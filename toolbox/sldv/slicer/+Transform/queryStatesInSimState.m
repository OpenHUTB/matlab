function[map,pathStrOut]=queryStatesInSimState(map,partSimState,pathStrIn,blockType)






    import Transform.*;
    pathStrOut=pathStrIn;



    switch blockType
    case 'DataStoreMemory'
        isTarget=@(partSimState)isDSMState(partSimState);
        getMap=@(map,partSimState,pathStrIn)getDSMMap(map,partSimState,pathStrIn);
    case 'Merge'
        isTarget=@(partSimState)isMergeState(partSimState);
        getMap=@(map,partSimState,pathStrIn)getMergeMap(map,partSimState,pathStrIn);
    end

    if isa(partSimState,'Simulink.SimState.ModelSimState')
        nStates=numel(partSimState.blockSimStates);
        for n=1:nStates
            thisPathStr=sprintf('%s.blockSimStates(%d)',pathStrIn,n);
            [map,pathStrOut]=queryStatesInSimState(map,partSimState.blockSimStates(n),thisPathStr,blockType);
        end

    elseif isa(partSimState,'Simulink.SimState.BlockSimState')
        try
            blockExecData=partSimState.blockExecData;
            if isa(blockExecData,'Simulink.SimState.SystemExecData')
                nStates=numel(blockExecData.blockSimStates);
                for n=1:nStates
                    thisPathStr=sprintf('%s.blockExecData.blockSimStates(%d)',pathStrIn,n);
                    [map,pathStrOut]=queryStatesInSimState(map,partSimState.blockExecData.blockSimStates(n),thisPathStr,blockType);
                end
            elseif isa(blockExecData,'Simulink.SimState.BlockDefaultExecData')
                if isTarget(partSimState)
                    map=getMap(map,partSimState,pathStrIn);
                end
            end
        catch mex %#ok<NASGU>

        end
    end
end



function yesno=isDSMState(partSimState)


    try
        yesno=strcmp(partSimState.blockExecData.execData.workVectors.label,'dsmMem');
    catch
        yesno=false;
    end
end
function map=getDSMMap(map,partSimState,pathStrIn)

    dsmName=partSimState.blockExecData.execData.workVectors.name;
    thisPathStr=sprintf('%s.blockExecData.execData.workVectors.value',pathStrIn);
    t=struct('value',partSimState.blockExecData.execData.workVectors.value,...
    'pathStr',thisPathStr,'BlockPath',partSimState.blockPath);
    if~isKey(map,dsmName)
        map(dsmName)=t;
    else
        origT=map(dsmName);
        map(dsmName)=[origT,t];
    end
end

function yesno=isMergeState(partSimState)

    yesno=strcmp(get_param(partSimState.blockPath,'BlockType'),'Merge');
end
function map=getMergeMap(map,partSimState,pathStrIn)
    thisPathStr=sprintf('%s.blockExecData.persistentOutputs',pathStrIn);
    map(partSimState.blockPath)=...
    struct('persistentOutputs',partSimState.blockExecData.persistentOutputs,...
    'pathStr',thisPathStr,'BlockPath',partSimState.blockPath);
end