function v=validateBlock(this,hC)





    v=hdlvalidatestruct;

    hN=hC.Owner;
    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        prm=this.buildSysObjParams(hC,hN,sysObjHandle);
    else
        prm=this.buildBlockParams(hC,hN);
    end


    if isa(hC.PirInputSignals(1).Type.getLeafType,'hdlcoder.tp_double')||...
        isa(hC.PirOutputSignals(1).Type.getLeafType,'hdlcoder.tp_double')
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:RectQAMModulator:validateBlock:doubletype'));
    end

    if~prm.IntegerInput
        if~(hC.PirInputSignals(1).Type.BaseType.is1BitType)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:RectQAMModulator:validateBlock:inputtype'));
        end

        RequiredArrayLen=log2(prm.M);
    else
        RequiredArrayLen=1;
    end



    msg=dsphdlshared.validation.getMultiSymbolValidationMessage(hC.PirInputSignals(1),...
    RequiredArrayLen);

    v(end+1)=baseValidateVectorPortLength(this,hC.PirInputSignals(1),...
    RequiredArrayLen,msg);


