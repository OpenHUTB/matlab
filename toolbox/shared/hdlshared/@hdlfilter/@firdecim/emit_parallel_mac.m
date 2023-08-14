function[hdl_arch,prodlist]=emit_parallel_mac(this,coeffs_data,preaddlist,phasece,entitysigs)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    hdlsetparameter('filter_excess_latency',...
    hdlgetparameter('filter_excess_latency')+...
    (hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline')).*this.DecimationFactor);

    phases=this.decimationfactor;
    polycoeffs=this.polyphasecoefficients;

    productall=hdlgetallfromsltype(this.productSLtype);
    productvtype=productall.vtype;
    productsltype=productall.sltype;

    complexity=isOutputPortComplex(this);

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    rmode=this.Roundmode;
    [productrounding,sumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [productsaturation,sumsaturation]=deal(omode);


    if hdlgetparameter('clockinputs')~=1


        saved_clk=hdlgetcurrentclock;
        saved_clkenb=hdlgetcurrentclockenable;
        saved_reset=hdlgetcurrentreset;
        hdlsetcurrentclock(entitysigs.clk1);
        hdlsetcurrentclockenable(entitysigs.clken1);
        hdlsetcurrentreset(entitysigs.reset1);
    else
        hdlsetcurrentclockenable(phasece(1));
    end

    input_pipe_exp=preaddlist;
    prodlist=zeros(size(coeffs_data.idx));

    total_typedefs={};

    for n=1:size(coeffs_data.idx,1)
        sizipe=length(input_pipe_exp{n});
        reginput=zeros(1,size(coeffs_data.idx,2));
        reginput(1:sizipe)=input_pipe_exp{n};
        for m=1:sizipe
            coeffn=coeffs_data.idx(n,m);
            [prodlist(n,m),prodbody,prodsignals,prodtempsignals,prodtypedefs]=hdlcoeffmultiply(...
            reginput(m),...
            polycoeffs(n,m),coeffn,...
            ['product_phase',num2str(n-1),'_',num2str(m)],...
            productvtype,productsltype,...
            productrounding,productsaturation,sumsltype);
            hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsignals];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];
            if strcmpi(hdlgetparameter('target_language'),'vhdl')
                total_typedefs=[total_typedefs,prodtypedefs];
            end

        end
    end

    total_typedefs=unique(total_typedefs);
    hdl_arch.typedefs=[hdl_arch.typedefs,total_typedefs{:}];


    if hdlgetparameter('filter_pipelined')
        hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+phases);

        pipeout=zeros(size(prodlist));
        for n=1:size(prodlist,1)
            for m=1:size(prodlist,2)
                if prodlist(n,m)~=0
                    [~,temppipe]=hdlnewsignal(['product_pipeline_phase',num2str(n-1),...
                    '_',num2str(m)],...
                    'filter',-1,hdlsignaliscomplex(prodlist(n,m)),0,...
                    hdlsignalvtype(prodlist(n,m)),...
                    hdlsignalsltype(prodlist(n,m)));
                    hdlregsignal(temppipe);
                    pipeout(n,m)=temppipe;
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(temppipe)];
                end
            end
        end
        [tempbody,tempsignals]=hdlunitdelay(prodlist(prodlist~=0),pipeout(pipeout~=0),...
        ['product_pipeline',hdlgetparameter('clock_process_label'),num2str(n-1)],...
        zeros(1,length(prodlist(prodlist~=0))));
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];

        prodlist=pipeout;
    end

    prodtosum=cell(1,phases);
    for n=1:phases
        tmp=prodlist(n,:);
        idx=find(tmp~=0);
        prodtosum{(phases-n+1)}=tmp(idx);
    end

    prodlist=cell2mat(prodtosum);

    if hdlgetparameter('bit_true_to_filter')

        dtccomplexity=hdlsignaliscomplex(prodlist(1));
        [~,firstprod]=hdlnewsignal('quantized_sum','filter',-1,dtccomplexity,0,sumvtype,sumsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(firstprod)];
        tempbody=hdldatatypeassignment(prodlist(1),firstprod,sumrounding,sumsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        prodlist(1)=firstprod;
    end




