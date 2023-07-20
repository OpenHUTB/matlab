function[inputreg_arch,entitysigs,current_input]=emit_inputreg_process(this,entitysigs)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inregvtype=inputall.vtype;
    inregsltype=inputall.sltype;

    coeffsvtype='';
    coeffssltype='';

    wraddrvtype='';
    wraddrsltype='';

    current_input=struct('input',0,...
    'wrenb',0,...
    'coeffs',0,...
    'wraddr',0,...
    'wrdone',0);

    inputreg_arch.signals='';
    inputreg_arch.body_blocks='';

    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    if emitMode

        if~coeffs_internal
            coeffsall=hdlgetallfromsltype(hdlsignalsltype(entitysigs.coeffs),'inputport');
            coeffsvtype=coeffsall.vtype;
            coeffssltype=coeffsall.sltype;

            wraddrall=hdlgetallfromsltype(hdlsignalsltype(entitysigs.wraddr),'inputport');
            wraddrvtype=wraddrall.vtype;
            wraddrsltype=wraddrall.sltype;
        end

        if hdlgetparameter('filter_registered_input')==1
            input_idx='';
            output_idx='';
            scalaric=[];
            [tempname,current_input.input]=hdlnewsignal('input_register','filter',-1,this.isInputPortComplex,0,inregvtype,inregsltype);
            hdlregsignal(current_input.input);
            inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.input)];
            input_idx=[input_idx,entitysigs.input];
            output_idx=[output_idx,current_input.input];
            scalaric=[scalaric,0];

            if~coeffs_internal
                [name_wrenb,current_input.wrenb]=hdlnewsignal('write_enable_reg','filter',-1,0,0,hdlsignalvtype(entitysigs.wrenb),hdlsignalsltype(entitysigs.wrenb));
                hdlregsignal(current_input.wrenb);
                inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.wrenb)];
                input_idx=[input_idx,entitysigs.wrenb];
                output_idx=[output_idx,current_input.wrenb];
                scalaric=[scalaric,0];

                [name_wrdone,current_input.wrdone]=hdlnewsignal('write_done_reg','filter',-1,0,0,hdlsignalvtype(entitysigs.wrdone),hdlsignalsltype(entitysigs.wrdone));
                hdlregsignal(current_input.wrdone);
                inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.wrdone)];
                input_idx=[input_idx,entitysigs.wrdone];
                output_idx=[output_idx,current_input.wrdone];
                scalaric=[scalaric,0];

                [name_wraddr,current_input.wraddr]=hdlnewsignal('write_address_reg','filter',-1,0,0,wraddrvtype,wraddrsltype);
                hdlregsignal(current_input.wraddr);
                inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.wraddr)];
                input_idx=[input_idx,entitysigs.wraddr];
                output_idx=[output_idx,current_input.wraddr];
                scalaric=[scalaric,0];

                [name_coeffs,current_input.coeffs]=hdlnewsignal('coeffs_in_reg','filter',-1,0,0,coeffsvtype,coeffssltype);
                hdlregsignal(current_input.coeffs);
                inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.coeffs)];
                input_idx=[input_idx,entitysigs.coeffs];
                output_idx=[output_idx,current_input.coeffs];
                scalaric=[scalaric,0];
            end
            [tempbody,tempsignals]=hdlunitdelay(input_idx,output_idx,...
            ['input_reg',hdlgetparameter('clock_process_label')],scalaric);
        else
            [tempname,current_input.input]=hdlnewsignal('input_typeconvert','filter',-1,this.isInputPortComplex,0,inregvtype,inregsltype);
            inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.input)];
            tempbody=hdldatatypeassignment(entitysigs.input,current_input.input,'floor',0);

            if~coeffs_internal
                current_input.wrenb=entitysigs.wrenb;
                current_input.wrdone=entitysigs.wrdone;

                [name_wraddr,current_input.wraddr]=hdlnewsignal('write_address_typeconvert','filter',-1,0,0,wraddrvtype,wraddrsltype);
                inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.wraddr)];
                tempbody=[tempbody,hdldatatypeassignment(entitysigs.wraddr,current_input.wraddr,'floor',0)];

                [name_coeffs,current_input.coeffs]=hdlnewsignal('coeffs_in_typeconvert','filter',-1,0,0,coeffsvtype,coeffssltype);
                inputreg_arch.signals=[inputreg_arch.signals,makehdlsignaldecl(current_input.coeffs)];
                tempbody=[tempbody,hdldatatypeassignment(entitysigs.coeffs,current_input.coeffs,'floor',0)];
            end
            tempsignals='';
        end
        inputreg_arch.body_blocks=[inputreg_arch.body_blocks,tempbody];
        inputreg_arch.signals=[inputreg_arch.signals,tempsignals];

        coeffs_port=hdlgetparameter('filter_generate_coeff_port');
        if coeffs_port
            current_input.coeffs=entitysigs.coeffs;
        end
    else
        current_input=entitysigs;
    end


