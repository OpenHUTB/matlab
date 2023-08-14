function blockInfo=getBlockInfo(this,hC)





    impl=getFunctionImpl(this,hC);

    if isempty(impl)
        slbh=hC.SimulinkHandle;
        sat=get_param(slbh,'DoSatur');
        originalBlkPath=getfullname(slbh);
        blockInfo.OutType=get_param(originalBlkPath,'OutDataTypeStr');
        if strcmp(sat,'on')
            blockInfo.ovMode='Saturate';
        else
            blockInfo.ovMode='Wrap';
        end
        blockInfo.rndMode=get_param(slbh,'RndMeth');
        blockInfo.inputSigns=strtrim(get_param(slbh,'Inputs'));
        blockInfo.firstInputSignDivide=false;


        blockInfo.networkName=get_param(slbh,'Name');

        if(isempty(this.getImplParams('UsePipelines')))
            blockInfo.pipeline='on';
        else
            blockInfo.pipeline=this.getImplParams('UsePipelines');
        end

        if(isempty(this.getImplParams('CustomLatency')))
            blockInfo.customLatency=0;
        else
            blockInfo.customLatency=this.getImplParams('CustomLatency');
        end

        if(isempty(this.getImplParams('LatencyStrategy')))
            blockInfo.latencyStrategy='MAX';
        else
            blockInfo.latencyStrategy=this.getImplParams('LatencyStrategy');
        end

        blockInfo.multiplicationMode=get_param(slbh,'Multiplication');

    else
        blockInfo=impl.getBlockInfo(hC);
    end

end
