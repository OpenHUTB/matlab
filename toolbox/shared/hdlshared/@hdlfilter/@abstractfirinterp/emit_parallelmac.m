function[hdl_arch,prodlist]=emit_parallelmac(this,coeffs_data,delaylist)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    total_typedefs={};
    productall=hdlgetallfromsltype(this.productSLtype);
    productvtype=productall.vtype;
    productsltype=productall.sltype;
    productsize=productall.size;
    productbp=productall.bp;

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumsize=sumall.size;
    sumbp=sumall.bp;
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;


    rmode=this.Roundmode;
    [productrounding,sumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [productsaturation,sumsaturation]=deal(omode);

    polycoeffs=this.polyphasecoefficients;

    counter_out=hdlsignalfindname('cur_count');




    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    numMultPipes=hdlgetparameter('multiplier_input_pipeline')+hdlgetparameter('multiplier_output_pipeline');
    if numMultPipes>0&&...
        (strcmpi(hdlgetparameter('filter_multipliers'),'factored-csd')||...
        strcmpi(hdlgetparameter('filter_multipliers'),'csd'))
        if emitMode
            counter_out_name=hdlsignalname(counter_out);
            sz=hdlsignalsizes(counter_out);
            [vt,slt]=hdlgettypesfromsizes(sz(1),sz(2),sz(3));
            if numMultPipes==1

                vt=hdlsignalvtype(counter_out);
            end
            [~,counter_out_dly]=hdlnewsignal([counter_out_name,'_dly'],'block',-1,0,0,vt,slt);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out_dly)];
            ctrDly=hdl.intdelay('inputs',counter_out,'outputs',counter_out_dly,'nDelays',numMultPipes);
            ctrDlyhdlcode=ctrDly.emit;
            hdl_arch.signals=[hdl_arch.signals,ctrDlyhdlcode.arch_signals];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,ctrDlyhdlcode.arch_body_blocks];
            if strcmpi(hdlgetparameter('target_language'),'vhdl')

                cnttypedefs=hdlgetparameter('vhdl_package_type_defs');



                cnttypedefs=hdlUniquifyTypeDefinitions(cnttypedefs);



                hdlsetparameter('vhdl_package_required',0);
                total_typedefs=[total_typedefs,cnttypedefs];
            end

        else
            counter_out_name=hdlsignalname(counter_out);
            counter_out_dly=hN.addSignal(counter_out.Type,[counter_out_name,'_dly']);
            hWireComp=pirelab.getWireComp(hN,counter_out,counter_out_dly,counter_out_name);
            hWireComp.setInputPipeline(hdlgetparameter('multiplier_input_pipeline'));
            hWireComp.setOutputPipeline(hdlgetparameter('multiplier_output_pipeline'));
        end
    else
        counter_out_dly=counter_out;
    end

    final_adder_style=hdlgetparameter('filter_fir_final_adder');
    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end
    mult_type=hdlgetparameter('filter_multipliers');

    if hdlgetparameter('bit_true_to_filter')&&...
        strcmpi(final_adder_style,'linear')&&...
        strcmpi(mult_type,'multiplier')
        if((productsize>sumsize)||...
            (productbp>sumbp))&&...
            strcmp(productrounding,sumrounding)&&...
            productsaturation==sumsaturation
            warning(message('HDLShared:hdlfilter:quantizedifference'));
            lastmultvtype=sumvtype;
            lastmultsltype=sumsltype;
            lastmultsaturation=sumsaturation;
            lastmultrounding=sumrounding;
        else
            lastmultvtype=productvtype;
            lastmultsltype=productsltype;
            lastmultsaturation=productsaturation;
            lastmultrounding=productrounding;
        end
    else

        lastmultvtype=productvtype;
        lastmultsltype=productsltype;
        lastmultsaturation=productsaturation;
        lastmultrounding=productrounding;
    end



    preaddindex=[length(delaylist):-1:2];%#ok<NBRAK>
    preaddfinal=1;

    prodlist=[];
    for n=preaddindex

        [prodout,prodbody,prodsignals,prodtempsigs,prodtypedefs]=hdlmulticoeffmultiply(delaylist(n),...
        polycoeffs(:,n),coeffs_data.idx(:,n),...
        counter_out_dly,0:length(polycoeffs(:,n))-1,'product',productvtype,...
        productsltype,productrounding,...
        productsaturation,sumsltype);

        hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsigs];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];

        if strcmpi(hdlgetparameter('target_language'),'vhdl')
            total_typedefs=[total_typedefs,prodtypedefs];%#ok<AGROW> %add to typedefs
        end
        if prodout~=0
            prodlist=[prodlist,prodout];%#ok<AGROW>
        end

    end



    [prodout,prodbody,prodsignals,prodtempsigs,prodtypedefs]=hdlmulticoeffmultiply(delaylist(preaddfinal),...
    polycoeffs(:,preaddfinal),coeffs_data.idx(:,preaddfinal),...
    counter_out_dly,0:length(polycoeffs(:,preaddfinal))-1,'product',lastmultvtype,...
    lastmultsltype,lastmultrounding,...
    lastmultsaturation,sumsltype);

    hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsigs];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];
    if strcmpi(hdlgetparameter('target_language'),'vhdl')
        total_typedefs=[total_typedefs,prodtypedefs];
    end
    if prodout~=0
        prodlist=[prodlist,prodout];
    end

    final_adder_style=hdlgetparameter('filter_fir_final_adder');
    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end

    if strcmpi(final_adder_style,'linear')
        len=length(prodlist);
        prodlist_temp(1)=prodlist(end);
        for n=2:len
            prodlist_temp(n)=prodlist(end-n+1);%#ok<AGROW>
        end
        prodlist=prodlist_temp;
    end

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end


    saved_ce=hdlsignalfindname(hdlgetparameter('clockenablename'));
    saved_clk=hdlsignalfindname(hdlgetparameter('clockname'));
    saved_rst=hdlsignalfindname(hdlgetparameter('resetname'));

    if multiclock==0
        hdlsetcurrentclockenable(saved_ce);
    else

        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end

    total_typedefs=unique(total_typedefs);
    hdl_arch.typedefs=[hdl_arch.typedefs,total_typedefs{:}];


