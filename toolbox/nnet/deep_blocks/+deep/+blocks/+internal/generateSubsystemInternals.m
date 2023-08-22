function generateSubsystemInternals(...
    subsystem,...
    functionText,...
    inputNames,...
    predictOutputNames,...
    namedOutputNames,...
    includeSignalSpec,...
    mlfbPortInfo)
    inputNames=strrep(inputNames,'/','_');
    predictOutputNames=strrep(predictOutputNames,'/','_');
    namedOutputNames=strrep(namedOutputNames,'/','_');
    [inputNames,predictOutputNames,namedOutputNames]=iDisambiguateNames(inputNames,predictOutputNames,namedOutputNames);

    lines=find_system(...
    subsystem,...
    'FindAll','on',...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'type','line');

    delete_line(lines);

    mlfb="MLFB";
    fullMlfb=subsystem+"/"+mlfb;

    rt=sfroot;
    outputs=rt.find('-isa','Simulink.Outport','Path',fullMlfb);
    mlfbOutputNames=cell(size(outputs));
    for i=1:numel(outputs)
        mlfbOutputNames{i}=outputs(i).Name;
    end
    predictOutputKey=deep.blocks.internal.getPredictOutputKey();
    currentPredictOutputs=contains(mlfbOutputNames,predictOutputKey);

    mlfbSource='simulink/User-Defined Functions/MATLAB Function';
    mlfbConfig=get_param(fullMlfb,'MATLABFunctionConfiguration');
    mlfbUpdateMethod=mlfbConfig.UpdateMethod;
    mlfbSampleTime=mlfbConfig.SampleTime;

    if getSimulinkBlockHandle(fullMlfb)>0
        delete_block(fullMlfb);
    end
    mlfbPosition=[200,200,400,400];
    add_block(mlfbSource,fullMlfb,'Position',mlfbPosition);
    config=get_param(fullMlfb,'MATLABFunctionConfiguration');
    config.FunctionScript=functionText;

    config.UpdateMethod=mlfbUpdateMethod;
    if~(strcmp(mlfbUpdateMethod,'Continuous')||strcmp(mlfbUpdateMethod,'Inherited'))
        config.SampleTime=mlfbSampleTime;
    end

    if nargin>6
        configureMLFBPorts(fullMlfb,mlfbPortInfo);
    end
    currentInports=renamePorts(subsystem,'Inport','___in_');
    numCurrentInports=length(currentInports);
    numInputs=length(inputNames);
    inportStartPosition=[50,50,90,70];
    inportSource='simulink/Sources/In1';

    for i=1:max(numCurrentInports,numInputs)
        if i>numCurrentInports
            block=subsystem+"/"+inputNames{i};
            increment=100*i;
            portPosition=inportStartPosition+[0,increment,0,increment];
            add_block(inportSource,block,'Position',portPosition);
        elseif i>numInputs
            block=currentInports{i};
            delete_block(block);
        else

            block=currentInports{i};
            set_param(block,'Name',inputNames{i});
        end
    end

    if includeSignalSpec
        existingSignalSpecs=find_system(...
        subsystem,...
        'LookUnderMasks','on',...
        'FollowLinks','on',...
        'SearchDepth',1,...
        'BlockType','SignalSpecification');
        delete_block(existingSignalSpecs);

        signalSpecSource='simulink/Signal Attributes/Signal Specification';
        signalSpecStartPosition=[70,50,150,70];
        signalSpecName="Signal Specification";
        for i=1:numInputs
            block=subsystem+"/"+signalSpecName+" "+inputNames{i};
            increment=100*i;
            portPosition=signalSpecStartPosition+[0,increment,0,increment];
            add_block(signalSpecSource,block,'Position',portPosition);
            set_param(block,'SampleTime','SampleTime');
        end
    end
    oldNames=getPortNames(subsystem,'Outport');
    oldActivationNames=oldNames(~currentPredictOutputs);
    lastPredictIdx=find(currentPredictOutputs,1,'last');
    [idx,pidx]=getIdx(oldActivationNames,namedOutputNames);

    if isempty(lastPredictIdx)
        lastPredictIdx=0;
    end

    outportStartPosition=[500,50,540,70];
    outportSource='simulink/Sinks/Out1';
    numPredictOutputs=numel(predictOutputNames);
    currentOutports=renamePorts(subsystem,'Outport','___out_');

    for i=1:max(lastPredictIdx,numPredictOutputs)
        if i>lastPredictIdx
            block=subsystem+"/"+predictOutputNames{i};
            increment=100*i;
            portPosition=outportStartPosition+[0,increment,0,increment];
            add_block(outportSource,block,'Position',portPosition,'Port',num2str(i));
        elseif i>numPredictOutputs

            block=currentOutports{i};
            delete_block(block);
        else

            block=currentOutports{i};
            set_param(block,'Name',predictOutputNames{i});
        end
    end

    for i=1:numel(pidx)
        if pidx(i)==0
            port=subsystem+"/___out_"+num2str(lastPredictIdx+i);
            delete_block(port);
        end
    end

    for i=1:numel(pidx)
        index=pidx(i);
        port=subsystem+"/___out_"+num2str(lastPredictIdx+i);
        if index>0
            increment=100*(numPredictOutputs+index);
            portPosition=outportStartPosition+[0,increment,0,increment];
            set_param(port,'Port',num2str(numPredictOutputs+index));
            set_param(port,'Position',portPosition);
            set_param(port,'Name',namedOutputNames{index});

        end
    end

    for i=1:numel(idx)
        if idx(i)==0
            block=subsystem+"/"+namedOutputNames{i};
            increment=100*(numPredictOutputs+i);
            portPosition=outportStartPosition+[0,increment,0,increment];
            add_block(outportSource,block,'Position',portPosition,'Port',num2str(numPredictOutputs+i));
        end
    end

    if includeSignalSpec

        for i=1:length(inputNames)
            source=inputNames{i}+"/1";
            destination=signalSpecName+" "+inputNames{i}+"/1";
            add_line(subsystem,source,destination,'autorouting','on');
        end

        for i=1:length(inputNames)
            source=signalSpecName+" "+inputNames{i}+"/1";
            destination=mlfb+"/"+num2str(i);
            add_line(subsystem,source,destination,'autorouting','on');
        end
    else

        for i=1:length(inputNames)
            source=inputNames{i}+"/1";
            destination=mlfb+"/"+num2str(i);
            add_line(subsystem,source,destination,'autorouting','on');
        end
    end
    for i=1:numPredictOutputs
        source=mlfb+"/"+num2str(i);
        destination=predictOutputNames{i}+"/1";
        add_line(subsystem,source,destination,'autorouting','on');
    end

    for i=1:numel(namedOutputNames)
        index=i+numPredictOutputs;
        source=mlfb+"/"+num2str(index);
        destination=namedOutputNames{i}+"/1";
        add_line(subsystem,source,destination,'autorouting','on');
    end

