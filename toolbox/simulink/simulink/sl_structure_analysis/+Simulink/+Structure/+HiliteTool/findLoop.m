function loopInfo=findLoop(blockPath,varargin)






















    assert(isBlockPath(blockPath),...
    message('Simulink:HiliteTool:LoopDetectionUnexpectedInputType'));

    numArgin=length(varargin)+1;

    if numArgin==1

        isInputBlock=true;
    elseif numArgin==2


        isInputBlock=false;
        secondInput=varargin{1};
        isSecondInputPortHandle=ishandle(secondInput)&&...
        strcmpi(get_param(secondInput,'Type'),'port');
        assert(isSecondInputPortHandle,...
        message('Simulink:HiliteTool:LoopDetectionUnexpectedInputType'));
    else
        error(message('Simulink:HiliteTool:LoopDetectionUnexpectedInputNumber'));
    end

    warnID="Simulink:blocks:BusSelectorUnconnected";
    os=warning('off',warnID);
    c=onCleanup(@()warning(os.state,warnID));

    blockPath.validate;

    if blockPath.getLength>1






        blockPath=Simulink.BlockPath(blockPath.getBlock(blockPath.getLength));
        blockPath.validate;
    end


    prtBlockPath=blockPath.getParent;


    if isBlockPath(prtBlockPath)
        prtBlockPath.validate;
        path=prtBlockPath.getBlock(prtBlockPath.getLength);
    else

        path=prtBlockPath;
    end






    path=retrieveNewLineFromBP(path);
    ref=SLM3I.Util.getDiagram(path);
    assert(ref.diagram.isvalid);


    bpLength=blockPath.getLength;
    blockName=blockPath.getBlock(bpLength);
    blockHandle=get_param(blockName,'Handle');
    loopInfo.ParentSystem=get_param(get_param(blockHandle,'Parent'),'Handle');


    loopInfo.IsInLoop=false;
    loopInfo.Elements=[];










    import Simulink.Structure.HiliteTool.*;

    if isInputBlock

        ph=get_param(blockHandle,'PortHandles');
        blkInport=ph.Inport;
        blkOutport=ph.Outport;



        if~Simulink.Structure.HiliteTool.internal.isImplicitConnectionBlock(blockHandle)&&...
            (isempty(blkInport)||isempty(blkOutport))||...
            (isempty(blkInport)&&isempty(blkOutport))

            return
        end

        if~isempty(blkInport)&&~isempty(blkOutport)

            if length(blkInport)<length(blkOutport)
                ports=blkInport;
                oppositePorts=blkOutport;
            else
                ports=blkOutport;
                oppositePorts=blkInport;
            end
        elseif isempty(blkInport)
            ports=blkOutport;
            oppositePorts=blkInport;
        else
            ports=blkInport;
            oppositePorts=blkOutport;
        end

        [loopInfo.IsInLoop,loopInfo.Elements]=getElementsInLoopForBlockInput(blockHandle,ports,oppositePorts);
    end











    if~isInputBlock

        port=secondInput;
        block=get_param(get_param(port,'Parent'),'Handle');
        loopInfo.ParentSystem=get_param(get_param(block,'Parent'),'Handle');

        portHandles=get_param(block,'PortHandles');
        isInport=strcmpi(get_param(port,'PortType'),'inport');


        if isInport
            oppositePorts=portHandles.Outport;
        else
            oppositePorts=portHandles.Inport;
        end


        if isempty(oppositePorts)&&~Simulink.Structure.HiliteTool.internal.isImplicitConnectionBlock(blockHandle)
            return
        end

        [loopInfo.IsInLoop,loopInfo.Elements]=getElementsInLoopForPortInput(block,port,oppositePorts);
    end
end



function[isInLoop,elementsInLoop]=getElementsInLoopForPortInput(prtBlock,port,oppositePorts)

    impactRegionOfOrigPort=findImpactRegionUnionForPorts(port);
    isInLoop=ismember(prtBlock,impactRegionOfOrigPort);
    elementsInLoop=[];

    if~isInLoop
        return
    end

    if~isempty(oppositePorts)
        oppositePortsInRegion=findPortsInGivenImpactRegion(oppositePorts,impactRegionOfOrigPort);
        unionImpactRegionOfOppositePorts=findImpactRegionUnionForPorts(oppositePortsInRegion);
        elementsInLoop=unique(intersect(impactRegionOfOrigPort,unionImpactRegionOfOppositePorts));
    else
        [port,bdref]=getParentPortForPortBlock(prtBlock);%#ok
        assert(ismember(get_param(port,'Line'),impactRegionOfOrigPort),...
        'We would not be cheking this if this port is not in the impact region.');
        prtImpactRegion=findImpactRegionUnionForPorts(port);
        elementsInLoop=unique(intersect(impactRegionOfOrigPort,prtImpactRegion));
    end

    assert(~isempty(elementsInLoop),'Loop elements should not be empty for this model.');
end


