function[hdl_arch,final_result]=emit_finalsum(this,prodlist,sumlist,delaylist)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    rmode=this.Roundmode;
    [sumrounding]=(rmode);
    cplxity=this.isInputPortComplex||~isreal(this.polyphasecoefficient);
    omode=this.Overflowmode;
    [sumsaturation]=(omode);

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumsize=sumall.size;
    sumsigned=sumall.signed;
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    polycoeffs=this.polyphasecoefficients;
    delaylen=size(polycoeffs,2)-1;

    [~,final_result]=hdlnewsignal('finalsum','filter',-1,cplxity,0,sumvtype,sumsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(final_result)];

    if length(prodlist)>1

        if prodlist(1)~=0
            [tempbody,tempsignals]=hdlfilteradd(prodlist(1),delaylist(1),final_result,sumrounding,sumsaturation);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
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
    else
        [tempbody]=hdldatatypeassignment(sumlist(end),final_result,sumrounding,sumsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    end


    if prodlist(end)~=0
        tempbody=hdldatatypeassignment(prodlist(end),sumlist(end),sumrounding,sumsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        if hdlsignaliscomplex(sumlist(end))&&~hdlsignaliscomplex(prodlist(end))


            [~,constzero]=hdlnewsignal('constzero','filter',-1,0,0,sumvtype,sumsltype);
            hdl_arch.constants=[hdl_arch.constants,...
            makehdlconstantdecl(constzero,hdlconstantvalue(0,sumsize,0,sumsigned))];
            zerobody=hdldatatypeassignment(constzero,hdlsignalimag(sumlist(end)),'floor',0);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,zerobody];
        end
    else
        [~,constzero]=hdlnewsignal('constzero','filter',-1,cplxity,0,sumvtype,sumsltype);
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




