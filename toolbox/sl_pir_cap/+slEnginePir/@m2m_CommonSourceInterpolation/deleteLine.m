function deleteLine(m2mObj,aSys,aSrcBlk,aSrcIdx,aDstBlk,aDstIdx)



    sys=[m2mObj.fPrefix,aSys];
    srcIdx=str2double(aSrcIdx)+1;
    oportIdx=num2str(srcIdx);
    oport=[aSrcBlk,'/',oportIdx];
    iportIdx=num2str(str2double(aDstIdx)+1);
    iport=[aDstBlk,'/',iportIdx];


    lineHandles=get_param([sys,'/',aSrcBlk],'LineHandles');
    seg=get_param(lineHandles.Outport(srcIdx),'object');


    m2mObj.fRemovedSrcSegs([sys,'/',oport])=seg.get;
    m2mObj.fRemovedDstSegs([sys,'/',iport])=seg.get;

    delete_line([m2mObj.fPrefix,aSys],oport,iport);
end
