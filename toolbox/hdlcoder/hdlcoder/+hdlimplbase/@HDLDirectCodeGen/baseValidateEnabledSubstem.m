function v=baseValidateEnabledSubstem(this,hN)



    v=hdlvalidatestruct;

    maxOversampling=hdlgetparameter('maxoversampling');
    if maxOversampling>0&&maxOversampling~=inf
        msgobj=message('hdlcoder:makehdl:DeprecateMaxOverSampling');
        warning(msgobj);
        hdlsetparameter('maxoversampling',inf);
    end

    if hN.hasEnabledInstances()
        v=hdlvalidatestruct(1,...
        message('hdlcoder:validate:illegalBlockInEnabledSubsys'));
    end
