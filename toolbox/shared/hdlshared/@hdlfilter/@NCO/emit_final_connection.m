function finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce_delay)





    finalcon_arch.functions='';
    finalcon_arch.typedefs='';
    finalcon_arch.constants='';
    finalcon_arch.signals='';
    finalcon_arch.body_blocks='';
    finalcon_arch.body_output_assignments='';

    complexity=isOutputPortComplex(this);

    arch=this.implementation;
    radix=hdlgetparameter('filter_daradix');
    baat=log2(radix);

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    castvtype=outputall.vtype;
    castsltype=outputall.sltype;


    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsize=inputall.size;

    if hdlgetparameter('filter_registered_output')==1
        [outputregname,outputreg]=hdlnewsignal('output_register','filter',-1,complexity,0,castvtype,castsltype);
        hdlregsignal(outputreg);
        finalcon_arch.signals=[finalcon_arch.signals,makehdlsignaldecl(outputreg)];

        if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')||(strcmpi(arch,'distributedarithmetic')&&...
            baat~=inputsize)
            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce_delay);
        end
        [tempbody,tempsignals]=hdlunitdelay(cast_result,outputreg,...
        ['Output_Register',hdlgetparameter('clock_process_label')],0);

        if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')||(strcmpi(arch,'distributedarithmetic')&&...
            baat~=inputsize)
            hdlsetcurrentclockenable(oldce);
        end
        finalcon_arch.body_blocks=[finalcon_arch.body_blocks,tempbody];
        finalcon_arch.signals=[finalcon_arch.signals,tempsignals];
        final_result=outputreg;
    else
        final_result=cast_result;
    end

    [tempbody,tempsignals]=hdlfinalassignment(final_result,entitysigs.output);
    finalcon_arch.signals=[finalcon_arch.signals,tempsignals];
    finalcon_arch.body_output_assignments=[finalcon_arch.body_output_assignments,tempbody];


