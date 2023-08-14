function hdlcode=emit(this)








    hdlcode=hdlcodeinit;

    body='';
    constants='';
    hdlsignals='';
    hdltypedefs='';

    cmnt_char=hdlgetparameter('comment_char');
    cmnt_line=repmat('*',1,32);

    booleanhdl=hdlblockdatatype('boolean');

    block_name=hdllegalname(this.processName);


    inputs=this.inputs;
    outputs=this.outputs;



    body=[body,'\n',hdlformatcomment('*** NCO ***',[],cmnt_char),'\n'];
    accumall=hdlgetallfromsltype(this.AccumulatorSLType);
    accum_vtype=accumall.vtype;
    accum_sltype=accumall.sltype;
    accumWL=accumall.size;

    oldcbs=hdlgetparameter('cast_before_sum');
    hdlsetparameter('cast_before_sum',0);


    insig_idx=1;


    context=this.beginClockBundleContext(this.clock,this.clockenable,this.reset);

    if strcmpi(this.PhaseIncrementSource,'Input port'),


        inc_insig=inputs(insig_idx);
        nco_copies=max(hdlsignalvector(inc_insig));
        if nco_copies==0,
            nco_copies=1;
        end
        [~,pinc_idx]=hdlnewsignal('phase_increment','block',-1,0,nco_copies,accum_vtype,accum_sltype);
        body=[body,hdldatatypeassignment(inc_insig,pinc_idx,'floor',false)];
        insig_idx=insig_idx+1;
    else

        accinc=this.PhaseIncrement;
        nco_copies=length(accinc);

        if nco_copies==1,
            C_pinc_val=hdlconstantvalue(accinc,accumWL,0,1,'bin');
            [~,pinc_idx]=hdlnewsignal('C_NCO_PHASE_INCREMENT','block',-1,0,1,accum_vtype,accum_sltype);
            constants=[constants,makehdlconstantdecl(pinc_idx,C_pinc_val)];
        else
            [~,pinc_idx]=hdlnewsignal('phase_increment','block',-1,0,nco_copies,accum_vtype,accum_sltype);
            body=[body,hdlvectorconstantassign(pinc_idx,accinc,{'bin'})];
            hdlsignals=[hdlsignals,makehdlsignaldecl(pinc_idx)];
        end
    end




    body=[body,hdlformatcomment([cmnt_line,'\nPHASE ACCUMULATION\n',cmnt_line],[],cmnt_char),'\n'];
    [~,accum_reg_idx]=hdlnewsignal('accumulator_reg','block',-1,0,nco_copies,...
    accum_vtype,accum_sltype);
    hdlregsignal(accum_reg_idx);
    hdlsignals=[hdlsignals,makehdlsignaldecl(accum_reg_idx)];

    [~,accum_input_idx]=hdlnewsignal('accumulator_input','block',-1,0,nco_copies,...
    accum_vtype,accum_sltype);
    hdlsignals=[hdlsignals,makehdlsignaldecl(accum_input_idx)];

    [accaddbody,accaddsigs]=hdlvectoradd(accum_reg_idx,pinc_idx,accum_input_idx);

    body=[body,accaddbody];
    hdlsignals=[hdlsignals,accaddsigs];



    if strcmpi(this.PhaseOffsetSource,'Input port'),
        poffset_insig=inputs(insig_idx);

        body=[body,hdlunitdelay(accum_input_idx,accum_reg_idx,[block_name,'_phase_accumulator_',hdluniqueprocessname],...
        zeros(1,nco_copies))];


        [~,poffset_idx]=hdlnewsignal('phase_offset','block',-1,0,nco_copies,...
        accum_vtype,accum_sltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(poffset_idx)];

        body=[body,hdldatatypeassignment(poffset_insig,poffset_idx,'floor',false)];

        [~,total_phase_idx]=hdlnewsignal('total_phase','block',-1,0,nco_copies,...
        accum_vtype,accum_sltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(total_phase_idx)];

        body=[body,hdlformatcomment([cmnt_line,'\nPHASE OFFSET ADDITION\n',cmnt_line],[],cmnt_char),'\n'];
        body=[body,hdlvectoradd(accum_reg_idx,poffset_idx,total_phase_idx)];

    else

        poffset_val=this.PhaseOffset;


        body=[body,hdlunitdelay_winits(accum_input_idx,accum_reg_idx,...
        [block_name,'_phase_accumulator_',hdluniqueprocessname],repmat(poffset_val,1,nco_copies))];


        total_phase_idx=accum_reg_idx;
    end






    if this.Dither,

        pnpoly_str=this.PolyBitPattern;
        for ii=1:length(pnpoly_str),
            dither_pngen.GenPoly(ii)=str2num(pnpoly_str(ii));%#ok<ST2NM>
        end
        dither_pngen.InitialStates=[zeros(1,(length(pnpoly_str)-2)),1];

        body=[body,hdlformatcomment([cmnt_line,'\nDITHER\n',cmnt_line],[],cmnt_char),'\n'];
        [~,dithered_phase_idx]=hdlnewsignal('dithered_phase','block',-1,0,nco_copies,...
        accum_vtype,accum_sltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(dithered_phase_idx)];
        dither_pngen.NumBitsOut=this.NumDitherBits;




        [bodytmp,dithered_val_idx,pnconsts,pnsigs,pntypedefs]=hdlpngen(dither_pngen);
        body=[body,bodytmp];
        constants=[constants,pnconsts];
        hdlsignals=[hdlsignals,pnsigs];
        hdltypedefs=[hdltypedefs,pntypedefs];
        expanded_total_phase=hdlexpandvectorsignal(total_phase_idx);
        expanded_dithered_phase=hdlexpandvectorsignal(dithered_phase_idx);
        for ii=1:nco_copies,
            [tmpbody,tmpsigs]=hdladd(dithered_val_idx,expanded_total_phase(ii),...
            expanded_dithered_phase(ii),'floor',0);
            body=[body,tmpbody];
            hdlsignals=[hdlsignals,tmpsigs];
        end



    else

        dithered_phase_idx=total_phase_idx;

    end


    this.endClockBundleContext(context);

    if this.PhaseQuantization
        body=[body,hdlformatcomment([cmnt_line,'\nPHASE QUANTIZATION\n',cmnt_line],[],cmnt_char),'\n'];
        quantWL=this.NumQuantizerAccumulatorBits;
        droppedbitsWL=accumWL-quantWL;
        [quant_vtype,quant_sltype]=hdlgettypesfromsizes(quantWL,-droppedbitsWL,0);
        [~,quantized_phase_idx]=hdlnewsignal('quantized_phase','block',-1,0,nco_copies,...
        quant_vtype,quant_sltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(quantized_phase_idx)];

        body=[body,hdldatatypeassignment(dithered_phase_idx,quantized_phase_idx,'floor',0)];

    else
        droppedbitsWL=0;


        quantized_phase_idx=dithered_phase_idx;
    end


    if(this.PhaseQuantizationErrorOutputPort&&this.PhaseQuantization),
        [quanterr_vtype,quanterr_sltype]=hdlgettypesfromsizes(droppedbitsWL,0,0);

        [~,quanterr_idx]=hdlnewsignal('unsigned_quantization_err','block',-1,0,nco_copies,quanterr_vtype,quanterr_sltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(quanterr_idx)];

        body=[body,hdldatatypeassignment(dithered_phase_idx,quanterr_idx,'floor',false)];
        body=[body,hdldatatypeassignment(quanterr_idx,outputs(end),'floor',false)];
    end



    trig_func=this.Waveform;
    outsig_idx=1;


    addr_idx=quantized_phase_idx;


    outputall=hdlgetallfromsltype(this.OutputSLType);
    outputWL=outputall.size;
    outputFL=outputall.bp;
    func_out_vtype=outputall.vtype;
    func_out_sltype=outputall.sltype;







    addrsize=hdlsignalsizes(addr_idx);
    [addrWL,addrbp,addrsigned]=deal(addrsize(1),addrsize(2),addrsize(3));%#ok<NASGU>
    rambits=addrWL-2;
    [lutaddr_vtype,lutaddr_sltype]=hdlgettypesfromsizes(rambits,-droppedbitsWL,0);


    body=[body,hdlformatcomment([cmnt_line,'\nQUARTER WAVE LOOKUP TABLE\n'...
    ,'The sinusoid is implemented via a quarter wave lookup table.\n'...
    ,'The values of the first quadrant of a SINE function are stored in the lookup table.\n'...
    ,'The lower ',num2str(rambits),' quantized phase bits form the address to the lookup table.\n'...
    ,'There are 2^',num2str(rambits),' values in the table on the interval [0,pi/2).\n'...
    ,'One extra value, sin(pi/2), is muxed into the output of the table.\n'...
    ,'The most significant two quantized phase bits determine how the quarter wave should be\n'...
    ,'reflect and/or inverted to create a full sinusoid.\n'...
    ,cmnt_line],[],cmnt_char),'\n\n'];


    C_addr_max_val=hdlconstantvalue(2^(rambits+droppedbitsWL),rambits+1,-droppedbitsWL,0,'bin');
    C_extra_val=hdlconstantvalue(fi(1,1,outputWL,outputFL),outputWL,outputFL,1,'bin');



    [c_addr_vtype,c_addr_sltype]=hdlgettypesfromsizes(rambits+1,-droppedbitsWL,0);
    [evcmp_in_vtype,evcmp_in_sltype]=hdlgettypesfromsizes(rambits+1,-droppedbitsWL,0);




    [~,lutaddrquad1_idx]=hdlnewsignal('lutaddr_quadrant1','block',-1,0,nco_copies,lutaddr_vtype,lutaddr_sltype);
    [~,lutaddrquad2_idx]=hdlnewsignal('lutaddr_quadrant2','block',-1,0,nco_copies,lutaddr_vtype,lutaddr_sltype);
    [~,C_addr_max_idx]=hdlnewsignal('C_NCO_ADDR_MAX','block',-1,0,1,c_addr_vtype,c_addr_sltype);
    [~,C_ev_idx]=hdlnewsignal('C_NCO_EXTRA_QTR_WAVE_VAL','block',-1,0,1,func_out_vtype,func_out_sltype);
    hdlsignals=[hdlsignals,...
    makehdlsignaldecl(lutaddrquad1_idx),...
    makehdlsignaldecl(lutaddrquad2_idx)];



    constants=[constants,makehdlconstantdecl(C_addr_max_idx,C_addr_max_val)];
    constants=[constants,makehdlconstantdecl(C_ev_idx,C_extra_val)];


    expanded_addr_vect=hdlexpandvectorsignal(addr_idx);
    expanded_lutaddrquad1_vect=hdlexpandvectorsignal(lutaddrquad1_idx);




    body=[body,'\n',hdlformatcomment('generation of LUT address and control signals',[],cmnt_char),'\n'];
    body=[body,hdldatatypeassignment(addr_idx,lutaddrquad1_idx,'floor',0)];
    [tmpbody,tmpsignals]=make_qwlutaddrgen(lutaddrquad1_idx,C_addr_max_idx,lutaddrquad2_idx);
    body=[body,tmpbody];
    hdlsignals=[hdlsignals,tmpsignals];
    complex_out=strcmpi(trig_func,'Complex exponential');
    dual_out=strcmpi(trig_func,'Sine and cosine');


    if(strcmpi(trig_func,'Sine')||dual_out||complex_out),
        if dual_out,
            body=[body,'\n',hdlformatcomment('generation of Sine part',[],cmnt_char),'\n'];
        elseif complex_out,
            body=[body,'\n',hdlformatcomment('generation of imaginary part',[],cmnt_char),'\n'];
        end
        [~,sevcmp_in_idx]=hdlnewsignal('sin_extra_value_cmp_in','block',-1,0,nco_copies,evcmp_in_vtype,evcmp_in_sltype);
        [~,sinv_hwoutput_idx]=hdlnewsignal('sin_inv_hwoutput','block',-1,0,nco_copies,booleanhdl,'boolean');
        [~,saddrmuxsel_idx]=hdlnewsignal('sin_addr_mux_sel','block',-1,0,nco_copies,booleanhdl,'boolean');
        hdlsignals=[hdlsignals,...
        makehdlsignaldecl(sevcmp_in_idx),...
        makehdlsignaldecl(sinv_hwoutput_idx),...
        makehdlsignaldecl(saddrmuxsel_idx)];

        expanded_sinv_hwoutput_vect=hdlexpandvectorsignal(sinv_hwoutput_idx);
        expanded_saddrmuxsel_vect=hdlexpandvectorsignal(saddrmuxsel_idx);


        for inst=1:nco_copies,
            body=[body,hdlsliceconcat(expanded_addr_vect(inst),{addrWL-1},expanded_sinv_hwoutput_vect(inst))];%#ok<AGROW> %slice the msb
            body=[body,hdlsliceconcat(expanded_addr_vect(inst),{addrWL-2},expanded_saddrmuxsel_vect(inst))];%#ok<AGROW> %slice the 2nd msb
        end


        body=[body,hdldatatypeassignment(addr_idx,sevcmp_in_idx,'floor',false)];




        if complex_out,
            outsig=hdlsignalimag(outputs(outsig_idx));
        else
            outsig=outputs(outsig_idx);
            outsig_idx=outsig_idx+1;
        end

        [tmpbody,~,tmpconsts,tmpsigs]=make_sinusoid(lutaddrquad1_idx,lutaddrquad2_idx,saddrmuxsel_idx,...
        sevcmp_in_idx,2^(rambits+droppedbitsWL),C_ev_idx,sinv_hwoutput_idx,outsig,'sin');
        body=[body,tmpbody];
        constants=[constants,tmpconsts];
        hdlsignals=[hdlsignals,tmpsigs];


    end

    if(strcmpi(trig_func,'Cosine')||dual_out||complex_out),
        if dual_out,
            body=[body,'\n',hdlformatcomment('generation of Cosine part',[],cmnt_char),'\n'];
        elseif complex_out,
            body=[body,'\n',hdlformatcomment('generation of real part',[],cmnt_char),'\n'];
        end
        [~,cevcmp_in_idx]=hdlnewsignal('cos_extra_value_cmp_in','block',-1,0,nco_copies,evcmp_in_vtype,evcmp_in_sltype);
        [~,cinv_hwoutput_idx]=hdlnewsignal('cos_inv_hwoutput','block',-1,0,nco_copies,booleanhdl,'boolean');
        [~,caddrmuxsel_idx]=hdlnewsignal('cos_addr_mux_sel','block',-1,0,nco_copies,booleanhdl,'boolean');

        hdlsignals=[hdlsignals,...
        makehdlsignaldecl(cevcmp_in_idx),...
        makehdlsignaldecl(cinv_hwoutput_idx),...
        makehdlsignaldecl(caddrmuxsel_idx)];

        expanded_cinv_hwoutput_vect=hdlexpandvectorsignal(cinv_hwoutput_idx);
        expanded_caddrmuxsel_vect=hdlexpandvectorsignal(caddrmuxsel_idx);
        expanded_cevcmp_in_vect=hdlexpandvectorsignal(cevcmp_in_idx);


        upperbitsBP=-(addrWL+droppedbitsWL-2);

        [qphase2msbs_vtype,qphase2msbs_sltype]=hdlgettypesfromsizes(2,upperbitsBP,0);
        [~,qphase2msbs_idx]=hdlnewsignal([hdlsignalname(addr_idx),'_2msbs'],'block',-1,0,nco_copies,qphase2msbs_vtype,qphase2msbs_sltype);
        [~,cosctrl_idx]=hdlnewsignal('cos_control_bits','block',-1,0,nco_copies,qphase2msbs_vtype,qphase2msbs_sltype);

        hdlsignals=[hdlsignals,...
        makehdlsignaldecl(qphase2msbs_idx),...
        makehdlsignaldecl(cosctrl_idx)];

        C_90deg_val=hdlconstantvalue(2^(addrWL-addrbp-2),2,upperbitsBP,0,'bin');
        [~,C_90deg_idx]=hdlnewsignal('C_NCO_90DEG','block',-1,0,1,qphase2msbs_vtype,...
        qphase2msbs_sltype);

        constants=[constants,makehdlconstantdecl(C_90deg_idx,C_90deg_val)];

        body=[body,hdldatatypeassignment(addr_idx,qphase2msbs_idx,'floor',0)];

        [tmpbody,tmpsigs]=hdlvectoradd(qphase2msbs_idx,C_90deg_idx,cosctrl_idx,'floor',false);
        body=[body,tmpbody];
        hdlsignals=[hdlsignals,tmpsigs];
        expanded_cosctrl_vect=hdlexpandvectorsignal(cosctrl_idx);


        for inst=1:nco_copies,
            body=[body,hdlsliceconcat(expanded_cosctrl_vect(inst),{1},expanded_cinv_hwoutput_vect(inst))];%#ok<AGROW> %slice the msb
            body=[body,hdlsliceconcat(expanded_cosctrl_vect(inst),{0},expanded_caddrmuxsel_vect(inst))];%#ok<AGROW> %slice the 2nd msb
            body=[body,hdlsliceconcat([expanded_cosctrl_vect(inst),expanded_lutaddrquad1_vect(inst)],{0,[]},expanded_cevcmp_in_vect(inst))];%#ok<AGROW> %makes the signal to check if extra value should be used
        end



        [tmpbody,~,tmpconsts,tmpsignals]=make_sinusoid(lutaddrquad1_idx,lutaddrquad2_idx,caddrmuxsel_idx,...
        cevcmp_in_idx,2^(rambits+droppedbitsWL),C_ev_idx,cinv_hwoutput_idx,outputs(outsig_idx),'cos');
        body=[body,tmpbody];
        constants=[constants,tmpconsts];
        hdlsignals=[hdlsignals,tmpsignals];
    end




    hdlsetparameter('cast_before_sum',oldcbs);
    hdlcode.arch_body_blocks=body;
    hdlcode.arch_signals=hdlsignals;
    hdlcode.arch_constants=constants;
    hdlcode.arch_typedefs=hdltypedefs;




    function[body,signals]=make_qwlutaddrgen(addr_lowerbits_idx,C_addr_max_idx,lutaddrquad2_idx)


        body=[];
        signals=[];

        expanded_addr_lowerbits_vect=hdlexpandvectorsignal(addr_lowerbits_idx);
        expanded_lutaddrquad2_vect=hdlexpandvectorsignal(lutaddrquad2_idx);

        nco_copies=length(expanded_addr_lowerbits_vect);




        for ops=1:nco_copies,
            [tmpbody,tmpsignals]=hdlsub(C_addr_max_idx,expanded_addr_lowerbits_vect(ops),expanded_lutaddrquad2_vect(ops),'floor',false);
            body=[body,tmpbody];%#ok<*AGROW>
            signals=[signals,tmpsignals];
        end





        function[body,sigs,constants,hdlsignals]=make_sinusoid(quad1addr_idx,quad2addr_idx,use_quad2addr_idx,evcmp_idx,evcmp_val,C_ev_idx,inv_idx,sinusoid_out_idx,func_str)



            body=[];
            sigs=[];
            constants=[];
            hdlsignals=[];
            cmnt_char=hdlgetparameter('comment_char');

            expanded_sinusoid_out_vect=hdlexpandvectorsignal(sinusoid_out_idx);
            copies=length(expanded_sinusoid_out_vect);


            out_sltype=hdlsignalsltype(expanded_sinusoid_out_vect(1));
            out_vtype=hdlblockdatatype(out_sltype);

            lutaddr_sltype=hdlsignalsltype(quad1addr_idx);
            lutaddr_vtype=hdlblockdatatype(lutaddr_sltype);


            [~,lutaddr_idx]=hdlnewsignal([func_str,'lutaddr'],'block',-1,0,copies,lutaddr_vtype,lutaddr_sltype);
            [~,lutout_idx]=hdlnewsignal([func_str,'lut_output'],'block',-1,0,copies,out_vtype,out_sltype);
            [~,hwout_idx]=hdlnewsignal([func_str,'_hw'],'block',-1,0,copies,out_vtype,out_sltype);

            hdlsignals=[hdlsignals,...
            makehdlsignaldecl(lutaddr_idx),...
            makehdlsignaldecl(lutout_idx),...
            makehdlsignaldecl(hwout_idx)];

            body=[body,make_quad1quad2mux(quad1addr_idx,quad2addr_idx,use_quad2addr_idx,lutaddr_idx)];

            body=[body,'\n',hdlformatcomment('quarter wave LUT',[],cmnt_char),'\n'];
            [tmpbody,~,tmpconsts,tmpsignals]=make_qwlut(lutaddr_idx,lutout_idx);
            body=[body,tmpbody];
            hdlsignals=[hdlsignals,tmpsignals];
            constants=[constants,tmpconsts];
            body=[body,'\n',hdlformatcomment('mux in sin(pi/2) for efficient ROM usage',[],cmnt_char),'\n'];
            [tmpbody,tmpconsts]=make_use_ev(lutout_idx,evcmp_idx,evcmp_val,C_ev_idx,hwout_idx);
            body=[body,tmpbody];
            constants=[constants,tmpconsts];

            body=[body,'\n',hdlformatcomment(['invert halfwave ',func_str,' to create a fullwave ',func_str],[],cmnt_char),'\n'];
            inv_sig_str=[hdlsignalname(hwout_idx),'_inv'];

            neg_opmux=hdl.negate_opmux('in',hwout_idx,'sel',inv_idx,'out',sinusoid_out_idx,'negate_string',inv_sig_str);
            neg_opmux_code=neg_opmux.emit();
            body=[body,neg_opmux_code.arch_body_blocks];
            hdlsignals=[hdlsignals,neg_opmux_code.arch_signals];



            function body=make_quad1quad2mux(quad1addr_idx,quad2addr_idx,use_quad2addr_idx,lutaddr_idx)



                body=[];

                expand_quad1addr_vect=hdlexpandvectorsignal(quad1addr_idx);
                expand_quad2addr_vect=hdlexpandvectorsignal(quad2addr_idx);
                expand_use_quad2addr_vect=hdlexpandvectorsignal(use_quad2addr_idx);
                expand_lutaddr_vect=hdlexpandvectorsignal(lutaddr_idx);


                nco_copies=length(expand_quad1addr_vect);


                for ops=1:nco_copies,
                    body=[body,hdlmux([expand_quad1addr_vect(ops),expand_quad2addr_vect(ops)],...
                    expand_lutaddr_vect(ops),expand_use_quad2addr_vect(ops),{'='},0,'when-else'),'\n'];%#ok<AGROW>
                end





                function[body,sigs,consts,hdlsignals]=make_qwlut(lutaddr_idx,lutout_idx)
                    body=[];
                    sigs=[];
                    consts=[];
                    hdlsignals=[];
                    expand_addr=hdlexpandvectorsignal(lutaddr_idx);
                    expand_lutout=hdlexpandvectorsignal(lutout_idx);
                    copies=length(expand_addr);


                    addrsize=hdlsignalsizes(expand_addr(1));
                    [addrWL,addrbp,addrsigned]=deal(addrsize(1),addrsize(2),addrsize(3));%#ok<NASGU>
                    ramlength=2^addrWL;
                    idx=0:ramlength-1;
                    intable=idx*2^-addrbp;
                    outtable=sin(2*pi*idx/(4*ramlength));

                    lutout_size=hdlsignalsizes(expand_lutout(1));
                    [lutoutWL,lutoutBP,lutoutSIGNED]=deal(lutout_size(1),lutout_size(2),lutout_size(3));%#ok<NASGU>

                    if lutoutWL>2,
                        [lutunsoutvtype,lutunsoutsltype]=hdlgettypesfromsizes(lutoutWL-1,lutoutBP,0);
                        [~,lutunsout_idx]=hdlnewsignal([hdlsignalname(lutout_idx),'_unsigned'],'block',-1,0,copies,...
                        lutunsoutvtype,lutunsoutsltype);
                        netlo_idx=lutunsout_idx;
                    else
                        netlo_idx=lutout_idx;
                    end
                    hdlregsignal(netlo_idx);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(netlo_idx)];
                    expand_lo=hdlexpandvectorsignal(netlo_idx);


                    for ii=1:copies,
                        [body_tmp,sigs_tmp,consts_tmp]=hdllookuptable(expand_addr(ii),expand_lo(ii),intable,outtable,'Nearest',1);

                        body=[body,body_tmp];%#ok<AGROW>
                        sigs=[sigs,sigs_tmp];%#ok<AGROW>
                        consts=consts_tmp;
                        if lutoutWL>2,
                            body=[body,hdldatatypeassignment(expand_lo(ii),expand_lutout(ii),'floor',false)];%#ok<AGROW>
                        end
                    end




                    function[body,constants]=make_use_ev(lutout_idx,evcmp_idx,evcmp_val,C_ev_idx,hwout_idx)

                        body=[];
                        constants=[];
                        expand_hwout=hdlexpandvectorsignal(hwout_idx);
                        expand_lutout=hdlexpandvectorsignal(lutout_idx);
                        expand_evcmp=hdlexpandvectorsignal(evcmp_idx);

                        copies=length(expand_hwout);








                        for ii=1:copies,
                            body=[body,hdlmux([expand_lutout(ii),C_ev_idx],expand_hwout(ii),expand_evcmp(ii),{'~='},evcmp_val,'when-else'),'\n'];%#ok<AGROW>
                        end










                        function hdlbody=hdlunitdelay_winits(Din,Qout,proc_name,init)
                            body=[];
                            expanded_D=hdlexpandvectorsignal(Din);
                            expanded_Q=hdlexpandvectorsignal(Qout);
                            copies=length(expanded_Q);


                            if isscalar(init),
                                init=repmat(init,1,length(expanded_D));
                            end

                            if all(init==0),
                                body=[body,hdlunitdelay(Din,Qout,proc_name,init)];
                            else
                                for ii=1:copies,
                                    body=[body,hdlunitdelay(expanded_D(ii),expanded_Q(ii),[proc_name,'_',num2str(ii-1)],init(ii))];%#ok<AGROW> %accum reg resets to phase offset
                                end
                            end

                            hdlbody=body;





                            function[hdlbody,hdlsignals]=hdlvectoradd(addend1_idx,addend2_idx,sum_idx,rounding,saturation)
                                if nargin<4,
                                    rounding='floor';
                                    saturation=false;
                                end
                                addend1_vect=hdlexpandvectorsignal(addend1_idx);
                                addend2_vect=hdlexpandvectorsignal(addend2_idx);
                                if(isscalar(addend1_vect)&&isvector(addend2_vect)),
                                    addend1_vect=repmat(addend1_vect,size(addend2_vect));
                                elseif(isscalar(addend2_vect)&&isvector(addend1_vect)),
                                    addend2_vect=repmat(addend2_vect,size(addend1_vect));
                                end


                                sum_vect=hdlexpandvectorsignal(sum_idx);

                                hdlbody=[];
                                hdlsignals=[];
                                for elem=1:length(addend1_vect),
                                    [tmpbody,tmpsigs]=hdladd(addend1_vect(elem),addend2_vect(elem),sum_vect(elem),rounding,saturation);%#ok<AGROW> % accum_input <= accum_reg + pinc; No round, no sat
                                    hdlbody=[hdlbody,tmpbody];
                                    hdlsignals=[hdlsignals,tmpsigs];
                                end;





