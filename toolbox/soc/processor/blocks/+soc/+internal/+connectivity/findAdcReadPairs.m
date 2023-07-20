function out=findAdcReadPairs(mdlName)




    out={};


    addIfBlks=find_system(mdlName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','FollowLinks','on','MaskType','ADC Interface');




    for i=1:numel(addIfBlks)
        thisChBlk=addIfBlks{i};
        myDwnBlks=locFindHandlesOfDownstreamBlks(thisChBlk,'Task Manager');
        for j=1:numel(myDwnBlks)
            myDwnBlk=myDwnBlks(j);
            while~isempty(myDwnBlk)&&~isADCReadMyParent(myDwnBlk)
                myDwnBlk=locFindHandlesOfDownstreamBlks(myDwnBlk,'Task Manager');
            end
            if~isempty(myDwnBlk)
                a.adcinterface=addIfBlks{i};
                a.adcread=get_param(myDwnBlk,'Parent');
                out{end+1}=a;%#ok<AGROW>
            end
        end
    end
    function res=isADCReadMyParent(blk)
        res=false;
        p=get_param(blk,'Parent');
        if~isequal(get_param(p,'Type'),'block_diagram')
            mType=get_param(p,'MaskType');
            res=isequal(mType,'ADC Read');
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
            out(end+1)=locFindMatchingSubsystemInport(blks(i),portIdx(i));%#ok<AGROW>
        elseif isequal(blkType,'ModelReference')
            out(end+1)=locFindMatchingModelReferenceInport(blks(i),portIdx(i));%#ok<AGROW>
        else
            out(end+1)=blks(i);%#ok<AGROW>
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


function[dstBlks,portIdx]=locFindDstBlksForBlk(hBlk)

    thisBlkPorts=get_param(hBlk,'PortConnectivity');
    qualPorts=thisBlkPorts(...
    arrayfun(@(x)(~isempty(x.DstBlock)),thisBlkPorts));
    dstBlks=arrayfun(@(x)(x.DstBlock),qualPorts);
    portIdx=arrayfun(@(x)(x.DstPort),qualPorts);
end

