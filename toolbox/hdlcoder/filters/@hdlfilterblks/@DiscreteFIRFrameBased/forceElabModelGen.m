function retval=forceElabModelGen(this,hN,hPreElabC)











    retval=false;

    mip=this.getImplParams('MultiplierInputPipeline');
    if isempty(mip)
        mip=0;
    end

    mop=this.getImplParams('MultiplierOutputPipeline');
    if isempty(mop)
        mop=0;
    end

    hasInternalPipe=(mip>0)||(mop>0);

    if~isempty(hPreElabC.SimulinkHandle)
        hasEnablePort=strcmp(get_param(hPreElabC.SimulinkHandle,'ShowEnablePort'),'on');
    else
        hasEnablePort=0;
    end



    if(hN.isInConditionalHierarchy||hasEnablePort)&&hasInternalPipe
        retval=true;
    end
