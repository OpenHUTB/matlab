function transformedSys=transformDisableSystemOutput(sliceXfrmr,...
    mdl,mdlCopy,deadProcs,simState)



    import Transform.*;

    transformedSys=[];
    refMdlToMdlBlk=sliceXfrmr.ms.refMdlToMdlBlk;

    subsystemH=sliceXfrmr.ms.utilGetAllChildComponents();

    for i=1:length(subsystemH)
        sysH=subsystemH(i);
        sysO=get(sysH,'Object');
        [isMdl,mdlBlkH]=Analysis.isRootOfMdlref(refMdlToMdlBlk,sysH);
        if isMdl

            mdlH=sysO.getCompiledParent;
            bH=mdlBlkH;
        else
            bH=sysH;
            mdlH=-1;
        end
        blksToAdd=[];
        if isSystemToBeRemoved(bH)
            if~isMdl
                ph=get(bH,'PortHandles');
                sysCopy=getCopyHandles(sysH,refMdlToMdlBlk,mdl,mdlCopy);
                if~isempty(sysCopy)
                    [blksToAdd,deadOutIdx]=analyzeSystem(sysH,ph,sysCopy,deadProcs,refMdlToMdlBlk,simState,sliceXfrmr.ms);
                end
            else
                ph=get(bH,'PortHandles');
                sysCopy=getCopyHandles(mdlH,refMdlToMdlBlk,mdl,mdlCopy);
                if~isempty(sysCopy)
                    [blksToAdd,deadOutIdx]=analyzeSystem(mdlH,ph,sysCopy,deadProcs,refMdlToMdlBlk,simState,sliceXfrmr.ms);
                end
            end

            if~isempty(blksToAdd)
                if islogical(blksToAdd)




                    disableActivateSignals(sliceXfrmr,sysCopy);
                else
                    deleteInputSignals(sliceXfrmr,sysCopy);
                    deleteActivateSignals(sliceXfrmr,sysCopy);


                    phSlice=get_param(sysCopy,'PortHandles');
                    for j=deadOutIdx
                        sliceXfrmr.deletePortLine(phSlice.Outport(j));
                    end

                    sliceXfrmr.deleteBlock(sysCopy);

                    for j=1:length(blksToAdd)
                        addReplacementBlocks(sliceXfrmr,blksToAdd(j),bH);
                    end
                end
                transformedSys=[transformedSys;sysH];%#ok<AGROW>
            else


            end
        end
    end

    function yesno=isSystemToBeRemoved(h)
        yesno=false;
        if ismember(h,deadProcs)
            yesno=true;
        end
    end
end

