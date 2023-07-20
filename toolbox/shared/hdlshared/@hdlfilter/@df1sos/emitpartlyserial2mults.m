function[sections_arch,opconvert,phase_0]=emitpartlyserial2mults(this,current_input)







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
    [cwlt,svflt]=hdlgetsizesfromtype(this.ScaleSLtype);
    [~,nflt]=hdlgetsizesfromtype(this.NumCoeffSLtype);
    [~,dflt]=hdlgetsizesfromtype(this.DenCoeffSLtype);
    [nswlt,nsflt]=hdlgetsizesfromtype(this.NumStateSLtype);
    [dswlt,dsflt]=hdlgetsizesfromtype(this.DenStateSLtype);



    if any(scales==1)&&cwlt<svflt+2

        cwlt=svflt+2;
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
    cplxty_densection=0;


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


    [sections_arch,ffactor,ctr_sigs,ctr_out,numcast_result,dencast_result,clear_Accum_phase,den_phase]=emit_timingcontrol(this,...
    sections_arch,opscaleisunity);


    [sections_arch,scaled_inp_list,numdelaylist,dendelaylist,coeff_list,pre_stg_op_list]=emit_delayline(this,...
    den_phase,numcast_result,dencast_result,numdelay_vector_vtype,dendelay_vector_vtype,sections_arch,scales,...
    current_input,coeffs,ctr_sigs,opscaleisunity);


    new_coeff_list=coeff_list;


    if~opscaleisunity
        denstorageall=hdlgetallfromsltype(this.denstateSLtype);
        denstoragevtype=denstorageall.vtype;
        denstoragesltype=denstorageall.sltype;
        [~,dencast_result_reg]=hdlnewsignal('dentypeconvert_reg',...
        'filter',-1,cplxty_densection,0,...
        denstoragevtype,denstoragesltype);
        hdlregsignal(dencast_result_reg);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dencast_result_reg)];
        [tempbody_den,tempsignals_den]=hdlunitdelay(dencast_result,dencast_result_reg,...
        ['dencast_result_reg',num2str(1),hdlgetparameter('clock_process_label')],0);
        sections_arch.signals=[sections_arch.signals,tempsignals_den];
        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody_den];

    else
        dencast_result_reg=[];
    end

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
        if~opscaleisunity
            new_inp_list=[new_inp_list,dencast_result_reg];
        end
    else
        new_inp_list=inpmux_list1;
        if~opscaleisunity
            new_inp_list=[new_inp_list,dencast_result_reg];
        end
    end
    sections_arch.body_blocks=[sections_arch.body_blocks,[indentedcomment,'Making common precision for input, num state and denum state\n']];
    if(flag_no_cast_states_input==1)
        if opscaleisunity
            new_inp_list=inpmux_list1;
        end
    else
        for num_indx=1:6*this.Numsections
            sections_arch.body_blocks=[sections_arch.body_blocks,...
            hdldatatypeassignment(inpmux_list1(num_indx),new_inp_list((num_indx)),...
            this.RoundMode,this.OverflowMode)];
        end
    end
    mults=hdlgetparameter('filter_nummultipliers');
    if(mults==-1)
        ffactor=hdlgetparameter('userspecified_foldingfactor');
        if~opscaleisunity
            if(ffactor==(this.numSections)*6+1)
                mults=1;
            elseif(ffactor==(this.numSections)*3+1)
                mults=2;
            elseif(ffactor==(this.numSections)*2+1)
                mults=3;
            end
        else
            if(ffactor==(this.numSections)*6)
                mults=1;
            elseif(ffactor==(this.numSections)*3)
                mults=2;
            elseif(ffactor==(this.numSections)*2)
                mults=3;
            end
        end
    end

    if(mults==2)
        if~opscaleisunity
            inp_mux1=[];
            inp_mux2=[];

            [~,zeroptr1]=hdlnewsignal('zeroconstant','filter',-1,0,0,new_inputvtype,new_inputsltype);
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(zeroptr1,hdlconstantvalue(real(0),iwl,ifl,1))];
            new_inp_list(end+1)=zeroptr1;
            for i=1:6:length(new_inp_list)-2
                inp_mux1=[inp_mux1,new_inp_list(i:i+2)];
                inp_mux2=[inp_mux2,new_inp_list(i+3:i+5)];
            end
            inp_mux1(end+1)=new_inp_list(end-1);
            inp_mux2(end+1)=new_inp_list(end);
        else
            inp_mux1=zeros(1,length(new_inp_list)/2);
            inp_mux2=zeros(1,length(new_inp_list)/2);
            j=1;
            for i=1:6:length(new_inp_list)
                inp_mux1(1,j)=new_inp_list(i);
                inp_mux1(1,j+1)=new_inp_list(i+1);
                inp_mux1(1,j+2)=new_inp_list(i+2);
                inp_mux2(1,j)=new_inp_list(i+3);
                inp_mux2(1,j+1)=new_inp_list(i+4);
                inp_mux2(1,j+2)=new_inp_list(i+5);
                j=j+3;
            end
        end
        inp_mux3=0;
    elseif(mults==3)
        if~opscaleisunity
            inp_mux1=[];
            inp_mux2=[];
            inp_mux3=[];
            [~,zeroptr1]=hdlnewsignal('zeroconstant','filter',-1,0,0,new_inputvtype,new_inputsltype);
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(zeroptr1,hdlconstantvalue(real(0),iwl,ifl,1))];
            new_inp_list(end+1)=zeroptr1;
            new_inp_list(end+1)=zeroptr1;
            for i=1:6:length(new_inp_list)-3
                inp_mux1=[inp_mux1,new_inp_list(i:i+1)];
                inp_mux2=[inp_mux2,new_inp_list(i+2),new_inp_list(i+4)];
                inp_mux3=[inp_mux3,new_inp_list(i+3),new_inp_list(i+5)];
            end
            inp_mux1(end+1)=new_inp_list(end-2);
            inp_mux2(end+1)=new_inp_list(end-1);
            inp_mux3(end+1)=new_inp_list(end);
        else

            inp_mux1=zeros(1,length(new_inp_list)/3);
            inp_mux2=zeros(1,length(new_inp_list)/3);
            inp_mux3=zeros(1,length(new_inp_list)/3);
            j=1;
            for i=1:6:length(new_inp_list)
                inp_mux1(1,j)=new_inp_list(i);
                inp_mux1(1,j+1)=new_inp_list(i+1);
                inp_mux2(1,j)=new_inp_list(i+2);
                inp_mux2(1,j+1)=new_inp_list(i+4);
                inp_mux3(1,j)=new_inp_list(i+3);
                inp_mux3(1,j+1)=new_inp_list(i+5);
                j=j+2;
            end
        end
    end


    [sections_arch,opconvert]=emit_machdl(this,inp_mux1,inp_mux2,inp_mux3,new_inputvtype,new_inputsltype,new_coeffvtype,new_coeffsltype,pre_stg_op_list,den_phase,clear_Accum_phase,ctr_out,sections_arch,scaled_inp_list,...
    current_input,numcast_result,numdelaylist,dendelaylist,ffactor,...
    new_coeff_list,dencast_result,opscaleisunity);


    [sections_arch]=scaledinp_reg(this,sections_arch,ctr_sigs,scaled_inp_list,numcast_result);






    phase_0=den_phase(length(den_phase));
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

