function[sections_arch,opconvert,phase_0]=emitfullyserial(this,current_input)







    arithisdouble=strcmpi(this.InputSLType,'double');
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
    coeffs=this.Coefficients;
    sections_arch.typedefs='';
    sections_arch.constants='';
    sections_arch.body_blocks='';
    sections_arch.signals='';


    numstorageall=hdlgetallfromsltype(this.numstateSLtype);
    numstoragevtype=numstorageall.vtype;
    numstoragesltype=numstorageall.sltype;

    denstorageall=hdlgetallfromsltype(this.denstateSLtype);
    denstoragevtype=denstorageall.vtype;
    denstoragesltype=denstorageall.sltype;

    scales=this.ScaleValues;
    nsections=this.Numsections;


    if scales(nsections+1)==1
        opscaleisunity=1;
    else
        opscaleisunity=0;
    end


    [iwlt,iflt]=hdlgetsizesfromtype(this.InputSLType);


    [cwlt1,svflt1]=hdlgetsizesfromtype(this.ScaleSLtype);
    if~arithisdouble
        if any(scales==1)&&cwlt1<svflt1+2

            cwlt1=svflt1+2;
        end
    else
        cwlt1=0;
        svflt1=0;
    end

    [~,nflt]=hdlgetsizesfromtype(this.NumCoeffSLtype);
    [~,dflt]=hdlgetsizesfromtype(this.DenCoeffSLtype);
    [nswlt,nsflt]=hdlgetsizesfromtype(this.NumStateSLtype);
    [dswlt,dsflt]=hdlgetsizesfromtype(this.DenStateSLtype);



    if~opscaleisunity

        sc_list=[];
        flag_scale=0;
        for section=1:this.Numsections+1
            if(this.ScaleValues(section)==1)
                if((cwlt1-svflt1)<2)
                    sc_list=[sc_list,section];
                    cwlt=svflt1+2;
                    flag_scale=1;
                else
                    cwlt=cwlt1;
                    flag_scale=0;
                end
            elseif(flag_scale==0)
                cwlt=cwlt1;
                flag_scale=0;
            end
            svflt=svflt1;
        end
    else
        cwlt=cwlt1;
        svflt=svflt1;
    end
    if arithisdouble
        cwl=0;
        cfl=0;
        ifl=0;
        iwl=0;
    else

        ifl=max([iflt,nsflt,dsflt]);
        iwl=max([(iwlt-iflt),(nswlt-nsflt),(dswlt-dsflt)])+ifl;


        cfl=max([svflt,nflt,dflt]);
        cwl=max([(cwlt-svflt),(cwlt-nflt),(cwlt-dflt)])+cfl;
    end

    [~,this.ScaleSLType]=hdlgettypesfromsizes(cwl,cfl,1);
    this.NumCoeffSLType=this.ScaleSLType;
    this.DenCoeffSLType=this.ScaleSLType;



    if(iwl==iwlt&&iwl==cwlt&&iwl==nswlt&&iwl==dswlt)
        flag_no_cast_states_input=1;
    else
        flag_no_cast_states_input=0;
    end

    [new_inputvtype,new_inputsltype]=hdlgettypesfromsizes(iwl,ifl,1);
    [new_coeffvtype,new_coeffsltype]=hdlgettypesfromsizes(cwl,cfl,1);

    if arithisdouble

        doubletype=hdlgetallfromsltype(this.InputSLType);
        new_inputvtype=doubletype.vtype;
        new_coeffvtype=doubletype.vtype;
        new_inputsltype=doubletype.sltype;
        new_coeffsltype=doubletype.sltype;
        cwl=0;
        cfl=0;

    end


    if~opscaleisunity
        [~,ptr2]=hdlnewsignal('oneconstant','filter',-1,0,0,new_coeffvtype,new_coeffsltype);
        sections_arch.constants=[sections_arch.constants,...
        makehdlconstantdecl(ptr2,hdlconstantvalue(real(1),cwl,cfl,1))];
    end

    if hdlgetparameter('isvhdl')
        sections_arch.typedefs=[sections_arch.typedefs,...
        '  TYPE numdelay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        numstoragevtype,'; -- ',numstoragesltype,'\n',...
        '  TYPE dendelay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        denstoragevtype,'; -- ',denstoragesltype,'\n'];

        numdelay_vector_vtype='numdelay_pipeline_type(0 TO 1)';
        dendelay_vector_vtype='dendelay_pipeline_type(0 TO 1)';
    else
        numdelay_vector_vtype=numstoragevtype;
        dendelay_vector_vtype=denstoragevtype;
    end


    [sections_arch,ffactor,ctr_sigs,ctr_out,numcast_result,dencast_result,...
    dencast_result_reg,clear_Accum_phase,den_phase]=emit_timingcontrol(this,...
    sections_arch,opscaleisunity);


    [sections_arch,scaled_inp_list,numdelaylist,dendelaylist,coeff_list,pre_stg_op_list]=emit_delayline(this,...
    den_phase,dencast_result,numdelay_vector_vtype,dendelay_vector_vtype,sections_arch,scales,...
    current_input,coeffs,ctr_sigs,opscaleisunity,cwl,cfl);



    if~opscaleisunity
        if(~isempty(sc_list))
            for num_indx=1:1:(length(sc_list)-1)
                coeff_list((num_indx*6-5))=ptr2;
            end
            if(this.ScaleValues(length(this.ScaleValues))==1)
                if(sc_list(length(sc_list))>this.numsections)
                    coeff_list(length(coeff_list))=ptr2;
                end
            end
        end
    end

    new_coeff_list=coeff_list;



    cplxty_densection=0;
    inpmux_list1=[];
    new_inp_list=[];
    strt=1;
    for section=1:this.Numsections
        if(section>1)
            inp_sel=pre_stg_op_list(section-1);
        else
            inp_sel=current_input.input;
        end
        inpmux_list1=[inpmux_list1,inp_sel,scaled_inp_list(section),numdelaylist(strt:strt+1)...
        ,dendelaylist(strt:strt+1)];
        strt=strt+2;
    end
    if~flag_no_cast_states_input
        for section=1:this.Numsections
            [~,inp_new]=hdlnewsignal(['input_section',num2str(section),'_cast'],...
            'filter',-1,cplxty_densection,0,...
            new_inputvtype,new_inputsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(inp_new)];
            [~,sca_inp_new]=hdlnewsignal(['scaled_input_section',num2str(section),'_cast'],...
            'filter',-1,cplxty_densection,0,...
            new_inputvtype,new_inputsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sca_inp_new)];
            num_state_new_list=[];
            for num_ele=1:2
                [~,num_state_new]=hdlnewsignal(['numdelay_section',num2str(section),num2str(num_ele),'_cast'],...
                'filter',-1,cplxty_densection,0,...
                new_inputvtype,new_inputsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(num_state_new)];
                num_state_new_list=[num_state_new_list,num_state_new];
            end
            denum_state_new_list=[];
            for denum_ele=1:2
                [~,denum_state_new]=hdlnewsignal(['denumdelay_section',num2str(section),num2str(denum_ele),'_cast'],...
                'filter',-1,cplxty_densection,0,...
                new_inputvtype,new_inputsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(denum_state_new)];
                denum_state_new_list=[denum_state_new_list,denum_state_new];
            end
            new_inp_list=[new_inp_list,inp_new,sca_inp_new,num_state_new_list,denum_state_new_list];
        end
    else
        new_inp_list=inpmux_list1;
    end
    sections_arch.body_blocks=[sections_arch.body_blocks,[indentedcomment,'Making common precision for input, num state and denum state\n']];
    if(flag_no_cast_states_input==1)
        new_inp_list=inpmux_list1;
    else
        for num_indx=1:6*this.Numsections
            sections_arch.body_blocks=[sections_arch.body_blocks,...
            hdldatatypeassignment(inpmux_list1(num_indx),new_inp_list((num_indx)),...
            this.RoundMode,this.OverflowMode)];
        end
    end


    [sections_arch,opconvert]=emit_machdl(this,new_inputvtype,new_inputsltype,new_coeffvtype,new_coeffsltype,new_inp_list,pre_stg_op_list,clear_Accum_phase,ctr_out,sections_arch,scaled_inp_list,...
    current_input,numcast_result,numdelaylist,dendelaylist,ffactor,...
    new_coeff_list,dencast_result,dencast_result_reg,opscaleisunity);


    [sections_arch]=scaledinp_reg(this,sections_arch,ctr_sigs,scaled_inp_list,numcast_result);

    if~opscaleisunity
        phase_0=clear_Accum_phase(end);
    else
        phase_0=den_phase(end);
    end
    hdladdclockenablesignal(phase_0);
