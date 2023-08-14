function dnnfpgaSharedRenderRamByDepth(gcb,depth,minDepth,ramSrcLibPath,extraArgs)



    if(isempty(depth))
        return;
    end
    if(isempty(minDepth))
        return;
    end
    if(isempty(ramSrcLibPath))
        ramSrcLibPath='dnnfpgaSharedGenericlib/Simple Dual Port RAM System Forced Addr';
    end

    ramPath=[gcb,'/Ram'];
    pos=get_param(ramPath,'Position');
    try
        lh=get_param(ramPath,'LineHandles');
        delete_block(ramPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        redrawRamByDepth(gcb,pos,depth,minDepth,ramSrcLibPath,extraArgs);
    catch me %#ok<NASGU>
    end
end

function redrawRamByDepth(curGcb,pos,depth,minDepth,ramSrcLibPath,extraArgs)
    inputs(1)=createIoInfo('wr_din','wr_din/1');
    inputs(2)=createIoInfo('wr_addr','wr_addr/1');
    inputs(3)=createIoInfo('wr_en','wr_en/1');
    inputs(4)=createIoInfo('rd_addr','rd_addr/1');
    outputs=createIoInfo('rd_dout','rd_dout/1');
    drawRam(minDepth,pos,curGcb,depth,ramSrcLibPath,extraArgs,inputs,outputs);
end

function drawRam(minDepth,pos,curGcbOrig,depth,ramSrcLibPath,extraArgs,inputsOrig,outputsOrig)

    if(depth<=0)
        return;
    end
    [curGcb,inputs,outputs]=createRamSubsystem(pos,[curGcbOrig,'/Ram'],inputsOrig,outputsOrig);
    pos=[305,22,445,178];
    if(depth<=minDepth)
        if(minDepth>=depth*2)

            h=add_block('built-in/DataTypeConversion',[curGcb,'/dtc'],'MakeNameUnique','on','Position',getBlockPos(pos,0,0,'datatypeconversion'));
            dtcBlockName=get_param(h,'name');
            wraddrSrc=getInOut(inputs,'wr_addr');
            add_line(curGcb,wraddrSrc.port,[dtcBlockName,'/1'],'autorouting','on');
            inputs=setInOut(inputs,'wr_addr',[dtcBlockName,'/1']);
            h=add_block('built-in/DataTypeConversion',[curGcb,'/dtc'],'MakeNameUnique','on','Position',getBlockPos(pos,0,1,'datatypeconversion'));
            dtcBlockName=get_param(h,'name');
            rdaddrSrc=getInOut(inputs,'rd_addr');
            add_line(curGcb,rdaddrSrc.port,[dtcBlockName,'/1'],'autorouting','on');
            inputs=setInOut(inputs,'rd_addr',[dtcBlockName,'/1']);
            pos=getBlockPos(pos,2,0,'ram');
        end
        drawAlignedRam(curGcb,pos,minDepth,ramSrcLibPath,extraArgs,inputs,outputs);
        return;
    end

    addrW=ceil(log2(depth));
    if(2^addrW==depth)
        drawAlignedRam(curGcb,pos,depth,ramSrcLibPath,extraArgs,inputs,outputs);
        return;
    end

    if(depth>minDepth)
        lowerHalfDepth=2^(addrW-1);
        lowerHalfInputs=splitInputAddr(curGcb,getBlockPos(pos,0,4,'switch'),inputs,0,lowerHalfDepth-1);
        upperHalfInputs=splitInputAddr(curGcb,getBlockPos(pos,0,2,'switch'),inputs,0,depth-lowerHalfDepth-1);
        selectorInputs=splitInputAddr(curGcb,getBlockPos(pos,0,0,'switch'),inputs,lowerHalfDepth,depth-1);
        [lowerHalfInputs,upperHalfInputs]=fixWriteEnable(curGcb,pos,lowerHalfInputs,upperHalfInputs,selectorInputs);
        innerOutputs=mergeOutputs(curGcb,getBlockPos(pos,8,2,'switch'),selectorInputs,outputs);
        lowerPos=getBlockPos(pos,5,4,'ram');
        drawRam(minDepth,lowerPos,curGcb,lowerHalfDepth,ramSrcLibPath,extraArgs,lowerHalfInputs,innerOutputs.lower);
        upperPos=getBlockPos(pos,5,0,'ram');
        drawRam(minDepth,upperPos,curGcb,depth-lowerHalfDepth,ramSrcLibPath,extraArgs,upperHalfInputs,innerOutputs.upper);
    else
        drawAlignedRam([curGcb,'/Ram'],pos,2^addrW,ramSrcLibPath,extraArgs,inputs,outputs);
    end
end

function info=getInOut(ioInfo,portName)




    switch lower(portName)
    case{'wr_din'}
        idx=1;
    case{'wr_addr'}
        idx=2;
    case{'wr_en'}
        idx=3;
    case{'rd_addr'}
        idx=4;
    case{'rd_dout'}
        idx=1;
    otherwise
        assert(false);
    end
    info=ioInfo(idx);
end

function ioInfo=setInOut(ioInfo,portName,value)




    switch lower(portName)
    case{'wr_din'}
        idx=1;
    case{'wr_addr'}
        idx=2;
    case{'wr_en'}
        idx=3;
    case{'rd_addr'}
        idx=4;
    case{'rd_dout'}
        idx=1;
    otherwise
        assert(false);
    end
    ioInfo(idx).port=value;
end

function ioInfo=createIoInfo(portName,port)
    ioInfo.name=portName;
    ioInfo.port=port;
end

function blockPos=getBlockPos(origin,xOffset,yOffset,blockName)
    xSpacer=[80,0,0,0];
    ySpacer=[0,80,0,0];
    switch lower(blockName)
    case{'bit slice'}
        blockSize=[195,304,260,326];
    case{'datatypeconversion'}
        blockSize=[195,304,260,326];
    case{'logic'}
        blockSize=[195,349,225,381];
    case{'ram'}
        blockSize=[315,87,455,243];
    case{'switch'}
        blockSize=[195,235,245,275];
    otherwise
        assert(false);
    end
    blockPos=origin+xOffset*xSpacer+yOffset*ySpacer;
    blockPos=[blockPos(1),blockPos(2),blockPos(1)+blockSize(3)-blockSize(1),blockPos(2)+blockSize(4)-blockSize(2)];
end

function[lowerHalfInputs,upperHalfInputs]=fixWriteEnable(curGcb,pos,lowerHalfInputs,upperHalfInputs,selectorInputs)

    selectSrc=getInOut(selectorInputs,'wr_addr');
    weSrc=getInOut(lowerHalfInputs,'wr_en');

    h=add_block('built-in/DataTypeConversion',[curGcb,'/dtc'],'MakeNameUnique','on','Position',getBlockPos(pos,1,0,'datatypeconversion'),'OutDataTypeStr','boolean');
    dtcBlockName=get_param(h,'name');

    h=add_block('built-in/Logic',[curGcb,'/Not'],'MakeNameUnique','on','Position',getBlockPos(pos,3,0,'logic'),'Operator','NOT');
    notBlockName=get_param(h,'name');

    h=add_block('built-in/Logic',[curGcb,'/And'],'MakeNameUnique','on','Position',getBlockPos(pos,4,1,'logic'),'Operator','AND');
    lowerAndBlockName=get_param(h,'name');
    h=add_block('built-in/Logic',[curGcb,'/And'],'MakeNameUnique','on','Position',getBlockPos(pos,4,0,'logic'),'Operator','AND');
    upperAndBlockName=get_param(h,'name');
    add_line(curGcb,selectSrc.port,[dtcBlockName,'/1'],'autorouting','on');
    add_line(curGcb,[dtcBlockName,'/1'],[notBlockName,'/1'],'autorouting','on');
    add_line(curGcb,[notBlockName,'/1'],[lowerAndBlockName,'/1'],'autorouting','on');
    add_line(curGcb,weSrc.port,[lowerAndBlockName,'/2'],'autorouting','on');
    add_line(curGcb,[dtcBlockName,'/1'],[upperAndBlockName,'/1'],'autorouting','on');
    add_line(curGcb,weSrc.port,[upperAndBlockName,'/2'],'autorouting','on');
    lowerHalfInputs=setInOut(lowerHalfInputs,'wr_en',[lowerAndBlockName,'/1']);
    upperHalfInputs=setInOut(upperHalfInputs,'wr_en',[upperAndBlockName,'/1']);
end

function innerOutputs=mergeOutputs(curGcb,pos,selectorInput,outputs)
    innerOutputs.upper=createIoInfo('rd_dout','');
    innerOutputs.lower=createIoInfo('rd_dout','');
    for i=1:length(outputs)

        switchPos=getBlockPos(pos,2,i,'switch');
        h=add_block('built-in/Switch',[curGcb,'/switch'],'MakeNameUnique','on','Position',switchPos,'Criteria','u2 ~= 0');
        switchName=get_param(h,'name');
        selectSrc=getInOut(selectorInput,'rd_addr');

        h=add_block('built-in/Delay',[curGcb,'/delay'],'MakeNameUnique','on','Position',getBlockPos(pos,0,0,'logic'),'DelayLength','1');
        delayBlockName=get_param(h,'name');
        h=add_block('built-in/DataTypeConversion',[curGcb,'/dtc'],'MakeNameUnique','on','Position',getBlockPos(pos,1,0,'datatypeconversion'),'OutDataTypeStr','boolean');
        dtcBlockName=get_param(h,'name');
        add_line(curGcb,selectSrc.port,[delayBlockName,'/1'],'autorouting','on');
        add_line(curGcb,[delayBlockName,'/1'],[dtcBlockName,'/1'],'autorouting','on');
        add_line(curGcb,[dtcBlockName,'/1'],[switchName,'/2'],'autorouting','on');

        add_line(curGcb,[switchName,'/1'],outputs(i).port,'autorouting','on');

        innerOutputs.upper=setInOut(innerOutputs.upper,'rd_dout',[switchName,'/1']);
        innerOutputs.lower=setInOut(innerOutputs.lower,'rd_dout',[switchName,'/3']);
    end
end

function idx=bound2idx(bound)
    if(bound==0)
        idx=0;
    else
        idx=ceil(log2(bound+1)-1);
    end
end

function lowerInputs=splitInputAddr(curGcb,pos,inputs,lowerBound,upperBound)
    assert(lowerBound<=upperBound);
    lowerInputs=inputs;

    lowerIdx=bound2idx(lowerBound);
    upperIdx=bound2idx(upperBound);
    wrAddr=getInOut(inputs,'wr_addr');
    i=1;
    slicePos=getBlockPos(pos,0,i,'bit slice');
    h=add_block('hdlsllib/HDL Operations/Bit Slice',[curGcb,'/Bit Slice'],'MakeNameUnique','on','Position',slicePos,'lidx',num2str(upperIdx),'ridx',num2str(lowerIdx));
    blkName=get_param(h,'name');

    add_line(curGcb,[wrAddr.name,'/1'],[blkName,'/1'],'autorouting','on');

    lowerInputs=setInOut(lowerInputs,'wr_addr',[blkName,'/1']);

    rdAddr=getInOut(inputs,'rd_addr');
    i=2;
    slicePos=getBlockPos(pos,0,i,'bit slice');
    h=add_block('hdlsllib/HDL Operations/Bit Slice',[curGcb,'/Bit Slice'],'MakeNameUnique','on','Position',slicePos,'lidx',num2str(upperIdx),'ridx',num2str(lowerIdx));
    blkName=get_param(h,'name');

    add_line(curGcb,[rdAddr.name,'/1'],[blkName,'/1'],'autorouting','on');

    lowerInputs=setInOut(lowerInputs,'rd_addr',[blkName,'/1']);
end

function[curGcb,newInputs,newOutputs]=createRamSubsystem(pos,curGcbOrig,inputs,outputs)
    root=fileparts(curGcbOrig);

    inPortPos=[195,98,225,112];
    outPortPos=[1180,138,1210,152];
    portSpacer=[0,40,0,40];

    h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];

    for i=1:length(inputs)
        add_block('built-in/InPort',[curGcb,'/',inputs(i).name],'Position',inPortPos);
        inPortPos=inPortPos+portSpacer;
    end
    for i=1:length(outputs)
        add_block('built-in/OutPort',[curGcb,'/',outputs(i).name],'Position',outPortPos);
        outPortPos=outPortPos+portSpacer;
    end

    for i=1:length(inputs)
        add_line(root,inputs(i).port,[subBlockName,'/',num2str(i)],'autorouting','on');
    end
    for i=1:length(outputs)
        add_line(root,[subBlockName,'/',num2str(i)],outputs(i).port,'autorouting','on');
    end
    newInputs=setInOut(inputs,'wr_din','wr_din/1');
    newInputs=setInOut(newInputs,'wr_addr','wr_addr/1');
    newInputs=setInOut(newInputs,'wr_en','wr_en/1');
    newInputs=setInOut(newInputs,'rd_addr','rd_addr/1');
    newOutputs=setInOut(outputs,'rd_dout','rd_dout/1');

end

function drawAlignedRam(curGcb,ramPos,depth,ramSrcLibPath,extraArgs,inputs,outputs)




    ramBlockName=[curGcb,'/Ram'];
    h=add_block(ramSrcLibPath,ramBlockName,'MakeNameUnique','on','Position',ramPos,'ram_size',num2str(ceil(log2(depth))),extraArgs{:});
    ramBlockName=get_param(h,'name');

    for i=1:length(inputs)
        add_line(curGcb,inputs(i).port,[ramBlockName,'/',num2str(i)],'autorouting','on');
    end
    for i=1:length(outputs)
        add_line(curGcb,[ramBlockName,'/',num2str(i)],outputs(i).port,'autorouting','on');
    end
end


