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

    addpipe=this.getImplParams('AddPipelineRegisters');
    if isempty(addpipe)
        addpipe=0;
    else
        addpipe=strcmpi(addpipe,'on');
    end

    hasInternalPipe=(mip>0)||(mop>0)||addpipe;

    if~isempty(hPreElabC.SimulinkHandle)
        hasEnablePort=strcmp(get_param(hPreElabC.SimulinkHandle,'ShowEnablePort'),'on');
    else
        hasEnablePort=0;
    end

    if~isempty(hPreElabC.SimulinkHandle)
        hasResetPort=~strcmpi(get_param(hPreElabC.SimulinkHandle,'ExternalReset'),'None');
    else
        hasResetPort=false;
    end



    if(hN.isInConditionalHierarchy||hN.isInResettableHierarchy||hasEnablePort||hasResetPort)&&hasInternalPipe
        retval=true;
    end
