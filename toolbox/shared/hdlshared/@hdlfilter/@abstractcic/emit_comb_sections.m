function[hdl_arch,current_input]=emit_comb_sections(this,sectionvtype,sectionsltype,current_input)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    numdifferentialdelay=this.differentialdelay;
    numsections=this.numberofsections;
    sections=this.getsections;
    numfactor=sections.numfactor;

    roundmode=this.roundmode;
    overflowmode=0;

    complexity=this.isInputPortComplex;

    secSLTypes=this.sectionSLtypes;
    secVTypes=cell(1,4);
    for n=1:length(secSLTypes)
        sectionall=hdlgetallfromsltype(this.sectionSLtype{n});
        secVTypes{n}=sectionall.vtype;
    end

    for section=sections.first_combsection:sections.last_combsection

        sectioninvtype=sectionvtype;
        sectioninsltype=sectionsltype;

        sectionvtype=secVTypes(section);
        sectionvtype=sectionvtype{1};
        sectionsltype=secSLTypes(section);
        sectionsltype=sectionsltype{1};


        fprintf('%s %s\n',hdlcodegenmsgs(11),...
        getString(message('HDLShared:hdlfilter:codegenmessage:seccomb',section)));


        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,...
        '  ------------------ Section # ',num2str(section),' : Comb ------------------\n\n'];
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



        [tempname,sub_temp]=hdlnewsignal(['diff',num2str(section-sections.diffindex)],...
        'filter',-1,complexity,0,sectionvtype,sectionsltype);
        if numdifferentialdelay==1

            hdlregsignal(sub_temp);
        end

        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sub_temp)];

        [tempname,section_out]=hdlnewsignal(['section_out',num2str(section)],...
        'filter',-1,complexity,0,sectionvtype,sectionsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(section_out)];

        [tempbody,tempsignals]=hdlfiltersub(cast_result,sub_temp,section_out,roundmode,overflowmode);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];





        if numdifferentialdelay==1
            [tempbody,tempsignals]=hdlunitdelay(cast_result,sub_temp,...
            ['comb_delay_section',num2str(section)],'');
        else
            obj=hdl.intdelay('clock',hdlgetcurrentclock,...
            'clockenable',hdlgetcurrentclockenable,...
            'reset',hdlgetcurrentreset,...
            'inputs',cast_result,...
            'outputs',sub_temp,...
            'processName',['comb_delay_section',num2str(section)],...
            'resetvalues',0,...
            'nDelays',numdifferentialdelay);
            if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
                obj.setResetNone;
            end
            intdelaycode=obj.emit;
            tempbody=intdelaycode.arch_body_blocks;
            tempsignals=intdelaycode.arch_signals;
            if section==sections.first_combsection
                int_typedefs={};
                total_typedefs=[];
            end
            if strcmpi(hdlgetparameter('target_language'),'vhdl')


                this_int_typedef=hdlgetparameter('vhdl_package_type_defs');
                if~any(strcmp(int_typedefs,this_int_typedef))
                    int_typedefs={int_typedefs{:},this_int_typedef};
                    this_int_typedef=strrep(this_int_typedef,'-- Type Definitions\n  ','');
                    total_typedefs=[total_typedefs,this_int_typedef];
                end
                hdlsetparameter('vhdl_package_required',0);
            end
            if section==sections.last_combsection
                hdl_arch.typedefs=[hdl_arch.typedefs,total_typedefs];
            end
        end

        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];



        if hdlgetparameter('filter_pipelined')&&section~=numsections*2
            hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+numfactor);
            [tempname,pipeout]=hdlnewsignal(['cic_pipeline',num2str(section)],...
            'filter',-1,complexity,0,...
            hdlsignalvtype(section_out),...
            hdlsignalsltype(section_out));
            hdlregsignal(pipeout);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(pipeout)];
            [tempbody,tempsignals]=hdlunitdelay(section_out,pipeout,...
            ['cic_pipeline',hdlgetparameter('clock_process_label'),...
            '_section',num2str(section)],0);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];

            section_out=pipeout;

        end

        current_input=section_out;

    end




