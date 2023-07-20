function[sections_arch,opconvert,phase_0]=emitfullyserial(this,current_input)











    storageall=hdlgetallfromsltype(this.StateSLtype);
    storagevtype=storageall.vtype;
    storagesltype=storageall.sltype;

    arithisdouble=strcmpi(this.InputSLType,'double');
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
    coeffs=this.Coefficients;
    sections_arch.typedefs='';
    sections_arch.constants='';
    sections_arch.body_blocks='';
    sections_arch.signals='';

    scales=this.ScaleValues;
    nsections=this.Numsections;


    if scales(nsections+1)==1
        opscaleisunity=1;
    else
        opscaleisunity=0;
    end


    allscaleones=isempty(find(scales(2:end)~=1,1));


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

    [swlt,sflt]=hdlgetsizesfromtype(this.StateSLtype);
    [sowlt,soflt]=hdlgetsizesfromtype(this.sectionoutputSLtype);




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

        ifl=max([iflt,sflt,soflt]);
        iwl=max([(iwlt-iflt),(swlt-sflt),(sowlt-soflt)])+ifl;


        cfl=max([svflt,nflt,dflt]);
        cwl=max([(cwlt-svflt),(cwlt-nflt),(cwlt-dflt)])+cfl;
    end

    [~,this.ScaleSLType]=hdlgettypesfromsizes(cwl,cfl,1);
    this.NumCoeffSLType=this.ScaleSLType;
    this.DenCoeffSLType=this.ScaleSLType;


    if(iwl==iwlt&&iwl==cwlt&&iwl==swlt)
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
        [~,ptr2]=hdlnewsignal('oneconstant','filter',-1,0,0,...
        new_coeffvtype,new_coeffsltype);
        sections_arch.constants=[sections_arch.constants,...
        makehdlconstantdecl(ptr2,hdlconstantvalue(real(1),cwl,cfl,1))];
    end


    if hdlgetparameter('isvhdl')
        sections_arch.typedefs=[sections_arch.typedefs,...
        '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        storagevtype,'; -- ',storagesltype,'\n'];
        delay_vector_vtype=['delay_pipeline_type(0 TO 1)'];
    else
        delay_vector_vtype=storagevtype;
    end



    [sections_arch,ffactor,ctr_sigs,ctr_out,storagecast_result,...
    sectionipconvert,clear_Accum_phase,...
    den_phase,storage_phase]=emit_timingcontrol(this,sections_arch,...
    opscaleisunity);



    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outregvtype=outputall.vtype;
    outregsltype=outputall.sltype;

    sectionoutputall=hdlgetallfromsltype(this.sectionoutputSLtype);
    stageoutputvtype=sectionoutputall.vtype;
    stageoutputsltype=sectionoutputall.sltype;

    cplxty_outputtc=0;
    [~,opconvert]=hdlnewsignal('output_typeconvert','filter',-1,...
    cplxty_outputtc,0,outregvtype,outregsltype);
    [~,sectionopconvert]=hdlnewsignal('sectionopconvert','filter',-1,...
    0,0,stageoutputvtype,stageoutputsltype);


    [sections_arch,scaled_inp_list,numdelaylist,coeff_list,...
    pre_stg_op_list]=emit_delayline(this,den_phase,...
    delay_vector_vtype,sections_arch,...
    current_input,coeffs,ctr_sigs,opscaleisunity,cwl,cfl,sectionopconvert);




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
    inpmux_print_list1=[];
    new_inp_list=[];
    strt=1;
    inp_print_list=[];

    for section=1:this.Numsections
        if(section>1)
            inp_sel=pre_stg_op_list(section-1);
        else
            inp_sel=current_input.input;
        end
        inpmux_list1=[inpmux_list1,inp_sel,numdelaylist(strt:strt+1)...
        ,scaled_inp_list(section),numdelaylist(strt:strt+1)];

        inpmux_print_list1=[inpmux_print_list1,inp_sel,numdelaylist(strt:strt+1)...
        ,scaled_inp_list(section)];
        strt=strt+2;
    end

    if~flag_no_cast_states_input
        for section=1:this.Numsections
            [~,inp_new]=hdlnewsignal(['input_section',num2str(section),...
            '_cast'],'filter',-1,cplxty_densection,0,new_inputvtype,...
            new_inputsltype);
            sections_arch.signals=[sections_arch.signals,...
            makehdlsignaldecl(inp_new)];
            [~,sca_inp_new]=hdlnewsignal(['storage_in_section',...
            num2str(section),'_cast'],'filter',-1,cplxty_densection,0,...
            new_inputvtype,new_inputsltype);
            sections_arch.signals=[sections_arch.signals,...
            makehdlsignaldecl(sca_inp_new)];
            num_state_new_list=[];
            for num_ele=1:2
                [~,num_state_new]=hdlnewsignal(['delay_section',...
                num2str(section),num2str(num_ele),'_cast'],...
                'filter',-1,cplxty_densection,0,new_inputvtype,...
                new_inputsltype);
                sections_arch.signals=[sections_arch.signals,...
                makehdlsignaldecl(num_state_new)];
                num_state_new_list=[num_state_new_list,num_state_new];
            end
            new_inp_list=[new_inp_list,inp_new,num_state_new_list...
            ,sca_inp_new,num_state_new_list];
            inp_print_list=[inp_print_list,inp_new,num_state_new_list...
            ,sca_inp_new];
        end
    else
        new_inp_list=inpmux_list1;
    end
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    [indentedcomment,...
    'Making common precision for input and state \n']];

    if(flag_no_cast_states_input==1)
        new_inp_list=inpmux_list1;
    else
        for num_indx=1:length(inp_print_list)
            sections_arch.body_blocks=[sections_arch.body_blocks,...
            hdldatatypeassignment(inpmux_print_list1(num_indx),...
            inp_print_list((num_indx)),this.RoundMode,this.OverflowMode)];
        end
    end



    [sections_arch]=emit_machdl(this,new_inputvtype,...
    new_inputsltype,new_coeffvtype,new_coeffsltype,new_inp_list,...
    pre_stg_op_list,clear_Accum_phase,ctr_out,sections_arch,...
    storagecast_result,sectionipconvert,ffactor,new_coeff_list,...
    opscaleisunity,opconvert,allscaleones,sectionopconvert);


    [sections_arch]=scaledinp_reg(this,storage_phase,sections_arch,...
    scaled_inp_list,storagecast_result);


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