end





function[num,den]=getcoeffs(coeffs,section)
    num=coeffs(section,1:3);
    den=coeffs(section,4:6);
end

function[sections_arch]=scaledinp_reg(this,sections_arch,ctr_sigs,scaled_inp_list,numcast_result)
    for section=1:this.NumSections
        hdladdclockenablesignal(ctr_sigs(section));
        hdlsetcurrentclockenable(ctr_sigs(section));
        [tempbody,tempsignals]=hdlunitdelay(numcast_result,scaled_inp_list(section),...
        ['scale_reg',num2str(section),hdlgetparameter('clock_process_label')],0);
        sections_arch.signals=[sections_arch.signals,tempsignals];
        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
        port_list=hdlinportsignals;
        hdlsetcurrentclockenable(port_list(2));
    end
end

function[sections_arch,num_list,den_list]=emit_coefficients(this,sections_arch,~,section,~,coeffsizes)



    coeffs=this.Coefficients;

    [fcoeffvsize,fcoeffsltype]=hdlgettypesfromsizes(coeffsizes(1),coeffsizes(2),1);
    [num,den]=getcoeffs(coeffs,section);

    num_list=[];
    for n=1:length(num)
        cplxty_num=any(imag(num(n)));
        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_b',num2str(n),'_section',num2str(section)]);
        [~,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_num,0,fcoeffvsize,fcoeffsltype);
        num_list=[num_list,ptr];
        if cplxty_num
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(real(num(n)),coeffsizes(1),coeffsizes(2),1))];
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(ptr),hdlconstantvalue(imag(num(n)),coeffsizes(1),coeffsizes(2),1))];
        else
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(num(n),coeffsizes(1),coeffsizes(2),1))];
        end
    end
    den_list=0;
    for n=2:length(den)

        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_a',num2str(n),'_section',num2str(section)]);
        cplxty_den=any(imag(den(n)));
        [~,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_den,0,fcoeffvsize,fcoeffsltype);
        den_list=[den_list,ptr];
        if cplxty_den
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(real(den(n)),coeffsizes(1),coeffsizes(2),1))];
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(ptr),hdlconstantvalue(imag(den(n)),coeffsizes(1),coeffsizes(2),1))];

        else
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(den(n),coeffsizes(1),coeffsizes(2),1))];
        end
    end
