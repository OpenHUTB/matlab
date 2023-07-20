function elaborate(this)





    hN=this.hN;


    addend1exp=hdlexpandvectorsignal(this.addend1);
    addend2exp=hdlexpandvectorsignal(this.addend2);
    adder_out_exp=hdlexpandconnectiontovectorsignal(hN,this.adder_output);
    outexp=hdlexpandvectorsignal(this.outputs);

    if~isempty(this.feedback_gain)
        gainoutexp=hdlexpandconnectiontovectorsignal(hN,this.gainoutidx);
    end

    for jj=1:this.num_copies























        pirelab.getAddComp(hN,[addend1exp(jj),addend2exp(jj)],adder_out_exp(jj),...
        this.adder_mode{1},this.adder_mode{2});


        if~isempty(this.feedback_gain)



            pirelab.getMulComp(hN,[this.feedback_gain,outexp(jj)],gainoutexp(jj),...
            this.feedback_gain_mode{1},this.feedback_gain_mode{2});
        end

    end




    if this.dtc_adder_output



        pirelab.getDTCComp(hN,this.adder_output,this.adder_output_recast,...
        this.adder_mode{1},this.adder_mode{2});
    end





















    if strcmpi(this.accumulator_style,'load_only')||strcmpi(this.accumulator_style,'load_and_acc_enable')





        pirelab.getConstComp(hN,this.load_val_idx,this.load_val);





        pirelab.getSwitchComp(hN,[this.reg_output,this.load_val_idx],...
        this.outputs,this.load,'loadMux','==',0);



    end

    if strcmpi(this.accumulator_style,'load_and_acc_enable')



        pirelab.getSwitchComp(hN,[this.outputs,this.adder_output_recast],...
        this.reg_input,this.reg_enable_accumulation,'loadAndAccEnable','==',0);
    end


    switch this.accumulator_style
    case 'load_only'
...
...
...
...
...
...
...
...
...
...
...
        pirelab.getUnitDelayComp(hN,this.reg_input,this.reg_output,...
        'LoadReg',this.resetvalues);

    case 'acc_enable_only'
...
...
...
...
...
...
...
...
...
...
...
        pirelab.getUnitDelayEnabledComp(hN,this.reg_input,this.reg_output,...
        this.reg_enable_accumulation,'AccEnableReg',this.resetvalues);
    case 'load_and_acc_enable'
...
...
...
...
...
...
...
...
...
...
...
        pirelab.getUnitDelayComp(hN,this.reg_input,this.reg_output,...
        'LoadAccEnableReg',this.resetvalues);












    case 'none'
...
...
...
...
...
...
...
...
...
...
...
        pirelab.getUnitDelayComp(hN,this.reg_input,this.reg_output,...
        'AccReg',this.resetvalues);
    end






end
