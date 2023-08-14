function srcBlk=findEventSourceBlockForTask(blk,varargin)




    import soc.internal.connectivity.*

    dstBlkPort=[];%#ok<*NASGU>
    inMdlRef=false;
    dstBlksSys=[];

    if nargin==2
        dstBlkPort=varargin{1};
    elseif nargin==3
        dstBlkPort=varargin{1};
        inMdlRef=varargin{2};
    elseif nargin==4
        dstBlkPort=varargin{1};
        inMdlRef=varargin{2};
        dstBlk=varargin{3};
    end
    if hasReachedSrcBlk(blk)
        srcBlk=blk;
    elseif locIsInport(blk)
        dstBlkPort=get_param(blk,'Port');
        dstBlk=get_param(locMyParent(blk),'Handle');
        intermBlk=locGetSrcBlkFromPortCon(dstBlk,dstBlkPort);
        if isempty(intermBlk)
            blk=[];
        elseif locIsInterruptChannel(intermBlk)
            blk=getMatchingInport(intermBlk,dstBlk,dstBlkPort);
            assert(locIsInport(blk),'Expected Inport block')
        elseif locIsPlainSubsystem(intermBlk)
            blk=getMatchingOutport(intermBlk,dstBlk,dstBlkPort);
        else
            blk=intermBlk;
        end
        srcBlk=findEventSourceBlockForTask(blk,dstBlkPort,inMdlRef,dstBlk);
    elseif locIsOutport(blk)
        portNum=get_param(blk,'Port');
        intermBlk=locGetSrcBlkFromPortCon(blk,'1');
        srcBlk=findEventSourceBlockForTask(intermBlk,portNum,inMdlRef);
    elseif locIsMdlReference(blk)
        refMdl=get_param(blk,'ModelName');
        load_system(refMdl);
        blks=locFindBlocksDirectlyUnderMask(refMdl,'Outport');


        if~isempty(get_param(blk,'VariantControl'))


            intermBlk=blks{str2double(dstBlkPort)};
        else
            portCon=get_param(blk,'PortConnectivity');


            idx=arrayfun(@(x)~isempty(x.DstBlock)&&ismember(dstBlk,x.DstBlock)&&...
            ismember(str2double(dstBlkPort),x.DstPort+1),portCon);
            intermBlk=blks{str2double(portCon(idx).Type)};
        end
        srcBlk=findEventSourceBlockForTask(intermBlk,dstBlkPort,true);
    else
        intermBlk=locGetSrcBlkFromPortCon(blk,'1');
        if~isempty(intermBlk)
            srcBlk=findEventSourceBlockForTask(intermBlk,dstBlkPort,inMdlRef);
        else
            srcBlk=blk;
        end
    end
    function res=hasReachedSrcBlk(blk)
        res=locIsTerminalBlk(blk)||...
        (locIsSubsystem(blk)&&inMdlRef);
    end
end


