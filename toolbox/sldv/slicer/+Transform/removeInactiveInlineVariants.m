function removeInactiveInlineVariants(sliceXfrmr,mdl,mdlCopy,options,replaceModelBlockH)







    import Transform.*;
    refMdlToMdlBlk=sliceXfrmr.ms.refMdlToMdlBlk;
    allMdlH=get_param(mdl,'Handle');
    if options.InlineOptions.ModelBlocks
        refMdlH=arrayfun(@(blk)get_param(get_param(blk,'ModelName'),'handle'),replaceModelBlockH);
        allMdlH=[allMdlH,refMdlH];
    end
    lumOpt=AtomicGroup.msLookUnderMasks(options);
    fllOpt=AtomicGroup.msFollowLinks(options);
    fssrefOpt=AtomicGroup.msLookInsideSubsystemReference(options);

    inactiveH=[];
    for i=1:length(allMdlH)
        inactiveH=[inactiveH;AtomicGroup.getInactiveVariantBlocks(allMdlH(i),lumOpt,fllOpt,fssrefOpt)];%#ok<AGROW>
    end



    handlesCopy=getCopyHandles(inactiveH,refMdlToMdlBlk,mdl,mdlCopy);
    handlesCopy=handlesCopy(ishandle(handlesCopy));

    arrayfun(@(h)disconnectBlock(sliceXfrmr,h),handlesCopy);
    arrayfun(@(h)deleteBlockSafe(sliceXfrmr,h),handlesCopy);


    [sourceH,sinkH]=AtomicGroup.getVariantSourceSinkBlocks(mdlCopy,lumOpt,fllOpt,fssrefOpt);

    allVariantH=[sourceH;sinkH];
    if isempty(allVariantH)
        return;
    end

    mapper=Transform.CopyToOrigMap(mdl,mdlCopy,refMdlToMdlBlk);
    for i=1:length(allVariantH)
        blkH=allVariantH(i);
        ph=get_param(blkH,'porthandles');
        sys=get_param(blkH,'parent');
        try
            Idx=getActiveVariantPort(mapper.getOriginalBlock(blkH));
            srcH=[];
            dstH=[];
            if strcmp(get_param(blkH,'BlockType'),'VariantSource')
                inLine=get_param(ph.Inport(Idx),'line');
                outLine=get_param(ph.Outport(1),'line');
            else
                inLine=get_param(ph.Inport(1),'line');
                outLine=get_param(ph.Outport(Idx),'line');
            end
            if inLine~=-1&&outLine~=-1
                dstH=get_param(outLine,'DstPortHandle');
                dstH=dstH(ishandle(dstH));
                srcH=get_param(inLine,'SrcPortHandle');
                srcH=repmat(srcH,numel(dstH),1);
            end
            disconnectBlock(sliceXfrmr,blkH);
            deleteBlockSafe(sliceXfrmr,blkH);

            if~isempty(srcH)&&~isempty(dstH)
                add_line(sys,srcH,dstH,'autorouting','on');
            end
        catch Mx

        end
    end
end

function idx=getActiveVariantPort(blkH)






    portIdxStr=get_param(blkH,'CompiledActiveVariantPort');
    idx=str2double(portIdxStr);
end

