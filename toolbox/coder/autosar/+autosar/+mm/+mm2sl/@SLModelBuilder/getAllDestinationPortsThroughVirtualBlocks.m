function dstPortHs=getAllDestinationPortsThroughVirtualBlocks(srcBlk)











    dstPortHs={};
    portHs=getDestinationPorts(srcBlk);
    if isempty(portHs)
        return
    end

    for ii=1:numel(portHs)
        portH=portHs{ii};
        dstBlock=get_param(portH,'Parent');
        dstBlockType=get_param(dstBlock,'BlockType');
        dstBlockParent=get_param(dstBlock,'Parent');
        if strcmp(dstBlockType,'SubSystem')&&...
            strcmp(get_param(dstBlock,'IsSubsystemVirtual'),'on')



            inPortIdx=num2str(get_param(portH,'PortNumber'));
            inPort=find_system(dstBlock,'SearchDepth',1,...
            'FollowLinks','on','LookUnderMasks','all','Type','Block',...
            'BlockType','Inport','Port',inPortIdx);
            if isempty(inPort)
                continue
            end
            subSrcBlk=getfullname(inPort{1});
            ssPortHs=autosar.mm.mm2sl.SLModelBuilder.getAllDestinationPortsThroughVirtualBlocks(subSrcBlk);
            dstPortHs=[dstPortHs,ssPortHs];%#ok<AGROW>
        elseif strcmp(dstBlockType,'Outport')&&...
            ~strcmp(bdroot(dstBlock),dstBlockParent)&&...
            strcmp(get_param(dstBlockParent,'BlockType'),'SubSystem')


            parentSubsys=get_param(dstBlock,'Parent');
            portNum=str2double(get_param(dstBlock,'Port'));
            if isVariantSubsysChoice(parentSubsys)


                parentSubsys=get_param(parentSubsys,'Parent');
            end
            lh=get_param(parentSubsys,'LineHandles');
            indirectDstPortHs=get_param(lh.Outport(portNum),'DstPortHandle');
            dstPortHs=[dstPortHs,indirectDstPortHs];%#ok<AGROW>
        elseif strcmp(dstBlockType,'Outport')&&...
            strcmp(bdroot(dstBlock),dstBlockParent)


            dstPortHs{end+1}=portH;%#ok<AGROW>
        elseif isVirtual(dstBlock)
            indirectDstPortHs=autosar.mm.mm2sl.SLModelBuilder.getAllDestinationPortsThroughVirtualBlocks(dstBlock);
            dstPortHs=[dstPortHs,indirectDstPortHs];%#ok<AGROW>
        else
            dstPortHs{end+1}=portH;%#ok<AGROW>
        end
    end
end

function result=isVirtual(block)




    result=strcmp(get_param(block,'Virtual'),'on');
end

function dstPortHs=getDestinationPorts(block)


    dstPortHs={};
    lineStruct=get_param(block,'LineHandles');
    if~isfield(lineStruct,'Outport')||isempty(lineStruct.Outport)
        return
    end

    lineH=lineStruct.Outport;
    if lineH==-1
        return
    end

    dstPorts=get_param(lineH,'DstPortHandle');
    if iscell(dstPorts)
        dstPorts=[dstPorts{:}];
    end
    for ii=1:numel(dstPorts)
        dstPort=dstPorts(ii);
        if dstPort==-1
            continue
        end
        dstBlock=get_param(dstPort,'Parent');

        blkType=get_param(dstBlock,'BlockType');
        if strcmp(blkType,'Goto')
            blockObj=get_param(dstBlock,'Object');
            fromBlocks={blockObj.FromBlocks.name};
            for jj=1:numel(fromBlocks)
                indirectDstPorts=getDestinationPorts(fromBlocks{jj});
                dstPortHs=[dstPortHs,indirectDstPorts];%#ok<AGROW>
            end
        else
            dstPortHs{end+1}=dstPort;%#ok<AGROW>
        end
    end
end

function isVariantSubsysChoice=isVariantSubsysChoice(blk)

    isVariantSubsysChoice=false;

    blkParent=get_param(blk,'Parent');
    if strcmp(bdroot(blk),blkParent)

        return;
    end

    assert(strcmp(get_param(blkParent,'BlockType'),'SubSystem'),'Expected parent to be a SubSystem');

    if strcmp(get_param(blkParent,'Variant'),'on')
        isVariantSubsysChoice=true;
    end
end



