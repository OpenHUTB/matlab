function[hdl_arch,counter_out,ce]=emit_timingcontrol(this,entitysigs,ce)




    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';




    phases=this.decimationfactor;
    bdt=hdlgetparameter('base_data_type');
    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    multcycles=hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline');

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    if hdlgetparameter('filter_registered_input')==1
        decodeval=1;
    else
        decodeval=0;
    end

    ce_outdelaycycles=floor((decodeval+multcycles)/phases)*phases;
    decodeval=mod(decodeval+multcycles,phases);


    countsize=max(2,ceil(log2(phases)));
    [countvt,countslt]=hdlgettypesfromsizes(countsize,0,0);

    [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countvt,countslt);
    hdlregsignal(counter_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];


    tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
    [tempprocessbody,ce.out_temp]=hdlcounter(counter_out,phases,'ce_output',1,0,decodeval);
    tcinfo.phases=decodeval;
    tcinfo.enbsOut=hdlsignalname(ce.out_temp);
    tcinfo.maxCount=phases;
    tcinfo.initValue=0;

    setLocalTimingInfo(this,tcinfo);
    hdladdclockenablesignal(ce.out_temp);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_temp)];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];

    if multiclock==0&&hdlgetparameter('filter_generate_ceout')

        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,...
        '  ------------------ CE Output Generation ------------------\n\n'];

        if hdlgetparameter('filter_registered_output')==1
            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            indentedcomment,...
            '  ------------------ CE Output Register ------------------\n\n'];

            [~,ce.out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');
            hdlregsignal(ce.out_reg);
            hdladdclockenablesignal(ce.out_reg);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];


            temp_enable=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable([]);
            [tempprocessbody,tempsignal]=hdlunitdelay(ce.out_temp,ce.out_reg,'ce_output_register',0);
            hdlsetcurrentclockenable(temp_enable);

            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignal];

        else
            ce.out_reg=ce.out_temp;
        end

        if ce_outdelaycycles>0
            [intdbody,intdsignals,intdconst,ce.out_reg]=emit_PhaseShiftRegisterDelay(this,ce.out_reg,...
            ['ce_pipeline_matching_delay',hdlgetparameter('clock_process_label')],ce_outdelaycycles);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];
            hdl_arch.constants=[hdl_arch.constants,intdconst];
            hdl_arch.signals=[hdl_arch.signals,intdsignals];
        end
        [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceoutput);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
    end



