function out=findIPCBlocks(ipcChBlks)




    out={};
    for i=1:numel(ipcChBlks)
        thisChBlk=ipcChBlks{i};
        myDwnBlk=locFindIPCChannelDst(thisChBlk);
        myUpBlk=locFindIPCChannelSrc(thisChBlk);

        while~isIPCReadMyParent(myDwnBlk)&&~isempty(myDwnBlk)
            myDwnBlk=locFindHandlesOfDownstreamBlks(myDwnBlk);
        end
        while~isIPCWriteMyParent(myUpBlk)&&~isempty(myUpBlk)
            myUpBlk=locFindHandlesOfUpstreamBlks(myUpBlk);
        end

        if~isempty(myDwnBlk)
            a.ipcchannel=ipcChBlks{i};
            a.ipcread=get_param(myDwnBlk,'Parent');
            out{end+1}=a;%#ok<AGROW>
        end
        if~isempty(myUpBlk)
            out{end}.ipcwrite=get_param(myUpBlk,'Parent');
        end
    end
    function res=isIPCReadMyParent(blk)
        res=false;
        p=get_param(blk,'Parent');
        if~isequal(get_param(p,'Type'),'block_diagram')
            mType=get_param(p,'MaskType');
            res=isequal(mType,'Interprocess Data Read');
        end
    end
    function res=isIPCWriteMyParent(blk)
        res=false;
        p=get_param(blk,'Parent');
        if~isequal(get_param(p,'Type'),'block_diagram')
            mType=get_param(p,'MaskType');
            res=isequal(mType,'Interprocess Data Write');
        end
    end
end


function out=locFindIPCChannelDst(hBlk)
    [blks,portIdx]=locFindDstBlksForBlk(hBlk);
    out=[];
    excludedMskTypes='Task Manager';
    for i=1:numel(blks)
        lbls=get_param(locFindHandlesOfUpstreamBlks(blks(i)),'Name');



        if~iscell(lbls),lbls={lbls};end
        if~ismember('dataout',lbls),continue,end


        mskType=get_param(blks(i),'MaskType');
        if ismember(mskType,excludedMskTypes),continue;end
        blkType=get_param(blks(i),'BlockType');
        if isequal(blkType,'SubSystem')
            out(end+1)=locFindMatchingSubsystemInport(blks(i),portIdx(i));%#ok<*AGROW> 
        elseif isequal(blkType,'ModelReference')
            out(end+1)=locFindMatchingModelReferenceInport(blks(i),portIdx(i));
        else
            out(end+1)=blks(i);
        end
    end
end


function out=locFindHandlesOfDownstreamBlks(hBlk,varargin)
    [blks,portIdx]=locFindDstBlksForBlk(hBlk);
    excludedMskTypes={};
    out=[];
    if nargin>1
        excludedMskTypes=varargin(1);
    end
    for i=1:numel(blks)
        mskType=get_param(blks(i),'MaskType');
        if ismember(mskType,excludedMskTypes),continue;end
        blkType=get_param(blks(i),'BlockType');
        if isequal(blkType,'SubSystem')
            out(end+1)=locFindMatchingSubsystemInport(blks(i),portIdx(i));
        elseif isequal(blkType,'ModelReference')
            out(end+1)=locFindMatchingModelReferenceInport(blks(i),portIdx(i));
        else
            out(end+1)=blks(i);
        end
    end
end


function out=locFindIPCChannelSrc(hBlk)
    [blks,portIdx]=locFindSrcBlksForBlk(hBlk);
    out=[];
    excludedMskTypes='Task Manager';
    for i=1:numel(blks)
        mskType=get_param(blks(i),'MaskType');
        if ismember(mskType,excludedMskTypes),continue;end
        blkType=get_param(blks(i),'BlockType');
        if isequal(blkType,'SubSystem')
            out(end+1)=locFindMatchingSubsystemOutport(blks(i),portIdx(i));
        elseif isequal(blkType,'ModelReference')
            out(end+1)=locFindMatchingModelReferenceOutport(blks(i),portIdx(i));
        else
            out(end+1)=blks(i);
        end
    end
