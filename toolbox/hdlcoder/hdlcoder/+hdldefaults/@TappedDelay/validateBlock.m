function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    if~isa(hC,'hdlcoder.sysobj_comp')
        v=hdlimplbase.EmlImplBase.validateRegisterRates(hC);
        v=hdlimplbase.EmlImplBase.baseValidateRegister(v,hC);
    end
