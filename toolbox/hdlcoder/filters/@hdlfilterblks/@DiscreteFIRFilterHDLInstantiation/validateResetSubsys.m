function v=validateResetSubsys(this,hC)




    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    hF=this.createHDLFilterObj(hC);
    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;
    this.unApplyParams(s.pcache);


    archIsFullyParallel=strcmp(this.class,'hdlfilterblks.DiscreteFIRFullyParallel');

    if hC.Owner.isInResettableHierarchy&&~archIsFullyParallel
        if isempty(block.HDLData)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_ResetSubsys_FullyParallel','default'));
        else
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_ResetSubsys_FullyParallel',block.HDLData.archSelection));
        end
    end


    isChannelShared=hF.HDLParameters.INI.getProp('filter_generate_multichannel')>1;

    if hC.Owner.isInResettableHierarchy&&isChannelShared
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_ResetSubsys_ChannelShare'));
    end