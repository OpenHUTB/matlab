function actDstInfo=getActualDstIdx(blk,portIdx,signalIdx)
































    hBlk=get_param(blk,'Handle');
    actDst=getActualDst(hBlk,portIdx);

    if isempty(actDst)||isequal(actDst,-1)
        actDstInfo=actDst;
    else
        pwidth=getActualDstPortWidth(hBlk,portIdx);

        if signalIdx<1
            error('getActualDstIdx:signalidxlt1','Signal index must be > 0')
        elseif signalIdx>pwidth
            error('getActualDstIdx:signalidxgtwidth',...
            'Signal index must not exceed %d',pwidth)
        end

        actDstInfo=[];



        nRows=size(actDst,1);
        for i=1:nRows
            regionLen=actDst(i,3);
            srcStartEl=actDst(i,4);
            if signalIdx>=srcStartEl+1&&signalIdx<=srcStartEl+regionLen
                dstPortH=actDst(i,1);
                dstBlkH=get_param(dstPortH,'ParentHandle');
                if~isPostCompileVirtual(dstBlkH)
                    dstPortIdx=get_param(dstPortH,'PortNumber');
                    dstSigOffset=actDst(i,2)+signalIdx-srcStartEl;
                    actDstInfo=[actDstInfo;...
                    dstBlkH,dstPortIdx,dstSigOffset];%#ok
                end
            end
        end
    end
end