function[sections_arch,num_list,den_list]=emit_coefficients(this,sections_arch,~,section,~)




    coeffs=this.Coefficients;

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

    [num,den]=getcoeffs(coeffs,section);

    num_list=[];
    for n=1:length(num)
        cplxty_num=any(imag(num(n)));
        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_b',num2str(n),'_section',num2str(section)]);
        [~,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_num,0,numcoeffsvtype,numcoeffssltype);
        num_list=[num_list,ptr];
        if cplxty_num
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(real(num(n)),coeffsvsize,numcoeffsvbp,coeffssigned))];
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(ptr),hdlconstantvalue(imag(num(n)),coeffsvsize,numcoeffsvbp,coeffssigned))];
        else
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(num(n),coeffsvsize,numcoeffsvbp,coeffssigned))];
        end
    end
    den_list=[0];
    for n=2:length(den)

        coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_a',num2str(n),'_section',num2str(section)]);
        cplxty_den=any(imag(den(n)));
        [~,ptr]=hdlnewsignal(coeffname,'filter',-1,cplxty_den,0,dencoeffsvtype,dencoeffssltype);
        den_list=[den_list,ptr];
        if cplxty_den
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(real(den(n)),coeffsvsize,dencoeffsvbp,coeffssigned))];
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(ptr),hdlconstantvalue(imag(den(n)),coeffsvsize,dencoeffsvbp,coeffssigned))];

        else
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(den(n),coeffsvsize,dencoeffsvbp,coeffssigned))];
        end
    end
