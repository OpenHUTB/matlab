function v=validateControlPorts(this,hC)




    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    hF=this.createHDLFilterObj(hC);
    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;
    this.unApplyParams(s.pcache);


    try
        hasEnablePort=strcmpi(get_param(hC.SimulinkHandle,'ShowEnablePort'),'on');
    catch
        hasEnablePort=false;
    end


    reset_type=get_param(hC.SimulinkHandle,'ExternalReset');

    hasResetPort=~strcmpi(reset_type,'None');
    isChannelShared=hF.HDLParameters.INI.getProp('filter_generate_multichannel')>1;

    archIsFullyParallel=strcmp(this.class,'hdlfilterblks.DiscreteFIRFullyParallel');

    isHWFriendly=hC.Owner.hasSLHWFriendlySemantics||hC.Owner.getWithinHWFriendlyHierarchy;



    if hasEnablePort&&~archIsFullyParallel
        if isempty(block.HDLData)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_EnablePort_FullyParallel','default'));
        else
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_EnablePort_FullyParallel',block.HDLData.archSelection));
        end
    end

    if hasEnablePort&&isChannelShared
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_EnablePort_ChannelShare'));
    end

    if~isHWFriendly&&hasEnablePort
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_EnablePort_NotHWFriendly'));
    end

    if hasEnablePort&&hC.Owner.isInResettableHierarchy
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_EnablePort_inResetHierarchy'));
        return;
    end

    if hasEnablePort&&hC.Owner.isInConditionalHierarchy
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_EnablePort_inConditionalHierarchy'));
    end






    if hasResetPort&&~archIsFullyParallel
        if isempty(block.HDLData)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_ResetPort_FullyParallel',reset_type,'default'));
        else
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_ResetPort_FullyParallel',reset_type,block.HDLData.archSelection));
        end
    end

    if hasResetPort&&isChannelShared
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_ResetPort_ChannelShare',reset_type));
    end

    if~isHWFriendly&&hasResetPort
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_ResetPort_NotHWFriendly'));
    end



















    if hasResetPort&&hasEnablePort
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_EnAndRstPort_NotSupported'));
    end
