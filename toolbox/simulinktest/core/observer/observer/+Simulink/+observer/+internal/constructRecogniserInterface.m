function constructRecogniserInterface(designHdl,obsMdlName,designPortHdls)
    assert(strcmp(get_param(designHdl,'SimulinkSubDomain'),'Architecture'));

    if~slfeature('SynthesizedObserver')||isempty(designPortHdls)||slsvTestingHook('SequenceDiagramGenerateRecogniser')<1
        return;
    end

    Simulink.BlockDiagram.deleteContents(obsMdlName);

    set_param(obsMdlName,'UnconnectedInputMsg','none','UnconnectedOutputMsg','none');
    obsHdls=flattenDesignPortHdlsStructure(designPortHdls);

    for i=1:length(obsHdls)
        [blkPathHdls,phObj]=extractStartingPoint(obsHdls(i).ParentBlockPath,...
        obsHdls(i).PortIndex+1,obsHdls(i).PortType);
        srcInfo=Simulink.observer.internal.determineObservableSrcAndResidualBusPath(phObj,obsHdls(i).InterfaceElement);
        portIdx=get_param(srcInfo.observedPort,'PortNumber');
        blkPathHdls(end)=get_param(srcInfo.observedPort,'ParentHandle');

        if obsHdls(i).IsMessage
            if strcmp(get_param(blkPathHdls(end),'BlockType'),'Queue')
                opHdl=addObserverPortBlock(obsMdlName,i,'');
                configureObserverPortForSend(blkPathHdls,opHdl,obsHdls(i).BackEndId,obsHdls(i).InterfaceElement);
            elseif strcmp(get_param(blkPathHdls(end),'BlockType'),'SubSystem')||...
                strcmp(get_param(blkPathHdls(end),'BlockType'),'S-Function')
                if(isempty(srcInfo.elems))
                    opHdl=addObserverPortBlock(obsMdlName,i,'');
                    Simulink.observer.internal.configureObserverPort(opHdl,'Outport',blkPathHdls,portIdx,false,get_param(designHdl,'Name'));
                    setTag(opHdl,'',obsHdls(i).BackEndId,obsHdls(i).InterfaceElement);
                end
            end
        else
            opHdl=addObserverPortBlock(obsMdlName,i,'');
            Simulink.observer.internal.configureObserverPort(opHdl,'Outport',blkPathHdls,get_param(srcInfo.observedPort,'PortNumber'),false,get_param(designHdl,'Name'));
            subsysPath=Simulink.observer.internal.constructBusSelectorsForObserverPort(opHdl,srcInfo.elems);

            if isempty(subsysPath)
                setTag(opHdl,'',obsHdls(i).BackEndId,obsHdls(i).InterfaceElement);
            else
                ssHdl=get_param(subsysPath,'handle');
                setTag(ssHdl,'',obsHdls(i).BackEndId,obsHdls(i).InterfaceElement);
            end
        end
    end

    if slsvTestingHook('SequenceDiagramUseTestingBlock')<2

        hdl=add_block('built-in/display',string(obsMdlName)+"/verdict");%#ok<*NASGU>
        hdl=add_block('built-in/display',string(obsMdlName)+"/warnings");
    end
end


function configureObserverPortForSend(blkPathHdls,opHdl,backEndId,interfaceElement)

    queueBlk=blkPathHdls(end);
    assert(get_param(queueBlk,"BlockType")=="Queue");
    queuePH=get_param(queueBlk,'PortHandles');
    assert(isscalar(queuePH.Inport),"Expecting one input port");
    sourcePH=Simulink.observer.internal.traceSourceOfMessageSignal(queuePH.Inport);
    sourcePhObj=get_param(sourcePH,'Object');
    model=bdroot(sourcePhObj.Parent);
    Simulink.observer.internal.configureObserverPort(opHdl,'Outport',sourcePhObj.ParentHandle,sourcePhObj.PortNumber,false,model);
    setTag(opHdl,'',backEndId,interfaceElement);
end


function tag=setTag(opHdl,prefix,backEndId,interfaceElement)
    tag='';
    if~isempty(prefix)
        tag=[prefix,':'];
    end

    tag=[tag,backEndId];

    if~isempty(interfaceElement)
        tag=[tag,'.',interfaceElement];
    end

    set_param(opHdl,'Tag',tag);
end



function opHdl=addObserverPortBlock(obsMdlName,idx,postfix)
    otop=87;
    obtm=113;

    oBlk=[obsMdlName,'/ObserverPort',num2str(idx),postfix];
    add_block('sltestlib/ObserverPort',oBlk,'ShowName','off','Position',[100,otop+idx*10,145,obtm+idx*10]);
    opHdl=get_param(oBlk,'Handle');
end



function obsHdls=flattenDesignPortHdlsStructure(designPortHdls)
    obsHdls=struct([]);
    count=1;

    for i=1:length(designPortHdls)
        if~isempty(designPortHdls(i).InterfaceElements)
            for j=1:length(designPortHdls(i).InterfaceElements)
                obsHdls(count).ParentBlockPath=designPortHdls(i).ParentBlockPath;
                obsHdls(count).PortIndex=designPortHdls(i).PortIndex;
                obsHdls(count).PortType=designPortHdls(i).PortType;
                obsHdls(count).BackEndId=designPortHdls(i).BackEndId;
                obsHdls(count).IsMessage=designPortHdls(i).IsMessage;
                obsHdls(count).InterfaceElement=designPortHdls(i).InterfaceElements{j};
                count=count+1;
            end
        else
            obsHdls(count).ParentBlockPath=designPortHdls(i).ParentBlockPath;
            obsHdls(count).PortIndex=designPortHdls(i).PortIndex;
            obsHdls(count).PortType=designPortHdls(i).PortType;
            obsHdls(count).BackEndId=designPortHdls(i).BackEndId;
            obsHdls(count).IsMessage=designPortHdls(i).IsMessage;
            obsHdls(count).InterfaceElement='';
            count=count+1;
        end
    end
end



function[blkPathHdls,phObj]=extractStartingPoint(blkPath,portIdx,portType)
    pathCell=blkPath.convertToCell;
    blkPathHdls=cell2mat(get_param(pathCell,'Handle'));

    lastPathHdl=blkPathHdls(end);
    ph=get_param(lastPathHdl,'PortHandles');

    if strcmp(portType,'in')
        phObj=get_param(ph.Inport(portIdx),'Object');
    else
        phObj=get_param(ph.Outport(portIdx),'Object');
    end
end



