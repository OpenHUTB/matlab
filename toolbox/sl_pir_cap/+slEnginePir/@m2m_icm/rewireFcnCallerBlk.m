function rewireFcnCallerBlk(this,aFcnCallerBlk,aParams,aThisIOsIdx)
    currSys=get_param(aFcnCallerBlk,'Parent');
    this.fRemovedInputLines=containers.Map('KeyType','double','ValueType','any');
    this.fRemovedOutputLines=containers.Map('KeyType','double','ValueType','any');

    for lIdx=1:length(aParams.LineHandles.Inport)
        if lIdx~=aThisIOsIdx(1)&&aParams.LineHandles.Inport(lIdx)>0
            lineObj=get_param(aParams.LineHandles.Inport(lIdx),'object');
            SrcPortHandle=lineObj.SrcPortHandle;
            segInfo=lineObj.get;
            delete_line(aParams.LineHandles.Inport(lIdx));
            portHandles=get_param(aFcnCallerBlk,'PortHandles');
            if(lIdx>aThisIOsIdx(1))
                newLIdx=lIdx-1;
            else
                newLIdx=lIdx;
            end
            DstPortHandle=portHandles.Inport(newLIdx);
            this.fRemovedInputLines(newLIdx)=segInfo;
            add_line(currSys,SrcPortHandle,DstPortHandle,'autorouting','on');
        end
    end

    for lIdx=1:length(aParams.LineHandles.Outport)
        if lIdx~=aThisIOsIdx(2)&&aParams.LineHandles.Outport(lIdx)>0
            lineObj=get_param(aParams.LineHandles.Outport(lIdx),'object');
            DstPortHandle=lineObj.DstPortHandle;
            segInfo=lineObj.get;
            delete_line(aParams.LineHandles.Outport(lIdx));
            portHandles=get_param(aFcnCallerBlk,'PortHandles');
            if(lIdx>aThisIOsIdx(2))
                newLIdx=lIdx-1;
            else
                newLIdx=lIdx;
            end
            SrcPortHandle=portHandles.Outport(newLIdx);
            this.fRemovedOutputLines(newLIdx)=segInfo;
            for hIdx=1:length(DstPortHandle)
                add_line(currSys,SrcPortHandle,DstPortHandle(hIdx),'autorouting','on');
            end
        end
    end

    lineHandles=get_param(aFcnCallerBlk,'LineHandles');
    pIdxes=keys(this.fRemovedInputLines);
    for pIdx=1:length(pIdxes)
        newSeg=get_param(lineHandles.Inport(pIdxes{pIdx}),'object');
        this.setSegmentParam(newSeg,this.fRemovedInputLines(pIdxes{pIdx}));
    end

    pIdxes=keys(this.fRemovedOutputLines);
    for pIdx=1:length(pIdxes)
        newSeg=get_param(lineHandles.Outport(pIdxes{pIdx}),'object');
        this.setSegmentParam(newSeg,this.fRemovedOutputLines(pIdxes{pIdx}));
    end
end