end


function newPorts=renamePorts(subsystem,blockType,prefix)
    ports=find_system(...
    subsystem,...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'SearchDepth',1,...
    'BlockType',blockType);

    newPorts=cell(size(ports));

    for i=1:numel(ports)
        block=ports{i};
        newName=[prefix,num2str(i)];
        newPorts{i}=subsystem+"/"+newName;
        set_param(block,'Name',newName);
    end
end


function names=getPortNames(subsystem,blockType)

    ports=find_system(...
    subsystem,...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'SearchDepth',1,...
    'BlockType',blockType);

    names=cell(size(ports));

    for i=1:numel(ports)
        names{i}=get_param(ports{i},'Name');
    end

end


function[idx,pidx]=getIdx(prev,next)
    idx=zeros(size(next));
    pidx=zeros(size(prev));

    for i=1:numel(idx)
        index=find(strcmp(prev,next{i}));
        if~isempty(index)
            idx(i)=index;
        end
    end

    for i=1:numel(pidx)
        pindex=find(strcmp(next,prev{i}));
        if~isempty(pindex)
            pidx(i)=pindex;
        end
    end

end


function configureMLFBPorts(fullMlfb,portInfo)
    sfblkId=sf('Private','block2chart',getSimulinkBlockHandle(fullMlfb));
    sfblkobj=sf('IdToHandle',sfblkId);

    for i=1:length(portInfo)
        d=sfblkobj.find('-isa','Stateflow.Data','Name',portInfo(i).Name,'Scope',portInfo(i).Scope);
        if~isempty(d)
            d.Props.Array.IsDynamic=portInfo(i).VariableSize;
            d.Props.Array.Size=portInfo(i).Size;
        end
    end

end


function[inputNames,predictOutputNames,namedOutputNames]=iDisambiguateNames(inputNames,predictOutputNames,namedOutputNames)

    inputNames=inputNames';
    inputNamesLen=numel(inputNames);
    predictOutputNamesLen=numel(predictOutputNames);
    combinedNames=[inputNames,predictOutputNames,namedOutputNames];
    uniqueNames=matlab.lang.makeUniqueStrings(combinedNames);
    inputNames=uniqueNames(1:inputNamesLen);
    predictOutputNames=uniqueNames(inputNamesLen+1:inputNamesLen+predictOutputNamesLen);
    namedOutputNames=uniqueNames(inputNamesLen+predictOutputNamesLen+1:end);

end
