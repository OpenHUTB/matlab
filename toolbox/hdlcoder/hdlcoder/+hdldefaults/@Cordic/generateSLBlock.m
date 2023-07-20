function generateSLBlock(this,hC,targetBlkPath)



    reporterrors(this,hC);

    slbh=hC.SimulinkHandle;
    validBlk=1;

    try
        originalBlkPath=getfullname(slbh);
    catch
        validBlk=0;
    end

    if validBlk
        isSysObj=isa(hC,'hdlcoder.sysobj_comp');
        usePipelines=this.getUsePipelines(isSysObj);


        if isSysObj
            sysObjHandle=hC.getSysObjImpl;
            cordicInfo=getSysObjInfo(this,hC,sysObjHandle);
            fcn=sysObjHandle.FunctionName;
        else
            cordicInfo=getBlockInfo(this,slbh);
            fcn=get_param(slbh,'Operator');
        end
        iterNum=cordicInfo.iterNum;
        if(isempty(this.getImplParams('CustomLatency')))
            customLatency=0;
        else
            customLatency=this.getImplParams('CustomLatency');
        end
        if(isempty(this.getImplParams('LatencyStrategy')))
            latencyStrategy='MAX';
        else
            latencyStrategy=this.getImplParams('LatencyStrategy');
        end


        targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);

        slpir.PIR2SL.drawCordicTrigBlocks(hC,originalBlkPath,targetBlkPath,fcn,iterNum,usePipelines,customLatency,latencyStrategy);
    end