end

function[sections_arch,ffactor,ctr_sigs,ctr_out,numcast_result,...
    dencast_result,clear_Accum_phase,den_phase]=emit_timingcontrol(this,...
    sections_arch,opscaleisunity)


    numstorageall=hdlgetallfromsltype(this.numstateSLtype);
    numstoragevtype=numstorageall.vtype;
    numstoragesltype=numstorageall.sltype;

    denstorageall=hdlgetallfromsltype(this.denstateSLtype);
    denstoragevtype=denstorageall.vtype;
    denstoragesltype=denstorageall.sltype;
    mults=hdlgetparameter('filter_nummultipliers');
    uff=hdlgetparameter('userspecified_foldingfactor');

    if(mults==-1)
        [mults,~]=this.getSerialPartForFoldingFactor('foldingfactor',uff);
    else
        [mults,~]=this.getSerialPartForFoldingFactor('multipliers',mults);
    end






    indx=1;
    if(mults==2)
        for i=0:3:((this.NumSections-1)*3)
            phases_cell{indx}=i;
            phases_cell{indx+1}=i+2;
            indx=indx+2;
        end
        if~opscaleisunity
            phases_cell{end+1}=i+3;
        end
    elseif(mults==3)
        for i=0:2:((this.NumSections-1)*2)
            phases_cell{indx}=i;
            phases_cell{indx+1}=i+1;
            indx=indx+2;
        end
        if~opscaleisunity
            phases_cell{end+1}=i+2;
        end
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



    if~opscaleisunity
        clear_Accum_phase=ctr_sigs(1:2:length(ctr_sigs)-1);
        den_phase=[ctr_sigs(2:2:length(ctr_sigs)-1),ctr_sigs(end)];
    else
        clear_Accum_phase=ctr_sigs(1:2:length(ctr_sigs));
        den_phase=ctr_sigs(2:2:length(ctr_sigs));
    end
    ctr_sigs=clear_Accum_phase;

    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ctr_sigs)];

    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(den_phase)];
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
end

