function baseEmit(this)







    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    hdlentitysignalsinit;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');

    [entitysigs]=createhdlports(this);

    hdl_arch=emit_inithdlarch(this);

    complexity=isInputPortComplex(this);



    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    if hdlgetparameter('filter_registered_input')==1
        [tempname,current_input]=hdlnewsignal('input_register','filter',-1,complexity,0,inputall.vtype,inputall.sltype);
        hdlregsignal(current_input);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(current_input)];
        [tempbody,tempsignals]=hdlunitdelay(entitysigs.input,current_input,...
        ['input_reg',hdlgetparameter('clock_process_label')],0);
    else
        [tempname,current_input]=hdlnewsignal('input_typeconvert','filter',-1,complexity,0,inputall.vtype,inputall.sltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(current_input)];
        tempbody=hdldatatypeassignment(entitysigs.input,current_input,'floor',0);
        tempsignals='';
    end

    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    hdl_arch.signals=[hdl_arch.signals,tempsignals];

    latency=this.latency;
    if latency~=0
        [delayreg,delayinput]=hdlnewsignal('delayout_reg','filter',-1,complexity,0,inputall.vtype,inputall.sltype);
        if latency==1
            hdlregsignal(delayinput);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delayinput)];
            [delaybody,delaysignals]=hdlunitdelay(current_input,delayinput,...
            'delay_reg_process',0);
        else
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delayinput)];
            obj=hdl.intdelay('clock',hdlgetcurrentclock,...
            'clockenable',hdlgetcurrentclockenable,...
            'reset',hdlgetcurrentreset,...
            'inputs',current_input,...
            'outputs',delayinput,...
            'processName','delay_reg_process',...
            'resetvalues',0,...
            'nDelays',latency);
            intdelaycode=obj.emit;
            delaybody=intdelaycode.arch_body_blocks;
            delaysignals=intdelaycode.arch_signals;
        end
        hdl_arch.body_blocks=[hdl_arch.body_blocks,delaybody];
        hdl_arch.signals=[hdl_arch.signals,delaysignals];
        current_output=delayinput;
    else
        current_output=current_input;
    end



    ce_delay=0;
    finalcon_arch=emit_final_connection(this,entitysigs,current_output,ce_delay);
    outvldsig=hdlgetcurrentclockenable;
    if hdlgetparameter('filter_generate_datavalid_output')
        [tempbody,tempsignals]=hdlfinalassignment(outvldsig,entitysigs.ceoutput_datavld);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
    end
    hdl_arch=combinehdlcode(this,hdl_arch,finalcon_arch);
    emit_assemblehdlcode(this,hdl_arch);



