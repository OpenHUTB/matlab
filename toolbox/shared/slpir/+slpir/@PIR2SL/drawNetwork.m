
function drawNetwork(this,srcParentPath,hN)



    if~hN.shouldDraw
        return;
    end

    tgtParentPath=getTargetModelPath(this,srcParentPath);

    this.genmodeldisp(message('hdlcoder:engine:MsgWorkingHierarchy',tgtParentPath).getString(),3);

    if strcmpi(hN.getKind(),'verbatim')

        return;
    end

    connectNtwkGenericPorts(this,hN,tgtParentPath);

    drawComps(this,tgtParentPath,hN);

    if strcmpi(this.AutoPlace,'yes')
        applyDotLayoutInfo(this,tgtParentPath,hN);
    end

    drawBlkEdges(this,tgtParentPath,hN);

    if strcmpi(this.UseArrangeSystem,'yes')

        Simulink.BlockDiagram.arrangeSystem(tgtParentPath,'FullLayout','True','Animation','False');
    end

end