function[sections_arch,opconvert]=emit_machdl(this,inp_mux1,...
    inp_mux2,inp_mux3,new_inputvtype,new_inputsltype,new_coeffvtype,...
    new_coeffsltype,pre_stg_op_list,den_phase,...
    clear_Accum_phase,ctr_out,sections_arch,scaled_inp_list,...
    current_input,numcast_result,numdelaylist,...
    dendelaylist,ffactor,coeff_list,dencast_result,opscaleisunity)
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
    mults=hdlgetparameter('filter_nummultipliers');
    if(mults==-1)
        ffactor=hdlgetparameter('userspecified_foldingfactor');
        if~opscaleisunity
            if(ffactor==(this.numSections)*6+1)
                mults=1;
            elseif(ffactor==(this.numSections)*3+1)
                mults=2;
            elseif(ffactor==(this.numSections)*2+1)
                mults=3;
            end
        else
            if(ffactor==(this.numSections)*6)
                mults=1;
            elseif(ffactor==(this.numSections)*3)
                mults=2;
            elseif(ffactor==(this.numSections)*2)
                mults=3;
            end
        end
    end
    strt=1;
    inpmux_list=[];

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
    end
    [~,preaddlist(1)]=hdlnewsignal(hdllegalname(['inputmux_section_',num2str(1)]),...
    'filter',-1,0,0,...
    new_inputvtype,new_inputsltype);
    muxbody1=hdlmux(inp_mux1,preaddlist(1),...
    ctr_out,'=',[0:ffactor-1],'when-else');
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(1))];
    sections_arch.body_blocks=[sections_arch.body_blocks,muxbody1];
    [~,preaddlist(4)]=hdlnewsignal(hdllegalname(['inputmux_section_',num2str(2)]),...
    'filter',-1,0,0,...
    new_inputvtype,new_inputsltype);
    muxbody2=hdlmux(inp_mux2,preaddlist(4),...
    ctr_out,'=',[0:ffactor-1],'when-else');
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(4))];
    sections_arch.body_blocks=[sections_arch.body_blocks,muxbody2];
    if(mults==3)
        [~,preaddlist(5)]=hdlnewsignal(hdllegalname(['inputmux_section_',num2str(3)]),...
        'filter',-1,0,0,...
        new_inputvtype,new_inputsltype);
        muxbody3=hdlmux(inp_mux3,preaddlist(5),...
        ctr_out,'=',[0:ffactor-1],'when-else');
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(5))];
        sections_arch.body_blocks=[sections_arch.body_blocks,muxbody3];
    end


    [~,preaddlist(2)]=hdlnewsignal(hdllegalname(['coeffmux__section_',num2str(1)]),'filter',-1,0,0,...
    new_coeffvtype,new_coeffsltype);
    [~,preaddlist(3)]=hdlnewsignal(hdllegalname(['coeffmux__section_',num2str(2)]),'filter',-1,0,0,...
    new_coeffvtype,new_coeffsltype);
    if(mults==3)
        [~,preaddlist(6)]=hdlnewsignal(hdllegalname(['coeffmux__section_',num2str(3)]),'filter',-1,0,0,...
        new_coeffvtype,new_coeffsltype);
    end


    if(mults==2)
        if~opscaleisunity
            coeff_mux1=[];
            coeff_mux2=[];
            coeffall=hdlgetallfromsltype(new_coeffsltype);
            [~,zeroptr1]=hdlnewsignal('zeroconstant','filter',-1,0,0,new_coeffvtype,new_coeffsltype);
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(zeroptr1,hdlconstantvalue(real(0),coeffall.size,coeffall.bp,1))];
            coeff_list(end+1)=zeroptr1;
            for i=1:6:length(coeff_list)-2
                coeff_mux1=[coeff_mux1,coeff_list(i:i+2)];
                coeff_mux2=[coeff_mux2,coeff_list(i+3:i+5)];
            end
            coeff_mux1(end+1)=coeff_list(end-1);
            coeff_mux2(end+1)=coeff_list(end);
        else
            coeff_mux1=zeros(1,length(coeff_list)/2);
            coeff_mux2=zeros(1,length(coeff_list)/2);
            j=1;
            for i=1:6:length(coeff_list)
                coeff_mux1(1,j)=coeff_list(i);
                coeff_mux1(1,j+1)=coeff_list(i+1);
                coeff_mux1(1,j+2)=coeff_list(i+2);
                coeff_mux2(1,j)=coeff_list(i+3);
                coeff_mux2(1,j+1)=coeff_list(i+4);
                coeff_mux2(1,j+2)=coeff_list(i+5);
                j=j+3;
            end
        end

    elseif(mults==3)
        if~opscaleisunity
            coeff_mux1=[];
            coeff_mux2=[];
            coeff_mux3=[];
            coeffall=hdlgetallfromsltype(new_coeffsltype);
            [~,zeroptr1]=hdlnewsignal('zeroconstant','filter',-1,0,0,new_coeffvtype,new_coeffsltype);
            sections_arch.constants=[sections_arch.constants,...
            makehdlconstantdecl(zeroptr1,hdlconstantvalue(real(0),coeffall.size,coeffall.bp,1))];
            coeff_list(end+1)=zeroptr1;
            coeff_list(end+1)=zeroptr1;

            for i=1:6:length(coeff_list)-3
                coeff_mux1=[coeff_mux1,coeff_list(i:i+1)];
                coeff_mux2=[coeff_mux2,coeff_list(i+2),coeff_list(i+4)];
                coeff_mux3=[coeff_mux3,coeff_list(i+3),coeff_list(i+5)];
            end
            coeff_mux1(end+1)=coeff_list(end-2);
            coeff_mux2(end+1)=coeff_list(end-1);
            coeff_mux3(end+1)=coeff_list(end);
        else
            coeff_mux1=zeros(1,length(coeff_list)/3);
            coeff_mux2=zeros(1,length(coeff_list)/3);
            coeff_mux3=zeros(1,length(coeff_list)/3);
            j=1;
            for i=1:6:length(coeff_list)
                coeff_mux1(1,j)=coeff_list(i);
                coeff_mux1(1,j+1)=coeff_list(i+1);
                coeff_mux2(1,j)=coeff_list(i+2);
                coeff_mux2(1,j+1)=coeff_list(i+4);
                coeff_mux3(1,j)=coeff_list(i+3);
                coeff_mux3(1,j+1)=coeff_list(i+5);
                j=j+2;
            end
        end
    end
    muxbody1=hdlmux(coeff_mux1,...
    preaddlist(2),...
    ctr_out,'=',[0:ffactor-1],'when-else');
    muxbody2=hdlmux(coeff_mux2,...
    preaddlist(3),...
    ctr_out,'=',[0:ffactor-1],'when-else');
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(2))];
    sections_arch.body_blocks=[sections_arch.body_blocks,'\n',muxbody1];
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(3))];
    sections_arch.body_blocks=[sections_arch.body_blocks,'\n',muxbody2];
    if(mults==3)
        muxbody3=hdlmux(coeff_mux3,...
        preaddlist(6),...
        ctr_out,'=',[0:ffactor-1],'when-else');
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(preaddlist(6))];
        sections_arch.body_blocks=[sections_arch.body_blocks,'\n',muxbody3];
    end




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
    numsumsltype=numsumall.sltype;

    productrounding=this.Roundmode;
    productsaturation=this.Overflowmode;


    inpmuxlist=hdlexpandvectorsignal(preaddlist(1));
    coeffmuxlist=hdlexpandvectorsignal(preaddlist(2));
    [ipsize,ipbp]=hdlgetsizesfromtype(hdlsignalsltype(inpmuxlist));
    [cpsize,cpbp]=hdlgetsizesfromtype(hdlsignalsltype(coeffmuxlist));
    fpsize=ipsize+cpsize;
    fpbp=ipbp+cpbp;
    [fpprodvtype,fpprodsltype]=hdlgettypesfromsizes(fpsize,fpbp,1);


    [densumsize,densumbp]=hdlgetsizesfromtype(densumsltype);
    [numsumsize,numsumbp]=hdlgetsizesfromtype(numsumsltype);
    [denprodsize,denprodbp]=hdlgetsizesfromtype(denproductsltype);
    [numprodsize,numprodbp]=hdlgetsizesfromtype(numproductsltype);
    fpsumbp=max([denprodbp,numprodbp]);
    fpsumsize=max([denprodsize-denprodbp,numprodsize-numprodbp])+fpsumbp+4;


    need=(densumsize-densumbp)<(fpsumsize-fpsumbp)||densumbp<fpsumbp||...
    (numsumsize-numsumbp)<(fpsumsize-fpsumbp)||numsumbp<fpsumbp;
    if~strcmpi(densumsltype,'double')&&(need||(densumbp~=numsumbp))
        message=['Numeric error might occur. '...
        ,'Consider specifying AccumWordLength = %d, '...
        ,'NumAccumFracLength = %d, '...
        ,'DenAccumFracLength = %d. '];
        warning('WarnSumSLtype:precisionloss',message,fpsumsize,fpsumbp,fpsumbp);
    end


    [mul_op1,mul_blocks,mul_signals,mul_tempsignals]=hdlcoeffmultiply(inpmuxlist,...
    0.232424,...
    coeffmuxlist,...
    'prod1',...
    fpprodvtype,fpprodsltype,...
    productrounding,productsaturation,densumsltype);
    sections_arch.signals=[sections_arch.signals,mul_signals,mul_tempsignals];
    sections_arch.body_blocks=[sections_arch.body_blocks,'\n',mul_blocks];


    [mul_op2,mul_blocks2,mul_signals2,mul_tempsignals2]=hdlcoeffmultiply(preaddlist(4),...
    0.123211223,...
    preaddlist(3),...
    'prod2',...
    fpprodvtype,fpprodsltype,...
    productrounding,productsaturation,densumsltype);
    sections_arch.signals=[sections_arch.signals,mul_signals2,mul_tempsignals2];
    sections_arch.body_blocks=[sections_arch.body_blocks,'\n',mul_blocks2];

    if(mults==3)

        [mul_op3,mul_blocks3,mul_signals3,mul_tempsignals3]=hdlcoeffmultiply(preaddlist(5),...
        0.131341247,...
        preaddlist(6),...
        'prod3',...
        fpprodvtype,fpprodsltype,...
        productrounding,productsaturation,densumsltype);
        sections_arch.signals=[sections_arch.signals,mul_signals3,mul_tempsignals3];
        sections_arch.body_blocks=[sections_arch.body_blocks,'\n',mul_blocks3];
    end




    [~,prod1_num]=hdlnewsignal('prod1_num','filter',-1,...
    0,0,numproductvtype,numproductsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod1_num)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(mul_op1,prod1_num,...
    productrounding,productsaturation)];


    [~,prod1_num_cast]=hdlnewsignal('prod1_num_cast','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod1_num_cast)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(prod1_num,prod1_num_cast,...
    productrounding,productsaturation)];



    [~,prod2_num]=hdlnewsignal('prod2_num','filter',-1,...
    0,0,numproductvtype,numproductsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod2_num)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(mul_op2,prod2_num,...
    productrounding,productsaturation)];


    [~,prod2_num_cast]=hdlnewsignal('prod2_num_cast','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod2_num_cast)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(prod2_num,prod2_num_cast,...
    productrounding,productsaturation)];


    [~,prod2_den]=hdlnewsignal('prod2_den','filter',-1,...
    0,0,denproductvtype,denproductsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod2_den)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(mul_op2,prod2_den,...
    productrounding,productsaturation)];


    [~,prod2_den_cast]=hdlnewsignal('prod2_den_cast','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod2_den_cast)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(prod2_den,prod2_den_cast,...
    productrounding,productsaturation)];


    [~,prod2_den_cast_neg]=hdlnewsignal('prod2_den_cast_neg','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod2_den_cast_neg)];
    [prod_minus_body,prod_minus_sig]=hdlunaryminus(prod2_den_cast,prod2_den_cast_neg,...
    productrounding,productsaturation);
    sections_arch.signals=[sections_arch.signals,prod_minus_sig];
    sections_arch.body_blocks=[sections_arch.body_blocks,prod_minus_body];

    if(mults==3)


        [~,prod3_num]=hdlnewsignal('prod3_num','filter',-1,...
        0,0,numproductvtype,numproductsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod3_num)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(mul_op3,prod3_num,...
        productrounding,productsaturation)];


        [~,prod3_num_cast]=hdlnewsignal('prod3_num_cast','filter',-1,...
        0,0,densumvtype,densumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod3_num_cast)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(prod3_num,prod3_num_cast,...
        productrounding,productsaturation)];


        [~,prod3_den]=hdlnewsignal('prod3_den','filter',-1,...
        0,0,denproductvtype,denproductsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod3_den)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(mul_op3,prod3_den,...
        productrounding,productsaturation)];


        [~,prod3_den_cast]=hdlnewsignal('prod3_den_cast','filter',-1,...
        0,0,densumvtype,densumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod3_den_cast)];
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdldatatypeassignment(prod3_den,prod3_den_cast,...
        productrounding,productsaturation)];


        [~,prod3_den_cast_neg]=hdlnewsignal('prod3_den_cast_neg','filter',-1,...
        0,0,densumvtype,densumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod3_den_cast_neg)];
        [prod_minus_body,prod_minus_sig]=hdlunaryminus(prod3_den_cast,prod3_den_cast_neg,...
        productrounding,productsaturation);
        sections_arch.signals=[sections_arch.signals,prod_minus_sig];
        sections_arch.body_blocks=[sections_arch.body_blocks,prod_minus_body];
    end



    bdt=hdlgetparameter('base_data_type');
    [~,temp]=hdlnewsignal('final_phase','filter',-1,0,0,bdt,'boolean');
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(temp)];

    [~,ptr_zero]=hdlnewsignal('zeroconstant','filter',-1,0,0,densumvtype,densumsltype);
    sections_arch.constants=[sections_arch.constants,...
    makehdlconstantdecl(ptr_zero,hdlconstantvalue(real(0),densumall.size,densumall.bp,densumall.signed))];

    [~,prod1_mux]=hdlnewsignal('prod1_mux','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod1_mux)];
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdlmux([ptr_zero,prod1_num_cast],prod1_mux,...
    temp,'=',[1,0],'when-else')];



    [~,prod2_mux]=hdlnewsignal('prod2_mux','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod2_mux)];
    prod2_mux_list=ones(size(coeff_mux2))*prod2_num_cast;
    if(mults==2)
        prod2_mux_list(2:3:end)=prod2_den_cast_neg;
        prod2_mux_list(3:3:end)=prod2_den_cast_neg;
    elseif(mults==3)
        prod2_mux_list(2:2:end)=prod2_den_cast_neg;
    end
    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdlmux(prod2_mux_list,prod2_mux,...
    ctr_out,'=',[0:ffactor-1],'when-else')];



    if(mults==3)
        [~,prod3_mux]=hdlnewsignal('prod3_mux','filter',-1,...
        0,0,densumvtype,densumsltype);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(prod3_mux)];
        prod3_mux_list=ones(size(coeff_mux3))*prod3_num_cast;
        prod3_mux_list(2:2:end)=prod3_den_cast_neg;
        sections_arch.body_blocks=[sections_arch.body_blocks,...
        hdlmux(prod3_mux_list,prod3_mux,...
        ctr_out,'=',[0:ffactor-1],'when-else')];
    end

    phase_body_or=hdlbitop(clear_Accum_phase,temp,'OR');
    sections_arch.body_blocks=[sections_arch.body_blocks,phase_body_or];

    if~opscaleisunity

        [~,accummuxsig]=hdlnewsignal('final_phase1','filter',-1,0,0,bdt,'boolean');
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(accummuxsig)];
        ORedsigs=[clear_Accum_phase,den_phase(end)];
        phase_body_or=hdlbitop(ORedsigs,accummuxsig,'OR');
        sections_arch.body_blocks=[sections_arch.body_blocks,phase_body_or];
    else
        accummuxsig=temp;
    end


    sumrounding=this.Roundmode;
    sumsaturation=this.Overflowmode;

    [~,sum_prod_12]=hdlnewsignal('sum_prod_12','filter',-1,...
    0,0,densumvtype,densumsltype);
    [sum_body1,sum_signals1]=hdlfilteradd(prod1_mux,prod2_mux,...
    sum_prod_12,sumrounding,sumsaturation);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sum_prod_12)];
    sections_arch.signals=[sections_arch.signals,sum_signals1];
    sections_arch.body_blocks=[sections_arch.body_blocks,sum_body1];

    if(mults==3)
        [~,sum_prod_123]=hdlnewsignal('sum_prod_123','filter',-1,...
        0,0,densumvtype,densumsltype);
        [sum_body2,sum_signals2]=hdlfilteradd(sum_prod_12,prod3_mux,...
        sum_prod_123,sumrounding,sumsaturation);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(sum_prod_123)];
        sections_arch.signals=[sections_arch.signals,sum_signals2];
        sections_arch.body_blocks=[sections_arch.body_blocks,sum_body2];
    end




    denstoragerounding=this.Roundmode;
    denstoragesaturation=this.Overflowmode;
    [~,acc_mux_out_sig]=hdlnewsignal('accum_mux_out','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_mux_out_sig)];

    [~,acc_mux_in_sig2]=hdlnewsignal('accum_mux_in2','filter',-1,...
    0,0,densumvtype,densumsltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_mux_in_sig2)];

    [~,acc_op]=hdlnewsignal('accum_reg','filter',-1,...
    0,0,densumvtype,densumsltype);

    if(mults==2)
        acc_mux_in_sig1=sum_prod_12;
    elseif(mults==3)
        acc_mux_in_sig1=sum_prod_123;
    end

    [sum_body,sum_signals]=hdlfilteradd(acc_op,acc_mux_in_sig1,...
    acc_mux_in_sig2,sumrounding,sumsaturation);
    sections_arch.signals=[sections_arch.signals,sum_signals];
    sections_arch.body_blocks=[sections_arch.body_blocks,sum_body];

    acc_mux_out_body=hdlmux([acc_mux_in_sig1,acc_mux_in_sig2],acc_mux_out_sig,...
    accummuxsig,'=',[1,0],'when-else');
    sections_arch.body_blocks=[sections_arch.body_blocks,acc_mux_out_body];

    hdlregsignal(acc_op);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(acc_op)];
    [tempbody1,tempsignals1]=hdlunitdelay(acc_mux_out_sig,acc_op,...
    ['accumulator_reg',hdlgetparameter('clock_process_label')],0);
    sections_arch.signals=[sections_arch.signals,tempsignals1];
    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody1];

    sections_arch.body_blocks=[sections_arch.body_blocks,...
    hdldatatypeassignment(acc_mux_out_sig,dencast_result,...
    denstoragerounding,denstoragesaturation)];


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
        opcastfrom=mul_op1;
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
    hdldatatypeassignment(mul_op1,...
    numcast_result,...
    numstoragerounding,numstoragesaturation)];
