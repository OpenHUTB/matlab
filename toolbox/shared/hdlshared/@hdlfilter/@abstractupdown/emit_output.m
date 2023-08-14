function hdl_arch=emit_output(this,foutsignal,clkenboutsignal,entitysigs)






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



        [~,ceoutreg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,ceoutall.vtype,ceoutall.sltype);
        hdlregsignal(ceoutreg);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ceoutreg)];

        [clkenbsigbody,clkenbtempsignals]=hdlunitdelay(clkenboutsignal,ceoutreg,...
        ['ClkEnable_Output_Register',hdlgetparameter('clock_process_label')],0);
        hdl_arch.signals=[hdl_arch.signals,clkenbtempsignals];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,clkenbsigbody];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,...
        hdlfinalassignment(ceoutreg,entitysigs.ceoutput)];

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



