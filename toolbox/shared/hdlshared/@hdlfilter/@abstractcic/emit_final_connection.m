function hdl_arch=emit_final_connection(this,entitysigs,current_input,ratereg)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];


    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outregvtype=outputall.vtype;
    outregsltype=outputall.sltype;

    roundmode=this.roundmode;
    overflowmode=0;

    complexity=this.isInputPortComplex;

    if hdlgetparameter('RateChangePort')


        [current_input,shift_hdl]=emit_shiftOutputVarRate(this,current_input,ratereg,this.phases);
        hdl_arch=combinehdlcode(this,hdl_arch,shift_hdl);

    else

        if~strcmpi(hdlsignalvtype(current_input),outregvtype)||...
            ~strcmp(hdlsignalsltype(current_input),outregsltype)

            [~,conv_output]=hdlnewsignal('output_typeconvert','filter',-1,complexity,0,...
            outregvtype,outregsltype);
            hdl_arch.signals=[hdl_arch.signals,...
            makehdlsignaldecl(conv_output)];

            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            hdldatatypeassignment(current_input,conv_output,...
            roundmode,overflowmode)];
            current_input=conv_output;
        end
    end


    if hdlgetparameter('filter_registered_output')==1
        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,...
        '  ------------------ Output Register ------------------\n\n'];
        hdl_arch.signals=[hdl_arch.signals,indentedcomment,'  \n'];

        [~,reg_output]=hdlnewsignal('output_register','filter',-1,complexity,0,outregvtype,outregsltype);
        hdlregsignal(reg_output);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(reg_output)];
        [tempbody,tempsignals]=hdlunitdelay(current_input,reg_output,...
        ['output_reg',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
    else
        reg_output=current_input;
    end



    bpreg_arch.signals='';
    bpreg_arch.body_blocks='';
    if~hdlgetparameter('filter_registered_output')&&~hdlgetparameter('filter_registered_input')
        sel=hdlgetcurrentclockenable;
        [bpreg_arch,reg_output]=emit_Outputbypassreg(this,reg_output,sel);
    end
    [tempbody,tempsignals]=hdlfinalassignment(reg_output,entitysigs.output);
    hdl_arch.signals=[hdl_arch.signals,tempsignals];
    hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
    hdl_arch=combinehdlcode(this,hdl_arch,bpreg_arch);


