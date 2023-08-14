function baseEmit(this)







    emitMode=isempty(pirNetworkForFilterComp);

    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    if emitMode
        hdlentitysignalsinit;
    end


    checkhdl(this);



    hdl_arch=emit_inithdlarch(this);

    [entitysigs]=createhdlports(this);

    if emitMode

        fprintf('%s\n',hdlcodegenmsgs(2));
        fprintf('%s\n',hdlcodegenmsgs(3));
        fprintf('%s\n',hdlcodegenmsgs(4));
    end



    [inreg_arch,entitysigs,current_input]=emit_inputreg_process(this,entitysigs);
    switch this.implementation
    case 'parallel'

        [sections_arch,section_result]=emit_sections(this,current_input);


        [scaleout_arch,scaled_output]=emit_scaleoutput(this,section_result);


        finalcon_arch=emit_final_connection(this,entitysigs,scaled_output);

        hdl_arch=combinehdlcode(this,hdl_arch,inreg_arch,sections_arch,scaleout_arch,finalcon_arch);

        emit_assemblehdlcode(this,hdl_arch);

    case{'serial'}

        [sections_arch,opconvert,phase_0]=emit_iirserial(this,current_input);


        finalcon_arch=emit_final_connection_serial(this,entitysigs,opconvert,phase_0);
        [hdl_arch]=combinehdlcode(this,hdl_arch,inreg_arch,sections_arch,finalcon_arch);
        emit_assemblehdlcode(this,hdl_arch);
    end


