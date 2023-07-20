







function[dstBlocks,srcLabels,srcLabelBlocks]=walkThruVirtualBlockToDsts(lineObj,wrapperH,walkThruMergeBlocks)




    dstBlocks=[];
    srcLabels=[];
    srcLabelBlocks=[];
    origDstBlocks=lineObj.DstBlockHandle;
    for i=1:length(origDstBlocks)
        blkHandle=origDstBlocks(i);
        if(blkHandle>0&&...
            strcmp(get_param(blkHandle,'BlockType'),'Goto'))
            blkObj=get_param(blkHandle,'Object');
            fromHandles={blkObj.FromBlocks.handle};
            for j=1:length(fromHandles)
                fromHandle=fromHandles{j};
                fromPortHandles=get_param(fromHandle,'PortHandles');
                fromOutPortHandle=fromPortHandles.Outport;
                fromLineHandle=get_param(fromOutPortHandle,'Line');
                fromLineObj=get_param(fromLineHandle,'Object');
                [fromDsts,fromLabels,fromLabelBlocks]=...
                autosar.validation.walkThruVirtualBlockToDsts(fromLineObj,wrapperH,walkThruMergeBlocks);
                dstBlocks(end+1:end+length(fromDsts))=fromDsts;
                if~isempty(fromLabels)
                    for k=1:length(fromLabels)
                        srcLabels{end+1}=fromLabels{k};%#ok
                        srcLabelBlocks{end+1}=fromLabelBlocks{k};%#ok
                    end
                end
            end

        elseif(blkHandle>0&&...
            strcmpi(get_param(blkHandle,'BlockType'),'Subsystem')&&...
            strcmp(get_param(blkHandle,'virtual'),'on'))
            inPortHdl=lineObj.DstPortHandle(i);
            inPortIdx=num2str(get_param(inPortHdl,'PortNumber'));
            inPort=find_system(blkHandle,'SearchDepth',1,'LookUnderMasks','all',...
            'FollowLinks','on','Type','Block',...
            'BlockType','Inport','Port',inPortIdx);
            inPortPortHandles=get_param(inPort,'PortHandles');
            inPortOutPortHandle=inPortPortHandles.Outport(1);
            inPortLineHandle=get_param(inPortOutPortHandle,'Line');
            inPortLineObj=get_param(inPortLineHandle,'Object');
            [inPortDsts,inPortLabels,inPortLabelBlocks]=...
            autosar.validation.walkThruVirtualBlockToDsts(inPortLineObj,wrapperH,walkThruMergeBlocks);
            dstBlocks(end+1:end+length(inPortDsts))=inPortDsts;
            if~isempty(inPortLabels)
                for k=1:length(inPortLabels)
                    srcLabels{end+1}=inPortLabels{k};%#ok
                    srcLabelBlocks{end+1}=inPortLabelBlocks{k};%#ok
                end
            end

        elseif(blkHandle>0&&...
            (strcmpi(get_param(blkHandle,'BlockType'),'VariantSource')||strcmpi(get_param(blkHandle,'BlockType'),'VariantSink')))
            portHandles=get_param(blkHandle,'PortHandles');
            inPortOutPortHandle=portHandles.Outport(1);
            inPortLineHandle=get_param(inPortOutPortHandle,'Line');
            inPortLineObj=get_param(inPortLineHandle,'Object');
            [inPortDsts,inPortLabels,inPortLabelBlocks]=...
            autosar.validation.walkThruVirtualBlockToDsts(inPortLineObj,wrapperH,walkThruMergeBlocks);
            dstBlocks(end+1:end+length(inPortDsts))=inPortDsts;
            if~isempty(inPortLabels)
                for k=1:length(inPortLabels)
                    srcLabels{end+1}=inPortLabels{k};%#ok
                    srcLabelBlocks{end+1}=inPortLabelBlocks{k};%#ok
                end
            end

        elseif(blkHandle>0&&...
            strcmp(get_param(blkHandle,'BlockType'),'Outport')&&...
            strcmp(get_param(get_param(blkHandle,'Parent'),'Type'),'block'))&&...
            get_param(get_param(blkHandle,'Parent'),'Handle')~=wrapperH
            ssParent=get_param(blkHandle,'Parent');
            ssParentPortIdx=str2double(get_param(blkHandle,'Port'));
            ssParentPortHandles=get_param(ssParent,'PortHandles');
            ssParentOutPortHandle=ssParentPortHandles.Outport(ssParentPortIdx);
            ssParentLineHandle=get_param(ssParentOutPortHandle,'Line');
            ssParentLineObj=get_param(ssParentLineHandle,'Object');
            [ssParentDsts,ssParentLabels,ssParentLabelBlocks]=...
            autosar.validation.walkThruVirtualBlockToDsts(ssParentLineObj,wrapperH,walkThruMergeBlocks);
            dstBlocks(end+1:end+length(ssParentDsts))=ssParentDsts;
            if~isempty(ssParentLabels)
                for k=1:length(ssParentLabels)
                    srcLabels{end+1}=ssParentLabels{k};%#ok
                    srcLabelBlocks{end+1}=ssParentLabelBlocks{k};%#ok
                end
            end

        elseif(blkHandle>0&&...
            walkThruMergeBlocks&&...
            strcmpi(get_param(blkHandle,'BlockType'),'Merge'))
            portHandles=get_param(blkHandle,'PortHandles');
            outPortHandle=portHandles.Outport(1);
            outPortLineHandle=get_param(outPortHandle,'Line');
            outPortLineObj=get_param(outPortLineHandle,'Object');
            [outPortDsts,outPortLabels,outPortLabelBlocks]=...
            autosar.validation.walkThruVirtualBlockToDsts(outPortLineObj,wrapperH,walkThruMergeBlocks);
            dstBlocks(end+1:end+length(outPortDsts))=outPortDsts;
            if~isempty(outPortLabels)
                for k=1:length(outPortLabels)
                    srcLabels{end+1}=outPortLabels{k};%#ok
                    srcLabelBlocks{end+1}=outPortLabelBlocks{k};%#ok
                end
            end

        else

            dstBlocks(end+1)=blkHandle;%#ok
        end


        if~isempty(lineObj.Name)
            srcLabels{end+1}=lineObj.Name;%#ok
            srcLabelBlocks{end+1}=lineObj.SrcBlockHandle;%#ok
        end
    end

