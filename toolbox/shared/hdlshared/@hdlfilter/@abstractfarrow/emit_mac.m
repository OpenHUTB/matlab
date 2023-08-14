function[mac_arch,lastproductedsum]=emit_mac(this,preaddlist,fdregsig,coeffs_data)






    mac_arch.functions='';
    mac_arch.typedefs='';
    mac_arch.constants='';
    mac_arch.signals='';
    mac_arch.body_blocks='';
    mac_arch.body_output_assignments='';

    final_adder_style=hdlgetparameter('filter_fir_final_adder');

    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end

    mult_type=hdlgetparameter('filter_multipliers');

    hdlsetparameter('filter_excess_latency',...
    hdlgetparameter('filter_excess_latency')+...
    hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline'));

    coeffs=this.Coefficients;

    productall=hdlgetallfromsltype(this.productSLtype);
    productsize=productall.size;
    productbp=productall.bp;
    productvtype=productall.vtype;
    productsltype=productall.sltype;

    rmode=this.Roundmode;
    [productrounding,sumrounding,...
    fdproductrounding,multiplicandrounding]=deal(rmode);

    omode=this.Overflowmode;
    [productsaturation,sumsaturation,...
    fdproductsaturation,multiplicandsaturation]=deal(omode);

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumsize=sumall.size;
    sumbp=sumall.bp;
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    if hdlgetparameter('bit_true_to_filter')&&...
        strcmpi(final_adder_style,'linear')&&...
        strcmpi(mult_type,'multiplier')
        if(((productsize>sumsize)||...
            (productsize==sumsize&&productbp>sumbp))&&...
            strcmp(productrounding,sumrounding)&&...
            productsaturation==sumsaturation)
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

    multiplicandall=hdlgetallfromsltype(this.multiplicandSLtype);
    multiplicandvtype=multiplicandall.vtype;
    multiplicandsltype=multiplicandall.sltype;

    fdproductall=hdlgetallfromsltype(this.fdprodSLtype);
    fdproductvtype=fdproductall.vtype;
    fdproductsltype=fdproductall.sltype;

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    castvtype=outputall.vtype;
    castsltype=outputall.sltype;

    for numfirblock=1:size(coeffs,2)

        preaddindex=(length(preaddlist):-1:2);
        preaddfinal=1;

        prodlist=[];
        for n=preaddindex
            coeffn=coeffs_data.idx(n,numfirblock);
            if preaddlist(n)~=0
                [prodout,prodbody,prodsignals,prodtempsignals]=hdlcoeffmultiply(preaddlist(n),coeffs(n,numfirblock),coeffn,...
                ['product',num2str(numfirblock),'_',num2str(n)],...
                productvtype,productsltype,...
                productrounding,productsaturation);
                if prodout~=0
                    prodlist=[prodlist,prodout];%#ok<AGROW>
                end
                mac_arch.signals=[mac_arch.signals,prodsignals,prodtempsignals];
                mac_arch.body_blocks=[mac_arch.body_blocks,prodbody];
            end
        end



        coeffn=coeffs_data.idx(preaddfinal,numfirblock);
        [prodout,prodbody,prodsignals,prodtempsignals]=...
        hdlcoeffmultiply(preaddlist(preaddfinal),coeffs(preaddfinal,numfirblock),coeffn,...
        ['product',num2str(numfirblock),'_',num2str(preaddfinal)],...
        lastmultvtype,lastmultsltype,...
        lastmultrounding,lastmultsaturation);
        if prodout~=0
            prodlist=[prodlist,prodout];%#ok<AGROW>
        end

        mac_arch.signals=[mac_arch.signals,prodsignals,prodtempsignals];
        mac_arch.body_blocks=[mac_arch.body_blocks,prodbody];

        [~,firblocksig(numfirblock)]=hdlnewsignal(...
        ['fir_filter_',num2str(numfirblock)],'filter',-1,0,0,sumvtype,sumsltype);%#ok<AGROW>

        mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(firblocksig(numfirblock))];

        if isempty(prodlist)






            [~,zerosignaldecl]=hdlnewsignal(['const_zero_',num2str(numfirblock)],'filter',-1,0,0,sumvtype,sumsltype);

            [psize,pbp]=hdlgetsizesfromtype(sumsltype);
            zeroconstdecl=makehdlconstantdecl(zerosignaldecl,hdlconstantvalue(0,psize,pbp,1));

            zeroassignment=hdldatatypeassignment(zerosignaldecl,firblocksig(numfirblock),'Floor',0);


            mac_arch.constants=[mac_arch.constants,zeroconstdecl];
            mac_arch.body_blocks=[mac_arch.body_blocks,zeroassignment];

        else


            [fir_adder_body,fir_adder_signals]=hdlsumofelements(prodlist(end:-1:1),...
            firblocksig(numfirblock),'floor',0,final_adder_style);

            mac_arch.signals=[mac_arch.signals,fir_adder_signals];
            mac_arch.body_blocks=[mac_arch.body_blocks,fir_adder_body];

        end

    end

    if strcmpi(final_adder_style,'pipelined')
        additional_latency=ceil(log2(length(prodlist)));
        hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+additional_latency);
    end


    lastproductedsum=firblocksig(1);
    fdmcandsig=zeros(length(firblocksig)-1);
    fdpdtsig=zeros(length(firblocksig)-1);
    fdsumsig=zeros(length(firblocksig)-1);

    for n=1:length(firblocksig)-1


        [~,fdmcandsig(n)]=hdlnewsignal(['multiplicand_',num2str(n)],...
        'filter',-1,0,0,multiplicandvtype,multiplicandsltype);

        fddatatypebdy=hdldatatypeassignment(lastproductedsum,fdmcandsig(n),...
        multiplicandrounding,multiplicandsaturation);

        mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(fdmcandsig(n))];
        fdmultsig=fdmcandsig(n);
        mac_arch.body_blocks=[mac_arch.body_blocks,fddatatypebdy];



        [~,fdpdtsig(n)]=hdlnewsignal(['fdproduct_',num2str(n)],...
        'filter',-1,0,0,fdproductvtype,fdproductsltype);

        [fdpdctbody,fdpdtsignals]=hdlmultiply(fdregsig,fdmultsig,fdpdtsig(n),...
        fdproductrounding,fdproductsaturation);


        [in1size,in1bp]=hdlgetsizesfromtype(hdlsignalsltype(firblocksig(n+1)));
        [in2size,in2bp]=hdlgetsizesfromtype(hdlsignalsltype(fdpdtsig(n)));

        if strcmpi(this.InputSLType,'double')
            fdsumvtype='real';
            fdsumsltype='double';
        else
            fdsumbp=max(in1bp,in2bp);
            fdsumsize=max(in1size-in1bp,in2size-in2bp)+1+fdsumbp;
            [fdsumvtype,fdsumsltype]=hdlgettypesfromsizes(fdsumsize,fdsumbp,1);
        end


        [~,fdsumsig(n)]=hdlnewsignal(['fdsum_',num2str(n)],...
        'filter',-1,0,0,fdsumvtype,fdsumsltype);

        [fsumbdy,fsumsignals]=hdladd(firblocksig(n+1),fdpdtsig(n),fdsumsig(n),...
        sumrounding,sumsaturation);

        mac_arch.signals=[mac_arch.signals,...
        makehdlsignaldecl(fdpdtsig(n)),...
        makehdlsignaldecl(fdsumsig(n))];

        lastproductedsum=fdsumsig(n);

        mac_arch.signals=[mac_arch.signals,fdpdtsignals,fsumsignals];

        mac_arch.body_blocks=[mac_arch.body_blocks,...
        fdpdctbody,fsumbdy];

    end


    [~,dtcfdsumsig]=hdlnewsignal([hdlsignalname(lastproductedsum),'_typec'],...
    'filter',-1,0,0,castvtype,castsltype);

    dtcfdsumbody=hdldatatypeassignment(lastproductedsum,dtcfdsumsig,...
    multiplicandrounding,multiplicandsaturation);

    mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(dtcfdsumsig)];
    mac_arch.body_blocks=[mac_arch.body_blocks,dtcfdsumbody];

    lastproductedsum=dtcfdsumsig;

end