function[blksToAdd,deadOutIdx]=analyzeSystem(sysH,ph,sysCopy,deadProcs,refMdlToMdlBlk,simState,ms)
    import Transform.*;


    blksToAdd=[];
    deadOutIdx=[];

    outPortIndexToReplace=getOutportIdxToBeReplaced(ph);
    if isempty(outPortIndexToReplace)

        return;
    end


    deadOutIdx=setdiff(1:length(ph.Outport),outPortIndexToReplace);
    if isempty(simState)
        [initOutput,maskObj]=getInitialValueOfConditionalSS(sysH,refMdlToMdlBlk);
    else


        [initOutput,maskObj]=getInitialValueFromSimState(sysH,refMdlToMdlBlk,simState);
    end
    hasNonEmptyInitValue=false;
    for n=1:length(initOutput)
        if~isempty(initOutput{n})
            hasNonEmptyInitValue=true;
        end
    end

    if hasNonEmptyInitValue&&systemHasActiveParentConditionalSystem(sysH)
        blksToAdd=true;
        return;
    end

    phInSlice=get_param(sysCopy,'PortHandles');

    for oIdx=outPortIndexToReplace
        oport=get(ph.Outport(oIdx),'Object');

        portPos=get(phInSlice.Outport(oIdx),'Position');
        outBH=getOutportBlock(sysH,oIdx);

        if~strcmp(oport.CompiledPortDataType,'fcn_call')

            if dstBlockCanHaveInitialValue(ph.Outport(oIdx))
                isCondExec=true;
            else
                isCondExec=false;
            end
            isBus=~isempty(strfind(oport.CompiledBusType,'VIRTUAL_BUS'));
            if isCondExec&&isBus
                blockType='BusOutNonExecSystem';
            elseif isCondExec
                blockType='NonExecSystem';
            elseif isBus
                blockType='Bus';
            else
                blockType='Constant';
            end
        else


            blockType='Ground';
        end
        if isempty(initOutput{oIdx})
            initOut='0';
        else
            initOut=initOutput{oIdx};
        end
        b=computeBlockAndLines(outBH,initOut,portPos,blockType,oport,maskObj{oIdx});

        if isempty(blksToAdd)
            blksToAdd=b;
        else
            blksToAdd=[blksToAdd;b];%#ok<AGROW>
        end
    end

    function yesno=systemHasActiveParentConditionalSystem(sysH)
        yesno=false;




        sph=get_param(sysH,'PortHandles');
        if isempty(sph.Outport)
            return;
        end
        sysActDstPH=[];
        for i=1:length(sph.Outport)
            pObj=get(sph.Outport(i),'Object');
            aDst=pObj.getActualDst;
            for j=1:size(aDst,1)
                sysActDstPH(end+1)=aDst(j,1);%#ok<AGROW>
            end
        end
        acestors=ms.utilGetAncestors(sysH);
        for i=1:length(acestors)
            aSysH=acestors(i);
            aSysObj=get(aSysH,'Object');
            if isa(aSysObj,'Simulink.SubSystem')...
                &&(~isempty(aSysObj.PortHandles.Enable)...
                ||~isempty(aSysObj.PortHandles.Trigger)...
                ||~isempty(aSysObj.PortHandles.Ifaction)...
                ||~isempty(aSysObj.PortHandles.Reset)...
                )&&~ismember(aSysH,deadProcs)


                parentActDstPH=[];
                for j=1:length(aSysObj.PortHandles.Outport)
                    paObj=get(aSysObj.PortHandles.Outport(j),'Object');
                    aPDst=paObj.getActualDst;
                    for k=1:size(aPDst,1)
                        parentActDstPH(end+1)=aPDst(k,1);%#ok<AGROW>
                    end
                end
                if~isempty(intersect(sysActDstPH,parentActDstPH))
                    yesno=true;
                    return;
                end
            end
        end
    end

    function opIdx=getOutportIdxToBeReplaced(ph)




        opIdx=[];
        for i=1:length(ph.Outport)
            op=get(ph.Outport(i),'Object');
            aDst=op.getActualDst;
            for dIdx=1:size(aDst,1)
                dstBlkH=get(aDst(dIdx,1),'ParentHandle');
                parentH=ms.utilGetAncestors(dstBlkH);
                if isempty(intersect([dstBlkH,parentH],deadProcs))

                    opIdx(end+1)=i;%#ok<AGROW>
                    break;
                end
            end
        end
    end
    function blkToAdd=computeBlockAndLines(outBH,initOutput,portPos,blockType,...
        oPortObj,maskObj)





        blkToAdd=struct('Position',[],'Value',initOutput,'Name','',...
        'BlockType',blockType,...
        'MaskObject',maskObj,'origPortH',oPortObj.Handle,...
        'outBlkName',get_param(outBH,'Name'),'PropagatedSignals','');
        switch blockType
        case{'Constant','NonExecSystem','BusOutNonExecSystem'}
            width=30;
            halfHeight=7;
        case 'Ground'
            width=20;
            halfHeight=10;
        case 'Bus'
            width=30;
            halfHeight=7;
            blkToAdd.origPortH=oPortObj.Handle;
        end
        blockPos=[portPos(1)-width,...
        portPos(2)-halfHeight,...
        portPos(1),...
        portPos(2)+halfHeight];
        blkToAdd.Position=blockPos;
        blkToAdd.Name=[Simulink.ID.getFullName(sysCopy),'_',get_param(outBH,'Name')];
        if~isempty(oPortObj.PropagatedSignals)


            blkToAdd.PropagatedSignals=oPortObj.PropagatedSignals;
        end

    end
end

function deleteInputSignals(sliceXfrmr,sysH)
    ph=get(sysH,'PortHandles');
    if~isempty(ph.Inport)
        for i=1:length(ph.Inport)
            deleteLine(sliceXfrmr,ph.Inport(i));
        end
    end
