function createNetworksForSF(this)





    startNodeName=this.SimulinkConnection.System;
    sf_blocks=find_system(get_param(startNodeName,'handle'),...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'FirstResultOnly',true,...
    'FollowLinks','on','LookUnderMasks','all','MaskType','Stateflow');
    if isempty(sf_blocks)
        return;
    end

    p=this.hPir;
    networks=p.Networks;
    numNetworks=numel(networks);
    reuseSF=this.HandleReusableSubsystem;
    inlineEMLBlks=hdlgetparameter('inlinematlabblockcode');
    for ii=1:numNetworks
        hN=networks(ii);
        components=hN.Components;
        for jj=1:numel(components)
            hC=components(jj);

            if strcmp(hdlfeature('EnableFlattenSFComp'),'off')&&inLineEmlComp(inlineEMLBlks,hC)
                continue;
            end

            slbh=hC.SimulinkHandle;
            if(slbh~=-1)&&isprop(slbh,'BlockType')&&...
                strcmpi(get_param(slbh,'BlockType'),'SubSystem')&&...
                ~strcmpi(get_param(slbh,'SFBlockType'),'NONE')
                hC.setIsSF(true);



                if strcmp(hdlfeature('EnableFlattenSFComp'),'on')&&strcmp(hdlget_param(hC.getBlockPath,'FlattenHierarchy'),'on')
                    hChildNetwork=createSFNetwork(this,hC,true);





                    if~isempty(hChildNetwork)
                        continue
                    end
                end

                foundClone=reuseSF;
                blockPath=getfullname(slbh);

                if any(strcmp(hdlgetparameter('subsystemreuse'),...
                    {'Atomic and Virtual','Atomic only'}))


                    if reuseSF&&isKey(this.CheckSumInfo,blockPath)
                        foundClone=true;
                    end
                end

                if foundClone

                    [foundPrevInst,checksumStr,hChildNetwork]=this.isHandledReusableSS(blockPath);
                    if~isempty(checksumStr)

                        this.ReusedSSBlks(blockPath)=checksumStr;
                    end
                    if foundPrevInst

                        hNIC=this.pirAddNtwkInstanceComp(slbh,hN,hChildNetwork);
                        hN.replaceComponent(hC,hNIC,false);
                    else

                        hChildNetwork=createSFNetwork(this,hC);
                        hChildNetwork.Name=blockPath;
                        if~isempty(checksumStr)

                            this.CheckSumNtwkMap(checksumStr)=hChildNetwork;
                        end
                    end
                else
                    hChildNetwork=createSFNetwork(this,hC);
                end
            end
        end
    end
end

function[inPortNames,outPortNames]=getSFPortNames(this,slbh)
    chartId=sfprivate('block2chart',slbh);
    chartH=idToHandle(sfroot,chartId);


    hInputData=chartH.find('-isa','Stateflow.Data','Scope','Input','-depth',1);
    hInputEvent=chartH.find('-isa','Stateflow.Event','Scope','Input','-depth',1);
    hInputTrigger=chartH.find('-isa','Stateflow.Trigger','Scope','Input','-depth',1);
    hInputMessage=chartH.find('-isa','Stateflow.Message','Scope','Input','-depth',1);
    inPortNames=[getSortedPortNames(hInputData,false);...
    getSortedPortNames(hInputEvent,false);...
    getSortedPortNames(hInputTrigger,false);...
    getSortedPortNames(hInputMessage,false)];


    hOutputData=chartH.find('-isa','Stateflow.Data','Scope','Output','-depth',1);
    hOutputEvent=chartH.find('-isa','Stateflow.Event','Scope','Output','-depth',1);
    hOutputMessage=chartH.find('-isa','Stateflow.Message','Scope','Output','-depth',1);
    hOutputObject=[hOutputData;hOutputEvent;hOutputMessage];
    outPortNames=getSortedPortNames(hOutputObject,true);
    if~isempty(hInputMessage)||~isempty(hOutputMessage)
        msgobj=message('hdlcoder:stateflow:unsupportedstateflowmessages');
        this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
    end
end

function portNames=getSortedPortNames(obj_list,check_output)
    objInfo=cell(numel(obj_list),2);
    for ii=1:numel(obj_list)
        obj=obj_list(ii);
        name=obj.Name;
        if(check_output&&obj.isa('Stateflow.Data'))
            outputState=obj.outputState;
            if~isempty(outputState)&&~isActiveStateOutput(outputState)
                new_name=[' ',name];
                name=new_name;
            end
        end
        if(sf('Feature','Inplace EML')&&obj.isa('Stateflow.Data')&&strcmp(obj.Scope,'Input')&&...
            sf('get',obj.Id,'data.inPlace.isInPlace'))
            new_name=[name,' '];
            name=new_name;
        end
        objInfo{ii,1}=name;
        objInfo{ii,2}=obj_list(ii).Port;
    end
    objInfo=sortrows(objInfo,2);
    portNames=objInfo(:,1);
