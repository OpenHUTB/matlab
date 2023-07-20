
























function out=getVirtualSSNamedSignalBlocks(mdlH)



    out=containers.Map('KeyType','double','ValueType','any');
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);

    portMap=containers.Map('KeyType','double','ValueType','any');




    [~,mdlBlks]=find_mdlrefs(mdlH,'AllLevels',true,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'ReturnTopModelAsLastElement',false);

    mdlRefMap=containers.Map('KeyType','double','ValueType','any');

    for i=1:numel(mdlBlks)
        blkH=get_param(mdlBlks{i},'Handle');
        currentMdlRef=get_param(blkH,'ModelName');
        if~bdIsLoaded(currentMdlRef)
            load_system(currentMdlRef);
        end

        mdlRefMap(blkH)=currentMdlRef;
        populatePortInfoForBlock(blkH,out,portMap,mdlRefMap);
    end




    allSubsystems=find_system(mdlH,'AllBlocks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'BlockType','SubSystem');
    for i=1:numel(allSubsystems)
        subSSH=allSubsystems(i);
        if(isVirtualSS(subSSH))
            populatePortInfoForBlock(subSSH,out,portMap);
        end
    end


    modelRootOutports=find_system(mdlH,...
    'LookUnderMasks','on',...
    'SearchDepth',1,...
    'BlockType','Outport');
    for i=1:numel(modelRootOutports)
        outportHandle=modelRootOutports(i);
        srcs=slci.internal.getActualSrc(outportHandle,0);
        if(size(srcs,1)==1)
            blkH=srcs(1);
            portNumber=srcs(2);
            portIdentifier=get_param(outportHandle,'Name');
            try
                sig=slResolve(portIdentifier,...
                Simulink.ID.getSID(outportHandle));
            catch
                sig=[];
            end


            if isa(sig,'Simulink.Signal')
                out(blkH)={{portNumber,portIdentifier}};
            end
        end
    end
end


function populatePortInfoForBlock(blkHdl,outMap,portMap,varargin)



    if strcmp(get_param(blkHdl,"BlockType"),'ModelReference')
        mdlRefMap=varargin{1};
    else
        mdlRefMap='';
    end

    prtHandles=get_param(blkHdl,'PortHandles');

    outportNum=numel(prtHandles.Outport);
    for portIndex=1:outportNum
        portH=prtHandles.Outport(portIndex);
        [outBlkH,outPortNum,portIdentifier]=getPortInfo(portMap,mdlRefMap,portH,blkHdl,'Outport',portIndex);
        if~isempty(portIdentifier)
            if~isKey(outMap,outBlkH)
                outMap(outBlkH)={{outPortNum,portIdentifier}};
            else
                val=outMap(outBlkH);
                val(end+1)={{outPortNum,portIdentifier}};%#ok
                outMap(outBlkH)=val;
            end
        end
    end

    inportNum=numel(prtHandles.Inport);
    for portIndex=1:inportNum
        portH=prtHandles.Inport(portIndex);
        [outBlkH,outPortNum,portIdentifier]=getPortInfo(portMap,mdlRefMap,portH,blkHdl,'Inport',portIndex);
        if~isempty(portIdentifier)
            if~isKey(outMap,outBlkH)
                outMap(outBlkH)={{outPortNum,portIdentifier}};
            else
                val=outMap(outBlkH);
                val(end+1)={{outPortNum,portIdentifier}};%#ok
                outMap(outBlkH)=val;
            end
        end
    end

end

function[outBlkH,outPortNum,portIdentifier]=getPortInfo(portMap,mdlRefMap,portH,blkH,portBlockType,portNum)
    if strcmp(get_param(blkH,'BlockType'),'SubSystem')
        [outBlkH,outPortNum,portIdentifier]=...
        getSubSystemPortInfo(portH,blkH,portBlockType,portNum);
    else
        [outBlkH,outPortNum,portIdentifier]=...
        getModelRefBlockPortInfo(portMap,mdlRefMap,blkH,portBlockType,portNum);
    end
end

function[outBlkH,outPortNum,portIdentifier]=getSubSystemPortInfo(portH,blkH,portBlockType,portNum)
    outPortNum=0;
    outBlkH=blkH;

    portBlock=find_system(blkH,'SearchDepth',1,...
    'AllBlocks','on',...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'LookUnderReadProtectedSubsystems','on',...
    'BlockType',portBlockType,'Port',num2str(portNum));

    assert(numel(portBlock)==1);

    if strcmp(portBlockType,'Inport')
        portH=get_param(portBlock,'PortHandles');
        portIdentifier=get_param(portH.Outport,'Name');
        srcs=slci.internal.getActualSrc(blkH,portNum-1);
    else
        portIdentifier=get_param(portH,'Name');
        srcs=slci.internal.getActualSrc(portBlock,0);
    end
    if~isempty(portIdentifier)




        if(size(srcs,1)==1&&srcs(1,5)==-1)
            outBlkH=srcs(1);
            outPortNum=srcs(2);
        end
    end
end

function[outBlkH,outPortNum,portIdentifier]=getModelRefBlockPortInfo(portMap,mdlRefMap,blkH,portBlockType,portNum)
    outPortNum=portNum-1;
    outBlkH=blkH;

    modelRefName=get_param(blkH,'ModelName');
    refModelH=get_param(modelRefName,'Handle');

    mdlRefMap(blkH)=modelRefName;

    portBlock=find_system(refModelH,'SearchDepth',1,...
    'AllBlocks','on',...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'LookUnderReadProtectedSubsystems','on',...
    'BlockType',portBlockType,'Port',num2str(portNum));

    assert(numel(portBlock)==1);
    portBlkH=portBlock(1);

    if isKey(portMap,portBlkH)
        portIdentifier=portMap(portBlkH);
    else




        matchingBlockHandle=checkModelRefMapForExistingBlkHandle(modelRefName,mdlRefMap);
        if~isempty(matchingBlockHandle)&&~portMap.isKey(blkH)
            return
        end
        portIdentifier=getPortIdentifier(portBlkH,portBlockType,1);

        if isempty(portIdentifier)
            if strcmpi(portBlockType,'Outport')
                blks=slci.internal.getActualSrc(portBlkH,0);
            elseif strcmpi(portBlockType,'Inport')
                blks=slci.internal.getActualDst(portBlkH,0);
            end
            if size(blks,1)==1
                blkHdl=blks(1);
                if strcmp(get_param(blkHdl,'BlockType'),'ModelReference')

                    mdlRefPortNum=blks(2)+1;
                    [~,~,portIdentifier]=...
                    getPortInfo(portMap,mdlRefMap,0,blkHdl,portBlockType,mdlRefPortNum);
                end
            end
        end



        if~isempty(portIdentifier)&&strcmp(portBlockType,'Outport')
            portConnectionInfo=get_param(portBlkH,'PortConnectivity');
            if strcmpi(get_param(portConnectionInfo.SrcBlock,'BlockType'),'Inport')
                portIdentifier='';
            end
        end
    end

    portMap(portBlkH)=portIdentifier;

    if~isempty(portIdentifier)
        if strcmp(portBlockType,'Inport')
            srcs=slci.internal.getActualSrc(blkH,portNum-1);
            if size(srcs,1)==1

                outBlkH=srcs(1);
                outPortNum=srcs(2);
                srcPortIdentifier=getPortIdentifier(outBlkH,'Inport',outPortNum+1);
                if~isempty(srcPortIdentifier)

                    portIdentifier='';
                end
            end
        end
    end
end


function portIdentifier=getPortIdentifier(aBlkH,portType,portNum)
    ph=get_param(aBlkH,'PortHandles');
    if strcmpi(portType,'Inport')
        aSignalLine=get_param(ph.Outport(portNum),'Line');
    else
        aSignalLine=get_param(ph.Inport(portNum),'Line');
    end
    aSignalLineObj=get_param(aSignalLine,'Object');
    portIdentifier=aSignalLineObj.Name;
end


function result=isVirtualSS(blk)
    if strcmpi(get_param(blk,'BlockType'),'SubSystem')
        ssType=slci.internal.getSubsystemType(get_param(blk,'Object'));
        result=any(strcmpi(ssType,{'virtual','Function-call'}))...
        ||strcmpi(get_param(blk,'virtual'),'on');
    else
        result=false;
    end
end



function matchingBlockHandle=checkModelRefMapForExistingBlkHandle(currentMdlRef,modelRefMap)
    matchingBlockHandle='';

    matchingIndex=cellfun(@(x)strcmpi(x,currentMdlRef),values(modelRefMap));
    modelRefMapKeys=keys(modelRefMap);




    if numel(matchingIndex(matchingIndex==1))>1
        matchingBlockHandle=modelRefMapKeys(find(matchingIndex,1,'last'));
    end
end