end


function out=locFindHandlesOfUpstreamBlks(hBlk,varargin)
    [blks,portIdx]=locFindSrcBlksForBlk(hBlk);
    excludedMskTypes={};
    out=[];
    if nargin>1
        excludedMskTypes=varargin(1);
    end
    for i=1:numel(blks)
        mskType=get_param(blks(i),'MaskType');
        if ismember(mskType,excludedMskTypes),continue;end
        blkType=get_param(blks(i),'BlockType');
        if isequal(blkType,'SubSystem')
            out(end+1)=locFindMatchingSubsystemOutport(blks(i),portIdx(i));
        elseif isequal(blkType,'ModelReference')
            out(end+1)=locFindMatchingModelReferenceOutport(blks(i),portIdx(i));
        else
            out(end+1)=blks(i);
        end
    end
end


function out=locFindMatchingModelReferenceInport(mdlBlk,portIdx)
    mdl=get_param(mdlBlk,'ModelName');
    load_system(mdl);
    inpBlks=find_system(mdl,...
    'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth',1,'BlockType','Inport');
    inpBlkHdls=cellfun(@(x)...
    (get_param(x,'Handle')),inpBlks);

    pIdx=portIdx+1;
    idx=arrayfun(@(x)...
    (isequal(str2num(get_param(x,'Port')),pIdx)),inpBlkHdls);%#ok<ST2NM>
    out=inpBlkHdls(idx);
end


function out=locFindMatchingSubsystemInport(subsBlk,portIdx)
    inpBlkHdls=find_system(subsBlk,...
    'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth',1,'BlockType','Inport');

    pIdx=portIdx+1;
    idx=arrayfun(@(x)...
    (isequal(str2num(get_param(x,'Port')),pIdx)),inpBlkHdls);%#ok<ST2NM>
    out=inpBlkHdls(idx);
end


function out=locFindMatchingModelReferenceOutport(mdlBlk,portIdx)
    mdl=get_param(mdlBlk,'ModelName');
    load_system(mdl);
    outBlks=find_system(mdl,...
    'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth',1,'BlockType','Outport');
    outBlkHdls=cellfun(@(x)...
    (get_param(x,'Handle')),outBlks);

    pIdx=portIdx+1;
    idx=arrayfun(@(x)...
    (isequal(str2num(get_param(x,'Port')),pIdx)),outBlkHdls);%#ok<ST2NM>
    out=outBlkHdls(idx);
end


function out=locFindMatchingSubsystemOutport(subsBlk,portIdx)
    outBlkHdls=find_system(subsBlk,...
    'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth',1,'BlockType','Outport');

    pIdx=portIdx+1;
    idx=arrayfun(@(x)...
    (isequal(str2num(get_param(x,'Port')),pIdx)),outBlkHdls);%#ok<ST2NM>
    out=outBlkHdls(idx);
end

function[dstBlks,portIdx]=locFindDstBlksForBlk(hBlk)

    thisBlkPorts=get_param(hBlk,'PortConnectivity');
    qualPorts=thisBlkPorts(...
    arrayfun(@(x)(~isempty(x.DstBlock)),thisBlkPorts));
    dstBlks=arrayfun(@(x)(x.DstBlock),qualPorts);
    portIdx=arrayfun(@(x)(x.DstPort),qualPorts);
end


function[dstBlks,portIdx]=locFindSrcBlksForBlk(hBlk)

    thisBlkPorts=get_param(hBlk,'PortConnectivity');
    qualPorts=thisBlkPorts(...
    arrayfun(@(x)(~isempty(x.SrcBlock)),thisBlkPorts));
    dstBlks=arrayfun(@(x)(x.SrcBlock),qualPorts);
    portIdx=arrayfun(@(x)(x.SrcPort),qualPorts);
end