end

function b=inLineEmlComp(inlineEMLBlks,hC)
    b=false;
    if inlineEMLBlks&&hC.isBlockComp
        b=strcmp(hC.BlockTag,'eml_lib/MATLAB Function');
    end
end

function b=isActiveStateOutput(outputState)
    b=false;
    if~isempty(outputState)&&~isempty(outputState.OutputMonitoringMode)
        if(strcmp(outputState.OutputMonitoringMode,'ChildActivity')||...
            strcmp(outputState.OutputMonitoringMode,'LeafStateActivity'))
            if isa(outputState.Debug,'Stateflow.ChartDebug')
                b=true;
            end
        end
    end
end



function hNewNet=createSFNetwork(this,hC,inlineGeneratedCode)
    if nargin<3
        inlineGeneratedCode=false;
    end

    slbh=hC.SimulinkHandle;
    blkName=get_param(slbh,'Name');
    blkPath=getfullname(slbh);

    hCInSignals=hC.PirInputSignals;
    hCOutSignals=hC.PirOutputSignals;

    [inPortNames,outPortNames]=getSFPortNames(this,slbh);
    nins=numel(hCInSignals);
    nouts=numel(hCOutSignals);

    inPortNames=inPortNames(1:nins);
    outPortNames=outPortNames(1:nouts);

    for ii=1:nouts
        hCOutSignals(ii).Name=outPortNames{ii};
    end

    inPortKinds={};

    for ii=1:nins
        inPortKinds{ii}='data';
    end

    phan=get_param(slbh,'PortHandles');
    triggerPortWidth=get_param(phan.Trigger,'CompiledPortWidth');
    if~isempty(triggerPortWidth)
        triggerIdx=length(hCInSignals);

        chartId=sfprivate('block2chart',slbh);
        events=sf('EventsOf',chartId);
        inputEvents=sf('find',events,'event.scope','INPUT_EVENT');
        risingEdgeEvents=sf('find',inputEvents,'event.trigger','RISING_EDGE_EVENT');
        fallingEdgeEvents=sf('find',inputEvents,'event.trigger','FALLING_EDGE_EVENT');
        eitherEdgeEvents=sf('find',inputEvents,'event.trigger','EITHER_EDGE_EVENT');

        if~isempty(risingEdgeEvents)
            inPortKinds{triggerIdx}='subsystem_trigger_rising';
        elseif~isempty(fallingEdgeEvents)
            inPortKinds{triggerIdx}='subsystem_trigger_falling';
        elseif~isempty(eitherEdgeEvents)
            inPortKinds{triggerIdx}='subsystem_trigger_either';
        end
    end


    hN=hC.Owner;
    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'InportNames',inPortNames,...
    'OutportNames',outPortNames,...
    'InportKinds',inPortKinds,...
    'RefComponent',hC);
    hNewNet.FullPath=blkPath;
    hNewNet.SimulinkHandle=slbh;
    hNewNet.setSFHolder(true);

    if inlineGeneratedCode
        hNewNet.setFlattenSFHolderNetwork(true);
    end

    hNInSignals=hNewNet.PirInputSignals;
    hNOutSignals=hNewNet.PirOutputSignals;

    hNewNet.acquireComp(hC);

    for i=1:nins
        hCSignal=hCInSignals(i);
        hNSignal=hNInSignals(i);


        if hCSignal.getBustoVectorFlag()
            hNSignal.setBustoVectorFlag(true);
        end

        hCSignal.disconnectReceiver(hC,i-1);
        hNSignal.addReceiver(hC,i-1);
    end

    for i=1:nouts
        hCSignal=hCOutSignals(i);
        hNSignal=hNOutSignals(i);

        hNSignal.SimulinkRate=hCSignal.SimulinkRate;
        hNSignal.SimulinkHandle=hCSignal.SimulinkHandle;
        hNSignal.acquireDrivers(hCSignal);
    end


    hNIC=pirelab.instantiateNetwork(hN,hNewNet,hCInSignals,hCOutSignals,hC.Name);
    hNIC.Name=this.validateAndGetName(blkName);
    hNIC.SimulinkHandle=slbh;
    hNIC.copyComment(hC);

    if this.HDLCoder.AllowBlockAsDUT

        hNIC.setSynthetic();
    end


    hNewNet.setConstrainedOutputPipeline(hC.getConstrainedOutputPipeline());
    hC.setConstrainedOutputPipeline(0);
end


