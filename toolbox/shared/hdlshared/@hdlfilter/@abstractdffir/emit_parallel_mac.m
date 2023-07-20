function[hdl_arch,prodlist]=emit_parallel_mac(this,coeffs_data,preaddlist)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

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

    hdlsetparameter('filter_excess_latency',...
    hdlgetparameter('filter_excess_latency')+...
    hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline'));

    coeffs_table=coeffs_data.idx;
    coeffs=coeffs_data.values;

    firlen=length(coeffs);

    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    rmode=this.Roundmode;
    [~,productrounding,sumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [~,productsaturation,sumsaturation]=deal(omode);


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
        strcmpi(final_adder_style,'linear')
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


    if~isreal(coeffs)&&isInputPortComplex(this)
        force_extra_quantization=false;
        lastmultvtype=productvtype;
        lastmultsltype=productsltype;
        lastmultsaturation=productsaturation;
        lastmultrounding=productrounding;
    end


    preaddindex=(length(preaddlist):-1:2);
    preaddfinal=1;

    if~coeffs_internal



        if isreal(coeffs)
            coeffs=0.9585*ones(1,firlen);
        else
            coeffs=complex(0.9585,0.9585)*ones(1,firlen);
        end
    end



    pv_pkg_req=hdlgetparameter('vhdl_package_required');
    total_typedefs={};

    prodlist=[];

    for n=preaddindex
        coeffn=coeffs_table(n);
        if emitMode




            if preaddlist(n)~=0
                [prodout,prodbody,prodsignals,prodtempsignals,prodtypedefs]=hdlcoeffmultiply(preaddlist(n),coeffs(n),coeffn,...
                ['product',num2str(n)],...
                productvtype,productsltype,...
                productrounding,productsaturation,sumsltype);
                if prodout~=0
                    prodlist=[prodlist,prodout];
                end
                hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsignals];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];

                if strcmpi(hdlgetparameter('target_language'),'vhdl')
                    total_typedefs=[total_typedefs,prodtypedefs];
                end
            end
        else



            if ishandle(preaddlist(n))
                [prodout,~,~,~,~]=hdlcoeffmultiply(preaddlist(n),coeffs(n),coeffn,...
                ['product',num2str(n)],...
                productvtype,productsltype,...
                productrounding,productsaturation,sumsltype);
                if prodout~=0
                    prodlist=[prodlist,prodout];
                end
            end
        end
    end



    if emitMode

        coeffn=coeffs_table(preaddfinal);
        [prodout,prodbody,prodsignals,prodtempsignals,prodtypedefs]=...
        hdlcoeffmultiply(preaddlist(preaddfinal),coeffs(preaddfinal),coeffn,...
        ['product',num2str(preaddfinal)],...
        lastmultvtype,lastmultsltype,...
        lastmultrounding,lastmultsaturation,sumsltype);

        if strcmpi(hdlgetparameter('target_language'),'vhdl')
            total_typedefs=[total_typedefs,prodtypedefs];
        end

        if prodout~=0

            if force_extra_quantization
                if isempty(prodlist)
                    complexity=hdlgetparameter('filter_complex_inputs')||~isreal(coeffs(preaddfinal));
                else
                    complexity=hdlsignaliscomplex(prodlist(1))||hdlgetparameter('filter_complex_inputs')||~isreal(coeffs(preaddfinal));
                end

                [~,xqstepsig]=hdlnewsignal([hdlsignalname(prodout),'_cast'],'filter',-1,complexity,...
                0,sumvtype,sumsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(xqstepsig)];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,...
                hdldatatypeassignment(prodout,...
                xqstepsig,...
                productrounding,productsaturation)];
                prodlist=[prodlist,xqstepsig];
            else
                prodlist=[prodlist,prodout];
            end
        end

        hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsignals];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];
        total_typedefs=unique(total_typedefs);
        hdl_arch.typedefs=[hdl_arch.typedefs,total_typedefs{:}];

    else
        if ishandle(preaddlist(preaddfinal))
            coeffn=coeffs_table(preaddfinal);
            [prodout,~,~,~,~]=...
            hdlcoeffmultiply(preaddlist(preaddfinal),coeffs(preaddfinal),coeffn,...
            ['product',num2str(preaddfinal)],...
            lastmultvtype,lastmultsltype,...
            lastmultrounding,lastmultsaturation,sumsltype);
            prodlist=[prodlist,prodout];
        end
    end


    hdlsetparameter('vhdl_package_required',pv_pkg_req);
