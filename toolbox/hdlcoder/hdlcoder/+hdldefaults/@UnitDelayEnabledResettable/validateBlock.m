function v=validateBlock(~,hC)


    v=hdlimplbase.EmlImplBase.validateRegisterRates(hC);
    v=hdlimplbase.EmlImplBase.baseValidateRegister(v,hC);

    bfp=hC.SimulinkHandle;
    blkName=get_param(bfp,'Name');
    blkName=regexprep(blkName,'\n',' ');
    enableType=hC.SLInputSignals(2).Type;
    resetType=hC.SLInputSignals(3).Type;


    if~enableType.isBooleanType
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedDataType','Enable',blkName));
    end

    if~resetType.isBooleanType
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedDataType','Reset',blkName));
    end
end