end

function deleteActivateSignals(sliceXfrmr,sysH)
    ph=get(sysH,'PortHandles');
    if~isempty(ph.Enable)
        deleteLine(sliceXfrmr,ph.Enable);
    end
    if~isempty(ph.Trigger)
        deleteLine(sliceXfrmr,ph.Trigger);
    end
    if~isempty(ph.Ifaction)
        deleteLine(sliceXfrmr,ph.Ifaction);
    end
end

function disableActivateSignals(sliceXfrmr,sysH)
    ph=get(sysH,'PortHandles');
    if~isempty(ph.Enable)
        connectGround(sysH,ph.Enable)
    end
    if~isempty(ph.Trigger)
        connectGround(sysH,ph.Trigger)
    end
    if~isempty(ph.Ifaction)
        connectGround(sysH,ph.Trigger)
    end
    function connectGround(sysH,ph)
        pos=get(ph,'Position');
        bPath=get(sysH,'Parent');
        deleteLine(sliceXfrmr,ph);
        gndBlk=add_block('built-in/Ground',[bPath,'/Ground'],'MakeNameUnique','on');
        phGnd=get_param(gndBlk,'PortHandles');
        set_param(gndBlk,'Position',[pos(1)-60,pos(2)-30,pos(1)-40,pos(2)-10]);
        add_line(bPath,phGnd.Outport(1),ph,'autorouting','on');
        set_param(gndBlk,'Mask','on','MaskType','ModelSlicer_replaced');
    end
end

function addReplacementBlocks(sliceXfrmr,blkToAdd,bH)
    for i=1:length(blkToAdd)

        switch blkToAdd(i).BlockType
        case 'Constant'
            newBlkH=sliceXfrmr.replaceByConstant(blkToAdd(i).Name,...
            blkToAdd(i).Position,blkToAdd(i).Value,...
            blkToAdd(i).origPortH,...
            blkToAdd(i).MaskObject);
        case 'Ground'
            newBlkH=sliceXfrmr.replaceByGround(blkToAdd(i).Name,...
            blkToAdd(i).Position);
        case 'Bus'
            newBlkH=sliceXfrmr.replaceByBus(blkToAdd(i).Name,...
            blkToAdd(i).Position,blkToAdd(i).origPortH,...
            blkToAdd(i).outBlkName,blkToAdd(i).Value);
        case 'NonExecSystem'
            newBlkH=sliceXfrmr.replaceByNonExecSS(blkToAdd(i).Name,...
            blkToAdd(i).Position,blkToAdd(i).Value,...
            blkToAdd(i).origPortH);
        case 'BusOutNonExecSystem'
            newBlkH=sliceXfrmr.replaceByBusOutNonExecSS(blkToAdd(i).Name,...
            blkToAdd(i).Position,blkToAdd(i).origPortH,...
            blkToAdd(i).outBlkName,blkToAdd(i).Value);
        end
        ph=get(newBlkH,'PortHandle');
        if~isempty(blkToAdd(i).PropagatedSignals)




            if isempty(get(ph.Outport(1),'Name'))
                set(ph.Outport(1),'Name',blkToAdd(i).PropagatedSignals);
            end
        end
        set_param(ph.Outport(1),'MustResolveToSignalObject',...
        get_param(blkToAdd(i).origPortH,'MustResolveToSignalObject'))
        sliceXfrmr.sliceMapper.origTransform(bH,newBlkH,true);
    end
end


function yesno=dstBlockCanHaveInitialValue(portH)
    yesno=false;

    pO=get(portH,'Object');

    actDsts=pO.getActualDst;
    lh=pO.Line;
    if(size(actDsts,1)==1)
        bh=get(actDsts(1,1),'ParentHandle');
        yesno=ismember(get(bh,'BlockType'),{'Merge','RateTransition'});
    elseif lh>0
        dstBH=get(lh,'DstBlockHandle');
        if dstBH>0
            yesno=strcmp(get(dstBH,'BlockType'),'Merge');
        end
    end
end

function deleteLine(sliceXfrmr,pH)

    l=get(pH,'Line');
    if~isempty(l)&&l>0
        sliceXfrmr.deleteLine(l);
    end
end