end

function[sections_arch,ffactor,ctr_sigs,ctr_out,numcast_result,dencast_result,dencast_result_reg,clear_Accum_phase,den_phase]=emit_timingcontrol(this,sections_arch,opscaleisunity)


    densumall=hdlgetallfromsltype(this.denAccumSLtype);
    densumvtype=densumall.vtype;
    densumsltype=densumall.sltype;

    numstorageall=hdlgetallfromsltype(this.numstateSLtype);
    numstoragevtype=numstorageall.vtype;
    numstoragesltype=numstorageall.sltype;

    denstorageall=hdlgetallfromsltype(this.denstateSLtype);
    denstoragevtype=denstorageall.vtype;
    denstoragesltype=denstorageall.sltype;







    indx=1;
    for i=0:6:((this.NumSections-1)*6)
        phases_cell{indx}=i;
        phases_cell{indx+1}=i+1;
        phases_cell{indx+2}=i+5;
        indx=indx+3;
    end

    if~opscaleisunity
        phases_cell{end+1}=i+6;
    end

    ffactor=getfilterlengths(this);
    [~,~,~]=this.getSerialPartition('multipliers',1);
    hdlsetparameter('FoldingFactor',ffactor);
    count_to=ffactor;


    count_bits=max(2,ceil(log2(count_to)));
    [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
    [~,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
    countvtype,countsltype);
    hdlregsignal(ctr_out);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ctr_out)];

    [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',...
    hdlgetparameter('clock_process_label')],...
    1,0,phases_cell);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ctr_sigs)];



    if~opscaleisunity
        new_ctr_sigs=ctr_sigs(1:3:length(ctr_sigs)-1);
        clear_Accum_phase=[ctr_sigs(2:3:length(ctr_sigs)-1),ctr_sigs(end)];
        den_phase=ctr_sigs(3:3:length(ctr_sigs)-1);
    else
        new_ctr_sigs=ctr_sigs(1:3:length(ctr_sigs));
        clear_Accum_phase=ctr_sigs(2:3:length(ctr_sigs));
        den_phase=ctr_sigs(3:3:length(ctr_sigs));
    end

    ctr_sigs=new_ctr_sigs;
    hdladdclockenablesignal(ctr_sigs(1));
    sections_arch.body_blocks=[sections_arch.body_blocks,ctr_body];


    cplxty_densection=0;
    cplxty_numcast=0;
    [~,numcast_result]=hdlnewsignal('numtypeconvert',...
    'filter',-1,cplxty_numcast,0,...
    numstoragevtype,numstoragesltype);

    [~,dencast_result]=hdlnewsignal('dentypeconvert',...
    'filter',-1,cplxty_densection,0,...
    denstoragevtype,denstoragesltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dencast_result)];
    if~opscaleisunity
        [~,dencast_result_reg]=hdlnewsignal('dentypeconvert_reg',...
        'filter',-1,cplxty_densection,0,...
        denstoragevtype,denstoragesltype);
        hdlregsignal(dencast_result_reg);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dencast_result_reg)];
    else
        dencast_result_reg=[];
    end

