function hdl_arch=emit_output(this,foutsignal,clkenboutsignal,entitysigs,fclkvalidsignal)






    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    top=this;
    outputsltype=hdlsignalsltype(entitysigs.output);
    outputall=hdlgetallfromsltype(outputsltype);
    ceoutsltype=hdlsignalsltype(entitysigs.ceoutput);
    ceoutall=hdlgetallfromsltype(ceoutsltype);

    outrounding='nearest';
    outsaturation=1;

    if hdlgetparameter('filter_registered_output')==1
        [~,outputreg]=hdlnewsignal('output_register','filter',-1,top.isOutputPortComplex,0,outputall.vtype,outputsltype);
        hdlregsignal(outputreg);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(outputreg)];

        [tempbody,tempsignals]=hdlunitdelay(foutsignal,outputreg,...
        ['Output_Register',hdlgetparameter('clock_process_label')],0);

        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];



        hdlregsignal(clkenboutsignal);
        hdlregsignal(fclkvalidsignal);
        [~,ceouttmpsig]=hdlnewsignal('ce_out_valid_tmp','filter',-1,0,0,ceoutall.vtype,ceoutsltype);

        [~,validtmpsig]=hdlnewsignal('ce_out_tmp','filter',-1,0,0,ceoutall.vtype,ceoutsltype);

        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ceouttmpsig),...
        makehdlsignaldecl(validtmpsig)];
        obj=hdl.intdelay('clock',hdlgetcurrentclock,...
        'clockenable',hdlgetcurrentclockenable,...
        'reset',hdlgetcurrentreset,...
        'inputs',[clkenboutsignal,fclkvalidsignal],...
        'outputs',[ceouttmpsig,validtmpsig],...
        'processName',['ce_out_delays',hdlgetparameter('clock_process_label')],...
        'resetvalues',zeros(2,2),...
        'nDelays',2);
        if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
            obj.setResetNone;
        end
        intdelaycode=obj.emit;
        tempbody=intdelaycode.arch_body_blocks;
        tempsignals=intdelaycode.arch_signals;
        ceoutbodyassgn=hdlbitop([ceouttmpsig,entitysigs.clken],entitysigs.ceoutput,'AND');
        cevldbodyassgn=hdlbitop([validtmpsig,entitysigs.clken],entitysigs.ceoutput_datavld,'AND');
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,ceoutbodyassgn,cevldbodyassgn];


        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    else
        [~,outputreg]=hdlnewsignal('output_typeconvert','filter',-1,top.isOutputPortComplex,0,outputall.vtype,outputsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(outputreg)];
        tempbody=hdldatatypeassignment(foutsignal,outputreg,outrounding,outsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];


        clkenbsigbody=hdldatatypeassignment(clkenboutsignal,entitysigs.ceoutput,outrounding,outsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,clkenbsigbody];
    end
    [outputbody,outtempsignals]=hdlfinalassignment(outputreg,entitysigs.output);
    hdl_arch.signals=[hdl_arch.signals,outtempsignals];
    hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,outputbody];



