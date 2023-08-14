function rebuildTestSeqBlock(bd,blkPath,ioInfo)

    try
        rt=sfroot;
        machine=rt.find('-isa','Stateflow.Machine','Name',bd);
        if strcmp(get_param(blkPath,'SFBlockType'),'Test Sequence')
            isTestSequence=true;
        else
            isTestSequence=false;
        end

        if isTestSequence
            tsUDD=machine.find('-isa','Stateflow.ReactiveTestingTableChart','Path',blkPath);
        else
            tsUDD=machine.find('-isa','Stateflow.Chart','Path',blkPath);
        end

        nSlFcns=length(ioInfo.SlFcns);
        nIns=1;
        nOuts=1;
        for i=1:nSlFcns
            nArgIn=length(ioInfo.SlFcns{i}.inputs);
            for j=1:nArgIn
                sigInfo=ioInfo.SlFcns{i}.inputs{j};
                d=tsUDD.find('-isa','Stateflow.Data','scope','Input','Name',sigInfo.name);
                if isempty(d)
                    d=addInput(tsUDD,ioInfo.SlFcns{i}.inputs{j});
                end
                d.Port=nIns;
                nIns=nIns+1;
            end
            nArgOut=length(ioInfo.SlFcns{i}.outputs);
            for j=1:nArgOut
                sigInfo=ioInfo.SlFcns{i}.outputs{j};
                d=tsUDD.find('-isa','Stateflow.Data','scope','Output','Name',sigInfo.name);
                if isempty(d)
                    d=addOutput(tsUDD,ioInfo.SlFcns{i}.outputs{j});
                end
                d.Port=nOuts;
                nOuts=nOuts+1;
            end
        end

        nOutput=length(ioInfo.Output);
        for i=1:nOutput
            sigName=ioInfo.Output{i}.name;
            if isTestSequence
                d=tsUDD.find('-isa','Stateflow.FunctionCall','Name',sigName);
                if~isempty(d)
                    sltest.testsequence.deleteSymbol(blkPath,sigName);
                end
            else
                d=tsUDD.find('-isa','Stateflow.Event','Name',sigName);
                if~isempty(d)
                    d.delete;
                end
            end
        end

        for i=1:nOutput
            addOutput(tsUDD,ioInfo.Output{i});
        end

    catch ME
        Simulink.harness.internal.warn(ME);
    end
end

function d=addInput(tsUDD,sigInfo)
    if sigInfo.isMessage
        d=Stateflow.Message(tsUDD);
    else
        d=Stateflow.Data(tsUDD);
    end
    d.Scope='Input';
    d.Name=sigInfo.name;
    Simulink.harness.internal.configTSData(d,sigInfo);
end

function d=addOutput(tsUDD,sigInfo)
    isFcnCall=strcmp(sigInfo.dataType,'fcn_call');
    if sigInfo.isMessage
        d=Stateflow.Message(tsUDD);
    elseif isFcnCall
        d=Stateflow.createEvent(tsUDD,"FunctionCall");
    else
        d=Stateflow.Data(tsUDD);
    end
    d.Name=sigInfo.name;
    Simulink.harness.internal.configTSData(d,sigInfo);
    if~isFcnCall
        d.Scope='Output';
    end
end
