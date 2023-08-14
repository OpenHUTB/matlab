function actSrcInfo=getActualSrcIdx(blk,portIdx,signalIdx)





























    hBlk=get_param(blk,'Handle');
    actSrc=getActualSrc(hBlk,portIdx);

    if isempty(actSrc)||isequal(actSrc,-1)
        actSrcInfo=actSrc;
    else
        pwidth=getActualSrcPortWidth(hBlk,portIdx);

        if signalIdx<1
            error('getActualSrcIdx:sigidxlt1','Signal index must be > 0')
        elseif signalIdx>pwidth
            error('getActualSrcIdx:sigidxgtwidth',...
            'Signal index must not exceed %d',pwidth)
        end

        rowIdx=1;
        width=0;
        for i=1:size(actSrc,1)
            regionLen=actSrc(i,3);
            if signalIdx<=width+regionLen
                sigOffset=signalIdx-width;
                break
            end
            rowIdx=rowIdx+1;
            width=width+regionLen;
        end

        srcPortH=actSrc(rowIdx,1);
        actSrcInfo(1)=get_param(srcPortH,'ParentHandle');
        actSrcInfo(2)=get_param(srcPortH,'PortNumber');
        actSrcInfo(3)=actSrc(rowIdx,2)+sigOffset;
    end

end