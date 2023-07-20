function hdlcode=emit(this)







    if this.use_default_emit,
        oldsc=hdlsequentialcontext;
        hdlsequentialcontext(false);

        hdlcode=hdlcodeinit;



        addend1exp=hdlexpandvectorsignal(this.addend1);
        addend2exp=hdlexpandvectorsignal(this.addend2);
        adder_out_exp=hdlexpandvectorsignal(this.adder_output);
        outexp=hdlexpandvectorsignal(this.outputs);

        if~isempty(this.feedback_gain),
            gainoutexp=hdlexpandvectorsignal(this.gainoutidx);
        end

        for jj=1:this.num_copies,




















            bodytmp=hdladd(addend1exp(jj),addend2exp(jj),adder_out_exp(jj),...
            this.adder_mode{1},this.adder_mode{2});
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodytmp];


            if~isempty(this.feedback_gain),
                bodytmp=hdlmultiply(this.feedback_gain,outexp(jj),gainoutexp(jj),...
                this.feedback_gain_mode{1},this.feedback_gain_mode{2});
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodytmp];
            end

        end




        if this.dtc_adder_output,
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks...
            ,hdldatatypeassignment(this.adder_output,this.adder_output_recast,this.adder_mode{1},...
            this.adder_mode{2})];
        end





















        if strcmpi(this.accumulator_style,'load_only')||strcmpi(this.accumulator_style,'load_and_acc_enable'),

            const_assign_code=hdl.constantassign(this.load_val_idx,this.load_val);

            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            const_assign_code.arch_body_blocks,'\n'];


            postreg_body=[hdlmux([this.reg_output,this.load_val_idx],...
            this.outputs,this.load,{'='},0,'when-else'),'\n'];

        else
            postreg_body=[];
        end

        if strcmpi(this.accumulator_style,'load_and_acc_enable'),
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            hdlmux([this.outputs,this.adder_output_recast],...
            this.reg_input,this.reg_enable_accumulation,{'='},0,'when-else'),'\n'];
        end

        hdlsequentialcontext(true);
        switch this.accumulator_style
        case 'load_only'
            reg=hdl.unitdelay(...
            'clock',this.clock,...
            'clockenable',this.clockenable,...
            'reset',this.reset,...
            'inputs',this.reg_input,...
            'outputs',this.reg_output,...
            'resetvalues',this.resetvalues,...
            'processName',this.processName...
            );

        case 'acc_enable_only'
            reg=hdl.unitdelay(...
            'clock',this.clock,...
            'clockenable',[this.clockenable,this.reg_enable_accumulation],...
            'reset',this.reset,...
            'inputs',this.reg_input,...
            'outputs',this.reg_output,...
            'resetvalues',this.resetvalues,...
            'processName',this.processName...
            );
        case 'load_and_acc_enable'
            reg=hdl.unitdelay(...
            'clock',this.clock,...
            'clockenable',this.clockenable,...
            'reset',this.reset,...
            'inputs',this.reg_input,...
            'outputs',this.reg_output,...
            'resetvalues',this.resetvalues,...
            'processName',this.processName...
            );












        case 'none'
            reg=hdl.unitdelay(...
            'clock',this.clock,...
            'clockenable',this.clockenable,...
            'reset',this.reset,...
            'inputs',this.reg_input,...
            'outputs',this.reg_output,...
            'resetvalues',this.resetvalues,...
            'processName',this.processName...
            );
        end

        hdlcode=hdlcodeconcat([hdlcode,reg.emit()]);
        hdlsequentialcontext(oldsc);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,postreg_body];


    else
        hdlcode=this.baseEmit();
    end;
