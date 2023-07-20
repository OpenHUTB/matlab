function subsystemIO=deriveSubsystemPortInfo(sysH)










    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


    assert(~strcmp(get_param(bdroot(sysH),'SimulationStatus'),'stopped'))

    [InputPortInfo,OutputPortInfo,flatInfo]=...
    Sldv.DataUtils.generateIOportInfo(sysH);
    SampleTimes=flatInfo.SampleTimes;
    parentST=get_param(sysH,'CompiledSampleTime');
    if SampleTimes==-1



        sampleTs=[];
        for idx=1:length(InputPortInfo)
            portTs=sldvshareprivate('mdl_derive_sampletime_for_sldvdata',InputPortInfo{idx}.SampleTime);
            if isempty(sampleTs)||sampleTs>portTs
                sampleTs=portTs;
                parentST=InputPortInfo{idx}.SampleTime;
            end
        end
        SampleTimes=sampleTs;
    end
    InputPortInfo=createPortInfo(sysH,InputPortInfo,parentST);
    subsystemIO.Handle=sysH;
    subsystemIO.InputPortInfo=InputPortInfo;
    subsystemIO.OutputPortInfo=OutputPortInfo;
    subsystemIO.flatInfo=flatInfo;
    subsystemIO.SampleTimes=SampleTimes;


    ssPortHnadles=get_param(sysH,'PortHandles');
    PortHsToLog=[];
    for n=1:length(InputPortInfo)
        if isstruct(InputPortInfo{n})
            bPath=InputPortInfo{n}.BlockPath;
            switch get_param(bPath,'BlockType')
            case 'Inport'
                ph=get_param(bPath,'PortHandles');
                PortHsToLog(n)=ph.Outport(1);%#ok<AGROW>
            case 'EnablePort'
                lhSys=get_param(sysH,'LineHandles');
                if lhSys.Enable(1)~=-1
                    PortHsToLog(n)=get_param(lhSys.Enable(1),'SrcPortHandle');%#ok<AGROW>
                end
            case 'TriggerPort'
                lhSys=get_param(sysH,'LineHandles');
                if lhSys.Trigger(1)~=-1
                    PortHsToLog(n)=get_param(lhSys.Trigger(1),'SrcPortHandle');%#ok<AGROW>
                end
            end
        else

            if n<=length(ssPortHnadles.Inport)
                PortHsToLog(n)=ssPortHnadles.Inport(n);%#ok<AGROW>
            end
        end
    end
    subsystemIO.PortHsToLog=PortHsToLog;


    bObj=get_param(sysH,'Object');
    dsmInfo=bObj.getNeededDSMemBlks;
    subsystemIO.dsmHsToLog=[dsmInfo.Handle];
end

function InputPortInfo=createPortInfo(sysH,InputPortInfo,parentSampleTime)
    ph=get_param(sysH,'PortHandles');
    if iscell(parentSampleTime)
        parentSampleTime=parentSampleTime{1};
    end





    for n=1:length(ph.Enable)
        blk=find_system(sysH,'SearchDepth',1,...
        'FindAll','on','LookUnderMasks','all',...
        'BlockType','EnablePort');
        InputPortInfo{end+1}=getPortInfo(ph.Enable(n),blk(1),parentSampleTime);%#ok<AGROW>
    end
    for n=1:length(ph.Trigger)
        blk=find_system(sysH,'SearchDepth',1,...
        'FindAll','on','LookUnderMasks','all',...
        'BlockType','TriggerPort');
        InputPortInfo{end+1}=getPortInfo(ph.Trigger(n),blk(1),parentSampleTime);%#ok<AGROW>
    end
    DSMportInfo=getDSMPortInfo(sysH,parentSampleTime);
    InputPortInfo=[InputPortInfo,DSMportInfo];

end

function prm=getPortInfo(ph,blk,parentSampleTime)
    prm=Sldv.xform.getPortCompiledInfo(ph);
    prm.BlockPath=getfullname(blk);
    prm.SignalName=get_param(blk,'Name');
    prm.SignalLabels=prm.SignalName;
    prm.ParentSampleTime=parentSampleTime;
    prm=rmfield(prm,{'AliasThruDataType','IsTriggered','IsStructBus'});
end

function dsmPortInfo=getDSMPortInfo(sysH,parentSampleTime)


    dsmPortInfo=[];
    dsmMap=Sldv.SubsystemLogger.deriveDSWExecPriorToSubsystem(sysH);

    blkObj=get_param(sysH,'Object');
    dsmInfo=blkObj.getNeededDSMemBlks();

    for n=1:length(dsmInfo)
        portInfo.BlockPath=getfullname(dsmInfo(n).Handle);
        DataStoreName=get_param(dsmInfo(n).Handle,'DataStoreName');
        portInfo.SignalName=DataStoreName;
        dims=getDimensions(dsmInfo(n).CompiledDimensions);
        portInfo.Dimensions=dims;
        portInfo.DataType=dsmInfo(n).CompiledAliasedThruDataType;
        if~dsmInfo(n).CompiledComplexSignal
            portInfo.Complexity='real';
        else
            portInfo.Complexity='complex';
        end

        [ts,tsStr]=Sldv.utils.getSampleTime(dsmInfo(n).CompiledSampleTime);
        portInfo.SampleTimeStr=tsStr;
        portInfo.SampleTime=ts;
        portInfo.ParentSampleTime=parentSampleTime;
        portInfo.SignalLabels=portInfo.SignalName;
        portInfo.priorWriters=dsmMap(DataStoreName);
        dsmPortInfo{n}=portInfo;%#ok<AGROW>
    end
end

function[dims,dimsStr]=getDimensions(compDims)
    if(compDims(1)>=2)
        nDims=compDims(1);
        dimsStr='';
        spcVal='';
        for k=1:nDims
            if k>1
                spcVal=' ';
            end
            dimsStr=sprintf('%s%s%d',dimsStr,spcVal,compDims(k+1));
        end
        dimsStr=['[',dimsStr,']'];
        dims=compDims(2:end);
    else
        dimsStr=sprintf('%d',compDims(2));
        dims=compDims(2);
    end
end