end

function[sections_arch,scaled_inp_list,numdelaylist,dendelaylist,coeff_list,pre_stg_op_list]=emit_delayline(this,den_phase,~,dencast_result,numdelay_vector_vtype,dendelay_vector_vtype,sections_arch,~,current_input,coeffs,ctr_sigs,opscaleisunity)


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

    pre_stg_op_list=[];
    if(this.Numsections>1)
        sections_arch.body_blocks=[sections_arch.body_blocks,['\n','  ',...
        hdlgetparameter('comment_char'),' ',...
        'Next stage input = Previous stage output. Storing Previous stage output\n']];
        for section=1:this.NumSections-1
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
        current_input.input,section,scaleresultall);

        coeff_list=[coeff_list,scale_list(section),num_list,den_list(2:3)];

        [num,den]=getcoeffs(coeffs,section);

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



        if~opscaleisunity
            hdladdclockenablesignal(den_phase(end-1));
            hdlsetcurrentclockenable(den_phase(end-1));
        else
            hdladdclockenablesignal(den_phase(end));
            hdlsetcurrentclockenable(den_phase(end));
        end
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



        [~,dendelay]=hdlnewsignal(['dendelay_section',num2str(section)],'filter',-1,...
        cplxty_densection,[2,0],...
        dendelay_vector_vtype,denstoragesltype);
        hdlregsignal(dendelay);
        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dendelay)];
        if(section==this.Numsections)
            tdobj=hdl.tapdelay('clock',hdlgetcurrentclock,...
            'clockenable',hdlgetcurrentclockenable,...
            'reset',hdlgetcurrentreset,...
            'inputs',dencast_result,...
            'outputs',dendelay,...
            'processName',['dendelay',hdlgetparameter('clock_process_label'),...
            '_section',num2str(section)],...
            'resetvalues',0,...
            'nDelays',2,...
            'delayOrder','Newest');
        else
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
        end
        port_list=hdlinportsignals;
        hdlsetcurrentclockenable(port_list(2));
        hdlc=tdobj.emit;
        sections_arch.body_blocks=[sections_arch.body_blocks,hdlc.arch_body_blocks];
        dendelaylist1=hdlexpandvectorsignal(dendelay);
        dendelaylist=[dendelaylist,dendelaylist1];

    end



end

