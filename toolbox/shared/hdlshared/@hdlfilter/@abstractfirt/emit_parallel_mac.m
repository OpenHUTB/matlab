function[hdl_arch,prodlist]=emit_parallel_mac(this,coeffs_data,reginput)






    emitMode=isempty(pirNetworkForFilterComp);

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    coeffs_table=coeffs_data.idx;
    cplxty=this.isInputPortComplex||~isreal(this.Coefficients);

    rmode=this.Roundmode;
    [~,productrounding]=deal(rmode);

    omode=this.Overflowmode;
    [~,productsaturation]=deal(omode);

    coeffs=this.Coefficients;
    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsvsize=coeffall.size;
    coeffsvbp=coeffall.bp;

    productall=hdlgetallfromsltype(this.productSLtype);
    productsize=productall.size;
    productbp=productall.bp;
    productvtype=productall.vtype;
    productsltype=productall.sltype;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsize=inputall.size;
    inputbp=inputall.bp;

    if emitMode
        signalRate=0;
    else
        signalRate=reginput.SimulinkRate;
    end

    optimcoeffs=coeffs;
    if hdlgetparameter('bit_true_to_filter')

        if productsize==coeffsvsize+inputsize&&productbp==coeffsvbp+inputbp
            [~,fidx,polymap]=unique(myabs(optimcoeffs),'legacy');
        else
            [~,fidx,polymap]=unique((optimcoeffs),'legacy');
        end
    else
        [~,fidx,polymap]=unique(myabs(optimcoeffs),'legacy');
    end

    hdlsetparameter('filter_excess_latency',...
    hdlgetparameter('filter_excess_latency')+...
    hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline'));

    optimcoeffs(setdiff(1:length(optimcoeffs),fidx,'legacy'))=0;
    total_typedefs={};

    if emitMode
        prodlist=zeros(1,length(coeffs_table));
    end

    for n=1:length(coeffs_table)
        coeffn=coeffs_table(n);
        [prodout,prodbody,prodsignals,prodtempsignals,prodtypedefs]=hdlcoeffmultiply(reginput,...
        optimcoeffs(n),coeffn,...
        ['product',num2str(n)],...
        productvtype,productsltype,...
        productrounding,productsaturation,this.accumSLtype);
        if prodout~=0
            prodlist(n)=prodout;
        end

        hdl_arch.signals=[hdl_arch.signals,prodsignals,prodtempsignals];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,prodbody];
        if strcmpi(hdlgetparameter('target_language'),'vhdl')
            total_typedefs=[total_typedefs,prodtypedefs];
        end
    end

    total_typedefs=unique(total_typedefs,'legacy');
    hdl_arch.typedefs=[hdl_arch.typedefs,total_typedefs{:}];



    if hdlgetparameter('filter_pipelined')
        hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+1);

        if emitMode
            for n=1:length(prodlist)
                if prodlist(n)~=0
                    [~,temppipe]=hdlnewsignal(['product_pipeline',num2str(n)],...
                    'filter',-1,cplxty,0,...
                    hdlsignalvtype(prodlist(n)),...
                    hdlsignalsltype(prodlist(n)),...
                    signalRate);
                    hdlregsignal(temppipe);
                    pipeout(n)=temppipe;
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(temppipe)];
                end
            end


            [tempbody,tempsignals]=hdlunitdelay(prodlist(prodlist~=0),pipeout(pipeout~=0),...
            ['product_pipeline',hdlgetparameter('clock_process_label'),num2str(n)],...
            zeros(1,length(prodlist(prodlist~=0))));

            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];

            prodlist=pipeout;
        else
            for n=1:length(prodlist)
                if prodlist(n)~=0
                    hBufferC=prodlist(n).getDrivers.insertBufferOnSrc;
                    hBufferC.setOutputPipeline(1);
                end
            end
        end
    end

    tmp=prodlist(fidx);
    tmpc=optimcoeffs(fidx);
    prodlist=tmp(polymap);
    tmpc=tmpc(polymap);
    minuslist=find(tmpc~=coeffs);
    for n=minuslist
        if prodlist(n)~=0
            [~,minusprod]=hdlnewsignal(['negproduct',num2str(n)],...
            'filter',-1,cplxty,0,productvtype,productsltype,signalRate);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(minusprod)];
            [tempbody,tempsignals]=hdlfilterunaryminus(prodlist(n),minusprod,...
            productrounding,productsaturation);
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            prodlist(n)=minusprod;
        end
    end

    function abscoeffs=myabs(coeffs)

        if isreal(coeffs)
            abscoeffs=abs(coeffs);
        else
            abscoeffs=coeffs;
        end

