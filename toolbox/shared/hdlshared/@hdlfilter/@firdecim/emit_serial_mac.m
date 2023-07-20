function[hdl_arch,prodptr,last_sum,final_result]=emit_serial_mac(this,delaylist,counter_out,coeffs_data,ce,accumAndCeout)




    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';


    rmode=this.Roundmode;
    [productrounding,sumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [productsaturation,sumsaturation]=deal(omode);

    productall=hdlgetallfromsltype(this.productSLtype);
    productvtype=productall.vtype;
    productsltype=productall.sltype;

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    firadderstyle=hdlgetparameter('filter_fir_final_adder');

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;

    input_pipe_exp=delaylist;
    polycoeffs=this.polyphasecoefficients;

    phases=this.decimationfactor;

    inputcplxty=this.isInputPortComplex;

    ssi=hdlgetparameter('filter_serialsegment_inputs');
    ssi=sort(ssi,'descend');
    mults=numel(ssi);


    [mod_polycoeffs,power2coeffs]=modifypolycoeffsforpowerof2(this,polycoeffs);


    [mod_pcoeffs_aftersymm,indx_symm]=modifypolycoeffsforsymm(this,mod_polycoeffs);

    indx_inputs=cell2mat(input_pipe_exp');

    [lensummary,~,needSymmOptimization]=this.summaryofCoeffs;


    if needSymmOptimization
        sym_topcomment='Adding (or subtracting) the taps based on the symmetry (or asymmetry)';
        hdl_arch=this.insertComment(hdl_arch,'body_blocks',sym_topcomment);
        for n=1:size(indx_symm,1)
            indx_symm_phase=indx_symm(n,:);
            abs_indx_symm_phase=abs(indx_symm_phase);
            numofsymtaps=max(abs_indx_symm_phase);
            for symmnum=1:numofsymtaps
                indices_symm_phase=find(abs_indx_symm_phase==symmnum);
                indices_symm_inputs=indx_inputs(n,indices_symm_phase);
                indices_taps_real=indx_symm_phase(indices_symm_phase);
                indices_taps_real=indices_taps_real/max(indices_taps_real);

                [preaddptr,preaddbody,preaddsignals]=preaddsub(indices_symm_inputs,indices_taps_real,inputall.sltype,sumrounding,sumsaturation,inputcplxty);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,preaddbody];
                hdl_arch.signals=[hdl_arch.signals,preaddsignals];
                indx_inputs(n,indices_symm_phase(1))=preaddptr;
            end
        end

        mod_polycoeffs=mod_pcoeffs_aftersymm;
    end


    [muxin,muxVal]=getSerialMuxOrder(this,indx_inputs,mod_polycoeffs,ssi);

    if needAccumulator(this)




        muxsig=zeros(1,mults);
        prodgbits=zeros(mults,1);
        if inputmuxRequired(muxin)
            inputmux_topcomment='Mux(es) to select the input taps for multipliers ';
            hdl_arch=this.insertComment(hdl_arch,'body_blocks',inputmux_topcomment);
        end

        for muln=1:mults
            muxinplist=muxin{muln};
            if length(muxinplist)==1

                muxsig(muln)=muxinplist;
            else
                maxsize=findmaxsignalsize(muxinplist);
                prodgbits(muln)=maxsize-inputall.size;
                [muxinpvtype,muxinpsltype]=hdlgettypesfromsizes(maxsize,inputall.bp,1);
                [~,muxsig(muln)]=hdlnewsignal('inputmux','filter',-1,inputcplxty,0,...
                muxinpvtype,muxinpsltype);

                for n=1:numel(muxinplist)
                    sigidx=muxinplist(n);
                    isize=hdlsignalsizes(sigidx);
                    if isize(1)<maxsize

                        signame=hdlsignalname(sigidx);
                        signame=strrep([signame,'_cast'],'(','');
                        signame=strrep(signame,')','');
                        signame=strrep(signame,'[','');signame=strrep(signame,']','');
                        signame=strrep(signame,'__','_');
                        [~,dtcsig]=hdlnewsignal(signame,'filter',-1,inputcplxty,0,muxinpvtype,muxinpsltype);
                        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(dtcsig)];
                        dtc_body=hdldatatypeassignment(sigidx,dtcsig,sumrounding,sumsaturation);


                        muxinplist(n)=dtcsig;
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,dtc_body];
                    end
                end


                if hdlgetparameter('filter_registered_input')==1
                    muxbody=hdlmux(muxinplist,muxsig(muln),...
                    counter_out,{'='},muxVal{muln},'when-else');
                else
                    muxbody=hdlmux(muxinplist,muxsig(muln),...
                    counter_out,{'='},mod(muxVal{muln}-1,ssi(1)*phases),'when-else');
                end
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(muxsig(muln))];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,muxbody,'\n'];
            end
        end
    else

        muxsig(1)=muxin{1};
        prodgbits=zeros(mults,1);
    end

    [coeffs_index1,coeffs_indexVal]=getSerialMuxOrder(this,coeffs_data.idx,mod_polycoeffs,ssi);
    [coeffs_values1,coeffs_valuesVal]=getSerialMuxOrder(this,polycoeffs,mod_polycoeffs,ssi);
    prodbody=[];
    prodsignals=[];
    prodtempsignals=[];
    prodptr=[];
    total_typedefs={};
    for muln=1:mults
        mac_num=[];

        if needSymmOptimization
            psize=productall.size+prodgbits(muln);


        else
            psize=productall.size;
        end
        [multprodvtype,multprodsltype]=hdlgettypesfromsizes(psize,productall.bp,1);
        if hdlgetparameter('filter_registered_input')==1
            coeffmuxvals=coeffs_indexVal{muln};
        else
            coeffmuxvals=mod(coeffs_indexVal{muln}-1,ssi(1)*phases);
        end

        [prodptr1,prodbody1,prodsignals1,prodtempsignals1,prodtypedefs]=hdlmulticoeffmultiply(muxsig(muln),coeffs_values1{muln},...
        coeffs_index1{muln},counter_out,coeffmuxvals,['product',num2str(mac_num)],...
        multprodvtype,multprodsltype,...
        productrounding,productsaturation);
        if strcmpi(hdlgetparameter('target_language'),'vhdl')
            total_typedefs=[total_typedefs,prodtypedefs];
        end
        prodbody=[prodbody,prodbody1];
        prodsignals=[prodsignals,prodsignals1];
        prodtempsignals=[prodtempsignals,prodtempsignals1];
        prodptr=[prodptr,prodptr1];
    end

    hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];
    hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsignals];




    prodcplxty=hdlsignalcomplex(prodptr(1));

    if needAccumulator(this)



        muxbody=[];

        zeroptrcell={'sltypes',0};
        if~isempty(ce.phasemux)

            phasemuxes=ce.phasemux;
            for phasemuxn=1:mults
                if phasemuxes(phasemuxn)~=0
                    prodptrsizes=hdlsignalsizes(prodptr(phasemuxn));
                    [pmuxvtype,pmuxsltype]=hdlgettypesfromsizes(prodptrsizes(1),prodptrsizes(2),prodptrsizes(3));
                    zerosltypes=zeroptrcell(:,1);
                    indx_zerofound=strmatch(pmuxsltype,zerosltypes);
                    if isempty(indx_zerofound)
                        [~,zeroptr]=hdlnewsignal('const_zero','filter',-1,prodcplxty,0,pmuxvtype,pmuxsltype);
                        zerovalue=hdlconstantvalue(0,prodptrsizes(1),prodptrsizes(2),prodptrsizes(3));
                        hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(zeroptr,zerovalue)];
                        if prodcplxty
                            hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(hdlsignalimag(zeroptr),zerovalue)];
                        end
                        zeroptrcell(end+1,:)={pmuxsltype,zeroptr};
                    else
                        zeroptr=zeroptrcell{indx_zerofound,2};
                    end

                    [~,phasemux]=hdlnewsignal('phasemux',...
                    'filter',-1,prodcplxty,0,pmuxvtype,pmuxsltype);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(phasemux)];
                    muxbody=[muxbody,hdlmux([prodptr(phasemuxn),zeroptr],phasemux,...
                    ce.phasemux(phasemuxn),{'='},[1,0],'when-else')];

                    prodptr(phasemuxn)=phasemux;
                end
            end
        end
        hdl_arch.body_blocks=[hdl_arch.body_blocks,muxbody,'\n'];


    end


    prodpwr2ptr_cell={};
    if any(lensummary(:,3))
        pwr2_topcomment=['Implementing products without a multiplier for ',...
        'coefficients with values equal to a power of 2.'];
        hdl_arch=this.insertComment(hdl_arch,'body_blocks',pwr2_topcomment);

        for row=1:phases
            phasepwr2=power2coeffs(row,:);
            indx_power2coeffs=find(phasepwr2);
            input_indx=indx_inputs(row,indx_power2coeffs);

            coeffsindx=coeffs_data.idx;
            coeffsindx=coeffsindx(row,indx_power2coeffs);

            coeffs_values=phasepwr2(indx_power2coeffs);

            if~isempty(indx_power2coeffs)
                prodpwr2ptr=[];

                for n=1:numel(input_indx)

                    constname=hdlsignalname(coeffsindx(n));
                    phasenums=constname(11:end);
                    commentpwrtwo=['value of ''',constname,''' is ',...
                    num2str(coeffs_values(n))];

                    hdl_arch=this.insertComment(hdl_arch,'body_blocks',commentpwrtwo);
                    [pwr2prodout,pwr2body,pwr2signals,pwr2tempsignals,pwr2typedefs]=...
                    hdlcoeffmultiply(input_indx(n),coeffs_values(n),coeffsindx(n),...
                    hdllegalnamersvd(['prod_powertwo_',phasenums]),...
                    productvtype,productsltype,...
                    productrounding,productsaturation,this.accumSLtype);
                    if strcmpi(hdlgetparameter('target_language'),'vhdl')
                        total_typedefs=[total_typedefs,pwr2typedefs];
                    end
                    prodpwr2ptr(end+1)=pwr2prodout;

                    hdl_arch.signals=[hdl_arch.signals,pwr2signals,pwr2tempsignals];
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,pwr2body];

                end
                prodpwr2ptr_cell{row}=prodpwr2ptr;
            else
                prodpwr2ptr_cell{row}=0;
            end
        end
    end


    prodpwr2ptr_cell(2:end)=prodpwr2ptr_cell(end:-1:2);


    muxbody=[];
    pwr2mux_topcomment=[];
    ptr_phasemuxpwr2=[];
    if any(ce.power2phasemux)
        power2phasemux=ce.power2phasemux;

        pwr2mux_topcomment=['Mux(es) to select the power of 2 products ',...
        'for the corresponding polyphase'];
        hdl_arch=this.insertComment(hdl_arch,'body_blocks',pwr2mux_topcomment);

        for phase_num=1:phases
            if power2phasemux(phase_num)~=0
                if needAccumulator(this)
                    zerosltypes=zeroptrcell(:,1);
                    indx_zerofound=strmatch(productsltype,zerosltypes);
                    if isempty(indx_zerofound)
                        [~,zeroptr]=hdlnewsignal('const_zero','filter',-1,prodcplxty,0,productvtype,productsltype);
                        zerovalue=hdlconstantvalue(0,productall.size,productall.bp,1);
                        hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(zeroptr,zerovalue)];
                        if prodcplxty
                            hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(hdlsignalimag(zeroptr),zerovalue)];
                        end
                        zeroptrcell(end+1,:)={productsltype,zeroptr};
                    else
                        zeroptr=zeroptrcell{indx_zerofound,2};
                    end
                end

                for numpwr2mux=1:length(prodpwr2ptr_cell{phase_num})
                    if needAccumulator(this)
                        prodpwr2signame=hdlsignalname(prodpwr2ptr_cell{phase_num}(numpwr2mux));
                        prodnumindx=findstr(prodpwr2signame,'_');
                        prodnumpart=prodpwr2signame(prodnumindx(2)+1:end);

                        [~,phasemux]=hdlnewsignal(['powertwo_mux_',prodnumpart],...
                        'filter',-1,prodcplxty,0,productvtype,productsltype);
                        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(phasemux)];

                        muxbody=[muxbody,hdlmux([prodpwr2ptr_cell{phase_num}(numpwr2mux),zeroptr],phasemux,...
                        ce.power2phasemux(phase_num),{'='},[1,0],'when-else')];

                        ptr_phasemuxpwr2(end+1)=phasemux;
                    else
                        ptr_phasemuxpwr2(end+1)=prodpwr2ptr_cell{phase_num}(numpwr2mux);
                    end
                end

            end
        end
    end

    prodptr=[prodptr,ptr_phasemuxpwr2];

    hdl_arch.body_blocks=[hdl_arch.body_blocks,muxbody,'\n'];




    if~strcmpi(inputall.sltype,'double')

        prodmaxsize=findmaxsignalsize(prodptr);


        if strcmpi(firadderstyle,'linear');
            sopsize=prodmaxsize+length(prodptr)-1;
        else
            sopsize=prodmaxsize+ceil(log2(length(prodptr)));
        end

        sopbp=productall.bp;


        accum.size=max(sopsize+hdlgetparameter('foldingfactor')-1,sumall.size);
        accum.bp=sopbp;
    else
        sopsize=0;sopbp=0;
        accum.size=0;
        accum.bp=0;
    end
    accum.rounding=sumrounding;
    accum.saturation=sumsaturation;

    [sumofprodvtype,sumofprodsltype]=hdlgettypesfromsizes(sopsize,sopbp,1);
    [accum.vtype,accum.sltype]=hdlgettypesfromsizes(accum.size,accum.bp,1);

    sop_comment=['Add the products in ',hdlgetparameter('filter_fir_final_adder'),...
    ' fashion'];
    hdl_arch=this.insertComment(hdl_arch,'body_blocks',sop_comment);

    [~,sumout]=hdlnewsignal('sumofproducts',...
    'filter',-1,prodcplxty,0,sumofprodvtype,sumofprodsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];

    [sumbody,sumsignals]=hdlsumofelements(prodptr,...
    sumout,sumrounding,sumsaturation,hdlgetparameter('filter_fir_final_adder'));


    hdl_arch.body_blocks=[hdl_arch.body_blocks,sumbody];
    hdl_arch.signals=[hdl_arch.signals,sumsignals];

    ff=hdlgetparameter('foldingfactor');

    if needAccumulator(this)




        sopdtc_comment='Resize the sum of products to the accumulator type for full precision addition';
        hdl_arch=this.insertComment(hdl_arch,'body_blocks',sopdtc_comment);

        [~,sopdtc_sig]=hdlnewsignal('sumofproducts_cast','filter',-1,prodcplxty,0,accum.vtype,accum.sltype);
        sopdtc_signals=makehdlsignaldecl(sopdtc_sig);
        sopdtc_body=hdldatatypeassignment(sumout,sopdtc_sig,sumrounding,sumsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,sopdtc_body];

        acc_comment='Accumulator register with a mux to reset it with the first addend';
        hdl_arch=this.insertComment(hdl_arch,'body_blocks',acc_comment);

        [acccumbody,accumsignals,final_result]=emit_accumulator(accum,sopdtc_sig,ce);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,acccumbody];
        hdl_arch.signals=[hdl_arch.signals,sopdtc_signals,accumsignals];

        acc_comment='Register to hold the final value of the accumulated sum';
        hdl_arch=this.insertComment(hdl_arch,'body_blocks',acc_comment);


        [~,accreg_finalsig]=hdlnewsignal('accreg_final',...
        'filter',-1,prodcplxty,0,accum.vtype,accum.sltype);
        hdlregsignal(accreg_finalsig);


        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce.accummux)



        accfinalbody=hdlunitdelay(final_result,accreg_finalsig,...
        ['Acc_finalreg',hdlgetparameter('clock_process_label')],0);
        hdlsetcurrentclockenable(oldce);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(accreg_finalsig)];

        hdl_arch.body_blocks=[hdl_arch.body_blocks,accfinalbody];


        final_result=accreg_finalsig;
        last_sum=accreg_finalsig;

        if accumAndCeout
            acc_comment='Register to align phase with output clock';
            hdl_arch=this.insertComment(hdl_arch,'body_blocks',acc_comment);

            [~,acc_final_alignsig]=hdlnewsignal('acc_final_align',...
            'filter',-1,prodcplxty,0,accum.vtype,accum.sltype);
            hdlregsignal(acc_final_alignsig);

            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce.ceout);

            accfinalalignbody=hdlunitdelay(accreg_finalsig,acc_final_alignsig,...
            ['Acc_finalAlignreg',hdlgetparameter('clock_process_label')],0);

            hdlsetcurrentclockenable(oldce);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(acc_final_alignsig)];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,accfinalalignbody];

            final_result=acc_final_alignsig;
            last_sum=acc_final_alignsig;
        end
    else
        last_sum=sumout;
        final_result=sumout;
    end
    total_typedefs=unique(total_typedefs);
    hdl_arch.typedefs=[hdl_arch.typedefs,total_typedefs{:}];

    multcycles=hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline');
    if(hdlgetparameter('filter_registered_input')~=1)&&...
        (hdlgetparameter('filter_registered_output')~=1)&&...
        multcycles==ff*phases-(ff+2);

        [~,postaccsig]=hdlnewsignal('postaccdelay',...
        'filter',-1,hdlsignalcomplex(last_sum),0,hdlsignalvtype(last_sum),hdlsignalsltype(last_sum));
        hdlregsignal(postaccsig);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(postaccsig)];

        [extradelaybody,extradelaysignals]=hdlunitdelay(last_sum,postaccsig,...
        ['PostAccumDelay',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,extradelaybody];
        hdl_arch.signals=[hdl_arch.signals,extradelaysignals];
        last_sum=postaccsig;
        final_result=postaccsig;
    end


    function[hdlbody,hdlsignals,accreg_outsig]=emit_accumulator(sumtype,input,ce)

        accumcplxty=hdlsignaliscomplex(input);


        [~,acc_sumsig]=hdlnewsignal('acc_sum','filter',-1,accumcplxty,0,sumtype.vtype,sumtype.sltype);


        [~,accreg_insig]=hdlnewsignal('accreg_in','filter',-1,accumcplxty,0,sumtype.vtype,sumtype.sltype);


        [~,accreg_outsig]=hdlnewsignal('accreg_out',...
        'filter',-1,accumcplxty,0,sumtype.vtype,sumtype.sltype);
        hdlregsignal(accreg_outsig);


        hdlsignals=[makehdlsignaldecl(acc_sumsig),...
        makehdlsignaldecl(accreg_insig),...
        makehdlsignaldecl(accreg_outsig)];


        [adderbody,addersignals]=hdlfilteradd(input,accreg_outsig,...
        acc_sumsig,sumtype.rounding,sumtype.saturation);



        muxbody=hdlmux([input,acc_sumsig],accreg_insig,...
        ce.accummux,{'='},[1,0],'when-else');


        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce.accum)
        accregbody=hdlunitdelay(accreg_insig,accreg_outsig,...
        ['Acc_reg',hdlgetparameter('clock_process_label')],0);
        hdlsetcurrentclockenable(oldce);



        hdlbody=[adderbody,muxbody,'\n',accregbody];
        hdlsignals=[hdlsignals,addersignals];


        function[preaddptr,preaddbody,preaddsignals]=preaddsub(ins,posnegs,insltype,sumrounding,sumsaturation,complxity)

            preaddbody='';
            preaddsignals='';

            if~strcmpi(insltype,'double')
                [insize,inbp,insigned]=hdlgetsizesfromtype(insltype);
                outsize=insize+length(ins)-1;
                outbp=inbp;
            else
                insigned=1;
                outsize=0;
                outbp=0;
            end

            [outvtype,outsltype]=hdlgettypesfromsizes(outsize,outbp,insigned);

            oldsums=ins;
            oldposnegs=posnegs;
            for level=1:ceil(log2(length(ins)))
                count=1;
                newsums=[];
                newposnegs=[];
                for n=2:2:length(oldsums)

                    inp1name=hdlsignalname(oldsums(n-1));
                    str1=strfind(inp1name,'phase');
                    str1=inp1name(str1+5:end);
                    str1=strrep(str1,'(','_');str1=strrep(str1,')','');
                    str1=strrep(str1,'[','_');str1=strrep(str1,']','');

                    inp1name=hdlsignalname(oldsums(n));
                    str2=strfind(inp1name,'phase');
                    str2=inp1name(str2+5:end);
                    str2=strrep(str2,'(','_');str2=strrep(str2,')','');
                    str2=strrep(str2,'[','_');str2=strrep(str2,']','');

                    preaddname=['tapsum_',str1,'and',str2];
                    [~,sumout]=hdlnewsignal(preaddname,...
                    'filter',-1,complxity,0,outvtype,outsltype);
                    newsums=[newsums,sumout];
                    preaddsignals=[preaddsignals,makehdlsignaldecl(sumout)];

                    [tempbody,tempsignals,tempposneg]=filterpreaddsub([oldsums(n-1),oldsums(n)],oldposnegs(n-1:n),sumout,outvtype,outsltype,sumrounding,sumsaturation,complxity);
                    preaddbody=[preaddbody,tempbody];
                    preaddsignals=[preaddsignals,tempsignals];
                    newposnegs=[newposnegs,tempposneg];
                    count=count+1;
                end
                if mod(length(oldsums),2)==1
                    newsums=[newsums,oldsums(end)];
                    newposnegs=[newposnegs,oldposnegs(end)];
                end
                oldsums=newsums;
                oldposnegs=newposnegs;
            end

            preaddptr=oldsums(1);


            function[tempbody,tempsignals,tempposneg]=filterpreaddsub(ins,posnegs,out,outvtype,outsltype,rounding,saturation,complxity)

                tempposneg=1;
                if posnegs(1)==1
                    if posnegs(2)==1

                        [tempbody,tempsignals]=hdlfilteradd(ins(1),ins(2),...
                        out,rounding,saturation);
                    elseif posnegs(2)==-1

                        [tempbody,tempsignals]=hdlfiltersub(ins(1),ins(2),...
                        out,rounding,saturation);
                    end
                elseif posnegs(1)==-1
                    if posnegs(2)==1

                        [tempbody,tempsignals]=hdlfiltersub(ins(2),ins(1),...
                        out,rounding,saturation);
                    elseif posnegs(2)==-1

                        tempsignalname=[hdlsignalname(out),'_temp'];
                        [~,tempsum]=hdlnewsignal(tempsignalname,...
                        'filter',-1,complxity,0,outvtype,outsltype);
                        tempsignals0=makehdlsignaldecl(tempsum);
                        [tempbody1,tempsignals1]=hdlfilteradd(ins(1),ins(2),...
                        tempsum,rounding,saturation);
                        [tempbody2,tempsignals2]=hdlunaryminus(tempsum,...
                        out,rounding,saturation);
                        tempbody=[tempbody1,tempbody2];
                        tempsignals=[tempsignals0,tempsignals1,tempsignals2];
                        tempposneg=-1;
                    end
                end

                function maxsize=findmaxsignalsize(siglist)

                    maxsize=0;
                    for n=1:numel(siglist)
                        sizes=hdlsignalsizes(siglist(n));
                        maxsize=max(maxsize,sizes(1));
                    end

                    function success=inputmuxRequired(muxin)

                        success=false;
                        for nn=1:numel(muxin)
                            if length(muxin{nn})>1
                                success=true;
                                break;
                            end
                        end


