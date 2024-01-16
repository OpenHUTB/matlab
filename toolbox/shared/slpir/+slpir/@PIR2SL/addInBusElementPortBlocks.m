function portAdded=addInBusElementPortBlocks(this,hP,slBlockName,tgtParentPath,hNtwkSlHandle)

    portAdded=false;
    BusPortHandle=find_system(get_param(hNtwkSlHandle,'Handle'),...
    'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','SearchDepth',1,...
    'blocktype','Inport','port',sprintf('%d',hP.getOrigPIRPortNum+1));
    if isempty(BusPortHandle)

        return;
    end
    portAdded=true;
    setMqAttributes=0;
    if strcmp(get_param(hNtwkSlHandle,'Type'),'block_diagram')
        setMqAttributes=1;
    end
    nPorts=numel(BusPortHandle);
    if nPorts==1&&...
        ~strcmp(get_param(BusPortHandle,'IsBusElementPort'),'on')
        slBlockName=slpir.PIR2SL.getUniqueName(slBlockName);
        gmHandle=add_block(getfullname(BusPortHandle),slBlockName);
        hP.setGMHandle(gmHandle);
        if hP.isData
            this.modelgenset_param(slBlockName,'IOInterface',hP.getIOInterface);
            this.modelgenset_param(slBlockName,'IOInterfaceMapping',hP.getIOInterfaceMapping);
        end
        return;
    end
    if any(contains(get_param(BusPortHandle,'Element'),"."))

        portAdded=false;
        return;
    end

    if nPorts==1
        uniqueBusPortHandles=BusPortHandle;
    else
        [~,IA]=unique(get_param(BusPortHandle,'Element'),'stable');
        uniqueBusPortHandles=BusPortHandle(IA);
        nPorts=numel(uniqueBusPortHandles);
    end
    slAutoRoute=strcmpi(this.AutoRoute,'yes')&&strcmpi(this.AutoPlace,'yes');
    [~,gmPortHandle]=addBlock(this,[],'simulink/Signal Routing/Bus Creator',slBlockName);
    set_param(gmPortHandle,'Inputs',num2str(nPorts));

    srcBlkRef='simulink/Ports & Subsystems/In Bus Element';
    needsToSetAttributes=true;

    for ii=1:nPorts
        obj=get_param(uniqueBusPortHandles(ii),'Object');
        elementName=obj.Name;
        elementPath=slpir.PIR2SL.getUniqueName([tgtParentPath,'/',elementName]);
        busPortName=slpir.PIR2SL.getUniqueName([obj.PortName,'InBus']);

        if ii==1
            bepH=add_block(getfullname(uniqueBusPortHandles(ii)),elementPath,...
            'CreateNewPort','on','PortName',busPortName,...
            'Element',obj.Element);
            srcBlkRef=elementPath;

            if~contains(get_param(bepH,'OutDataTypeStr'),'Inherit:')||...
                strcmp(get_param(bepH,'BusVirtuality'),'nonvirtual')

                needsToSetAttributes=false;
            end

        else
            bepH=add_block(srcBlkRef,elementPath,...
            'CreateNewPort','off','Element',obj.Element);
        end

        if slAutoRoute
            add_line(tgtParentPath,[elementName,'/1'],...
            [hP.Name,'/',num2str(ii)],'autorouting','on');
        else
            add_line(tgtParentPath,[elementName,'/1'],...
            [hP.Name,'/',num2str(ii)]);
        end

        if needsToSetAttributes
            setBusElementPortAttributes(this,obj,bepH,setMqAttributes);
        end
    end

end


