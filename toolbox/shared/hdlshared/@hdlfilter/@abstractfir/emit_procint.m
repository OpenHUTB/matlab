function[hdl_arch,coeffs_data]=emit_procint(this,entitysigs,coeffs_data,ce,varargin)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';
    hdl_arch.component_decl='';
    hdl_arch.component_config='';
    hdl_arch.body_component_instances='';



    if numel(varargin)==1
        pairs=varargin{1};
    end

    fl=getfilterlengths(this);

    firlen=fl.firlen;
    coeff_len=fl.coeff_len;

    multpliers=hdlgetparameter('filter_multipliers');
    if strcmpi(multpliers,'csd')||strcmpi(multpliers,'factored-csd')
        hprop=PersistentHDLPropSet;
        hprop.CLI.CoeffMultipliers='multiplier';
        updateINI(hprop);
        warning(message('HDLShared:hdlfilter:procifnotwithcsd'));
    end


    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsvtype=coeffall.vtype;
    coeffssltype=coeffall.sltype;

    inputrounding='round';
    inputsaturation=true;

    bdt=hdlgetparameter('base_data_type');
    arithisdouble=strcmpi(this.inputSLtype,'double');
    addr_bits=ceil(log2(coeff_len));
    if arithisdouble
        wraddrvtype='real';
        wraddrsltype='double';
    else
        [wraddrvtype,wraddrsltype]=hdlgettypesfromsizes(addr_bits,0,0);
    end


    wrenbname=hdlsignalname(entitysigs.wrenb);
    wrdonename=hdlsignalname(entitysigs.wrdone);
    wraddrname=hdlsignalname(entitysigs.wraddr);
    coeffsinname=hdlsignalname(entitysigs.coeffs);

    [~,wraddrregsig]=hdlnewsignal([wraddrname,'_reg'],'filter',-1,0,...
    0,wraddrvtype,wraddrsltype);

    [~,coeffinregsig]=hdlnewsignal([coeffsinname,'_reg'],'filter',-1,0,...
    0,coeffsvtype,coeffssltype);

    if hdlgetparameter('filter_registered_input')~=0

        hdlregsignal(wraddrregsig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(wraddrregsig)];

        hdlregsignal(coeffinregsig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(coeffinregsig)];
        [~,wrenbregsig]=hdlnewsignal([wrenbname,'_reg'],'filter',-1,0,...
        0,bdt,'boolean');
        hdlregsignal(wrenbregsig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(wrenbregsig)];

        [~,wrdoneregsig]=hdlnewsignal([wrdonename,'_reg'],'filter',-1,0,...
        0,bdt,'boolean');
        hdlregsignal(wrdoneregsig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(wrdoneregsig)];

        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        hdlunitdelay([entitysigs.wrenb,entitysigs.wrdone,entitysigs.wraddr,entitysigs.coeffs],...
        [wrenbregsig,wrdoneregsig,wraddrregsig,coeffinregsig],...
        ['Input_Register',hdlgetparameter('clock_process_label')],[0,0,0,0])];
    else

        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(wraddrregsig)];
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(coeffinregsig)];

        wrenbregsig=entitysigs.wrenb;
        wrdoneregsig=entitysigs.wrdone;
        wraddrcastbody=hdldatatypeassignment(entitysigs.wraddr,wraddrregsig,inputrounding,inputsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,wraddrcastbody];
        coeffcastbody=hdldatatypeassignment(entitysigs.coeffs,coeffinregsig,inputrounding,inputsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,coeffcastbody];
    end








    if(ce.delay)
        [~,write_done_capture]=hdlnewsignal('write_done_capture_reg','filter',-1,0,0,bdt,'boolean');
        hdlregsignal(write_done_capture);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(write_done_capture)];

        [~,write_done_capture_in]=hdlnewsignal('write_done_capture_in','filter',-1,0,0,bdt,'boolean');
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(write_done_capture_in)];


        [~,ctr_phase_bar]=hdlnewsignal('control_phase_bar','filter',-1,0,0,bdt,'boolean');
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_phase_bar)];

        [~,coeffs_en_sig]=hdlnewsignal('coeffs_en','filter',-1,0,0,bdt,'boolean');
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(coeffs_en_sig)];

        [~,write_done_edge]=hdlnewsignal('write_done_edge_reg','filter',-1,0,0,bdt,'boolean');
        hdlregsignal(write_done_edge);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(write_done_edge)];

        [~,write_done_edge_bar]=hdlnewsignal('write_done_edge_bar','filter',-1,0,0,bdt,'boolean');
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(write_done_edge_bar)];

        [~,write_done_short]=hdlnewsignal('write_done_short','filter',-1,0,0,bdt,'boolean');
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(write_done_short)];


        egde_reg_bar_bdy=hdlbitop(write_done_edge,write_done_edge_bar,'NOT');
        write_done_edge_bdy=hdlbitop([wrdoneregsig,write_done_edge_bar],write_done_short,'AND');




        ctr_phase=ce.coeffs_en;

        ctr_phase_bdy=hdlbitop(ctr_phase,ctr_phase_bar,'NOT');
        write_done_capture_bdy=hdlmux([ctr_phase_bar,write_done_short],write_done_capture_in,write_done_capture,{'='},1,'when-else');
        coeffs_en_bdy=hdlbitop([ctr_phase,write_done_capture],coeffs_en_sig,'AND');
        hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_phase_bdy,write_done_capture_bdy,coeffs_en_bdy,egde_reg_bar_bdy,write_done_edge_bdy];

        [wr_capture_bdy,tempsignals]=hdlunitdelay([write_done_capture_in,wrdoneregsig],[write_done_capture,write_done_edge],['write_done_capture',hdlgetparameter('clock_process_label')],[0,0]);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,wr_capture_bdy];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
    else
        coeffs_en_sig=wrdoneregsig;
    end


    if(ce.delay)&&~strcmpi(hdlgetparameter('filter_storage_type'),'Registers')


        [coeff_RAM_arch,coeffs_RAM_outputs]=emit_coeff_RAM(this,...
        hdlgetcurrentclock,hdlgetcurrentclockenable,...
        coeffinregsig,wraddrregsig,...
        wrenbregsig,coeffs_en_sig,...
        ce,pairs);

        hdl_arch.component_decl=[hdl_arch.component_decl,coeff_RAM_arch.component_decl];
        hdl_arch.component_config=[hdl_arch.component_config,coeff_RAM_arch.component_config];
        hdl_arch.body_component_instances=[hdl_arch.body_component_instances,coeff_RAM_arch.body_component_instances];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,coeff_RAM_arch.body_blocks];
        hdl_arch.signals=[hdl_arch.signals,coeff_RAM_arch.signals];


        coeffs_table=coeffs_RAM_outputs;
        coeffs_data.idx=coeffs_table;
        coeffs_data.values=coeffs_data.values;
    else

        hdladdclockenablesignal(coeffs_en_sig);


        regfilelen=coeff_len;
        if hdlgetparameter('isvhdl')&&(firlen>1)

            hdl_arch.typedefs=[hdl_arch.typedefs,...
            '  TYPE register_file_type IS ARRAY (NATURAL range <>) OF ',...
            coeffsvtype,'; -- ',coeffssltype,'\n'];
            regfile_vector_vtype=['register_file_type(0 TO ',num2str(regfilelen-1),')'];
        else
            regfile_vector_vtype=coeffsvtype;
        end
        if regfilelen>1
            [~,coeffs_assignedsig]=hdlnewsignal('coeffs_assigned','filter',-1,0,...
            [regfilelen,0],regfile_vector_vtype,coeffssltype);
            [~,coeffs_tempsig]=hdlnewsignal('coeffs_temp','filter',-1,0,...
            [regfilelen,0],regfile_vector_vtype,coeffssltype);
            [~,coeffs_regssig]=hdlnewsignal('coeffs_regs','filter',-1,0,...
            [regfilelen,0],regfile_vector_vtype,coeffssltype);
            [~,coeffs_shadowsig]=hdlnewsignal('coeffs_shadow','filter',-1,0,...
            [regfilelen,0],regfile_vector_vtype,coeffssltype);
        else
            [~,coeffs_assignedsig]=hdlnewsignal('coeffs_assigned','filter',-1,0,...
            0,regfile_vector_vtype,coeffssltype);
            [~,coeffs_tempsig]=hdlnewsignal('coeffs_temp','filter',-1,0,...
            0,regfile_vector_vtype,coeffssltype);
            [~,coeffs_regssig]=hdlnewsignal('coeffs_regs','filter',-1,0,...
            0,regfile_vector_vtype,coeffssltype);
            [~,coeffs_shadowsig]=hdlnewsignal('coeffs_shadow','filter',-1,0,...
            0,regfile_vector_vtype,coeffssltype);
        end
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(coeffs_assignedsig)];
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(coeffs_tempsig)];
        hdlregsignal(coeffs_regssig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(coeffs_regssig)];
        hdlregsignal(coeffs_shadowsig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(coeffs_shadowsig)];

        c_asgn_sigs=hdlexpandvectorsignal(coeffs_assignedsig);
        c_regs_sigs=hdlexpandvectorsignal(coeffs_regssig);
        c_shdw_sigs=hdlexpandvectorsignal(coeffs_shadowsig);

        for n=1:coeff_len
            asgn_mux_bdy=hdlmux([coeffinregsig,c_regs_sigs(n)],c_asgn_sigs(n),wraddrregsig,{'='},n-1,'when-else');
            hdl_arch.body_blocks=[hdl_arch.body_blocks,asgn_mux_bdy];
        end

        c_tmp_bdy=hdlmux([coeffs_assignedsig,coeffs_regssig],coeffs_tempsig,wrenbregsig,{'='},1,'when-else');
        hdl_arch.body_blocks=[hdl_arch.body_blocks,c_tmp_bdy];


        [cfregs_bdy,tempsignals]=hdlunitdelay(coeffs_tempsig,coeffs_regssig,...
        ['Coeffs_Registers',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,cfregs_bdy];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];

        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(coeffs_en_sig);

        [cfshadow_bdy,tempsignals]=hdlunitdelay(coeffs_regssig,coeffs_shadowsig,...
        ['Coeffs_Shadow_Regs',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,cfshadow_bdy];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdlsetcurrentclockenable(oldce);
        coeffs_table=c_shdw_sigs;
        coeffs_data.idx=coeffs_table;
        coeffs_data.values=coeffs_data.values;

    end