function[sections_arch]=scaledinp_reg(this,storage_phase,...
    sections_arch,scaled_inp_list,storagecast_result)
    for section=1:this.NumSections
        hdladdclockenablesignal(storage_phase(section));
        hdlsetcurrentclockenable(storage_phase(section));
        [tempbody,tempsignals]=hdlunitdelay(storagecast_result,...
        scaled_inp_list(section),['storage_reg',num2str(section),...
        hdlgetparameter('clock_process_label')],0);
        sections_arch.signals=[sections_arch.signals,tempsignals];
        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
        port_list=hdlinportsignals;
        hdlsetcurrentclockenable(port_list(2));
    end
end



function[sections_arch,num_list,den_list]=emit_coefficients(this,...
    sections_arch,~,section,~,coeffsizes)


    coeffs=this.Coefficients;
    [fcoeffvsize,fcoeffsltype]=hdlgettypesfromsizes(coeffsizes(1),...
    coeffsizes(2),1);
    [num,den]=getcoeffs(coeffs,section);

    num_list=[];

    for n=1:length(num)
        cplxty_num=any(imag(num(n)));
        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),...
        '_b',num2str(n),'_section',num2str(section)]);
        [~,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_num,0,...
        fcoeffvsize,fcoeffsltype);
        num_list=[num_list,ptr];
        if cplxty_num
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(real(num(n)),...
            coeffsizes(1),coeffsizes(2),1))];
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(ptr),...
            hdlconstantvalue(imag(num(n)),coeffsizes(1),coeffsizes(2),1))];
        else
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(num(n),...
            coeffsizes(1),coeffsizes(2),1))];
        end
    end

    den_list=0;
    for n=2:length(den)

        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),...
        '_a',num2str(n),'_section',num2str(section)]);
        cplxty_den=any(imag(den(n)));
        [~,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_den,0,...
        fcoeffvsize,fcoeffsltype);
        den_list=[den_list,ptr];
        if cplxty_den
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(real(den(n)),...
            coeffsizes(1),coeffsizes(2),1))];
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(ptr),...
            hdlconstantvalue(imag(den(n)),coeffsizes(1),coeffsizes(2),1))];
        else
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(den(n),...
            coeffsizes(1),coeffsizes(2),1))];
        end
    end

