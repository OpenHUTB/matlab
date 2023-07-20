function coderDictionaryBusElementPorts(obj)





    converter=[];


    if isR2018bOrEarlier(obj.ver)

        obj.appendRule('<System<List<ListType|InterfaceData>:remove>>');

        obj.appendRule('<GraphicalInterface<Outport<BusData:remove>>>');
        obj.appendRule('<GraphicalInterface<Inport<BusData:remove>>>');
    end
    if isR2019aOrEarlier(obj.ver)...
        &&Simulink.CodeMapping.isMappedToAutosarComponent(obj.modelName)...
        &&obj.ver.isSLX

        if~autosarinstalled
            MSLDiagnostic('RTW:autosar:AUTOSARBlocksetRequiredMsg').reportAsWarning;
            return;
        end
        converter=@autosar.simulink.bep.RefactorModelInterface.exportToPreviousConverter;
    elseif obj.ver.isReleaseOrEarlier('R2020b')&&...
        obj.ver.isSLX&&...
        (Simulink.CodeMapping.isMappedToAutosarComponent(obj.modelName)||...
        Simulink.CodeMapping.isMappedToAdaptiveApplication(obj.modelName))


        if~autosarinstalled
            MSLDiagnostic('RTW:autosar:AUTOSARBlocksetRequiredMsg').reportAsWarning;
            return;
        end
        converter=@autosar.simulink.bep.RefactorModelInterface.exportToPreviousConverterForMessages;
    elseif isR2016bOrEarlier(obj.ver)

        converter=@locConvertFor16bAndEarlier;
    elseif isR2018bOrEarlier(obj.ver)

        converter=@locConvertFor17aTo18b;
    end


    if isempty(converter);return;end


    converter(obj);
end

