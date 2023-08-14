
function blkH=i_addBlock(optArgs,blkToAdd)


    blkH=-1;

    blkType=blkToAdd.BlkType;
    blkPath=blkToAdd.BlkPath;
    srcPort=blkToAdd.SrcPort;
    dstPort=blkToAdd.DstPort;




    function status=isInvalidPortHandle(port)
        status=isempty(port)||-1==port;
    end

    if blkType==Simulink.variant.reducer.InsertedBlockType.TERMINATOR||...
        blkType==Simulink.variant.reducer.InsertedBlockType.SIGNALSPECIFICATION||...
        blkType==Simulink.variant.reducer.InsertedBlockType.LABEL_MODE_SISO_VARIANT_SOURCE
        if isInvalidPortHandle(srcPort)
            return;
        end
    else
        if isInvalidPortHandle(dstPort)
            return;
        end
    end


    system=blkToAdd.System;

    sysHandle=get_param(system,'Handle');
    optArgs.SysHandlesToLayout(end+1,1)=sysHandle;


    if~any(optArgs.LayerPlacedSystems==sysHandle)...
        ||~isempty(intersect(optArgs.AddedBlockSrcDstPortVec,[srcPort(:);dstPort(:)]))

        glm=Simulink.internal.variantlayout.LayoutManager(system);
        glm.placeLayers;
        optArgs.LayerPlacedSystems(end+1,1)=sysHandle;
        optArgs.AddedBlockSrcDstPortVec=unique([optArgs.AddedBlockSrcDstPortVec;srcPort(:);dstPort(:)]);
    end


    dist=30;

    blkSize=[10,10];




    if blkType==Simulink.variant.reducer.InsertedBlockType.SIGNALSPECIFICATION
        dist=10;
    end


    if blkType==Simulink.variant.reducer.InsertedBlockType.LABEL_MODE_SISO_VARIANT_SOURCE


        dist=20;
    end



    if blkType==Simulink.variant.reducer.InsertedBlockType.TERMINATOR||...
        blkType==Simulink.variant.reducer.InsertedBlockType.SIGNALSPECIFICATION||...
        blkType==Simulink.variant.reducer.InsertedBlockType.LABEL_MODE_SISO_VARIANT_SOURCE
        placementAttrib=i_getBlockPlacementAttrib(srcPort,dist,blkSize);
    else
        placementAttrib=i_getBlockPlacementAttrib(dstPort,dist,blkSize);
    end

    posBlock=placementAttrib.Position;

    [blkAddPath,blkAddTag]=blkType.getBlockPath();

    blkH=add_block(blkAddPath,blkPath,...
    'MakeNameUnique','on',...
    'Position',posBlock,...
    'ShowName','off',...
    'Tag',blkAddTag);

    set(blkH,'Orientation',placementAttrib.Orientation);

    optArgs.BlocksInserted(end+1)=blkH;


    if blkType==Simulink.variant.reducer.InsertedBlockType.LABEL_MODE_SISO_VARIANT_SOURCE
        blkMask=Simulink.Mask.create(blkH);
        blkMask.Display='disp([''v''])';
        set(blkH,'VariantControls',{'Added_by_VARIANT_REDUCER'});
        set(blkH,'VariantControlMode','label');
    end

end







function placementAttrib=i_getBlockPlacementAttrib(portHandle,dist,blockSize)
    portType=get(portHandle,'PortType');
    theta=get(portHandle,'Rotation');
    portPos=get(portHandle,'Position');
    switch lower(portType)
    case{'inport','trigger','enable','reset'}




        xm=portPos(1)-dist*cos(theta);
        ym=portPos(2)+dist*sin(theta);
    case{'outport','state'}




        xm=portPos(1)+dist*cos(theta);
        ym=portPos(2)-dist*sin(theta);
    end


    posBlock=zeros(1,4);

    posBlock(1)=xm-(blockSize(1)/2)*abs(cos(theta))-(blockSize(1)/2)*abs(sin(theta));
    posBlock(3)=xm+(blockSize(1)/2)*abs(cos(theta))+(blockSize(1)/2)*abs(sin(theta));


    posBlock(2)=ym-(blockSize(2)/2)*abs(cos(theta))-(blockSize(2)/2)*abs(sin(theta));
    posBlock(4)=ym+(blockSize(2)/2)*abs(cos(theta))+(blockSize(2)/2)*abs(sin(theta));



    orientationBlock='right';
    if theta==0
        orientationBlock='right';
    elseif floor(theta)==floor(pi/2)
        orientationBlock='up';
    elseif floor(theta)==floor(pi)
        orientationBlock='left';
    elseif floor(theta)==floor(-pi/2)
        orientationBlock='down';
    end

    placementAttrib.Position=posBlock;
    placementAttrib.Orientation=orientationBlock;
end

