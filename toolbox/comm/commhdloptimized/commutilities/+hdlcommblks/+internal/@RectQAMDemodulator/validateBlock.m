function v=validateBlock(this,hC)





    hN=hC.Owner;

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        prm=this.buildSysObjParams(hC,hN,sysObjHandle);
    else
        prm=this.buildBlockParams(hC,hN);
    end

    v=hdlvalidatestruct;
    MessageID_unsupported='comm:hdl:RectQAMDemodulator:validateBlock:unsupported';



    if~prm.isHardDec
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:RectQAMDemodulator:validateBlock:harddecision'));
    end





    if~(prm.isNormMethodMinDist&&(prm.minDist==2))
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:RectQAMDemodulator:validateBlock:minimumdistance'));
    end






    if prm.isCosInitPhase
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:RectQAMDemodulator:validateBlock:phaseoffset'));


    end


    if isa(hC.PirInputSignals.Type.getLeafType,'hdlcoder.tp_double')||...
        isa(hC.PirOutputSignals.Type.getLeafType,'hdlcoder.tp_double')
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:RectQAMDemodulator:validateBlock:doubletype'));

    end



    RequiredArrayLen=1;
    msg=dsphdlshared.validation.getMultiSymbolValidationMessage(hC.PirInputSignals(1),...
    RequiredArrayLen);

    v(end+1)=baseValidateVectorPortLength(this,hC.PirInputSignals(1),...
    RequiredArrayLen,msg);


end