function locConvertFor16bAndEarlier(obj)



    blocks=find_system(obj.modelName,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IsBusElementPort','on');

    blocks=cell2mat(get_param(blocks,'Handle'));

    locConvertBEPBlocks(blocks);
end

function locConvertFor17aTo18b(obj)

    blocks=find_system(obj.modelName,'SearchDepth',1,'LookUnderMasks','all','IsBusElementPort','on');
    blocks=cell2mat(get_param(blocks,'Handle'));

    locConvertBEPBlocks(blocks);
end


function locConvertBEPBlocks(blocks)


    if isempty(blocks);return;end









    components=containers.Map('KeyType','double','ValueType','any');


    portPairs=zeros(0,2);


    lineHandles=[];
    for i=1:numel(blocks)

        curBlock=blocks(i);
        bType=get_param(curBlock,'BlockType');

        comp=get_param(get_param(curBlock,'Parent'),'Handle');


        if~isKey(components,comp)

            components(comp)=containers.Map('KeyType','char','ValueType','any');
        end


        compEntry=components(comp);


        pb=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(curBlock);
        port=pb.port;
        if~isKey(compEntry,port.UUID)

            s.portObj=port;
            s.portType=bType;
            s.portName=port.name;
            s.portNumber=port.indexOne;
            s.elements={};
            s.portHandles=[];
            s.signalNames={};
            compEntry(port.UUID)=s;
        end


        portEntry=compEntry(port.UUID);


        portEntry.elements{end+1}=pb.element;


        lh=get_param(curBlock,'LineHandles');
        ph=get_param(curBlock,'PortHandles');
        switch bType
        case 'Inport'
            lh=lh.Outport;
            ph=ph.Outport;

            portEntry.signalNames{end+1}=get_param(ph,'Name');
        case 'Outport'
            lh=lh.Inport;
            ph=ph.Inport;
        otherwise
            assert(false);
        end

        if(~isempty(ph))
            portEntry.portHandles(end+1)=ph;
        end
        if(~isempty(lh))
            portPairs=[portPairs;locGetPortPairsOfLine(lh)];%#ok<AGROW>
        end


        compEntry(port.UUID)=portEntry;%#ok<NASGU>




        if ishandle(lh)
            lineHandles(end+1)=lh;%#ok<AGROW>
        end
    end


    lineHandles=unique(lineHandles);
    delete_line(lineHandles);


    portPairs=unique(portPairs,'rows','stable');


    comps=components.keys();
    for i=1:numel(comps)
        compEntry=components(comps{i});
        ports=compEntry.keys();
        for j=1:numel(ports)
            portEntry=compEntry(ports{j});

            subsys=locConvertCompositePortToScalarPort(comps{i},portEntry);

            ph=get_param(subsys,'PortHandles');
            switch portEntry.portType
            case 'Inport'
                ph=ph.Outport;
            case 'Outport'
                ph=ph.Inport;
            otherwise
                assert(false);
            end
            assert(numel(ph)==numel(portEntry.portHandles));
            for k=1:numel(ph)
                portPairs(portPairs==portEntry.portHandles(k))=ph(k);
            end
        end
    end


    locConnectPorts(portPairs);
end



function locConnectPorts(portPairs)

    for i=1:size(portPairs,1)
        srcPort=portPairs(i,1);
        dstPort=portPairs(i,2);

        compPath=getfullname(get_param(get_param(srcPort,'Parent'),'Parent'));
        assert(strcmp(compPath,getfullname(get_param(get_param(dstPort,'Parent'),'Parent'))));

        add_line(compPath,locBlockPortStrFromPort(srcPort),locBlockPortStrFromPort(dstPort),'autorouting','on');
    end
end



function portPairs=locGetPortPairsOfLine(lh)
    assert(numel(lh)==1);
    portPairs=zeros(0,2);

    if~ishandle(lh);return;end

    src=get_param(lh,'SrcPortHandle');
    assert(numel(src)==1);

    if~ishandle(src);return;end
    dsts=get_param(lh,'DstPortHandle');

    for i=1:numel(dsts)

        if~ishandle(dsts(i));continue;end
        portPairs=[portPairs;src,dsts(i)];%#ok<AGROW>
    end
end




function h=locConvertCompositePortToScalarPort(parent,portEntry)
    parentFullName=getfullname(parent);

    blockpath=[parentFullName,'/Subsystem_for_',strrep(portEntry.portName,'/','_')];
    h=add_block('built-in/Subsystem',blockpath,'MakeNameUnique','on');
    assert(isempty(get_param(h,'Blocks')));
    hFullName=getfullname(h);
    hWidth=60;


    if(isempty(portEntry.portHandles))

        return;
    end

    origPortPos=get_param(portEntry.portHandles,'Position');
    if iscell(origPortPos);origPortPos=cell2mat(origPortPos);end
    maxX=max(origPortPos(:,1));
    minX=min(origPortPos(:,1));
    centerY=mean(origPortPos(:,2));


    switch portEntry.portType
    case 'Inport'
        numInputs=1;
        numOutputs=numel(portEntry.elements);

        [inports,outports]=locAddPortBlocks(hFullName,numInputs,numOutputs);

        bs=locAddBusSelectorAndMakeConnections(hFullName,portEntry.elements,inports,outports);%#ok<NASGU>


        height=locGetTargetHeight(h);
        locSetPos(h,[minX-hWidth,centerY-height/2,minX,centerY+height/2]);


        inportOffset=60;
        scalarInportH=Simulink.BlockDiagram.Internal.convertCompositePortToScalarPortForExport(parent,portEntry.portType,portEntry.portNumber);
        origInportPos=get_param(scalarInportH,'Position');
        inportWidth=origInportPos(3)-origInportPos(1);
        inportHeight=origInportPos(4)-origInportPos(2);
        locSetPos(scalarInportH,[minX-hWidth-inportWidth/2-inportOffset,centerY-inportHeight/2,minX-hWidth+inportWidth/2-inportOffset,centerY+inportHeight/2]);
        add_line(parentFullName,locBlockPortStr(scalarInportH,1),locBlockPortStr(h,1),'autorouting','on');


        ph=get_param(h,'PortHandles');
        ph=ph.Outport;
        assert(numel(portEntry.signalNames)==numel(ph));
        for i=1:numel(ph)

            if isempty(portEntry.signalNames{i});continue;end
            set_param(ph(i),'Name',portEntry.signalNames{i});
        end
    case 'Outport'

        assert(isempty(portEntry.signalNames));
        numInputs=numel(portEntry.elements);
        numOutputs=1;

        [inports,outports]=locAddPortBlocks(hFullName,numInputs,numOutputs);

        bcs=locAddBusCreatorsAndMakeConnections(hFullName,portEntry.elements,inports,outports);%#ok<NASGU>


        height=locGetTargetHeight(h);
        locSetPos(h,[maxX,centerY-height/2,maxX+hWidth,centerY+height/2]);


        scalarOutportH=Simulink.BlockDiagram.Internal.convertCompositePortToScalarPortForExport(parent,portEntry.portType,portEntry.portNumber);
        add_line(parentFullName,locBlockPortStr(h,1),locBlockPortStr(scalarOutportH,1),'autorouting','on');
        locBeautifyGenericBlock(scalarOutportH);
        locReconnectLinesOfBlock(scalarOutportH);
    otherwise
        assert(false);
    end


    locBeautifySubsystem(h);
end


function str=locBlockPortStrForEnableTriggerPorts(h,suffix)
    escaped_name=strrep(get_param(h,'Name'),'/','//');
    str=sprintf('%s/%s',escaped_name,suffix);
end


function str=locBlockPortStr(h,i)
    escaped_name=strrep(get_param(h,'Name'),'/','//');
    str=sprintf('%s/%d',escaped_name,i);
end


function str=locBlockPortStrFromPort(port)
    block=get_param(get_param(port,'Parent'),'Handle');
    idx=get_param(port,'PortNumber');
    portType=get_param(port,'PortType');

    if(strcmp(portType,'enable'))
        blockName='Enable';
        str=locBlockPortStrForEnableTriggerPorts(block,blockName);
    elseif(strcmp(portType,'trigger'))
        blockName='Trigger';
        str=locBlockPortStrForEnableTriggerPorts(block,blockName);
    else
        str=locBlockPortStr(block,idx);
    end
end


function[inpors,outports]=locAddPortBlocks(compPath,numInputs,numOutputs)
    inpors=arrayfun(@(i)add_block('simulink/Ports & Subsystems/In1',[compPath,'/In1'],'MakeNameUnique','on'),1:numInputs);
    outports=arrayfun(@(i)add_block('simulink/Ports & Subsystems/Out1',[compPath,'/Out1'],'MakeNameUnique','on'),1:numOutputs);
end



function bs=locAddBusSelectorAndMakeConnections(compPath,elements,inport,outports)
    bs=-1;
    assert(numel(inport)==1);
    assert(numel(outports)>=1);
    assert(~isempty(elements));



    outputSignals=elements(~cellfun(@isempty,elements));
    outputSignals=strjoin(outputSignals,',');

    if~isempty(outputSignals)
        bs=add_block('simulink/Signal Routing/Bus Selector',[compPath,sprintf('/Bus\nSelector')],'MakeNameUnique','on','OutputSignals',outputSignals);

        add_line(compPath,locBlockPortStr(inport,1),locBlockPortStr(bs,1),'autorouting','on');
    end


    busSelIdx=1;
    outportIdx=1;
    for i=1:numel(elements)
        if~isempty(elements{i})

            srcBlockPortStr=locBlockPortStr(bs,busSelIdx);
            busSelIdx=busSelIdx+1;
        else

            srcBlockPortStr=locBlockPortStr(inport,1);
        end
        add_line(compPath,srcBlockPortStr,locBlockPortStr(outports(outportIdx),1),'autorouting','on');
        outportIdx=outportIdx+1;
    end
end



function bcs=locAddBusCreatorsAndMakeConnections(compPath,elements,inports,outport)
    bcs=-1;
    assert(numel(outport)==1);
    assert(numel(inports)>=1);
    assert(~isempty(elements));


    if numel(elements)==1&&isempty(elements{1})
        assert(numel(inports)==1);
        add_line(compPath,locBlockPortStr(inports,1),locBlockPortStr(outport,1),'autorouting','on');
        return;
    end


    rootNode=locCreateBusNode('');
    for i=1:numel(elements)

        rootNode=locCreateBusNodesForElArray(rootNode,strsplit(elements{i},'.'));
    end


    [bc,~]=locRealizeBus(compPath,rootNode,inports,1);


    add_line(compPath,locBlockPortStr(bc,1),locBlockPortStr(outport,1),'autorouting','on');
end




function[thisBc,leafIdx]=locRealizeBus(compPath,busNode,inports,leafIdx)
    thisBc=-1;


    if isempty(busNode.children);return;end


    thisBc=add_block('simulink/Signal Routing/Bus Creator',[compPath,sprintf('/Bus\nCreator')],'MakeNameUnique','on','Inputs',num2str(numel(busNode.children)));


    for i=1:numel(busNode.children)

        [childBc,leafIdx]=locRealizeBus(compPath,busNode.children(i),inports,leafIdx);
        if ishandle(childBc)

            lh=add_line(compPath,locBlockPortStr(childBc,1),locBlockPortStr(thisBc,i),'autorouting','on');
        else

            lh=add_line(compPath,locBlockPortStr(inports(leafIdx),1),locBlockPortStr(thisBc,i),'autorouting','on');
            leafIdx=leafIdx+1;
        end

        set_param(lh,'Name',busNode.children(i).name);
    end
end



function parent=locCreateBusNodesForElArray(parent,elArray)
    assert(iscell(elArray));

    frontEl=elArray{1};
    remEl=elArray(2:end);


    [parent,frontElNodeIdx]=locFindOrCreateBusNode(parent,frontEl);


    if~isempty(remEl)

        parent.children(frontElNodeIdx)=locCreateBusNodesForElArray(parent.children(frontElNodeIdx),remEl);
    end
end




function[parent,idx]=locFindOrCreateBusNode(parent,name)

    for i=1:numel(parent.children)
        if strcmp(parent.children(i).name,name)
            idx=i;
            return;
        end
    end


    node=locCreateBusNode(name);
    parent.children=[parent.children,node];
    idx=numel(parent.children);
end


function busNode=locCreateBusNode(name)
    busNode.name=name;
    busNode.children=[];
end


function locBeautifySubsystem(h)
    beautifiers=containers.Map('KeyType','char','ValueType','any');
    beautifiers('Inport')=@locBeautifyInport;
    beautifiers('Outport')=@locBeautifyGenericBlock;
    beautifiers('BusSelector')=@locBeautifyGenericBlock;
    beautifiers('BusCreator')=@locBeautifyGenericBlock;


    blocks=find_system(h,'MatchFilter',@Simulink.match.allVariants);
    blocks=blocks(blocks~=h);
    done=false;

    while~done
        done=true;
        for i=1:numel(blocks)
            bh=blocks(i);

            oldPos=get_param(bh,'Position');

            f=beautifiers(get_param(bh,'BlockType'));
            f(blocks(i));

            if any(oldPos~=get_param(bh,'Position'));done=false;end
        end
    end
end



function locBeautifyInport(h)

    pos=get_param(h,'Position');
    width=pos(3)-pos(1);
    height=pos(4)-pos(2);

    topLeftX=50;
    topLeftY=28;
    yShift=(str2double(get_param(h,'Port'))-1)*60;
    locSetPos(h,[topLeftX,topLeftY+yShift,topLeftX+width,topLeftY+height+yShift]);
end





function locBeautifyGenericBlock(h)

    mid=locGetMidPointOfDrivers(h);

    pos=get_param(h,'Position');
    width=abs(pos(3)-pos(1));

    height=locGetTargetHeight(h);

    offsetX=60;
    pos=[mid(1)-width/2+offsetX,mid(2)-height/2,mid(1)+width/2+offsetX,mid(2)+height/2];
    locSetPos(h,pos);

    locReconnectLinesOfBlock(h);
end



function locReconnectLinesOfBlock(h)

    lh=get_param(h,'LineHandles');
    lh=unique([lh.Inport,lh.Outport]);
    lh=lh(ishandle(lh));

    portPairs=[];
    for i=1:numel(lh)
        portPairs=[portPairs;locGetPortPairsOfLine(lh(i))];%#ok<AGROW>
    end
    portPairs=unique(portPairs,'rows','stable');

    arrayfun(@(h)delete_line(h),lh);
    locConnectPorts(portPairs);
end



function mid=locGetMidPointOfDrivers(h)

    lh=get_param(h,'LineHandles');
    lh=lh.Inport;
    lh=lh(ishandle(lh));
    srcs=get_param(lh,'SrcPortHandle');
    if iscell(srcs);srcs=vertcat(srcs{:});end

    pos=get_param(srcs,'Position');
    if iscell(pos);pos=cell2mat(pos);end

    mid=mean(pos,1);
end



function height=locGetTargetHeight(h)

    ph=get_param(h,'PortHandles');
    numPorts=max(numel(ph.Inport),numel(ph.Outport));
    if numPorts==1

        pos=get_param(h,'Position');
        height=abs(pos(4)-pos(2));
    else

        height=numPorts*40;
    end
end



function locSetPos(h,pos)
    pos(pos>32767)=32767;
    pos(pos<-32767)=-32767;
    set_param(h,'Position',pos);
end