end



function[sections_arch,ffactor,ctr_sigs,ctr_out,storagecast_result,...
    sectionipconvert,clear_Accum_phase,...
    den_phase,storage_phase]=emit_timingcontrol(this,sections_arch,...
    opscaleisunity)


    [~,naflt]=hdlgetsizesfromtype(this.NumAccumSLtype);
    [~,daflt]=hdlgetsizesfromtype(this.DenAccumSLtype);
    if(daflt>=naflt)
        densumall=hdlgetallfromsltype(this.denAccumSLtype);
    else
        densumall=hdlgetallfromsltype(this.numAccumSLtype);
    end
    densumvtype=densumall.vtype;
    densumsltype=densumall.sltype;

    storageall=hdlgetallfromsltype(this.StateSLtype);
    storagevtype=storageall.vtype;
    storagesltype=storageall.sltype;

    sectioninputall=hdlgetallfromsltype(this.sectioninputSLtype);
    stageinputvtype=sectioninputall.vtype;
    stageinputsltype=sectioninputall.sltype;







    indx=1;
    for i=0:6:((this.NumSections-1)*6)
        phases_cell{indx}=i;
        phases_cell{indx+1}=i+2;
        phases_cell{indx+2}=i+3;
        phases_cell{indx+3}=i+5;
        indx=indx+4;
    end


    if~opscaleisunity
        phases_cell{end+1}=i+6;
    end


    ffactor=getfilterlengths(this);
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
    port_list=hdlinportsignals;
    hdlsetcurrentclockenable(port_list(2));

    if~opscaleisunity
        clear_Accum_phase=[ctr_sigs(1:2:length(ctr_sigs)),ctr_sigs(end)];
    else
        clear_Accum_phase=ctr_sigs(1:2:length(ctr_sigs));
    end
    new_ctr_sigs=ctr_sigs(1:3:length(ctr_sigs));
    storage_phase=ctr_sigs(2:4:length(ctr_sigs));
    den_phase=ctr_sigs(4:4:length(ctr_sigs));
    ctr_sigs=new_ctr_sigs;
    sections_arch.body_blocks=[sections_arch.body_blocks,ctr_body];


    cplxty_densection=0;
    cplxty_cast=0;
    [~,storagecast_result]=hdlnewsignal('storagetypeconvert',...
    'filter',-1,cplxty_cast,0,...
    storagevtype,storagesltype);


    [~,sectionipconvert]=hdlnewsignal('sectionipconvert',...
    'filter',-1,cplxty_densection,0,...
    stageinputvtype,stageinputsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sectionipconvert)];

    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast_result)];
end



