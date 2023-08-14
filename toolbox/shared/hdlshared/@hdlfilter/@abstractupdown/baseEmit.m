function baseEmit(this,varargin)






    top=this;
    fcascade=this.Filters;
    nco=this.NCO;

    inputrounding='round';
    inputsaturation=true;


    ncocastrounding='floor';
    ncocastsaturation=0;


    hdl_entity_comment=this.Comment;
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    topname=this.getHDLParameter('filter_name');


    hdl_arch_functions=[indentedcomment,'Local Functions\n'];
    hdl_arch_typedefs=[indentedcomment,'Type Definitions\n'];
    hdl_arch_constants=[indentedcomment,'Constants\n'];
    hdl_arch_signals=[indentedcomment,'Signals\n'];
    hdl_arch_body_blocks=['\n',indentedcomment,'Block Statements\n'];
    hdl_arch_body_output_assignments=[indentedcomment,'Assignment Statements\n'];

    if hdlgetparameter('isverilog')
        hdl_arch_decl='';
        hdl_arch_comment='';
        hdl_arch_end=['endmodule',indentedcomment,topname,'\n'];
        hdl_arch_component_decl='';
        hdl_arch_component_config='';
        hdl_arch_begin='';
        hdl_arch_body_component_instances='';
        hdl_entity_library='';
        hdl_entity_package=hdlverilogtimescale;
        hdl_entity_decl=['module ',topname,' '];
        hdl_entity_end='';
    elseif hdlgetparameter('isvhdl')
        hdl_arch_decl=['ARCHITECTURE rtl OF ',topname,' IS\n'];
        if hdlgetparameter('split_entity_arch')==1,
            hdl_arch_comment=hdl_entity_comment;
        else
            hdl_arch_comment=hdldefarchheader(topname);
        end
        hdl_arch_end='END rtl;\n';
        hdl_arch_component_decl='';
        hdl_arch_component_config='';
        hdl_arch_begin='\n\nBEGIN\n';
        hdl_arch_body_component_instances='';
        [hdl_entity_library,...
        hdl_entity_package,...
        hdl_entity_decl,...
        hdl_entity_end]=vhdlentityinit(topname);
    end

    if isFilterComplex(top)
        fcascade.setHDLParameter('InputComplex','on');
        filterscomplexity=1;
    else
        filterscomplexity=0;
    end

    filtersname=[topname,'_filters'];
    fcascade.setHDLParameter('Name',filtersname);
    fcascade.setHDLParameter('ClockEnableInputPort','clock_enable_filters');
    fcascade.setHDLParameter('ClockEnableOutputPort','ce_out_filters');
    fcascade.updateHdlfilterINI;

    PersistentHDLPropSet(fcascade.HDLParameters);
    if this.isa('hdlfilter.duc')
        filtvalidname=[hdlgetparameter('clockenableoutputvalidname'),'_filters'];
        hdlsetparameter('clockenableoutputvalidname',filtvalidname);
    end
    emit(fcascade);


    sfx='';

    if hdlgetparameter('filter_complex_inputs')
        sfx=hdlgetparameter('complex_real_postfix');
    end
    fin=hdlsignalfindname([hdlgetparameter('filter_input_name'),sfx]);
    fout=hdlsignalfindname([hdlgetparameter('filter_output_name'),sfx]);
    fin_name=hdlsignalname(fin);
    fin_name(end-length(sfx)+1:end)='';
    fin_vtype=hdlsignalvtype(fin);
    fin_sltype=hdlsignalsltype(fin);

    fout_name=hdlsignalname(fout);
    fout_name(end-length(sfx)+1:end)='';
    fout_vtype=hdlsignalvtype(fout);
    fout_sltype=hdlsignalsltype(fout);


    clkenbsig=hdlsignalfindname(hdlgetparameter('clockenablename'));
    clkenboutsig=hdlsignalfindname(hdlgetparameter('clockenableoutputname'));
    fclkenb_name=hdlsignalname(clkenbsig);
    fclkenbout_name=hdlsignalname(clkenboutsig);
    clkenbsig_vtype=hdlsignalvtype(clkenbsig);
    clkenbsig_sltype=hdlsignalsltype(clkenbsig);
    [filter_hdl_ports,~,filters_hdl_inst]=hdlentityports(filtersname);
    allfilternames=hdlentitynames;

    if hdlgetparameter('isvhdl')
        hdl_arch_component_decl=[hdl_arch_component_decl,...
        '  COMPONENT ',filtersname,'\n',...
        filter_hdl_ports,...
        '    END COMPONENT;\n\n'];
    end

    if hdlgetparameter('isvhdl')&&hdlgetparameter('inline_configurations')
        hdl_arch_component_config=[hdl_arch_component_config,...
        '  FOR ALL : ',filtersname,'\n',...
        '    USE ENTITY work.',filtersname,'(rtl);\n\n'];
    end

    hdl_arch_body_component_instances=[hdl_arch_body_component_instances,filters_hdl_inst];


    nconame=[topname,'_nco'];
    nco.setHDLParameter('Name',nconame);
    nco.setHDLParameter('ClockEnableInputPort','clock_enable_nco');
    nco.updateHdlfilterINI;
    PersistentHDLPropSet(nco.HDLParameters);
    hdlentitysignalsinit;
    emit(nco);
    if nco.isOutputPortComplex
        sfx=hdlgetparameter('complex_real_postfix');
    else
        sfx='';
    end
    ncoout=hdlsignalfindname(['nco_out',sfx]);
    ncoout_name=hdlsignalname(ncoout);
    ncoout_name(end-length(sfx)+1:end)='';
    ncoout_vtype=hdlsignalvtype(ncoout);
    ncoout_sltype=hdlsignalsltype(ncoout);

    [nco_hdl_ports,~,nco_hdl_inst]=hdlentityports(nconame);


    ncoclkenbsig=hdlsignalfindname(hdlgetparameter('clockenablename'));
    ncoclkenb_name=hdlsignalname(ncoclkenbsig);
    ncoclkenbsig_vtype=hdlsignalvtype(ncoclkenbsig);
    ncoclkenbsig_sltype=hdlsignalsltype(ncoclkenbsig);


    if hdlgetparameter('isvhdl')
        hdl_arch_component_decl=[hdl_arch_component_decl,...
        '  COMPONENT ',nconame,'\n',...
        nco_hdl_ports,...
        '    END COMPONENT;\n\n'];
    end

    if hdlgetparameter('isvhdl')&&hdlgetparameter('inline_configurations')
        hdl_arch_component_config=[hdl_arch_component_config,...
        '  FOR ALL : ',nconame,'\n',...
        '    USE ENTITY work.',nconame,'(rtl);\n\n'];
    end

    hdl_arch_body_component_instances=[hdl_arch_body_component_instances,nco_hdl_inst];


    PersistentHDLPropSet(top.HDLParameters);

    [convipportname,convopportname]=top.getIOPortNames;
    top.setHDLParameter('InputPort',convipportname);
    top.setHDLParameter('OutputPort',convopportname);

    hdlsetparameter('filter_input_name',convipportname);
    hdlsetparameter('filter_output_name',convopportname);
    entitysigs=createhdlports(top);

    [hdl_entity_ports,hdl_entity_portdecls]=hdlentityports;





    for n=1:numel(allfilternames)
        hdladdtoentitylist('filter',allfilternames{n},'','');
    end

    hdladdtoentitylist('filter',nconame,nco_hdl_ports,'');
    hdladdtoentitylist('filter',topname,hdl_entity_ports,'');
    fprintf('%s\n',hdlcodegenmsgs(2));
    fprintf('%s\n',hdlcodegenmsgs(3));
    fprintf('%s\n',hdlcodegenmsgs(4));


    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';


    [~,finsignal]=hdlnewsignal(fin_name,'filter',-1,filterscomplexity,0,...
    fin_vtype,fin_sltype);
    [~,foutsignal]=hdlnewsignal(fout_name,'filter',-1,filterscomplexity,0,...
    fout_vtype,fout_sltype);
    [~,ncosignal]=hdlnewsignal(ncoout_name,'filter',-1,nco.isOutputPortComplex,0,...
    ncoout_vtype,ncoout_sltype);
    [~,clkenbsignal]=hdlnewsignal(fclkenb_name,'filter',-1,0,0,...
    clkenbsig_vtype,clkenbsig_sltype);
    [~,clkenboutsignal]=hdlnewsignal(fclkenbout_name,'filter',-1,0,0,...
    clkenbsig_vtype,clkenbsig_sltype);
    [~,ncoclkenbsignal]=hdlnewsignal(ncoclkenb_name,'filter',-1,0,0,...
    ncoclkenbsig_vtype,ncoclkenbsig_sltype);
    hdlregsignal(clkenbsignal);
    hdl_arch.signals=[hdl_arch.signals,...
    makehdlsignaldecl(finsignal),...
    makehdlsignaldecl(foutsignal),...
    makehdlsignaldecl(ncosignal),...
    makehdlsignaldecl(clkenbsignal),...
    makehdlsignaldecl(clkenboutsignal),...
    makehdlsignaldecl(ncoclkenbsignal),...
    ];
    if this.isa('hdlfilter.duc')
        [~,fclkvalidsignal]=hdlnewsignal(filtvalidname,'filter',-1,0,0,...
        clkenbsig_vtype,clkenbsig_sltype);
        hdl_arch.signals=[hdl_arch.signals,...
        makehdlsignaldecl(fclkvalidsignal)];

        ncoclkenbody=hdlbitop([clkenbsignal,fclkvalidsignal],ncoclkenbsignal,'AND');
        hdl_arch.body_blocks=[hdl_arch.body_blocks,ncoclkenbody];
    else

        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        hdlsignalassignment(clkenbsig,ncoclkenbsignal)];
        fclkvalidsignal=[];
    end


    inputall=hdlgetallfromsltype(this.InputSLType);




    if hdlgetparameter('filter_registered_input')
        [~,inputreg]=hdlnewsignal([convipportname,'_reg'],'filter',-1,hdlsignaliscomplex(entitysigs.input),0,inputall.vtype,inputall.sltype);
        hdlregsignal(inputreg);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputreg)];
        [iputsigbody,iptempsignals]=hdlunitdelay(entitysigs.input,inputreg,...
        ['Input_Register',hdlgetparameter('clock_process_label')],0);
        hdl_arch.signals=[hdl_arch.signals,iptempsignals];

        [clkenbsigbody,clkenbtempsignals]=hdlunitdelay(entitysigs.clken,clkenbsignal,...
        ['Clk_Enable_Register',hdlgetparameter('clock_process_label')],0);
        hdl_arch.signals=[hdl_arch.signals,clkenbtempsignals];
    else
        [~,inputreg]=hdlnewsignal([convipportname,'_cast'],'filter',-1,hdlsignaliscomplex(entitysigs.input),0,inputall.vtype,inputall.sltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputreg)];
        iputsigbody=hdldatatypeassignment(entitysigs.input,inputreg,inputrounding,inputsaturation);

        clkenbsigbody=hdldatatypeassignment(entitysigs.clken,clkenbsignal,inputrounding,inputsaturation);
    end
    hdl_arch.body_blocks=[hdl_arch.body_blocks,iputsigbody,clkenbsigbody];



    ncoall=hdlgetallfromsltype(ncoout_sltype);
    if hdlgetparameter('filter_registered_input')
        [~,ncocastsig]=hdlnewsignal('nco_out_reg','filter',-1,nco.isOutputPortComplex,0,ncoall.vtype,ncoall.sltype);
        hdlregsignal(ncocastsig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ncocastsig)];
        [ncocastbody,ncotempsignals]=hdlunitdelay(ncosignal,ncocastsig,...
        ['NCO_Output_Register',hdlgetparameter('clock_process_label')],0);
        hdl_arch.signals=[hdl_arch.signals,ncotempsignals];
    else

        [~,ncocastsig]=hdlnewsignal('nco_out_cast','filter',-1,nco.isOutputPortComplex,0,ncoall.vtype,ncoall.sltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ncocastsig)];
        ncocastbody=hdldatatypeassignment(ncosignal,ncocastsig,ncocastrounding,ncocastsaturation);
    end
    hdl_arch.body_blocks=[hdl_arch.body_blocks,ncocastbody];

    [conjbody,conjsignals,ncoouttoprod]=emit_ncoconjugateout(this,ncocastsig);


    [wiringbody,wiringsignals,wiringbodyassignments]=emit_topwiring(this,inputreg,...
    ncoouttoprod,finsignal,foutsignal,clkenboutsignal,entitysigs,fclkvalidsignal);

    hdl_arch.body_blocks=[hdl_arch.body_blocks,conjbody,wiringbody];
    hdl_arch.signals=[hdl_arch.signals,conjsignals,wiringsignals];
    hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,...
    wiringbodyassignments];

    codegendir=hdlGetCodegendir;
    fileprefix=hdlgetparameter('module_prefix');
    if hdlgetparameter('split_entity_arch')==1
        entityfilename=fullfile(codegendir,[fileprefix,topname,...
        hdlgetparameter('split_entity_file_postfix'),...
        hdlgetparameter('filename_suffix')]);
        archfilename=fullfile(codegendir,[fileprefix,topname,...
        hdlgetparameter('split_arch_file_postfix'),...
        hdlgetparameter('filename_suffix')]);
        opentype='w';
    else
        entityfilename=fullfile(codegendir,[fileprefix,topname,...
        hdlgetparameter('filename_suffix')]);
        archfilename=entityfilename;
        opentype='a';
    end
    entityfid=fopen(entityfilename,'w');
    if entityfid==-1
        error(message('HDLShared:hdlfilter:fileerror',entityfilename));
    end

    hdl_entity=[hdl_entity_comment,...
    hdl_entity_library,...
    hdl_entity_package,...
    hdl_entity_decl,...
    hdl_entity_ports,...
    hdl_entity_portdecls,...
    hdl_entity_end];

    fprintf(entityfid,hdl_entity);
    fclose(entityfid);

    archfid=fopen(archfilename,opentype);
    if archfid==-1
        error(message('HDLShared:hdlfilter:fileerror',archfilename));
    end

    hdl_arch_body_blocks=[hdl_arch_body_blocks,hdl_arch.body_blocks];
    hdl_arch_signals=[hdl_arch_signals,hdl_arch.signals];
    hdl_arch_body_output_assignments=[hdl_arch_body_output_assignments,...
    hdl_arch.body_output_assignments];

    hdl_arch=[hdl_arch_comment,...
    hdl_arch_decl,...
    hdl_arch_component_decl,...
    hdl_arch_component_config,...
    hdl_arch_functions,...
    hdl_arch_typedefs,...
    hdl_arch_constants,...
    hdl_arch_signals,...
    hdl_arch_begin,...
    hdl_arch_body_component_instances,...
    hdl_arch_body_blocks,...
    hdl_arch_body_output_assignments,...
    hdl_arch_end];
    fprintf(archfid,hdl_arch);
    fclose(archfid);
    disp(sprintf('%s',hdlcodegenmsgs(7,latency(this))));




