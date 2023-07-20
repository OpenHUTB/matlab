function[hdl_arch,last_sum]=emit_mac(this,delaylist,coeffs_data,cforder,phase_ceout)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    final_adder_style=hdlgetparameter('filter_fir_final_adder');
    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end
    mult_type=hdlgetparameter('filter_multipliers');

    hdlsetparameter('filter_excess_latency',0);

    polycoeffs=this.PolyphaseCoefficients;
    arithisdouble=strcmpi(this.InputSLType,'double');

    rmode=this.Roundmode;
    [productrounding,sumrounding]=deal(rmode);



    omode=this.Overflowmode;
    [productsaturation,sumsaturation]=deal(omode);


    productall=hdlgetallfromsltype(this.productSLtype);
    productsize=productall.size;
    productbp=productall.bp;
    productvtype=productall.vtype;
    productsltype=productall.sltype;


    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumsize=sumall.size;
    sumbp=sumall.bp;
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    if hdlgetparameter('bit_true_to_filter')&&...
        strcmpi(final_adder_style,'linear')&&...
        strcmpi(mult_type,'multiplier')&&~arithisdouble
        if(((productsize>sumsize)||...
            (productbp>sumbp)))&&strcmpi(productrounding,'floor')


            force_extra_quantization=false;
            lastmultvtype=sumvtype;
            lastmultsltype=sumsltype;
            lastmultsaturation=sumsaturation;
            lastmultrounding=sumrounding;
        else


            force_extra_quantization=true;
            lastmultvtype=productvtype;
            lastmultsltype=productsltype;
            lastmultsaturation=productsaturation;
            lastmultrounding=productrounding;
        end
    else
        force_extra_quantization=false;
        lastmultvtype=productvtype;
        lastmultsltype=productsltype;
        lastmultsaturation=productsaturation;
        lastmultrounding=productrounding;
    end

    preaddindex=[length(delaylist):-1:2];
    preaddfinal=1;


    counter_out=hdlsignalfindname('cur_count');
    prodlist=[];
    for n=preaddindex

        [prodout,prodbody,prodsignals,prodtempsigs]=hdlmulticoeffmultiply(delaylist(n),...
        polycoeffs(cforder,n),coeffs_data.idx(cforder,n),...
        counter_out,phase_ceout,'product',productvtype,...
        productsltype,productrounding,...
        productsaturation,sumsltype);

        hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsigs];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];

        if prodout~=0
            prodlist=[prodlist,prodout];
        end

    end


    [prodout,prodbody,prodsignals,prodtempsigs]=hdlmulticoeffmultiply(delaylist(preaddfinal),...
    polycoeffs(cforder,preaddfinal),coeffs_data.idx(cforder,preaddfinal),...
    counter_out,phase_ceout,'product',lastmultvtype,...
    lastmultsltype,lastmultrounding,...
    lastmultsaturation,sumsltype);

    hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsigs];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];


    if force_extra_quantization
        cplxty_cast=hdlsignaliscomplex(prodout);
        [~,xqstepsig]=hdlnewsignal([hdlsignalname(prodout),'_cast'],'filter',-1,cplxty_cast,...
        0,sumvtype,sumsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(xqstepsig)];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        hdldatatypeassignment(prodout,...
        xqstepsig,...
        productrounding,productsaturation)];
        prodlist=[prodlist,xqstepsig];
    else
        if prodout~=0
            prodlist=[prodlist,prodout];
        end
    end

    complexity=isOutputPortComplex(this);


    if strcmpi(final_adder_style,'pipelined')
        warning(message('HDLShared:hdlfilter:PipelinedAddedNotSupported'));
        final_adder_style='linear';
    end
    [~,last_sum]=hdlnewsignal('fir_sum',...
    'filter',-1,complexity,0,sumvtype,sumsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(last_sum)];
    [fir_adder_body,fir_adder_signals]=hdlsumofelements(prodlist(end:-1:1),...
    last_sum,'floor',0,final_adder_style);
    hdl_arch.signals=[hdl_arch.signals,fir_adder_signals];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,fir_adder_body];

