function finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce)





    finalcon_arch.functions='';
    finalcon_arch.typedefs='';
    finalcon_arch.constants='';
    finalcon_arch.signals='';
    finalcon_arch.body_blocks='';
    finalcon_arch.body_output_assignments='';

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    castvtype=outputall.vtype;
    castsltype=outputall.sltype;

    complexity=isOutputPortComplex(this);

    if hdlgetparameter('filter_registered_output')==1
        [outputregname,outputreg]=hdlnewsignal('output_register','filter',-1,complexity,0,castvtype,castsltype);
        hdlregsignal(outputreg);
        finalcon_arch.signals=[finalcon_arch.signals,makehdlsignaldecl(outputreg)];
        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce.output);
        tempbody=hdlunitdelay(cast_result,outputreg,...
        ['Output_Register',hdlgetparameter('clock_process_label')],0);
        hdlsetcurrentclockenable(oldce);
        finalcon_arch.body_blocks=[finalcon_arch.body_blocks,tempbody];
        final_result=outputreg;
    else
        final_result=cast_result;
    end

    [tempbody,tempsignals]=hdlfinalassignment(final_result,entitysigs.output);
    finalcon_arch.signals=[finalcon_arch.signals,tempsignals];
    finalcon_arch.body_output_assignments=[finalcon_arch.body_output_assignments,tempbody];





