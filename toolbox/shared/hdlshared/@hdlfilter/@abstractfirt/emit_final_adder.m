function[hdl_arch,final_result]=emit_final_adder(this,prodlist,delaylist,sumlist)






    emitMode=isempty(pirNetworkForFilterComp);

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';


    coeffs=this.Coefficients;
    firlen=length(coeffs);

    if emitMode
        signalRate=0;
    else
        signalRate=prodlist(1).SimulinkRate;
    end


    num_channel=hdlgetparameter('filter_generate_multichannel');
    delaylen=(firlen-1)*num_channel;
    prodlist_new(1:num_channel:delaylen+1)=prodlist;
    prodlist=prodlist_new;

    omode=this.Overflowmode;
    [outputsaturation,productsaturation,sumsaturation]=deal(omode);

    rmode=this.Roundmode;
    [outputrounding,productrounding,sumrounding]=deal(rmode);

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumsize=sumall.size;

    sumsigned=sumall.signed;
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    cplxity=this.isOutputPortComplex;

    if emitMode
        vectorSize=1;
    else
        vectorSize=pirelab.getVectorTypeInfo(prodlist(1),1);
    end

    [uname,final_result]=hdlnewsignal('finalsum','filter',-1,cplxity,vectorSize,sumvtype,sumsltype,signalRate);

    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(final_result)];


    if prodlist(1)~=0&&delaylen~=0
        [tempbody,tempsignals]=hdlfilteradd(prodlist(1),delaylist(1),final_result,sumrounding,sumsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
    elseif prodlist(1)~=0&&delaylen==0
        [tempbody]=hdldatatypeassignment(prodlist(1),final_result,sumrounding,sumsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    else
        [tempbody]=hdldatatypeassignment(delaylist(1),final_result,sumrounding,sumsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    end

    for n=1:delaylen-1
        prod_elem=prodlist(n+1);
        delay_elem=delaylist(n+1);
        sumout=sumlist(n);
        if prod_elem~=0
            [tempbody,tempsignals]=hdlfilteradd(prod_elem,delay_elem,sumout,sumrounding,sumsaturation);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
        else
            [tempbody]=hdldatatypeassignment(delay_elem,sumout,sumrounding,sumsaturation);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        end
    end


    if delaylen~=0
        if prodlist(end)~=0
            tempbody=hdldatatypeassignment(prodlist(end),sumlist(end),sumrounding,sumsaturation);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];

            if~isempty(hdlsignalcomplex(sumlist(end)))&&isempty(hdlsignalcomplex(prodlist(end)))


                [uname,constzro]=hdlnewsignal('constzero','filter',-1,0,0,sumvtype,sumsltype,signalRate);
                hdl_arch.constants=[hdl_arch.constants,...
                makehdlconstantdecl(constzro,hdlconstantvalue(0,sumsize,0,sumsigned))];
                tempbody=hdldatatypeassignment(constzro,hdlsignalimag(sumlist(end)),'floor',0);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            end
        else
            [uname,constzero]=hdlnewsignal('constzero','filter',-1,cplxity,0,sumvtype,sumsltype,signalRate);
            if cplxity
                hdl_arch.constants=[hdl_arch.constants,...
                makehdlconstantdecl(constzero,hdlconstantvalue(0,sumsize,0,sumsigned)),...
                makehdlconstantdecl(hdlsignalimag(constzero),hdlconstantvalue(0,sumsize,0,sumsigned))];
            else
                hdl_arch.constants=[hdl_arch.constants,...
                makehdlconstantdecl(constzero,hdlconstantvalue(0,sumsize,0,sumsigned))];
            end

            tempbody=hdldatatypeassignment(constzero,sumlist(end),'floor',0);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        end
    end









