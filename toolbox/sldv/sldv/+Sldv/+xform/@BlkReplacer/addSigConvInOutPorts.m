function addSigConvInOutPorts(mdlItem)












    if~isa(mdlItem,'Sldv.xform.RepMdlRefBlkTreeNode')
        return;
    end

    BlockH=mdlItem.ReplacementInfo.AfterReplacementH;
    if~strcmp(get_param(BlockH,'BlockType'),'SubSystem')
        return;
    end


    reductionFactor=0.25;

    compIOInfo=mdlItem.CompIOInfo;
    parentH=get_param(get_param(BlockH,'Parent'),'Handle');
    [SSInBlkHs,SSOutBlkHs,SSTriggerBlkHs,SSEnableBlkHs]=Sldv.utils.getBlockHandlesForPortsInSubsys(BlockH);



    MdlInlineMode=mdlItem.ReplacementInfo.Rule.InlineOnlyMode;
    if~MdlInlineMode
        if updateInOutPortHs(mdlItem)
            [parentSSInBlkHs,parentSSOutBlkHs]=...
            Sldv.utils.getBlockHandlesForPortsInSubsys(parentH);
            SSOutBlkHs=parentSSOutBlkHs;
            if~isempty(SSTriggerBlkHs)&&~isempty(SSEnableBlkHs)
                SSInBlkHs=parentSSInBlkHs(3:end);
            elseif~isempty(SSTriggerBlkHs)||~isempty(SSEnableBlkHs)
                SSInBlkHs=parentSSInBlkHs(2:end);
            end
        end
    end



    blkReplacer=Sldv.xform.BlkReplacer.getInstance();
    firstSigConv=true;

    for idx=1:length(SSInBlkHs)
        NeedBusConv=compIOInfo(idx).NeedBusConv;
        if~strcmp(NeedBusConv,'NOT_BUS')&&...
            ~strcmp(NeedBusConv,'NO_CONVERSION')





            if firstSigConv
                firstSigConv=false;
                pos=get_param(BlockH,'Position');
                reduceBlkSize(BlockH,pos,reductionFactor);
            end




            convPos=getConvPos(pos,idx,length(SSInBlkHs),reductionFactor);





            busName=compIOInfo(idx).busName;
            newTypeName=['Bus:',busName];


            complPath=[getfullname(parentH),'/__SLDVAddConversion'];
            convBlkH=blkReplacer.addBlock('built-in/SignalConversion',complPath,...
            'MakeNameUnique','on',...
            'showName','off',...
            'OutDataTypeStr',newTypeName,...
            'Position',convPos);

            updateLinesToBlk(blkReplacer,parentH,convBlkH,BlockH,idx);

            setConversionType(convBlkH,compIOInfo(idx).NeedBusConv);

        end
    end


    idxInc=length(SSInBlkHs);

    for idx=1:length(SSOutBlkHs)
        idxInc=idxInc+1;
        NeedBusConv=compIOInfo(idxInc).NeedBusConv;
        if~strcmp(NeedBusConv,'NOT_BUS')&&...
            ~strcmp(NeedBusConv,'NO_CONVERSION')
            pos=get_param(SSOutBlkHs(idx),'Position');


            moveBlock(SSOutBlkHs(idx),pos,75,0);





            busName=compIOInfo(idxInc).busName;
            newTypeName=['Bus:',busName];



            complPath=[getReplacementPath(mdlItem),'/__SLDVAddConversion'];
            convBlkH=blkReplacer.addBlock('built-in/SignalConversion',complPath,...
            'MakeNameUnique','on',...
            'showName','off',...
            'OutDataTypeStr',newTypeName,...
            'Position',pos);

            if updateInOutPortHs(mdlItem)
                updateLinesToBlk(blkReplacer,parentH,convBlkH,SSOutBlkHs(idx),1);
            else
                updateLinesToBlk(blkReplacer,BlockH,convBlkH,SSOutBlkHs(idx),1);
            end


            setConversionType(convBlkH,compIOInfo(idxInc).NeedBusConv);
        end
    end
end

function needsUpdate=updateInOutPortHs(mdlItem)



    needsUpdate=false;
    if mdlItem.ReplacementInfo.IsMaskConstructedMdlBlk||...
        mdlItem.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
        mdlItem.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk
        needsUpdate=true;
    end
end


function convPos=getConvPos(origPos,index,totalPorts,reductionFactor)





    availWidth=(origPos(3)-origPos(1))*reductionFactor;
    availHeight=(origPos(4)-origPos(2))/(totalPorts+1);

    width=availWidth*(1-reductionFactor);
    height=availHeight*(1-reductionFactor);

    convPos(1)=origPos(1);
    convPos(3)=origPos(1)+width;

    convPos(2)=origPos(2)+(index*availHeight)-(height/2);
    convPos(4)=convPos(2)+height;
end


function reduceBlkSize(blockH,origPos,reductionBy)


    xSize=origPos(3)-origPos(1);
    ySize=origPos(4)-origPos(2);

    xSize=xSize*(1-reductionBy);
    ySize=ySize*(1-reductionBy);

    yCenter=(origPos(2)+origPos(4))/2;

    newPos(1)=origPos(3)-xSize;
    newPos(3)=origPos(3);
    newPos(2)=yCenter-(ySize/2);
    newPos(4)=newPos(2)+ySize;

    set_param(blockH,'Position',newPos);
end

function moveBlock(blockH,origPos,xdiff,ydiff)


    newPos(1)=origPos(1)+xdiff;
    newPos(3)=origPos(3)+xdiff;

    newPos(2)=origPos(2)+ydiff;
    newPos(4)=origPos(4)+ydiff;

    set_param(blockH,'Position',newPos);
end

function replPath=getReplacementPath(mdlItem)



    replPath=mdlItem.ReplacementInfo.BlockToReplaceOriginalPath;
end


function updateLinesToBlk(blkReplacer,SSBlkH,convBlkH,toBlkH,portIdx)


    toBlkPortHs=get_param(toBlkH,'PortHandles');

    if(length(toBlkPortHs.Inport)==1)&&(portIdx==1)

        toPortH=toBlkPortHs.Inport;
    else
        toPortH=toBlkPortHs.Inport(portIdx);
    end
    origLine=get_param(toPortH,'Line');
    origLineName=get_param(origLine,'Name');
    origSrcH=get_param(origLine,'SrcPortHandle');


    blkReplacer.deleteLine(SSBlkH,origSrcH,toPortH);




    convBlkPortHs=get_param(convBlkH,'PortHandles');
    newInLineH=blkReplacer.addLine(SSBlkH,origSrcH,convBlkPortHs.Inport,'autorouting','on');%#ok<NASGU>
    newOutLineH=blkReplacer.addLine(SSBlkH,convBlkPortHs.Outport,toPortH,'autorouting','on');
    set_param(newOutLineH,'Name',origLineName);

end

function setConversionType(convBlkH,needBusConv)




    if isequal(needBusConv,'VIRTUAL_BUS')
        set_param(convBlkH,'ConversionOutput','Virtual Bus');
    else
        set_param(convBlkH,'ConversionOutput','Nonvirtual Bus');
    end
end