function[sections_arch]=emit_machdl(this,new_inputvtype,...
    new_inputsltype,new_coeffvtype,new_coeffsltype,new_inp_list,...
    pre_stg_op_list,clear_Accum_phase,ctr_out,sections_arch,...
    storagecast_result,sectionipconvert,ffactor,coeff_list,...
    opscaleisunity,opconvert,allscaleones,sectionopconvert)


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
    [sumsize,sumbp]=hdlgetsizesfromtype(sumsltype);

    productrounding=this.Roundmode;
    productsaturation=this.Overflowmode;


    if~opscaleisunity

        [~,sectionopconvert_cast]=hdlnewsignal('sectionopconvert_cast',...
        'filter',-1,0,0,new_inputvtype,new_inputsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sectionopconvert_cast)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(pre_stg_op_list(this.NumSections),sectionopconvert_cast,...
        this.RoundMode,this.OverflowMode)];

        new_inp_list=[new_inp_list,sectionopconvert_cast];
    end
    [~,preaddlist(1)]=hdlnewsignal(hdllegalname(['inputmux_section_',...
    num2str(1)]),...
    'filter',-1,0,0,...
    new_inputvtype,new_inputsltype);
    muxbody=hdlmux(new_inp_list,preaddlist(1),...
    ctr_out,'=',[0:ffactor],'when-else');
    sections_arch.signals=[sections_arch.signals,...
    makehdlsignaldecl(preaddlist(1))];
    sections_arch.body_blocks=[sections_arch.body_blocks,muxbody];


    [~,preaddlist(2)]=hdlnewsignal(hdllegalname(['coeffmux__section_',...
    num2str(1)]),'filter',-1,0,0,...
    new_coeffvtype,new_coeffsltype);

    muxbody1=hdlmux(coeff_list,...
    preaddlist(2),...
    ctr_out,'=',[0:ffactor],'when-else');
    sections_arch.signals=[sections_arch.signals,...
    makehdlsignaldecl(preaddlist(2))];
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
    productrounding,productsaturation,sumsltype);
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
    prodmux_list(2:6:end)=prod_den_cast_neg;
    prodmux_list(3:6:end)=prod_den_cast_neg;
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
        accmux_list(2:6:end)=sum_den_cast;
        accmux_list(3:6:end)=sum_den_cast;
        muxbody3=hdlmux(accmux_list,...
        acc_mux_in_sig2,...
        ctr_out,'=',[0:ffactor],'when-else');
        sections_arch.body_blocks=[sections_arch.body_blocks,muxbody3,'\n'];
    end



    denstoragerounding=this.Roundmode;
    denstoragesaturation=this.Overflowmode;
    [~,acc_mux_out_sig]=hdlnewsignal('accum_mux_out','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,...
    makehdlsignaldecl(acc_mux_out_sig)];
    [~,accum_mux_in_sig1_temp]=hdlnewsignal('accum_mux_in1_temp','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,...
    makehdlsignaldecl(accum_mux_in_sig1_temp)];

    if(allscaleones&&(this.Numsections~=1))
        [~,ptrzero]=hdlnewsignal('zeroconstant','filter',-1,0,0,...
        sumvtype,sumsltype);
        sections_arch.constants=[sections_arch.constants,...
        makehdlconstantdecl(ptrzero,hdlconstantvalue(real(0),sumsize,sumbp,1))];
        bdt=hdlgetparameter('base_data_type');
        [~,temp]=hdlnewsignal('bypass_sectionipscale_phase','filter',-1,0,0,bdt,'boolean');
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(temp)];
        avoidscalemult_phase=clear_Accum_phase(1:2:length(clear_Accum_phase));
        str_temp=avoidscalemult_phase(2:1:length(avoidscalemult_phase));
        if(this.Numsections==2)
            sections_arch.body_blocks=[sections_arch.body_blocks,...
            hdldatatypeassignment(str_temp,temp,...
            this.Roundmode,this.Overflowmode)];
        else
            phase_body_or=hdlbitop(str_temp,temp,'OR');
            sections_arch.body_blocks=[sections_arch.body_blocks,phase_body_or];
        end
        [~,acc_mux_out_sig1]=hdlnewsignal('accum_mux_temp1','filter',-1,...
        0,0,sumvtype,sumsltype);
        [~,acc_mux_out_sig2]=hdlnewsignal('accum_mux_temp2','filter',-1,...
        0,0,sumvtype,sumsltype);
        sections_arch.signals=[sections_arch.signals,...
        makehdlsignaldecl(acc_mux_out_sig1)];
        sections_arch.signals=[sections_arch.signals,...
        makehdlsignaldecl(acc_mux_out_sig2)];
        acc_mux_out_body1=hdlmux([acc_mux_in_sig2,acc_mux_out_sig1],acc_mux_out_sig,...
        temp,'=',[1,0],'when-else');
        sections_arch.body_blocks=[sections_arch.body_blocks,acc_mux_out_body1];
        acc_mux_out_body2=hdlmux([ptrzero,acc_mux_in_sig1],acc_mux_out_sig2,...
        temp,'=',[1,0],'when-else');
        sections_arch.body_blocks=[sections_arch.body_blocks,'\n',acc_mux_out_body2];
    end

    [~,sectionipconvert_cast]=hdlnewsignal('sectionipconvert_cast','filter',-1,...
    0,0,sumvtype,sumsltype);
    sections_arch.signals=[sections_arch.signals,...
    makehdlsignaldecl(sectionipconvert_cast)];

    bdt=hdlgetparameter('base_data_type');
    [~,temp]=hdlnewsignal('final_phase','filter',-1,0,0,bdt,'boolean');

    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(temp)];
    phase_body_or=hdlbitop(clear_Accum_phase,temp,'OR');
    sections_arch.body_blocks=[sections_arch.body_blocks,phase_body_or];

    bdt=hdlgetparameter('base_data_type');
    [~,temp1]=hdlnewsignal('section_phase','filter',-1,0,0,bdt,'boolean');
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(temp1)];
    section_phase_body_or=hdlbitop(clear_Accum_phase(1:2:length(clear_Accum_phase)),...
    temp1,'OR');
    sections_arch.body_blocks=[sections_arch.body_blocks,section_phase_body_or];

    acc_mux_out_body1=hdlmux([sectionipconvert_cast,acc_mux_in_sig1],accum_mux_in_sig1_temp,...
    temp1,'=',[1,0],'when-else');
    sections_arch.body_blocks=[sections_arch.body_blocks,acc_mux_out_body1,'\n'];

    if(allscaleones&&(this.Numsections~=1))
        acc_mux_out_body=hdlmux([accum_mux_in_sig1_temp,acc_mux_in_sig2],acc_mux_out_sig1,...
        temp,'=',[1,0],'when-else');
    else
        acc_mux_out_body=hdlmux([accum_mux_in_sig1_temp,acc_mux_in_sig2],acc_mux_out_sig,...
        temp,'=',[1,0],'when-else');
    end
    sections_arch.body_blocks=[sections_arch.body_blocks,acc_mux_out_body,'\n'];

    [~,acc_op]=hdlnewsignal('accum_reg','filter',-1,...
    0,0,sumvtype,sumsltype);
    hdlregsignal(acc_op);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_op)];
    [tempbody1,tempsignals1]=hdlunitdelay(acc_mux_out_sig,acc_op,...
    ['accumulator_reg',hdlgetparameter('clock_process_label')],0);
    sections_arch.signals=[sections_arch.signals,tempsignals1];
    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody1];


    sumrounding=this.Roundmode;
    sumsaturation=this.Overflowmode;
    if(allscaleones&&(this.Numsections~=1))
        [sum_body,sum_signals]=hdlfilteradd(acc_op,acc_mux_out_sig2,...
        acc_sum,sumrounding,sumsaturation);
    else
        [sum_body,sum_signals]=hdlfilteradd(acc_op,acc_mux_in_sig1,...
        acc_sum,sumrounding,sumsaturation);
    end
    sections_arch.signals=[sections_arch.signals,sum_signals];
    sections_arch.body_blocks=[sections_arch.body_blocks,sum_body];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(acc_mux_out_sig,storagecast_result,...
    denstoragerounding,denstoragesaturation)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(mul_op,sectionipconvert,...
    denstoragerounding,denstoragesaturation)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(sectionipconvert,sectionipconvert_cast,...
    this.Roundmode,this.Overflowmode)];


    [~,acc_out_cast_numacc]=hdlnewsignal('acc_out_cast_numacc',...
    'filter',-1,0,0,numsumvtype,numsumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_out_cast_numacc)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(acc_mux_out_sig,acc_out_cast_numacc,...
    this.RoundMode,this.OverflowMode)];


    if~((this.NumSections==1)&&opscaleisunity)
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sectionopconvert)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(acc_out_cast_numacc,sectionopconvert,...
        this.RoundMode,this.OverflowMode)];
    end



    outregrounding=this.Roundmode;
    outregsaturation=this.OverflowMode;
    sections_arch.signals=[sections_arch.signals,...
    makehdlsignaldecl(opconvert)];
    if~opscaleisunity
        opcastfrom=mul_op;
    else
        opcastfrom=acc_out_cast_numacc;
    end
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(opcastfrom,opconvert,...
    outregrounding,outregsaturation)];