function[isInLoop,elementsInLoop]=getElementsInLoopForBlockInput(blockHandle,ports,oppositePorts)

    elementsInLoop=[];

    unionImpactRegionOfPorts=findImpactRegionUnionForPorts(ports);
    isInLoop=ismember(blockHandle,unionImpactRegionOfPorts);

    if~isInLoop
        return
    end

    groupOpposite=[];
    if~isempty(oppositePorts)
        oppositePortsInRegion=findPortsInGivenImpactRegion(oppositePorts,unionImpactRegionOfPorts);
        if~isempty(oppositePortsInRegion)
            unionImpactRegionOfOppositePorts=findImpactRegionUnionForPorts(oppositePortsInRegion);
            groupOpposite=unique(intersect(unionImpactRegionOfPorts,unionImpactRegionOfOppositePorts));
        end
    end


    enablePort=getEnablePortForBlock(blockHandle);
    groupEnable=[];
    if~isempty(enablePort)&&ismember(get_param(enablePort,'Line'),unionImpactRegionOfPorts)
        enablePortInRegion=findPortsInGivenImpactRegion(enablePort,unionImpactRegionOfPorts);
        if~isempty(enablePortInRegion)
            impactRegionOfEnablePort=findImpactRegionUnionForPorts(enablePortInRegion);
        end
        groupEnable=unique(intersect(unionImpactRegionOfPorts,impactRegionOfEnablePort));
    end


    triggerPort=getTriggerPortForBlock(blockHandle);
    groupTrigger=[];
    if~isempty(triggerPort)&&ismember(get_param(triggerPort,'Line'),unionImpactRegionOfPorts)
        triggerPortInRegion=findPortsInGivenImpactRegion(triggerPort,unionImpactRegionOfPorts);
        if~isempty(triggerPortInRegion)
            impactRegionOfTriggerPort=findImpactRegionUnionForPorts(triggerPortInRegion);
        end
        groupTrigger=unique(intersect(unionImpactRegionOfPorts,impactRegionOfTriggerPort));
    end



    resetPort=getResetPortForBlock(blockHandle);
    groupReset=[];
    if~isempty(resetPort)&&ismember(get_param(resetPort,'Line'),unionImpactRegionOfPorts)
        resetPortInRegion=findPortsInGivenImpactRegion(resetPort,unionImpactRegionOfPorts);
        if~isempty(resetPortInRegion)
            impactRegionOfResetPort=findImpactRegionUnionForPorts(resetPortInRegion);
        end
        groupReset=unique(intersect(unionImpactRegionOfPorts,impactRegionOfResetPort));
    end

    elementsInLoop=unique(union(union(union(groupOpposite,groupEnable),groupTrigger),groupReset));

    if isempty(elementsInLoop)


        [port,bdref]=getParentPortForPortBlock(blockHandle);%#ok

        assert(ismember(get_param(port,'Line'),unionImpactRegionOfPorts),...
        'We would not be cheking this if this port is not in the impact region.');

        prtImpactRegion=findImpactRegionUnionForPorts(port);
        elementsInLoop=unique(intersect(unionImpactRegionOfPorts,prtImpactRegion));

    end

    assert(~isempty(elementsInLoop),'Loop elements should not be empty for this model.');
end


function[port,bdref]=getParentPortForPortBlock(blk)



    blkType=get_param(blk,'BlockType');
    if strcmpi(blkType,'Inport')||strcmpi(blkType,'Outport')

        portId=str2double(get_param(blk,'Port'));
        prtBlk=get_param(blk,'Parent');
        assert(strcmpi(get_param(prtBlk,'Type'),'block'),...
        'We would not be checking loop elements if the inport/outport was on top level.');


        prtDiagram=get_param(prtBlk,'Parent');

        bdref=SLM3I.Util.getDiagram(prtDiagram);
        assert(bdref.diagram.isvalid);

        prtPortHandles=get_param(prtBlk,'PortHandles');
        if strcmpi(blkType,'Inport')
            port=prtPortHandles.Inport(portId);
        end

        if strcmpi(blkType,'Outport')
            port=prtPortHandles.Outport(portId);
        end

    else
        port=[];
        bdref=[];
    end
end

function unionImpactRegion=findImpactRegionUnionForPorts(ports)

    assert(~isempty(ports));
    unionImpactRegion=[];
    isInport=any(strcmpi(get_param(ports(1),'PortType'),{'inport','trigger','enable'}));
    for p=ports
        line=get_param(p,'Line');
        impactRegionOfPort=getImpactRegionForLineOnGivenDirection(isInport,line);
        unionImpactRegion=union(impactRegionOfPort,unionImpactRegion);
    end
end

function impactRegion=getImpactRegionForLineOnGivenDirection(isTraceSrc,line)


    if line==-1
        impactRegion=[];
    else
        isTraceAll=true;
        hiliteInfo=Simulink.Structure.HiliteTool.internal.getHiliteInfo(isTraceSrc,line,isTraceAll);
        impactRegion=[hiliteInfo.graphHighlightMap{:,2}];
    end
end

function portsInRegion=findPortsInGivenImpactRegion(ports,region)

    assert(isvector(ports)&&isvector(region),'Both inputs need to be vectors.');
    lines=arrayfun(@(p)get_param(p,'Line'),ports);
    portsInRegion=ports(ismember(lines,region));
end

function bool=isBlockPath(x)
    bool=isa(x,'Simulink.BlockPath');
end

function ep=getEnablePortForBlock(blk)
    portHandles=get_param(blk,'PortHandles');
    ep=portHandles.Enable;
end

function tp=getTriggerPortForBlock(blk)
    portHandles=get_param(blk,'PortHandles');
    tp=portHandles.Trigger;
end

function tp=getResetPortForBlock(blk)
    portHandles=get_param(blk,'PortHandles');
    tp=portHandles.Reset;
end

function path=retrieveNewLineFromBP(path)

    obj=get_param(path,'object');
    path=obj.getFullName();
end
