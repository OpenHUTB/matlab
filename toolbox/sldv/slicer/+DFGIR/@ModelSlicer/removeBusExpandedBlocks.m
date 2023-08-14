function removeBusExpandedBlocks(~,sliceXfrmr,synthDeadBlockH)





    trueDeadOrigBlockH=[];
    for m=1:length(synthDeadBlockH)
        if ishandle(synthDeadBlockH(m))
            bObj=get(synthDeadBlockH(m),'Object');
            if bObj.isSynthesized&&...
                strcmp(bObj.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')
                trueDeadOrigBlockH(end+1)=bObj.getTrueOriginalBlock;%#ok<AGROW>
            end
        end
    end
    trueDeadOrigBlockH=unique(trueDeadOrigBlockH);
    for n=1:length(trueDeadOrigBlockH)
        trueDeadSliceBlockH=sliceXfrmr.sliceMapper.findInSlice(trueDeadOrigBlockH(n));
        if ishandle(trueDeadSliceBlockH)
            lhSlice=get_param(trueDeadSliceBlockH,'LineHandles');
            if all(lhSlice.Inport<0)&&all(lhSlice.Outport<0)
                try
                    sliceXfrmr.deleteBlock(trueDeadSliceBlockH);
                catch me %#ok<NASGU>
                end
            end
        end
    end
end
