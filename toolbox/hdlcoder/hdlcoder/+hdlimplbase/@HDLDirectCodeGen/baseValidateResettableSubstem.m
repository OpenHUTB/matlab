function v=baseValidateResettableSubstem(~,hC)



    v=hdlvalidatestruct;


    if hC.Owner.hasResettableInstances
        v=hdlvalidatestruct(1,...
        message('hdlcoder:validate:blockcannotbereset'));
    end