function res=locIsTerminalBlk(blk)

    terminalBlocks={'prociodatalib/IO Data Source','prociodatalib/IO Data Sink',...
    'prociodatalib/Event Source','socmemlib/Memory Channel',...
    'socmemlib/AXI4-Stream to Software','socmemlib/Software to AXI4-Stream',...
    'procinterlib/Interprocess Data Channel',...
    'peripheralslib/ADC Interface','peripheralslib/PWM Interface',...
    'peripheralslib/Audio Capture Interface','peripheralslib/Video Capture Interface'};
    res=locHasNoSrc(blk)||ismember(locRefBlock(blk),terminalBlocks');
end

function res=getMatchingInport(subSys,dstBlk,dstBlkPort)
    blks=locFindBlocksDirectlyUnderMask(subSys,'Inport');


    portCon=locOutportConnectivity(subSys);
    idx1=arrayfun(@(x)(ismember(dstBlk,x.DstBlock)),portCon);
    portCon=portCon(idx1);

    found=false;
    for portIdx=1:numel(portCon)
        for dstIdx=1:numel(portCon(portIdx).DstBlock)
            if isequal(dstBlk,portCon(portIdx).DstBlock(dstIdx))
                if isequal(str2double(dstBlkPort),portCon(portIdx).DstPort(dstIdx)+1)
                    found=true;
                    break;
                end
            end
        end
        if found,break;end
    end
    portCon=portCon(portIdx);
    assert(isscalar(portCon),'Expected to find one port only')
    res=blks(str2double(portCon.Type));
end

function res=getMatchingOutport(subSys,dstBlk,dstBlkPort)
    blks=locFindBlocksDirectlyUnderMask(subSys,'Outport');


    portCon=locOutportConnectivity(subSys);
    idx=arrayfun(@(x)(ismember(dstBlk,x.DstBlock)),portCon);
    portCon=portCon(idx);
    found=false;
    for portIdx=1:numel(portCon)
        for dstIdx=1:numel(portCon(portIdx).DstBlock)
            if isequal(dstBlk,portCon(portIdx).DstBlock(dstIdx))
                if isequal(str2double(dstBlkPort),portCon(portIdx).DstPort(dstIdx)+1)
                    found=true;
                    break;
                end
            end
        end
        if found,break;end
    end
    portCon=portCon(portIdx);
    assert(isscalar(portCon),'Expected to find one port only')
    res=blks(str2double(portCon.Type));
end

function res=locIsInterruptChannel(blk)
    passThroughBlocks={'socmemlib/Interrupt Channel'};
    res=ismember(locRefBlock(blk),passThroughBlocks');
end

function res=locIsPlainSubsystem(blk)
    res=locIsSubsystem(blk)&&~locIsTerminalBlk(blk);
end

function res=locIsMdlReference(blk)
    res=isequal(locBlockType(blk),'ModelReference');
end

function res=locIsSubsystem(blk)
    res=isequal(locBlockType(blk),'SubSystem');
end

function res=locIsInport(blk)
    res=isequal(locBlockType(blk),'Inport');
end

function res=locIsOutport(blk)
    res=isequal(locBlockType(blk),'Outport');
end

function par=locMyParent(blk)
    par=get_param(blk,'Parent');
end

function typ=locBlockType(blk)
    typ=get_param(blk,'Type');
    if~isequal(typ,'block_diagram'),typ=get_param(blk,'BlockType');end
end

function typ=locRefBlock(blk)
    typ=get_param(blk,'Type');
    if~isequal(typ,'block_diagram'),typ=get_param(blk,'ReferenceBlock');end
end

function res=locGetSrcBlkFromPortCon(blk,dstBlkPort)
    res=[];
    portCon=locPortConnectivity(blk);
    if~isempty(portCon)
        idx=arrayfun(@(x)~isempty(x.SrcBlock),portCon);
        portCon=portCon(idx);
        idx=arrayfun(@(x)isequal(x.Type,dstBlkPort),portCon);
        portCon=portCon(idx);
        if~isempty(portCon)&&portCon.SrcBlock~=-1
            res=portCon.SrcBlock;
        end
    end
end

function res=locPortConnectivity(blk)
    res=[];
    if~isequal(get_param(blk,'Type'),'block_diagram')
        res=get_param(blk,'PortConnectivity');
    end
end

function portCon=locOutportConnectivity(blk)
    portCon=locPortConnectivity(blk);
    idx=arrayfun(@(x)~isempty(x.DstBlock),portCon);
    portCon=portCon(idx);
end

function res=locHasNoSrc(blk)
    portCon=locPortConnectivity(blk);
    idx=arrayfun(@(x)~isempty(x.SrcBlock),portCon);
    res=isempty(idx);
end

function blks=locFindBlocksDirectlyUnderMask(subSys,blkType)
    blks=find_system(subSys,'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth',1,'BlockType',blkType);
end