end

function[sections_arch,opconvert]=emit_machdl(this,new_inputvtype,...
    new_inputsltype,new_coeffvtype,new_coeffsltype,new_inp_list,...
    pre_stg_op_list,clear_Accum_phase,ctr_out,sections_arch,...
    scaled_inp_list,current_input,numcast_result,...
    numdelaylist,dendelaylist,ffactor,coeff_list,dencast_result,...
    dencast_result_reg,opscaleisunity)

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    denprodall=hdlgetallfromsltype(this.denprodSLtype);
    denproductvtype=denprodall.vtype;
    denproductsltype=denprodall.sltype;

    densumall=hdlgetallfromsltype(this.denAccumSLtype);
    densumvtype=densumall.vtype;
    densumsltype=densumall.sltype;

    numprodall=hdlgetallfromsltype(this.numprodSLtype);
    numproductvtype=numprodall.vtype;
    numproductsltype=numprodall.sltype;

    numsumall=hdlgetallfromsltype(this.numAccumSLtype);
    numsumvtype=numsumall.vtype;
    numsumsltype=numsumall.sltype;


    if densumsltype==numsumsltype
        sumvtype=densumall.vtype;
        sumsltype=densumall.sltype;
    else
        [densumsize,densumbp]=hdlgetsizesfromtype(densumsltype);
        [numsumsize,numsumbp]=hdlgetsizesfromtype(numsumsltype);
        sumbp=max([densumbp,numsumbp]);
        sumsize=max([densumsize-densumbp,numsumsize-numsumbp])+sumbp;
        [sumvtype,sumsltype]=hdlgettypesfromsizes(sumsize,sumbp,1);

        message=['Consider specifying the same NumAccumFracLength and DenAccumFracLength, '...
        ,'otherwise additional castings are inserted to match the reference output.'];
        warning('WarnSumSLtype:diffsumtype',message);
    end

    productrounding=this.Roundmode;
    productsaturation=this.Overflowmode;
    strt=1;
    inpmux_list=[];
    [~,acc_op]=hdlnewsignal('accum_reg','filter',-1,...
    0,0,sumvtype,sumsltype);

    for section=1:this.NumSections
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(scaled_inp_list(section))];
        if(section>1)
            inp_sel=pre_stg_op_list(section-1);
        else
            inp_sel=current_input.input;
        end

        inpmux_list=[inpmux_list,inp_sel,scaled_inp_list(section),numdelaylist(strt:strt+1)...
        ,dendelaylist(strt:strt+1)];
        strt=strt+2;
        if~opscaleisunity
            if(section==this.NumSections)
                inpmux_list=[inpmux_list,acc_op];
            end
        end
    end
    if~opscaleisunity
        new_inp_list=[new_inp_list,dencast_result_reg];
    end
    [~,preaddlist(1)]=hdlnewsignal(hdllegalname(['inputmux_section_',num2str(1)]),...
    'filter',-1,0,0,...
    new_inputvtype,new_inputsltype);
    muxbody=hdlmux(new_inp_list,preaddlist(1),...
    ctr_out,'=',[0:ffactor],'when-else');
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(1))];
    sections_arch.body_blocks=[sections_arch.body_blocks,muxbody];


    [~,preaddlist(2)]=hdlnewsignal(hdllegalname(['coeffmux__section_',num2str(1)]),'filter',-1,0,0,...
    new_coeffvtype,new_coeffsltype);

    muxbody1=hdlmux(coeff_list,...
    preaddlist(2),...
    ctr_out,'=',[0:ffactor],'when-else');
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(2))];
    sections_arch.body_blocks=[sections_arch.body_blocks,'\n',muxbody1];


    coeffmuxlist=hdlexpandvectorsignal(preaddlist(2));
    inpmuxlist=hdlexpandvectorsignal(preaddlist(1));


    [ipsize,ipbp]=hdlgetsizesfromtype(hdlsignalsltype(inpmuxlist));
    [cpsize,cpbp]=hdlgetsizesfromtype(hdlsignalsltype(coeffmuxlist));
    fpsize=ipsize+cpsize;
    fpbp=ipbp+cpbp;
    [fpprodvtype,fpprodsltype]=hdlgettypesfromsizes(fpsize,fpbp,1);


    [mul_op,mul_blocks,mul_signals,mul_tempsignals]=hdlcoeffmultiply(inpmuxlist,...
    0.232429,...
    coeffmuxlist,...
    'prod',...
    fpprodvtype,fpprodsltype,...
    productrounding,productsaturation,densumsltype);
    sections_arch.signals=[sections_arch.signals,mul_signals,mul_tempsignals];
    sections_arch.body_blocks=[sections_arch.body_blocks,'\n',mul_blocks];



    [~,prod_den]=hdlnewsignal('prod_den','filter',-1,...
    0,0,denproductvtype,denproductsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod_den)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(mul_op,prod_den,...
    productrounding,productsaturation)];


    [~,prod_den_cast_temp]=hdlnewsignal('prod_den_cast_temp','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod_den_cast_temp)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(prod_den,prod_den_cast_temp,...
    productrounding,productsaturation)];

    [~,prod_den_cast]=hdlnewsignal('prod_den_cast','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod_den_cast)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(prod_den_cast_temp,prod_den_cast,...
    productrounding,productsaturation)];


    [~,prod_den_cast_neg]=hdlnewsignal('prod_den_cast_neg','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod_den_cast_neg)];
    [prod_minus_body,prod_minus_sig]=hdlunaryminus(prod_den_cast,prod_den_cast_neg,...
    productrounding,productsaturation);
    sections_arch.signals=[sections_arch.signals,prod_minus_sig];
    sections_arch.body_blocks=[sections_arch.body_blocks,prod_minus_body];



    [~,prod_num]=hdlnewsignal('prod_num','filter',-1,...
    0,0,numproductvtype,numproductsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod_num)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(mul_op,prod_num,...
    productrounding,productsaturation)];


    [~,prod_num_cast_temp]=hdlnewsignal('prod_num_cast_temp','filter',-1,...
    0,0,numsumvtype,numsumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod_num_cast_temp)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(prod_num,prod_num_cast_temp,...
    productrounding,productsaturation)];

    [~,prod_num_cast]=hdlnewsignal('prod_num_cast','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod_num_cast)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(prod_num_cast_temp,prod_num_cast,...
    productrounding,productsaturation)];


    [~,acc_mux_in_sig1]=hdlnewsignal('accum_mux_in1','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_mux_in_sig1)];
    prodmux_list=ones(size(coeff_list))*prod_num_cast;
    prodmux_list(5:6:end)=prod_den_cast_neg;
    prodmux_list(6:6:end)=prod_den_cast_neg;
    muxbody2=hdlmux(prodmux_list,...
    acc_mux_in_sig1,...
    ctr_out,'=',[0:ffactor],'when-else');
    sections_arch.body_blocks=[sections_arch.body_blocks,muxbody2,'\n'];

    [~,acc_mux_in_sig2]=hdlnewsignal('accum_mux_in2','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_mux_in_sig2)];


    if densumsltype==numsumsltype
        acc_sum=acc_mux_in_sig2;
    else
        [~,acc_sum]=hdlnewsignal('acc_sum','filter',-1,...
        0,0,sumvtype,sumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_sum)];


        [~,sum_den]=hdlnewsignal('sum_den','filter',-1,...
        0,0,densumvtype,densumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sum_den)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(acc_sum,sum_den,...
        productrounding,productsaturation)];

        [~,sum_den_cast]=hdlnewsignal('sum_den_cast','filter',-1,...
        0,0,sumvtype,sumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sum_den_cast)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(sum_den,sum_den_cast,...
        productrounding,productsaturation)];


        [~,sum_num]=hdlnewsignal('sum_num','filter',-1,...
        0,0,numsumvtype,numsumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sum_num)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(acc_sum,sum_num,...
        productrounding,productsaturation)];

        [~,sum_num_cast]=hdlnewsignal('sum_num_cast','filter',-1,...
        0,0,sumvtype,sumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sum_num_cast)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(sum_num,sum_num_cast,...
        productrounding,productsaturation)];

        accmux_list=ones(size(coeff_list))*sum_num_cast;
        accmux_list(5:6:end)=sum_den_cast;
        accmux_list(6:6:end)=sum_den_cast;
        muxbody3=hdlmux(accmux_list,...
        acc_mux_in_sig2,...
        ctr_out,'=',[0:ffactor],'when-else');
        sections_arch.body_blocks=[sections_arch.body_blocks,muxbody3,'\n'];
    end



    denstoragerounding=this.Roundmode;
    denstoragesaturation=this.Overflowmode;
    [~,acc_mux_out_sig]=hdlnewsignal('accum_mux_out','filter',-1,...
    0,0,sumvtype,sumsltype);
    bdt=hdlgetparameter('base_data_type');
    [~,temp]=hdlnewsignal('final_phase','filter',-1,0,0,bdt,'boolean');

    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(temp)];
    phase_body_or=hdlbitop(clear_Accum_phase,temp,'OR');
    sections_arch.body_blocks=[sections_arch.body_blocks,phase_body_or];
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_mux_out_sig)];
    acc_mux_out_body=hdlmux([acc_mux_in_sig1,acc_mux_in_sig2],acc_mux_out_sig,...
    temp,'=',[1,0],'when-else');
    sections_arch.body_blocks=[sections_arch.body_blocks,acc_mux_out_body];

    hdlregsignal(acc_op);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_op)];
    [tempbody1,tempsignals1]=hdlunitdelay(acc_mux_out_sig,acc_op,...
    ['accumulator_reg',hdlgetparameter('clock_process_label')],0);
    sections_arch.signals=[sections_arch.signals,tempsignals1];
    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody1];


    sumrounding=this.Roundmode;
    sumsaturation=this.Overflowmode;

    [sum_body,sum_signals]=hdlfilteradd(acc_op,acc_mux_in_sig1,...
    acc_sum,sumrounding,sumsaturation);
    sections_arch.signals=[sections_arch.signals,sum_signals];
    sections_arch.body_blocks=[sections_arch.body_blocks,sum_body];

    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(acc_mux_out_sig,dencast_result,...
    denstoragerounding,denstoragesaturation)];
    if~opscaleisunity
        hdladdresetsignal(dencast_result_reg);
        [tempbody_den,tempsignals_den]=hdlunitdelay(dencast_result,dencast_result_reg,...
        ['dencast_result_reg',num2str(1),hdlgetparameter('clock_process_label')],0);
        sections_arch.signals=[sections_arch.signals,tempsignals_den];
        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody_den];
    end


    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outregrounding=this.Roundmode;
    outregsaturation=this.OverflowMode;
    outregvtype=outputall.vtype;
    outregsltype=outputall.sltype;
    cplxty_outputtc=0;
    [~,opconvert]=hdlnewsignal('output_typeconvert','filter',-1,cplxty_outputtc,0,...
    outregvtype,outregsltype);
    sections_arch.signals=[sections_arch.signals,...
    makehdlsignaldecl(opconvert)];
    if~opscaleisunity
        opcastfrom=mul_op;
    else
        opcastfrom=dencast_result;
    end
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(opcastfrom,opconvert,...
    outregrounding,outregsaturation)];


    numstoragerounding=this.Roundmode;
    numstoragesaturation=this.Overflowmode;
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(numcast_result)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(mul_op,...
    numcast_result,...
    numstoragerounding,numstoragesaturation)];
