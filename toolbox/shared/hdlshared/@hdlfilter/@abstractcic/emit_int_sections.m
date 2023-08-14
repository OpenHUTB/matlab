function[hdl_arch,current_input]=emit_int_sections(this,sectionvtype,sectionsltype,current_input)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];



    roundmode=this.roundmode;
    overflowmode=0;

    complexity=this.isInputPortComplex;

    secSLTypes=this.sectionSLtypes;
    secVTypes=cell(1,4);

    for n=1:length(secSLTypes)
        sectionall=hdlgetallfromsltype(this.sectionSLtype{n});
        secVTypes{n}=sectionall.vtype;
    end
    [sections]=getsections(this);

    sumindex=1;

    for section=sections.first_intsection:sections.last_intsection
        sectioninvtype=sectionvtype;
        sectioninsltype=sectionsltype;

        sectionvtype=secVTypes(section);
        sectionvtype=sectionvtype{1};
        sectionsltype=secSLTypes(section);
        sectionsltype=sectionsltype{1};

        fprintf('%s %s\n',hdlcodegenmsgs(11),...
        getString(message('HDLShared:hdlfilter:codegenmessage:secint',section)));


        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,...
        '  ------------------ Section # ',num2str(section),' : Integrator ------------------\n\n'];
        hdl_arch.signals=[hdl_arch.signals,indentedcomment,'  -- Section ',num2str(section),' Signals \n'];


        [tempname,section_in]=hdlnewsignal(['section_in',num2str(section)],'filter',-1,complexity,0,sectioninvtype,sectioninsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(section_in)];

        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdldatatypeassignment(current_input,section_in,...
        roundmode,overflowmode)];


        if~strcmpi(sectioninvtype,sectionvtype)||...
            ~strcmp(sectioninsltype,sectionsltype)

            [castname,cast_result]=hdlnewsignal(['section_cast',num2str(section)],'filter',-1,complexity,0,...
            sectionvtype,sectionsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(cast_result)];

            hdl_arch.body_blocks=[hdl_arch.body_blocks,hdldatatypeassignment(section_in,cast_result,...
            roundmode,overflowmode)];

        else
            cast_result=section_in;
        end



        [tempname,add_temp]=hdlnewsignal(['sum',num2str(sumindex)],...
        'filter',-1,complexity,0,sectionvtype,sectionsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(add_temp)];
        [tempname,section_out]=hdlnewsignal(['section_out',num2str(section)],...
        'filter',-1,complexity,0,sectionvtype,sectionsltype);
        hdlregsignal(section_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(section_out)];

        [tempbody,tempsignals]=hdlfilteradd(cast_result,section_out,add_temp,roundmode,overflowmode);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];


        [tempbody,tempsignals]=hdlunitdelay(add_temp,section_out,...
        ['integrator_delay_section',num2str(section)],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];

        current_input=section_out;
        sumindex=sumindex+1;
    end





