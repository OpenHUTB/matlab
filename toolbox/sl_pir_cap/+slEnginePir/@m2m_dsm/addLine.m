function addLine(this,oldNtwPath,srcPortStr,dstPortStr,isSrcParentSubsys,isDstParentSubsys)


    newNtwPath=[this.fPrefix,oldNtwPath];



    if strcmp(isSrcParentSubsys,'subsys')&&~strcmp(isSrcParentSubsys,'action')
        slashPos=find(srcPortStr=='/');
        srcBlkName=srcPortStr(1:slashPos-1);
        srcPortName=srcPortStr(slashPos+1:end);
        portIndex=get_param([newNtwPath,'/',srcBlkName,'/',srcPortName],'Port');
        srcPortStr=[srcBlkName,'/',num2str(portIndex)];
    end

    if strcmp(isDstParentSubsys,'subsys')&&~strcmp(isDstParentSubsys,'action')
        slashPos=find(dstPortStr=='/');
        dstBlkName=dstPortStr(1:slashPos-1);
        dstPortName=dstPortStr(slashPos+1:end);
        portIndex=get_param([newNtwPath,'/',dstBlkName,'/',dstPortName],'Port');
        dstPortStr=[dstBlkName,'/',num2str(portIndex)];
    end


    newLH=add_line(newNtwPath,srcPortStr,dstPortStr,'autorouting','smart');


    newDstPH=get_param(newLH,'DstPortHandle');
    newSrcPH=get_param(newLH,'SrcPortHandle');
    newDstBH=get_param(newLH,'DstBlockHandle');
    newSrcBH=get_param(newLH,'SrcBlockHandle');



    oldDst=find_system(oldNtwPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Name',get_param(newDstBH,'Name'));

    if~isempty(oldDst)
        oldDst=oldDst{1};
        newPortNum=getDstPortNum(newDstBH,newDstPH);
        oldPHs=get_param(oldDst,'portHandles');
        oldPHs=oldPHs.Inport;
        if length(oldPHs)>=newPortNum
            oldPH=oldPHs(newPortNum);
            oldLH=get_param(oldPH,'Line');
            lineNameStr=get_param(oldLH,'Name');
            set_param(newLH,'Name',lineNameStr);
        end
    end

end


function pNum=getDstPortNum(bH,pH)
    pHs=get_param(bH,'PortHandles');
    if~isempty(pHs.Inport)
        pNum=find(pHs.Inport==pH);
    else
        pNum=-1;
    end
end