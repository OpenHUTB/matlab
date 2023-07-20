function v=validateBlock(~,hC)


    v=hdlimplbase.EmlImplBase.validateRegisterRates(hC);
    v=hdlimplbase.EmlImplBase.baseValidateRegister(v,hC);


    resetType=hC.SLInputSignals(2).Type;
    if~resetType.isBooleanType
        bfp=hC.SimulinkHandle;
        blkName=regexprep(get_param(bfp,'Name'),'\n',' ');
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnitDelayResetDataType',blkName));
    end
end
