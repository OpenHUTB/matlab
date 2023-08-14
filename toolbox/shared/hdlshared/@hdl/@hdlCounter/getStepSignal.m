function hdlcode=getStepSignal(this)





    hdlcode=hdlcodeinit;

    slType=hdlsignalsltype(this.outputs);
    outputType=hdlgetallfromsltype(slType);


    type=this.getCounterType(outputType);


    if~isempty(this.cnt_dir)
        posStepValue=hdlconstantvalue(this.Stepvalue,type.size,type.bp,type.signed);
        [idxname,posStepSignal]=hdlnewsignal('STEP_VALUE','block',-1,0,0,type.vtype,type.sltype);
        makehdlconstantdecl(posStepSignal,posStepValue);

        negStepValue=hdlconstantvalue(-(this.Stepvalue),type.size,type.bp,type.signed);
        [idxname,negStepSignal]=hdlnewsignal('STEP_VALUE_NEG','block',-1,0,0,type.vtype,type.sltype);
        makehdlconstantdecl(negStepSignal,negStepValue);

        this.negStepSignal=negStepSignal;
        this.posStepSignal=posStepSignal;

    else
        if this.Stepvalue>0
            posStepValue=hdlconstantvalue(this.Stepvalue,type.size,type.bp,type.signed);
            [idxname,posStepSignal]=hdlnewsignal('STEP_VALUE','block',-1,0,0,type.vtype,type.sltype);
            makehdlconstantdecl(posStepSignal,posStepValue);
            this.posStepSignal=posStepSignal;
        else
            negStepValue=hdlconstantvalue((this.Stepvalue),type.size,type.bp,type.signed);
            [idxname,negStepSignal]=hdlnewsignal('STEP_VALUE','block',-1,0,0,type.vtype,type.sltype);
            makehdlconstantdecl(negStepSignal,negStepValue);
            this.negStepSignal=negStepSignal;
        end

    end

    [idxname,StepSignal]=hdlnewsignal('step','block',-1,0,0,type.vtype,type.sltype);

    this.StepSignal=StepSignal;
