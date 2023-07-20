function[hdl_arch,final_result]=emit_finalsum(this,hdl_arch,prodlist,delaylist,sumlist)






    coeffs=this.Coefficients;
    firlen=length(coeffs);
    delaylen=firlen-1;
    omode=this.Overflowmode;
    [outputsaturation,productsaturation,sumsaturation]=deal(omode);

    rmode=this.Roundmode;
    [outputrounding,productrounding,sumrounding]=deal(rmode);

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumsize=sumall.size;

    sumsigned=sumall.signed;
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    [uname,final_result]=hdlnewsignal('finalsum','filter',-1,0,0,sumvtype,sumsltype);
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
    else
        [uname,constzero]=hdlnewsignal('constzero','filter',-1,0,0,sumvtype,sumsltype);
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(constzero,hdlconstantvalue(0,sumsize,0,sumsigned))];
        tempbody=hdldatatypeassignment(constzero,sumlist(end),'floor',0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    end



