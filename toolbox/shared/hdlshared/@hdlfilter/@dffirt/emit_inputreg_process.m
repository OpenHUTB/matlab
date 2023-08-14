function[hdl_arch,reginput]=emit_inputreg_process(this,entitysigs)





    emitMode=isempty(pirNetworkForFilterComp);

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;
    inputrounding='round';
    inputsaturation=true;
    cplxity=this.isInputPortComplex;

    if emitMode&&hdlgetparameter('filter_registered_input')==1
        [uname,reginput]=hdlnewsignal('inputreg','filter',-1,cplxity,0,reginputvtype,reginputsltype);
        hdlregsignal(reginput);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(reginput)];

        [tempbody,tempsignals]=hdlunitdelay(entitysigs.input,reginput,...
        ['input_reg',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
    else
        if emitMode&&(~strcmpi(reginputvtype,inputvtype)||~strcmp(reginputsltype,inputsltype))


            inuname=hdlsignalname(entitysigs.input);
            [uname,entitysigs.input_type_conv]=hdlnewsignal([inuname,'_regtype'],'filter',-1,cplxity,...
            0,reginputvtype,reginputsltype);
            hdlregsignal(entitysigs.input_type_conv);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(entitysigs.input_type_conv)];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            hdldatatypeassignment(entitysigs.input,...
            entitysigs.input_type_conv,...
            inputrounding,inputsaturation)];
            reginput=entitysigs.input_type_conv;

        else
            reginput=entitysigs.input;
        end
    end


