function sqrtInfo=getBlockInfo(this,slbh)









    sqrtInfo.networkName=get_param(slbh,'Name');


    sqrtInfo.rndMode=get_param(slbh,'RndMeth');
    sqrtInfo.satMode=strcmpi(get_param(slbh,'SaturateOnIntegerOverflow'),'on');


    if strcmpi(this.getChoice,'on')
        sqrtInfo.algorithm='UseMultiplier';
    else
        sqrtInfo.algorithm='UseShift';
    end

    if(isempty(this.getImplParams('UsePipelines')))
        sqrtInfo.pipeline='on';
    else
        sqrtInfo.pipeline=this.getImplParams('UsePipelines');
    end

    latencyParam=this.getImplParams('LatencyStrategy');

    if(isempty(latencyParam)||strcmpi(latencyParam,'inherit'))
        sqrtInfo.latencyStrategy='MAX';
    else
        sqrtInfo.latencyStrategy=latencyParam;
    end

    if(isempty(this.getImplParams('CustomLatency')))
        sqrtInfo.customLatency=0;
    else
        sqrtInfo.customLatency=this.getImplParams('CustomLatency');
    end