end



function[sections_arch,scaled_inp_list,numdelaylist,coeff_list,...
    pre_stg_op_list]=emit_delayline(this,den_phase,...
    delay_vector_vtype,sections_arch,...
    current_input,coeffs,ctr_sigs,opscaleisunity,cwl,cfl,sectionopconvert)



    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    coeffssigned=numcoeffall.signed;
    numstorageall=hdlgetallfromsltype(this.stateSLtype);


    scales=this.ScaleValues;
    scaleall=hdlgetallfromsltype(this.scaleSLtype);
    scalebp=scaleall.bp;
    scalevtype=scaleall.vtype;
    scalesltype=scaleall.sltype;
    scaleresultall=numstorageall;


    storageall=hdlgetallfromsltype(this.stateSLtype);
    storagevtype=storageall.vtype;
    storagesltype=storageall.sltype;


    sectionoutputall=hdlgetallfromsltype(this.sectionoutputSLtype);
    stageoutputvtype=sectionoutputall.vtype;
    stageoutputsltype=sectionoutputall.sltype;

    if(~opscaleisunity)||(this.Numsections>1)
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        ['\n','  ',hdlgetparameter('comment_char'),...
        ' ','Next stage input = Previous stage output. Storing Previous stage output\n']];
    end

    pre_stg_op_list=[];
    if(this.Numsections>=1)
        for section=1:this.NumSections
            if~((section==this.NumSections)&&opscaleisunity)
                [~,pre_stg_op]=hdlnewsignal(['prev_stg_op',num2str(section)],...
                'filter',-1,0,0,...
                stageoutputvtype,stageoutputsltype);
                hdlregsignal(pre_stg_op);
                sections_arch.signals=[sections_arch.signals,...
                makehdlsignaldecl(pre_stg_op)];
                hdladdclockenablesignal(den_phase(section));
                hdlsetcurrentclockenable(den_phase(section));
                [tempbody,tempsignals]=hdlunitdelay(sectionopconvert,pre_stg_op,...
                ['prev_stg_op',num2str(section),...
                hdlgetparameter('clock_process_label')],0);
                sections_arch.signals=[sections_arch.signals,tempsignals];
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                port_list=hdlinportsignals;
                hdlsetcurrentclockenable(port_list(2));
                pre_stg_op_list=[pre_stg_op_list,pre_stg_op];
            end
        end
    end

    coeff_all=[];
    scale_list=[];
    scaled_inp_list=[];
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


        coeff_list=[coeff_list,scale_list(section),den_list(2:3),num_list];
        coeff_all=[coeff_all,scales(section)];
        [num,den]=getcoeffs(coeffs,section);
        coeff_all=[coeff_all,num,den(2:3)];

        if~opscaleisunity
            if(section==this.Numsections)
                coeff_list=[coeff_list,scale_list(section+1)];
            end
        end


        [~,indx_scale_inp]=hdlnewsignal(hdllegalname(['storage_state_in',...
        num2str(section)]),'filter',-1,0,0,...
        storagevtype,storagesltype);
        hdlregsignal(indx_scale_inp);
        sections_arch.signals=[sections_arch.signals,...
        makehdlsignaldecl(indx_scale_inp)];
        scaled_inp_list=[scaled_inp_list,indx_scale_inp];
        hdladdclockenablesignal(ctr_sigs(1));
        hdlsetcurrentclockenable(ctr_sigs(1));

        cplxty_numcast=0;
        [~,delay]=hdlnewsignal(['delay_section',num2str(section)],'filter',...
        -1,cplxty_numcast,[2,0],...
        delay_vector_vtype,storagesltype);
        hdlregsignal(delay);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(delay)];
        tdobj=hdl.tapdelay('clock',hdlgetcurrentclock,...
        'clockenable',hdlgetcurrentclockenable,...
        'reset',hdlgetcurrentreset,...
        'inputs',scaled_inp_list(section),...
        'outputs',delay,...
        'processName',['delay',hdlgetparameter('clock_process_label'),...
        '_section',num2str(section)],...
        'resetvalues',0,...
        'nDelays',2,...
        'delayOrder','Newest');
        port_list=hdlinportsignals;
        hdlsetcurrentclockenable(port_list(2));
        hdlc=tdobj.emit;
        sections_arch.body_blocks=[sections_arch.body_blocks,hdlc.arch_body_blocks];
        numdelaylist1=hdlexpandvectorsignal(delay);
        numdelaylist=[numdelaylist,numdelaylist1];
        port_list=hdlinportsignals;
        hdlsetcurrentclockenable(port_list(2));

    end

end