end

function[sections_arch,scaled_inp_list,numdelaylist,dendelaylist,...
    coeff_list,pre_stg_op_list]=emit_delayline(this,den_phase,...
    dencast_result,numdelay_vector_vtype,dendelay_vector_vtype,...
    sections_arch,~,current_input,coeffs,ctr_sigs,opscaleisunity,coeffwl,coefffl)

    cwl=coeffwl;
    cfl=coefffl;


    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    coeffsvsize=numcoeffall.size;
    coeffssigned=numcoeffall.signed;
    numstorageall=hdlgetallfromsltype(this.numstateSLtype);

    denstorageall=hdlgetallfromsltype(this.denstateSLtype);
    denstoragevtype=denstorageall.vtype;
    denstoragesltype=denstorageall.sltype;

    scales=this.ScaleValues;
    scaleall=hdlgetallfromsltype(this.scaleSLtype);
    scalebp=scaleall.bp;
    scalevtype=scaleall.vtype;
    scalesltype=scaleall.sltype;
    scaleresultall=numstorageall;

    numstorageall=hdlgetallfromsltype(this.numstateSLtype);
    numstoragevtype=numstorageall.vtype;
    numstoragesltype=numstorageall.sltype;
    sections_arch.body_blocks=[sections_arch.body_blocks,['\n','  ',hdlgetparameter('comment_char'),' ','Next stage input = Previous stage output. Storing Previous stage output\n']];
    if(this.Numsections>=1)
        pre_stg_op_list=[];
        for section=1:this.NumSections
            [~,pre_stg_op]=hdlnewsignal(['prev_stg_op',num2str(section)],'filter',-1,0,0,...
            denstoragevtype,denstoragesltype);
            hdlregsignal(pre_stg_op);
            sections_arch.signals=[sections_arch.signals,...
            makehdlsignaldecl(pre_stg_op)];
            hdladdclockenablesignal(den_phase(section));
            hdlsetcurrentclockenable(den_phase(section));
            [tempbody,tempsignals]=hdlunitdelay(dencast_result,pre_stg_op,...
            ['prev_stg_op',num2str(section),hdlgetparameter('clock_process_label')],0);
            sections_arch.signals=[sections_arch.signals,tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            port_list=hdlinportsignals;
            hdlsetcurrentclockenable(port_list(2));
            pre_stg_op_list=[pre_stg_op_list,pre_stg_op];
        end
    end

    coeff_all=[];
    scale_list=[];
    scaled_inp_list=[];
    dendelaylist=[];
    numdelaylist=[];
    coeff_list=[];

    for section=1:this.Numsections




        cplxty_scaleconst=any(imag(scales(section)));
        [~,scaleconstant]=hdlnewsignal(['scaleconst',num2str(section)],...
        'filter',-1,cplxty_scaleconst,0,...
        scalevtype,scalesltype);
        scale_list=[scale_list,scaleconstant];
        if cplxty_scaleconst
            value=hdlconstantvalue(real(scales(section)),scaleall.size,...
            scalebp,coeffssigned);
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(scaleconstant,value)];
            value=hdlconstantvalue(imag(scales(section)),scaleall.size,...
            scalebp,coeffssigned);
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(scaleconstant),value)];
        else
            value=hdlconstantvalue(scales(section),scaleall.size,scalebp,...
            coeffssigned);
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(scaleconstant,value)];
        end
        if~opscaleisunity
            if(section==this.Numsections)
                [~,opscaleconstant]=hdlnewsignal(['opscaleconst',num2str(1)],...
                'filter',-1,cplxty_scaleconst,0,...
                scalevtype,scalesltype);
                value=hdlconstantvalue(scales(section+1),scaleall.size,scalebp,...
                coeffssigned);
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(opscaleconstant,value)];
                scale_list=[scale_list,opscaleconstant];
            end
        end



        [sections_arch,num_list,den_list]=emit_coefficients(this,sections_arch,...
        current_input.input,section,scaleresultall,[cwl,cfl]);

        coeff_list=[coeff_list,scale_list(section),num_list,den_list(2:3)];
        coeff_all=[coeff_all,scales(section)];
        [num,den]=getcoeffs(coeffs,section);
        coeff_all=[coeff_all,num,den(2:3)];
        if~opscaleisunity
            if(section==this.Numsections)
                coeff_list=[coeff_list,scale_list(section+1)];
            end
        end


        [~,indx_scale_inp]=hdlnewsignal(hdllegalname(['scaled_inp_',...
        num2str(section)]),'filter',-1,0,0,...
        numstoragevtype,numstoragesltype);
        hdlregsignal(indx_scale_inp);
        scaled_inp_list=[scaled_inp_list,indx_scale_inp];


        hdladdclockenablesignal(ctr_sigs(1));
        hdlsetcurrentclockenable(ctr_sigs(1));
        cplxty_numcast=0;
        [~,numdelay]=hdlnewsignal(['numdelay_section',num2str(section)],'filter',...
        -1,cplxty_numcast,[2,0],...
        numdelay_vector_vtype,numstoragesltype);
        hdlregsignal(numdelay);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(numdelay)];
        tdobj=hdl.tapdelay('clock',hdlgetcurrentclock,...
        'clockenable',hdlgetcurrentclockenable,...
        'reset',hdlgetcurrentreset,...
        'inputs',scaled_inp_list(section),...
        'outputs',numdelay,...
        'processName',['numdelay',hdlgetparameter('clock_process_label'),...
        '_section',num2str(section)],...
        'resetvalues',0,...
        'nDelays',2,...
        'delayOrder','Newest');
        hdlc=tdobj.emit;
        sections_arch.body_blocks=[sections_arch.body_blocks,hdlc.arch_body_blocks];
        numdelaylist1=hdlexpandvectorsignal(numdelay);
        numdelaylist=[numdelaylist,numdelaylist1];


        cplxty_densection=any(imag([num,den]))||cplxty_numcast;
        hdladdclockenablesignal(ctr_sigs(1));
        hdlsetcurrentclockenable(ctr_sigs(1));
        [~,dendelay]=hdlnewsignal(['dendelay_section',num2str(section)],'filter',-1,...
        cplxty_densection,[2,0],...
        dendelay_vector_vtype,denstoragesltype);
        hdlregsignal(dendelay);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dendelay)];
        tdobj=hdl.tapdelay('clock',hdlgetcurrentclock,...
        'clockenable',hdlgetcurrentclockenable,...
        'reset',hdlgetcurrentreset,...
        'inputs',pre_stg_op_list(section),...
        'outputs',dendelay,...
        'processName',['dendelay',hdlgetparameter('clock_process_label'),...
        '_section',num2str(section)],...
        'resetvalues',0,...
        'nDelays',2,...
        'delayOrder','Newest');
        port_list=hdlinportsignals;
        hdlsetcurrentclockenable(port_list(2));
        hdlc=tdobj.emit;
        sections_arch.body_blocks=[sections_arch.body_blocks,hdlc.arch_body_blocks];
        dendelaylist1=hdlexpandvectorsignal(dendelay);
        dendelaylist=[dendelaylist,dendelaylist1];

    end



end

