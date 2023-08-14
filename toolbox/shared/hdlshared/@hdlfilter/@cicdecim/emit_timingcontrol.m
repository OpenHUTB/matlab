function[hdl_arch,ce]=emit_timingcontrol(this,ce,entitysigs)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    bdt=hdlgetparameter('base_data_type');

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    clken=hdlsignalfindname([hdlgetparameter('clockenablename')]);


    numsections=this.numberofsections;
    numfactor=this.decimationfactor;


    if numfactor==1
        ce.out_reg=clken;
        ce.out_temp=clken;
    else

        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,...
        '  ------------------ CE Output Generation ------------------\n\n'];

        if hdlgetparameter('filter_registered_input')==1
            decodeval=1;
        else
            decodeval=0;
        end

        if hdlgetparameter('RateChangePort')
            load_val=1;

            countersltype=hdlsignalsltype(ce.ratereg);
            countervtype=hdlsignalvtype(ce.ratereg);

            [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,1,countervtype,countersltype);
            hdlregsignal(counter_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];

            [tempprocessbody,ce.out_temp]=hdlcounter(counter_out,{ce.ratereg},...
            'ce_output',1,0,decodeval,0,entitysigs.loadenb,load_val);
            ce.out_temp=ce.out_temp(1);
        else
            countsize=max(2,ceil(log2(numfactor)));
            [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
            [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
            hdlregsignal(counter_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];

            [tempprocessbody,ce.out_temp]=hdlcounter(counter_out,numfactor,...
            'ce_output',1,0,decodeval);



            LocalTCinfo=struct('enbsIn',hdlsignalname(hdlgetcurrentclockenable),...
            'enbsOut',hdlsignalname(ce.out_temp),...
            'phases',decodeval,...
            'maxCount',numfactor,...
            'initValue',0);
            setLocalTimingInfo(this,LocalTCinfo);
        end

        hdladdclockenablesignal(ce.out_temp);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_temp)];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];

        if hdlgetparameter('filter_generate_ceout')&&~multiclock
            if hdlgetparameter('filter_pipelined')&&numsections>1

                saved_ce=hdlgetcurrentclockenable;
                hdlsetcurrentclockenable(ce.out_temp);
                [~,ce.delayline]=hdlnewsignal('ce_delayline',...
                'filter',-1,0,0,bdt,'boolean');
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.delayline)];


                obj=hdl.intdelay('clock',hdlgetcurrentclock,...
                'clockenable',hdlgetcurrentclockenable,...
                'reset',hdlgetcurrentreset,...
                'inputs',clken,...
                'outputs',ce.delayline,...
                'processName','ce_delay',...
                'resetvalues',0,...
                'nDelays',numsections-1);
                if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
                    obj.setResetNone;
                end
                intdelaycode=obj.emit;
                hdl_arch.signals=[hdl_arch.signals,intdelaycode.arch_signals];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,intdelaycode.arch_body_blocks];

                hdlsetcurrentclockenable(saved_ce);

                [~,ce.internal]=hdlnewsignal('ce_gated','filter',-1,0,0,bdt,'boolean');
                hdladdclockenablesignal(ce.internal);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.internal)];
                temp_body=hdllogop([ce.delayline,ce.out_temp],ce.internal,'AND');
                hdl_arch.body_blocks=[hdl_arch.body_blocks,temp_body];

            else
                ce.internal=ce.out_temp;
            end
            if hdlgetparameter('filter_registered_output')==1
                hdl_arch.body_blocks=[hdl_arch.body_blocks,...
                indentedcomment,...
                '  ------------------ CE Output Register ------------------\n\n'];

                [~,ce.out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');
                hdlregsignal(ce.out_reg);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];


                saved_ce=hdlgetcurrentclockenable;
                hdlsetcurrentclockenable([]);
                [tempprocessbody,tempsignal]=hdlunitdelay(ce.internal,ce.out_reg,'ce_output_register',0);
                hdl_arch.signals=[hdl_arch.signals,tempsignal];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
                hdlsetcurrentclockenable(saved_ce);


            else
                ce.out_reg=ce.internal;
            end
        end
    end
    if hdlgetparameter('filter_generate_ceout')&&~multiclock
        [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceoutput);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
    end




