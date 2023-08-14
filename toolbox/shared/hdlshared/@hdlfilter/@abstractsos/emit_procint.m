function[sections_arch,num_list,den_list,scaled_input]=emit_procint(this,sections_arch,current_input,section,scaleresultall)










    scales=0.9585*ones(1,(this.NumSections+1));
    coeffs=0.9585*ones(size(this.coefficients));

    coeffs(:,[3,6])=0.9585*[any(this.Coefficients(:,[3,6]),3)];


    multpliers=hdlgetparameter('filter_multipliers');
    if strcmpi(multpliers,'csd')||strcmpi(multpliers,'factored-csd')
        hprop=PersistentHDLPropSet;
        hprop.CLI.CoeffMultipliers='multiplier';
        updateINI(hprop);
        warning(message('HDLShared:hdlfilter:procifnotwithcsd'));
    end

    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    coeffsvsize=numcoeffall.size;
    numcoeffsvbp=numcoeffall.bp;
    coeffssigned=numcoeffall.signed;

    numcoeffsvtype=numcoeffall.vtype;
    numcoeffssltype=numcoeffall.sltype;

    dencoeffall=hdlgetallfromsltype(this.dencoeffSLtype);
    dencoeffsvbp=dencoeffall.bp;
    dencoeffsvtype=dencoeffall.vtype;
    dencoeffssltype=dencoeffall.sltype;

    scaleall=hdlgetallfromsltype(this.scaleSLtype);
    scalebp=scaleall.bp;
    scalevtype=scaleall.vtype;
    scalesltype=scaleall.sltype;

    scaleresultvtype=scaleresultall.vtype;
    scaleresultsltype=scaleresultall.sltype;

    rmode=this.Roundmode;
    productrounding=rmode;
    omode=this.Overflowmode;
    productsaturation=omode;

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
    sections_arch.signals=[sections_arch.signals,indentedcomment,'Section ',num2str(section),'   Processor Interface Signals \n'];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    indentedcomment,...
    '  -------- Section ',num2str(section),' Processor Interface logic------------------\n\n'];

    scale_assigned_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(section),'_assigned']);
    [uname,scale_assigned]=hdlnewsignal(scale_assigned_name,'filter',-1,0,0,scalevtype,scalesltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(scale_assigned)];

    scale_temp_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(section),'_temp']);
    [uname,scale_temp]=hdlnewsignal(scale_temp_name,'filter',-1,0,0,scalevtype,scalesltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(scale_temp)];

    scale_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(section),'_reg']);
    [uname,scale_reg]=hdlnewsignal(scale_reg_name,'filter',-1,0,0,scalevtype,scalesltype);
    hdlregsignal(scale_reg);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(scale_reg)];

    scale_shadow_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(section),'_shadow_reg']);
    [uname,scale_shadow_reg]=hdlnewsignal(scale_shadow_reg_name,'filter',-1,0,0,scalevtype,scalesltype);
    hdlregsignal(scale_shadow_reg);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(scale_shadow_reg)];

    mcand_input=current_input.input;

    [scaled_input,tempbody,tempsignals,moresignals]=hdlcoeffmultiply(mcand_input,...
    scales(section),...
    scale_shadow_reg,...
    ['scale',num2str(section)],...
    scaleresultvtype,scaleresultsltype,...
    productrounding,productsaturation);

    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
    sections_arch.signals=[sections_arch.signals,tempsignals,moresignals];


    s_asgn_mux_bdy=hdlmux([current_input.coeffs,scale_reg],scale_assigned,current_input.wraddr,{'='},((section-1)*8),'when-else');
    sections_arch.body_blocks=[sections_arch.body_blocks,s_asgn_mux_bdy];

    s_tmp_mux_bdy=hdlmux([scale_assigned,scale_reg],scale_temp,current_input.wrenb,{'='},1,'when-else');
    sections_arch.body_blocks=[sections_arch.body_blocks,s_tmp_mux_bdy];


    [num,den]=getcoeffs(coeffs,section);
    filterorders=this.SectionOrder;


    input_idx_1=[scale_temp];
    output_idx_1=[scale_reg];
    input_idx_2=[scale_reg];
    output_idx_2=[scale_shadow_reg];
    scalaric=[0];

    num_list=[];
    for n=1:length(num)
        if(filterorders(section)==1)&&(n==3)
            num_list=[num_list,0];
        else
            coeff_assigned_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_b',num2str(n),'_section',num2str(section),'_assigned']);
            [uname,coeff_assigned]=hdlnewsignal(coeff_assigned_name,'filter',-1,0,0,numcoeffsvtype,numcoeffssltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_assigned)];

            coeff_temp_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_b',num2str(n),'_section',num2str(section),'_temp']);
            [uname,coeff_temp]=hdlnewsignal(coeff_temp_name,'filter',-1,0,0,numcoeffsvtype,numcoeffssltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_temp)];

            coeff_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_b',num2str(n),'_section',num2str(section),'_reg']);
            [uname,coeff_reg]=hdlnewsignal(coeff_reg_name,'filter',-1,0,0,numcoeffsvtype,numcoeffssltype);
            hdlregsignal(coeff_reg);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_reg)];

            coeff_shadow_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_b',num2str(n),'_section',num2str(section),'_shadow_reg']);
            [uname,coeff_shadow_reg]=hdlnewsignal(coeff_shadow_reg_name,'filter',-1,0,0,numcoeffsvtype,numcoeffssltype);
            hdlregsignal(coeff_shadow_reg);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_shadow_reg)];

            num_list=[num_list,coeff_shadow_reg];
            input_idx_1=[input_idx_1,coeff_temp];
            output_idx_1=[output_idx_1,coeff_reg];
            input_idx_2=[input_idx_2,coeff_reg];
            output_idx_2=[output_idx_2,coeff_shadow_reg];
            scalaric=[scalaric,0];


            c_asgn_mux_bdy=hdlmux([current_input.coeffs,coeff_reg],coeff_assigned,current_input.wraddr,{'='},((section-1)*8+n),'when-else');
            sections_arch.body_blocks=[sections_arch.body_blocks,c_asgn_mux_bdy];

            c_tmp_mux_bdy=hdlmux([coeff_assigned,coeff_reg],coeff_temp,current_input.wrenb,{'='},1,'when-else');
            sections_arch.body_blocks=[sections_arch.body_blocks,c_tmp_mux_bdy];
        end

    end

    den_list=[0];
    for n=2:length(den)
        if(filterorders(section)==1)&&(n==3)
            den_list=[den_list,0];
        else
            coeff_assigned_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_a',num2str(n),'_section',num2str(section),'_assigned']);
            [uname,coeff_assigned]=hdlnewsignal(coeff_assigned_name,'filter',-1,0,0,dencoeffsvtype,dencoeffssltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_assigned)];

            coeff_temp_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_a',num2str(n),'_section',num2str(section),'_temp']);
            [uname,coeff_temp]=hdlnewsignal(coeff_temp_name,'filter',-1,0,0,dencoeffsvtype,dencoeffssltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_temp)];

            coeff_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_a',num2str(n),'_section',num2str(section),'_reg']);
            [uname,coeff_reg]=hdlnewsignal(coeff_reg_name,'filter',-1,0,0,dencoeffsvtype,dencoeffssltype);
            hdlregsignal(coeff_reg);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_reg)];

            coeff_shadow_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_a',num2str(n),'_section',num2str(section),'_shadow_reg']);
            [uname,coeff_shadow_reg]=hdlnewsignal(coeff_shadow_reg_name,'filter',-1,0,0,dencoeffsvtype,dencoeffssltype);
            hdlregsignal(coeff_shadow_reg);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(coeff_shadow_reg)];

            den_list=[den_list,coeff_shadow_reg];
            input_idx_1=[input_idx_1,coeff_temp];
            output_idx_1=[output_idx_1,coeff_reg];
            input_idx_2=[input_idx_2,coeff_reg];
            output_idx_2=[output_idx_2,coeff_shadow_reg];
            scalaric=[scalaric,0];


            c_asgn_mux_bdy=hdlmux([current_input.coeffs,coeff_reg],coeff_assigned,current_input.wraddr,{'='},((section-1)*8+n+2),'when-else');
            sections_arch.body_blocks=[sections_arch.body_blocks,c_asgn_mux_bdy];

            c_tmp_mux_bdy=hdlmux([coeff_assigned,coeff_reg],coeff_temp,current_input.wrenb,{'='},1,'when-else');
            sections_arch.body_blocks=[sections_arch.body_blocks,c_tmp_mux_bdy];
        end
    end

    [tempbody,tempsignals]=hdlunitdelay(input_idx_1,output_idx_1,...
    ['coeff_reg',hdlgetparameter('clock_process_label'),'_section',num2str(section)],scalaric);
    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
    sections_arch.signals=[sections_arch.signals,tempsignals];

    oldce=hdlgetcurrentclockenable;
    hdladdclockenablesignal(current_input.wrdone);
    hdlsetcurrentclockenable(current_input.wrdone);

    [tempbody,tempsignals]=hdlunitdelay(input_idx_2,output_idx_2,...
    ['coeff_shadow_reg',hdlgetparameter('clock_process_label'),'_section',num2str(section)],scalaric);
    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
    sections_arch.signals=[sections_arch.signals,tempsignals];
    hdlsetcurrentclockenable(oldce);



    function[num,den]=getcoeffs(coeffs,section)
        num=coeffs(section,1:3);
        den=coeffs(section,4:6);


